#!/usr/bin/env python3

r"""
build_flashcards.py
====================

Compiles the client's LaTeX flashcard deck into the .webp pairs + manifest
consumed by the Flutter app.

Single-compile design: the whole deck is assembled into ONE document and
compiled ONCE, then the script walks the source cards and the resulting
PDF's pages in lockstep (page 2i+1 = card i's front, page 2i+2 = card i's
back) to extract each card's images. This means what you'd see previewing
the assembled document directly in an editor IS, byte-for-byte, the same
compile that produces the app's images - not an isolated per-card compile
that merely resembles it.

Pipeline:

    tagged .tex source
        -> parse into (category, frage-tex, antwort-tex) records, in order
        -> assemble ALL of them into one document using
           praeambel_app_standalone.tex - a from-scratch, minimal preamble
           that does NOT depend on the client's real
           praeambel_karteikarten.tex, and fixes every page to the app's
           card shape directly
        -> compile ONCE with latexmk, into --preamble-dir/.rendered/
        -> sanity check: PDF page count must be exactly 2x the card count,
           or this aborts rather than silently mis-pairing pages to cards
           (see "IMPORTANT" note below)
        -> for each card, extract its two pages (pdftoppm -f/-l), skipping
           extraction+encode for cards whose combined content hash matches
           a previous run (tracked in .build_cache.json)
        -> emit assets/flashcards_manifest.json

IMPORTANT - the one real risk of this design: it assumes every \begin{frage}
...\end{frage} and \begin{antwort}...\end{antwort} produces EXACTLY one
physical page. If any single card overflows to a second page, every card
after it silently shifts by one page - fronts pair with the wrong backs,
with no error. The page-count sanity check catches the aggregate case (you
end up short/over on total pages) and aborts loudly, but can't by itself
tell you WHICH card overflowed. If it fires, check the deck PDF directly
around where the count goes wrong (or bisect with a smaller source file)
before re-running.

Also written to --preamble-dir/.rendered/, for reference: a
<card_id>_front.tex / <card_id>_back.tex per card, each just that one
environment + the preamble. These are NOT separately compiled - they're
human-readable copies so you can find a given card's source without
scrolling the whole deck. The actual images always come from the single
combined compile.

praeambel_karteikarten.tex (the real print preamble) is never touched or
needed here, so the original a6-landscape print deck still compiles from
Karteikarten_Akademus.tex unmodified, using its own preamble as before.

Card ids are a hash of (category, frage, antwort) TOGETHER, so editing
either side of a card still correctly resets its proficiency in the app -
this script has no notion of a smaller, independently-cacheable "side".

Requirements (all external, not pip-installable):
    - a LaTeX toolchain with `latexmk` on PATH and the packages
      praeambel_app_standalone.tex uses (amsmath, amssymb, extarrows,
      array, tabularx, diagbox, graphicx, tikz, geometry - all common,
      bundled with most distributions)
    - poppler-utils (`pdfinfo`, `pdftoppm`) for page counting and
      PDF -> PNG rasterization
    - libwebp (`cwebp`) for PNG -> WEBP conversion

Usage (no flags needed - paths default to the layout below, derived from
this script's own location so it works from any cwd):

    python3 tools/build_flashcards.py

Expects this layout, relative to the project root (this file's grandparent
directory):

    <project root>/
      flashcards_source/
        Karteikarten_Akademus.tex   <- --source default
        praeambel_app_standalone.tex
        schema_*.pdf/png
      assets/                        <- --out-assets default
      tools/
        build_flashcards.py          <- this file

--source/--preamble-dir/--out-assets can still be passed explicitly to
override any of these, e.g. for a differently-laid-out project or a test
fixture living elsewhere.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import shutil
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path

# Must match lib/constants/categories.dart in the Flutter app exactly.
VALID_CATEGORIES = {"Analysis", "Geometrie", "Stochastik"}

# A card can be excluded from the deck (e.g. the cover/title card) by
# tagging it "% category: skip".
SKIP_CATEGORY = "skip"

# The name praeambel_app_standalone.tex expects to be \input as. Must sit
# in --preamble-dir; praeambel_karteikarten.tex itself is not needed here.
APP_PREAMBLE_NAME = "praeambel_app_standalone"

# Persistent build output, nested inside --preamble-dir so \input and
# \includegraphics in the assembled document resolve against the real
# preamble/schema images with zero copying.
RENDERED_DIRNAME = ".rendered"
DECK_STEM = "deck"  # -> .rendered/deck.tex, .rendered/deck.pdf

# Everything below is relative to this file's own location, not the
# current working directory - so `python3 tools/build_flashcards.py`
# works whether you're sitting in the project root, in tools/, or
# anywhere else. All three can still be overridden via flags.
SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = SCRIPT_DIR.parent
DEFAULT_SOURCE = PROJECT_ROOT / "flashcards_source" / "Karteikarten_Akademus.tex"
DEFAULT_PREAMBLE_DIR = PROJECT_ROOT / "flashcards_source"
DEFAULT_OUT_ASSETS = PROJECT_ROOT / "assets"

CARD_RE = re.compile(
    r"\\begin\{frage\}(?P<frage>.*?)\\end\{frage\}"
    r"\s*"
    r"\\begin\{antwort\}(?P<antwort>.*?)\\end\{antwort\}",
    re.DOTALL,
)
CATEGORY_COMMENT_RE = re.compile(r"^\s*%\s*category:\s*(\S+)\s*$")

DOC_HEADER_RE = re.compile(r"(?P<preamble>.*?\\begin\{document\})", re.DOTALL)

# Matches \documentclass[opt1,opt2,...]{cls} so the 'landscape' class
# option can be stripped for app-render compiles - it fights with the
# portrait ratio set via \geometry{...} in the app preamble.
DOCUMENTCLASS_RE = re.compile(r"\\documentclass\[(?P<opts>[^\]]*)\]\{(?P<cls>[^}]*)\}")


def _run(cmd: list[str], **kwargs) -> subprocess.CompletedProcess:
    """subprocess.run wrapper that prints the failing command's stderr
    before re-raising - CalledProcessError carries .stdout/.stderr, but
    silently, so an uncaught one only shows a generic traceback with no
    indication of what pdftoppm/cwebp/pdfinfo actually complained about."""
    try:
        return subprocess.run(cmd, check=True, capture_output=True, text=True, **kwargs)
    except subprocess.CalledProcessError as e:
        print(f"error: command failed: {' '.join(cmd)}", file=sys.stderr)
        if e.stdout:
            print("--- stdout ---", file=sys.stderr)
            print(e.stdout, file=sys.stderr)
        if e.stderr:
            print("--- stderr ---", file=sys.stderr)
            print(e.stderr, file=sys.stderr)
        raise


def _hash(*parts: str) -> str:
    h = hashlib.sha256()
    for p in parts:
        h.update(p.encode("utf-8"))
    return h.hexdigest()[:16]


@dataclass
class CardSource:
    index: int  # position in the source file, for stable ordering
    category: str
    frage_tex: str
    antwort_tex: str

    @property
    def card_id(self) -> str:
        # Hash-based, not sequential: reordering cards in the source
        # doesn't change ids, and editing a card's content (either side)
        # naturally produces a new id (== a "new" card for proficiency
        # tracking, which is the right behavior since content changed).
        return f"{self.category.lower()}_{_hash(self.category, self.frage_tex, self.antwort_tex)}"


def parse_source(tex_path: Path) -> tuple[str, list[CardSource]]:
    """Returns (preamble_text, cards). preamble_text is everything up to
    and including \\begin{document}, reused (with app_preamble() applied)
    once for the whole assembled deck."""
    text = tex_path.read_text(encoding="utf-8")

    header_match = DOC_HEADER_RE.match(text)
    if not header_match:
        raise ValueError("Couldn't find \\begin{document} in source file")
    preamble = header_match.group("preamble")

    # Walk the file top to bottom, tracking the most recent
    # "% category: X" comment as sticky state, and pairing that state
    # with each frage/antwort block encountered after it.
    lines = text.splitlines(keepends=True)
    current_category: str | None = None
    line_categories: list[str | None] = []
    for line in lines:
        m = CATEGORY_COMMENT_RE.match(line)
        if m:
            current_category = m.group(1)
        line_categories.append(current_category)

    cards: list[CardSource] = []
    for i, match in enumerate(CARD_RE.finditer(text)):
        start_line = text.count("\n", 0, match.start())
        category = (
            line_categories[start_line] if start_line < len(line_categories) else None
        )

        if category is None:
            raise ValueError(
                f"Card #{i} (starting near line {start_line + 1}) has no "
                f"'% category: X' marker above it in the source."
            )
        if category == SKIP_CATEGORY:
            continue
        if category not in VALID_CATEGORIES:
            raise ValueError(
                f"Card #{i} (line {start_line + 1}) is tagged "
                f"'{category}', which isn't one of {sorted(VALID_CATEGORIES)}. "
                f"Check lib/constants/categories.dart stays in sync."
            )

        cards.append(
            CardSource(
                index=i,
                category=category,
                frage_tex=match.group("frage").strip(),
                antwort_tex=match.group("antwort").strip(),
            )
        )

    return preamble, cards


def app_preamble(preamble: str) -> str:
    """Adapts the captured print-deck preamble for an app-render compile:
    drops the 'landscape' (and 'paper=...') class options, which would
    fight with the portrait ratio praeambel_app_standalone.tex sets via
    \\geometry{...}, and points \\input at that standalone preamble
    instead of the print one."""

    def strip_print_options(m: re.Match) -> str:
        opts = [o.strip() for o in m.group("opts").split(",")]
        keep = [
            o
            for o in opts
            if o and not o.startswith("landscape") and not o.startswith("paper=")
        ]
        return f"\\documentclass[{','.join(keep)}]{{{m.group('cls')}}}"

    out = DOCUMENTCLASS_RE.sub(strip_print_options, preamble, count=1)
    out = out.replace("praeambel_karteikarten", APP_PREAMBLE_NAME)
    return out


def write_reference_snippets(
    card: CardSource, rendered_dir: Path, preamble_block: str
) -> None:
    """Writes human-readable, NOT-separately-compiled copies of this
    card's front/back source, for browsing a single card without
    scrolling the whole deck.tex. The actual images always come from
    deck.pdf, extracted by page number."""
    front_tex = (
        f"{preamble_block}\n"
        f"\\begin{{frage}}{card.frage_tex}\\end{{frage}}\n"
        f"\\end{{document}}\n"
    )
    back_tex = (
        f"{preamble_block}\n"
        f"\\begin{{antwort}}{card.antwort_tex}\\end{{antwort}}\n"
        f"\\end{{document}}\n"
    )
    (rendered_dir / f"{card.card_id}_front.tex").write_text(front_tex, encoding="utf-8")
    (rendered_dir / f"{card.card_id}_back.tex").write_text(back_tex, encoding="utf-8")


def compile_deck(preamble: str, cards: list[CardSource], preamble_dir: Path) -> Path:
    """Assembles every card into one document and compiles it once.
    Returns the resulting PDF's path."""
    rendered_dir = preamble_dir / RENDERED_DIRNAME
    rendered_dir.mkdir(exist_ok=True)

    parts = [app_preamble(preamble)]
    for card in cards:
        parts.append(f"\\begin{{frage}}{card.frage_tex}\\end{{frage}}")
        parts.append(f"\\begin{{antwort}}{card.antwort_tex}\\end{{antwort}}")
    parts.append("\\end{document}\n")
    deck_tex = "\n".join(parts)

    tex_path = rendered_dir / f"{DECK_STEM}.tex"
    tex_path.write_text(deck_tex, encoding="utf-8")

    print(f"Compiling {len(cards)} cards as one document ...")
    result = subprocess.run(
        [
            "latexmk",
            "-pdf",
            "-interaction=nonstopmode",
            "-halt-on-error",
            f"-outdir={RENDERED_DIRNAME}",
            str(tex_path.relative_to(preamble_dir)),
        ],
        cwd=preamble_dir,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        tail = "\n".join(result.stdout.splitlines()[-60:])
        raise RuntimeError(f"LaTeX failed compiling the deck:\n{tail}")

    pdf_path = tex_path.with_suffix(".pdf")
    if not pdf_path.exists():
        raise RuntimeError("No PDF produced for the deck")
    return pdf_path


def pdf_page_count(pdf_path: Path) -> int:
    result = _run(["pdfinfo", str(pdf_path)])
    for line in result.stdout.splitlines():
        if line.startswith("Pages:"):
            return int(line.split(":", 1)[1].strip())
    raise RuntimeError(f"Couldn't parse page count from pdfinfo output for {pdf_path}")


def extract_page_to_webp(pdf_path: Path, page: int, out_path: Path, dpi: int) -> None:
    """Rasterizes one page straight to webp - no cropping. The page is
    already the exact target aspect ratio (praeambel_app_standalone.tex
    fixes it), so cropping would only throw that away."""
    out_path.parent.mkdir(parents=True, exist_ok=True)  # pdftoppm writes here too

    tmp_prefix = out_path.with_suffix("")
    _run(
        [
            "pdftoppm",
            "-png",
            "-r",
            str(dpi),
            "-f",
            str(page),
            "-l",
            str(page),
            "-singlefile",
            str(pdf_path),
            str(tmp_prefix),
        ]
    )
    png_path = tmp_prefix.with_suffix(".png")
    if not png_path.exists():
        raise RuntimeError(f"pdftoppm produced no output for page {page} of {pdf_path}")

    _run(["cwebp", "-lossless", "-z", "9", str(png_path), "-o", str(out_path)])
    png_path.unlink(missing_ok=True)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--source",
        type=Path,
        default=DEFAULT_SOURCE,
        help=f"Path to the tagged Karteikarten_Akademus.tex "
        f"(default: {DEFAULT_SOURCE})",
    )
    parser.add_argument(
        "--preamble-dir",
        type=Path,
        default=DEFAULT_PREAMBLE_DIR,
        help="Directory containing praeambel_app_standalone.tex "
        "and any images cards \\includegraphics directly "
        "(schema_gerade_gerade, schema_ebene_gerade, "
        "schema_ebene_ebene). Build output is written here "
        f"too, under .rendered/ (default: {DEFAULT_PREAMBLE_DIR})",
    )
    parser.add_argument(
        "--out-assets",
        type=Path,
        default=DEFAULT_OUT_ASSETS,
        help=f"Path to the Flutter project's assets/ directory "
        f"(default: {DEFAULT_OUT_ASSETS})",
    )
    parser.add_argument("--dpi", type=int, default=400)
    parser.add_argument(
        "--force",
        action="store_true",
        help="Re-extract every card's images, ignoring the cache "
        "(the deck always recompiles regardless - there's "
        "only one document, so there's nothing smaller to "
        "skip at the LaTeX step)",
    )
    args = parser.parse_args()

    for tool in ("latexmk", "pdfinfo", "pdftoppm", "cwebp"):
        if shutil.which(tool) is None:
            print(f"error: required tool '{tool}' not found on PATH", file=sys.stderr)
            return 1

    app_preamble_path = args.preamble_dir / f"{APP_PREAMBLE_NAME}.tex"
    if not app_preamble_path.exists():
        print(
            f"error: {app_preamble_path} not found - copy it into " f"--preamble-dir",
            file=sys.stderr,
        )
        return 1

    preamble, cards = parse_source(args.source)
    print(f"Parsed {len(cards)} cards.")
    if not cards:
        print("error: no cards to render", file=sys.stderr)
        return 1

    deck_pdf = compile_deck(preamble, cards, args.preamble_dir)

    expected_pages = 2 * len(cards)
    actual_pages = pdf_page_count(deck_pdf)
    if actual_pages != expected_pages:
        print(
            f"error: expected {expected_pages} pages (2 per card x {len(cards)} "
            f"cards) but the compiled deck has {actual_pages}. At least one "
            f"card almost certainly overflowed to a second page, which would "
            f"silently mis-pair every following card's front/back - aborting "
            f"instead. Check {deck_pdf} directly (or bisect with a smaller "
            f"source file) to find the overflowing card before re-running.",
            file=sys.stderr,
        )
        return 1
    print(f"Page count check OK: {actual_pages} pages for {len(cards)} cards.")

    rendered_dir = args.preamble_dir / RENDERED_DIRNAME
    preamble_block = app_preamble(preamble)

    cache_path = args.out_assets / ".build_cache.json"
    cache = (
        {}
        if args.force or not cache_path.exists()
        else json.loads(cache_path.read_text(encoding="utf-8"))
    )

    def save_cache() -> None:
        cache_path.parent.mkdir(parents=True, exist_ok=True)
        cache_path.write_text(
            json.dumps(cache, indent=2, ensure_ascii=False), encoding="utf-8"
        )

    manifest: list[dict] = []
    extracted_count = 0

    for i, card in enumerate(cards):
        front_page = 2 * i + 1
        back_page = 2 * i + 2

        front_path = (
            args.out_assets
            / "flashcards"
            / card.category.lower()
            / f"{card.card_id}_front.webp"
        )
        back_path = (
            args.out_assets
            / "flashcards"
            / card.category.lower()
            / f"{card.card_id}_back.webp"
        )

        manifest.append(
            {
                "id": card.card_id,
                "category": card.category,
                "front": f"assets/flashcards/{card.category.lower()}/{card.card_id}_front.webp",
                "back": f"assets/flashcards/{card.category.lower()}/{card.card_id}_back.webp",
            }
        )

        content_hash = _hash(card.category, card.frage_tex, card.antwort_tex)
        up_to_date = (
            cache.get(card.card_id) == content_hash
            and front_path.exists()
            and back_path.exists()
        )
        write_reference_snippets(card, rendered_dir, preamble_block)
        if up_to_date:
            continue

        print(
            f"  extracting {card.card_id} ({card.category}) pages {front_page}-{back_page} ..."
        )
        extract_page_to_webp(deck_pdf, front_page, front_path, args.dpi)
        extract_page_to_webp(deck_pdf, back_page, back_path, args.dpi)

        cache[card.card_id] = content_hash
        save_cache()
        extracted_count += 1

    live_ids = {c.card_id for c in cards}
    cache = {k: v for k, v in cache.items() if k in live_ids}
    save_cache()

    manifest_path = args.out_assets / "flashcards_manifest.json"
    manifest_path.write_text(
        json.dumps(manifest, indent=2, ensure_ascii=False), encoding="utf-8"
    )

    print(
        f"Extracted {extracted_count} card(s), {len(cards) - extracted_count} unchanged."
    )
    print(f"Manifest written to {manifest_path} ({len(manifest)} cards).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
