# LaTeX deck → .webp flashcard pipeline

# LaTeX deck → .webp flashcard pipeline

## The idea

Your `.tex` file stays the single source of truth — that's where the client
already edits and adds cards. Card *tagging* works exactly as before (see
"Category tagging" below, unchanged from the first version of this
pipeline). What's new here is how each card gets rendered, and it's the
same approach validated end-to-end in `latex_pipeline_test/` first:

- Every card compiles to a **fixed 105mm × 140mm (3:4) page** — the same
  shape as the app's card `AspectRatio`. No content-cropping step needed
  or wanted: the page already *is* the target shape, so rasterizing it
  1:1 is enough.
- **No auto-fit, no font-scaling magic.** If a card's content overflows
  the fixed box, that's visible and expected — you resolve it by hand,
  per card, the same way you'd have done it in the test environment.
- This is deliberately the simplest thing that works, not the most
  automated thing possible.

## How the fixed page is achieved

**`praeambel_app_standalone.tex`** is a from-scratch, lightweight preamble
that knows nothing about `praeambel_karteikarten.tex` — no `\input`, no
shared macros, no background layers, no print machinery. It's built from
checking exactly what the real 129-card deck uses (not guessed):

- **Fixed page:** `\geometry{paperwidth=105mm,paperheight=140mm,margin=6mm}`
  — same ratio validated in `latex_pipeline_test/`.
- **Packages the deck actually needs:** `amsmath`, `amssymb`, `extarrows`
  (for `\xlongrightarrow`), `array`/`tabularx`/`diagbox` (for the
  hypothesis-test tables), `graphicx` (for `\resizebox` and the 3
  `\includegraphics` calls), `tikz` (diagrams — one card loads the
  `patterns` library itself, inline, so that's not declared globally).
- **Custom commands the deck relies on**, re-defined simply:
  `\R` → `\mathbb{R}`, `\D` → `\mathbb{D}`, `\abs{}` → `\left|...\right|`,
  `\mal` → `\cdot`, `\std` → `\sigma`. (`\circleA`/`\circleB` need no
  definition here — the two cards that use them `\def` them inline,
  self-contained.)
- **`frage`/`antwort` environments:** one page each, vertically centered,
  no auto-fit, no counters/headers/footers/background — same as
  `preamble_test.tex` in the test environment.

This means **`praeambel_karteikarten.tex` and its `1.png`/`2.png`
background are no longer needed at all** for app renders — only for
compiling the print deck directly, which still works exactly as before
since nothing in this pipeline touches it.

The build script still does one small transform per card: it strips
`landscape`/`paper=a6` from the source's `\documentclass[...]` line (they'd
fight with the portrait geometry) and redirects `\input` from
`praeambel_karteikarten` to `praeambel_app_standalone` — both only in the
in-memory copy assembled for that card's scratch compile.

**One caveat:** the custom command definitions above are my best
reconstruction from how they're *used* in the deck, not copied from your
real preamble (which I don't have) — functionally correct (things will
compile and mean the right thing), but the exact visual styling (e.g. is
`\R` normally bold-double-struck via a specific font package, or does
`\mal` render with extra spacing around it in the original?) may differ
slightly from what the print deck shows. Worth a glance at a rendered
card or two before treating this as final.

## Category tagging (unchanged from before)

A sticky `% category: X` comment above a card applies to every card after
it until the next tag — 3 lines currently tag all 129 cards. I already
added these to your file at the real topic boundaries:

| Line | Tag |
|---|---|
| 5 | `% category: skip` (cover card, excluded) |
| 19 | `% category: Analysis` |
| 785 | `% category: Stochastik` |
| 1350 | `% category: Geometrie` |

Verified again against this version of the script: **129 cards — 49
Analysis / 48 Geometrie / 32 Stochastik**, all unique ids.

## Ids and incremental rebuilds (unchanged from before)

Each card's id is a hash of its own `(category, frage, antwort)` text —
stable across reordering, changes automatically if you edit a card's
content (which correctly resets that card's proficiency in the app, since
the old "I know this" signal shouldn't survive a content change).
`.build_cache.json` (written to your assets folder) skips recompiling
cards whose hash hasn't changed, and is now saved after *every* card
instead of only at the end of the run — a crash partway through a large
rebuild no longer throws away cards that already rendered successfully.

## Layout

```
<flutter project root>/
  flashcards_source/
    Karteikarten_Akademus.tex       (tagged, included here)
    praeambel_app_standalone.tex    (included here)
    schema_gerade_gerade.*          (add this)
    schema_ebene_gerade.*           (add this)
    schema_ebene_ebene.*            (add this)
  assets/
    flashcards_manifest.json
    flashcards/
  tools/
    build_flashcards.py
  lib/
  pubspec.yaml
```

Only the three `schema_*` files (whatever format they are — `.pdf`/`.png`)
are missing from what's in this delivery: three cards `\includegraphics`
them directly, so they need to sit in `flashcards_source/` alongside
everything here. `praeambel_karteikarten.tex` and its `1.png`/`2.png`
background are **not** needed for this pipeline anymore — only for
compiling the print deck directly, wherever you keep doing that.

## Usage

Requires on `PATH`: `latexmk`, `pdftoppm` (poppler-utils), `cwebp`
(libwebp) — no ImageMagick this time, since there's no cropping step.

```bash
cd <flutter project root>
python3 tools/build_flashcards.py \
  --source flashcards_source/Karteikarten_Akademus.tex \
  --preamble-dir flashcards_source \
  --out-assets assets
```

Output:
```
assets/
  flashcards_manifest.json
  flashcards/
    analysis/
      analysis_<hash>_front.webp
      analysis_<hash>_back.webp
      ...
    geometrie/...
    stochastik/...
```

## What still needs doing on the Flutter side

The app's card container needs to be pinned to the same `105/140` ratio,
the same way `latex_pipeline_test/lib/main.dart` does it — wrap the card
`Stack` in `CategoryFlashcardScreen` with `Center(child: AspectRatio(...))`
instead of letting it freely fill the `Expanded` space. I haven't touched
`lib/` in this delivery since the test app already proved the pattern;
say the word and I'll write out the exact diff for the real
`category_flashcard_screen.dart`.

## What I still can't run here

Same limitation as before: no LaTeX toolchain in this sandbox, and I'm
still missing the three `schema_*` include files. I verified parsing,
category assignment, id hashing, and the `\documentclass`/`\input`
transform directly against your real 129-card file (shown above). I
also checked `praeambel_app_standalone.tex`'s package/command list
against every non-standard command actually used across the deck (see
the caveat above about custom-command styling) — but I can't confirm the
LaTeX itself compiles cleanly without a toolchain to run it on. That's
what you're running locally next.

