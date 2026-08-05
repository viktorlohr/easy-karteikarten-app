#!/usr/bin/env python3
"""
build_flashcards.py
====================

Compiles the client's LaTeX flashcard deck into the .webp pairs + manifest
consumed by the Flutter app.

Same philosophy as latex_pipeline_test/tools/build_test_pipeline.py,
validated there first: every card compiles to a fixed-ratio page (matches
the app's AspectRatio exactly, so nothing gets cropped or letterboxed),
and overflow on long cards is left for you to resolve by hand — no
auto-fit/font-scaling magic.

Pipeline, per card:

    tagged .tex source
        -> parse into (category, frage-tex, antwort-tex) records
        -> render a standalone 2-page PDF (page 1 = front, page 2 = back),
           reusing praeambel_app_standalone.tex - a from-scratch, minimal
           preamble that does NOT depend on the client's real
           praeambel_karteikarten.tex (no shared macros, no background,
           no print machinery) and fixes the page to the app's card
           shape directly. The real preamble is never touched or needed
           for app renders, so the original a6-landscape print deck
           still compiles from Karteikarten_Akademus.tex unmodified,
           using its own (untouched) preamble as before.
        -> rasterize each page 1:1 - NO cropping, the page IS the target
           shape already
        -> emit assets/flashcards_manifest.json

Re-runs are incremental: a card is only recompiled if its own LaTeX
content changed, tracked via a content hash cached in .build_cache.json
(saved after every card, so a crash partway through a run doesn't throw
away work already done). Adding one new card to a 130-card deck
re-renders one card, not 130.

Requirements (all external, not pip-installable):
    - a LaTeX toolchain with `latexmk` on PATH and the packages
      praeambel_app_standalone.tex uses (amsmath, amssymb, extarrows,
      array, tabularx, diagbox, graphicx, tikz, geometry - all common,
      bundled with most distributions)
    - poppler-utils (`pdftoppm`) for PDF -> PNG rasterization
    - libwebp (`cwebp`) for PNG -> WEBP conversion

Usage:
    python3 tools/build_flashcards.py \\
        --source flashcards_source/Karteikarten_Akademus.tex \\
        --preamble-dir flashcards_source \\
        --out-assets assets
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import shutil
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path

# Must match lib/constants/categories.dart in the Flutter app exactly.
VALID_CATEGORIES = {"Analysis", "Geometrie", "Stochastik"}

# A card can be excluded from the deck (e.g. the cover/title card) by
# tagging it "% category: skip".
SKIP_CATEGORY = "skip"

# The name praeambel_app_standalone.tex expects to be \input as - swapped
# in per-card. This preamble is self-contained (doesn't \input the real
# praeambel_karteikarten.tex at all), so it just needs to sit in
# --preamble-dir; praeambel_karteikarten.tex itself is no longer required
# for app renders.
APP_PREAMBLE_NAME = "praeambel_app_standalone"

CARD_RE = re.compile(
    r"\\begin\{frage\}(?P<frage>.*?)\\end\{frage\}"
    r"\s*"
    r"\\begin\{antwort\}(?P<antwort>.*?)\\end\{antwort\}",
    re.DOTALL,
)
CATEGORY_COMMENT_RE = re.compile(r"^\s*%\s*category:\s*(\S+)\s*$")

DOC_HEADER_RE = re.compile(
    r"(?P<preamble>.*?\\begin\{document\})", re.DOTALL
)

# Matches \documentclass[opt1,opt2,...]{cls} so the 'landscape' class
# option can be stripped for app-render compiles - it fights with the
# portrait ratio set via \geometry{...} in the app preamble.
DOCUMENTCLASS_RE = re.compile(r"\\documentclass\[(?P<opts>[^\]]*)\]\{(?P<cls>[^}]*)\}")


@dataclass
class CardSource:
    index: int          # position in the source file, for stable ordering
    category: str
    frage_tex: str
    antwort_tex: str

    @property
    def content_hash(self) -> str:
        h = hashlib.sha256()
        h.update(self.category.encode("utf-8"))
        h.update(self.frage_tex.encode("utf-8"))
        h.update(self.antwort_tex.encode("utf-8"))
        return h.hexdigest()[:16]

    @property
    def card_id(self) -> str:
        # Hash-based, not sequential: reordering cards in the source
        # doesn't change ids, and editing a card's content naturally
        # produces a new id (== a "new" card for proficiency tracking,
        # which is the right behavior since the content changed).
        slug = self.category.lower()
        return f"{slug}_{self.content_hash}"


def parse_source(tex_path: Path) -> tuple[str, list[CardSource]]:
    """Returns (preamble_text, cards). preamble_text is everything up to
    and including \\begin{document}, reused (with app_preamble() applied)
    for every card so custom macros/environments from
    praeambel_karteikarten keep working."""
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
        category = line_categories[start_line] if start_line < len(line_categories) else None

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
    """Adapts the captured print-deck preamble for a standalone app-render
    compile: drops the 'landscape' (and 'paper=...') class options, which
    would fight with the portrait ratio praeambel_app_standalone.tex sets
    via \\geometry{...}, and points \\input at that standalone preamble
    instead of the print one. Only the class-option line survives from
    the original preamble; everything else (packages, custom commands,
    frage/antwort) comes from praeambel_app_standalone.tex instead."""

    def strip_print_options(m: re.Match) -> str:
        opts = [o.strip() for o in m.group("opts").split(",")]
        keep = [o for o in opts if o and not o.startswith("landscape") and not o.startswith("paper=")]
        return f"\\documentclass[{','.join(keep)}]{{{m.group('cls')}}}"

    out = DOCUMENTCLASS_RE.sub(strip_print_options, preamble, count=1)
    out = out.replace("praeambel_karteikarten", APP_PREAMBLE_NAME)
    return out


def render_card(
    card: CardSource,
    preamble: str,
    work_dir: Path,
    source_dir: Path,
) -> Path:
    """Compiles one card to a 2-page PDF (page 1 = front, page 2 = back)
    and returns its path. Runs latexmk in a scratch dir that also has the
    client's preamble/image assets copied alongside it, since \\input and
    \\includegraphics resolve relative to the working directory."""

    card_tex = (
        f"{app_preamble(preamble)}\n"
        f"\\begin{{frage}}{card.frage_tex}\\end{{frage}}\n"
        f"\\begin{{antwort}}{card.antwort_tex}\\end{{antwort}}\n"
        f"\\end{{document}}\n"
    )

    card_dir = work_dir / card.card_id
    card_dir.mkdir(parents=True, exist_ok=True)

    # Bring along everything the standalone preamble/includegraphics calls
    # might need: praeambel_app_standalone.tex itself, and the schema_*
    # images three cards \includegraphics directly. praeambel_karteikarten.tex
    # and its 1.png/2.png background are NOT needed for app renders.
    for item in source_dir.iterdir():
        if item.is_file() and item.suffix in {".tex", ".sty", ".cls", ".pdf", ".png", ".jpg"}:
            shutil.copy(item, card_dir / item.name)

    tex_path = card_dir / "card.tex"
    tex_path.write_text(card_tex, encoding="utf-8")

    result = subprocess.run(
        ["latexmk", "-pdf", "-interaction=nonstopmode", "-halt-on-error", "card.tex"],
        cwd=card_dir,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        log_tail = "\n".join(result.stdout.splitlines()[-40:])
        raise RuntimeError(
            f"LaTeX failed for card {card.card_id} "
            f"(source line ~{card.index}):\n{log_tail}"
        )

    pdf_path = card_dir / "card.pdf"
    if not pdf_path.exists():
        raise RuntimeError(f"No PDF produced for card {card.card_id}")
    return pdf_path


def pdf_page_to_webp(pdf_path: Path, page: int, out_path: Path, dpi: int = 400) -> None:
    """Rasterizes one page straight to webp - no cropping. The page is
    already the exact target aspect ratio (praeambel_app_standalone.tex
    fixes it), so cropping would only throw that away."""
    with tempfile.TemporaryDirectory() as tmp:
        prefix = Path(tmp) / "page"
        subprocess.run(
            [
                "pdftoppm", "-png", "-r", str(dpi),
                "-f", str(page), "-l", str(page),
                str(pdf_path), str(prefix),
            ],
            check=True,
            capture_output=True,
        )
        rendered = sorted(Path(tmp).glob("page*.png"))
        if not rendered:
            raise RuntimeError(f"pdftoppm produced no output for {pdf_path} page {page}")

        out_path.parent.mkdir(parents=True, exist_ok=True)
        subprocess.run(
            ["cwebp", "-lossless", "-z", "9", str(rendered[0]), "-o", str(out_path)],
            check=True,
            capture_output=True,
        )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", required=True, type=Path,
                         help="Path to the tagged Karteikarten_Akademus.tex")
    parser.add_argument("--preamble-dir", required=True, type=Path,
                         help="Directory containing praeambel_app_standalone.tex "
                              "and any images cards \\includegraphics directly "
                              "(schema_gerade_gerade, schema_ebene_gerade, "
                              "schema_ebene_ebene - NOT praeambel_karteikarten.tex "
                              "or its 1.png/2.png background, neither needed here)")
    parser.add_argument("--out-assets", required=True, type=Path,
                         help="Path to the Flutter project's assets/ directory")
    parser.add_argument("--dpi", type=int, default=400)
    parser.add_argument("--force", action="store_true",
                         help="Recompile every card, ignoring the cache")
    args = parser.parse_args()

    for tool in ("latexmk", "pdftoppm", "cwebp"):
        if shutil.which(tool) is None:
            print(f"error: required tool '{tool}' not found on PATH", file=sys.stderr)
            return 1

    app_preamble_path = args.preamble_dir / f"{APP_PREAMBLE_NAME}.tex"
    if not app_preamble_path.exists():
        print(f"error: {app_preamble_path} not found - copy it into "
              f"--preamble-dir", file=sys.stderr)
        return 1

    preamble, cards = parse_source(args.source)
    print(f"Parsed {len(cards)} cards.")

    flashcards_dir = args.out_assets / "flashcards"
    cache_path = args.out_assets / ".build_cache.json"
    cache = (
        {} if args.force or not cache_path.exists()
        else json.loads(cache_path.read_text(encoding="utf-8"))
    )

    def save_cache() -> None:
        cache_path.parent.mkdir(parents=True, exist_ok=True)
        cache_path.write_text(json.dumps(cache, indent=2, ensure_ascii=False), encoding="utf-8")

    work_root = Path(tempfile.mkdtemp(prefix="flashcard_build_"))
    manifest: list[dict] = []
    rendered_count = 0

    try:
        for card in cards:
            front_path = flashcards_dir / card.category.lower() / f"{card.card_id}_front.webp"
            back_path = flashcards_dir / card.category.lower() / f"{card.card_id}_back.webp"

            manifest.append({
                "id": card.card_id,
                "category": card.category,
                "front": f"assets/flashcards/{card.category.lower()}/{card.card_id}_front.webp",
                "back": f"assets/flashcards/{card.category.lower()}/{card.card_id}_back.webp",
            })

            up_to_date = (
                cache.get(card.card_id) == card.content_hash
                and front_path.exists()
                and back_path.exists()
            )
            if up_to_date:
                continue

            print(f"  rendering {card.card_id} ({card.category}) ...")
            pdf_path = render_card(card, preamble, work_root, args.preamble_dir)
            pdf_page_to_webp(pdf_path, page=1, out_path=front_path, dpi=args.dpi)
            pdf_page_to_webp(pdf_path, page=2, out_path=back_path, dpi=args.dpi)

            # Saved immediately, not just at the end - a crash on a later
            # card doesn't throw away cards that already rendered fine.
            cache[card.card_id] = card.content_hash
            save_cache()
            rendered_count += 1
    finally:
        shutil.rmtree(work_root, ignore_errors=True)

    # Cards that used to exist but were removed/retagged from the source
    # leave orphaned cache entries; drop anything not in this run.
    live_ids = {c.card_id for c in cards if c.category != SKIP_CATEGORY}
    cache = {k: v for k, v in cache.items() if k in live_ids}
    save_cache()

    manifest_path = args.out_assets / "flashcards_manifest.json"
    manifest_path.write_text(
        json.dumps(manifest, indent=2, ensure_ascii=False), encoding="utf-8"
    )

    print(f"Rendered {rendered_count} card(s), {len(cards) - rendered_count} unchanged.")
    print(f"Manifest written to {manifest_path} ({len(manifest)} cards).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
