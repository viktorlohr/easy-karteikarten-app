# LaTeX deck → .webp flashcard pipeline

## The idea

Your `.tex` file stays the single source of truth — that's where the client
already edits and adds cards. Nothing about how you write cards changes,
except one thing: each topic block gets a one-line comment tagging its
category, e.g.:

```latex
% category: Analysis
\begin{frage}
    Nullstellen einer Funktion?
\end{frage}
\begin{antwort}
    ...
\end{antwort}
\begin{frage}
    Nullstellen: Lineare Funktion
...
```

The tag is **sticky** — it applies to every card after it until the next
`% category:` comment. Since your deck is already grouped by topic, this
means *3 lines total* tag all 129 cards (I added them for you — see below),
not 129 individual annotations. Adding a new card to an existing block
needs no tag at all; adding a whole new topic block needs one line.

A `% category: skip` tag excludes a card entirely — used here for the
cover/title card ("Karteikarten Mathematik © AKADEMUS"), which isn't a
real flashcard.

## What I did to your file

`Karteikarten_Akademus.tex` in this folder is your original file with four
comments inserted, based on where the topics actually shift:

| Line | Tag | First card after it |
|---|---|---|
| 5 | `% category: skip` | the cover card |
| 19 | `% category: Analysis` | "Nullstellen einer Funktion?" |
| 785 | `% category: Stochastik` | "Pfadregel bei Baumdiagrammen" |
| 1350 | `% category: Geometrie` | "Vektor von A nach B aufstellen" |

I parsed the tagged file (logic only, not the LaTeX rendering — see
"What I couldn't run here" below) and confirmed it splits cleanly into
**129 cards: 49 Analysis / 48 Geometrie / 32 Stochastik**, all with
unique ids, zero cards left untagged.

## How the build script works (`tools/build_flashcards.py`)

Per card:

1. **Compile.** Wrap the card's `\begin{frage}...\end{antwort}` pair with
   your existing preamble (`\input{praeambel_karteikarten}`, same
   `a6,landscape,...` document class) into a standalone 2-page PDF —
   page 1 is the front, page 2 the back. Compiling front+back *together*
   (rather than as two separate documents) matters here because your
   class is `twoside=true`, so left/right margins differ by page parity,
   and the answer's rendering may depend on the question's page/counter
   state.
2. **Rasterize + crop.** `pdftoppm` renders each page at high DPI, then
   ImageMagick's `-trim` removes the a6 whitespace margin around the
   actual content (a card that's just one formula shouldn't ship as a
   mostly-blank full-page image).
3. **Encode.** `cwebp -lossless` — lossless because these are sharp
   text/formula renders where compression artifacts on thin glyph
   strokes would actually be visible, and the files are tiny anyway
   (single card, mostly whitespace).
4. **id.** Each card's id is a short hash of its own `(category, frage,
   antwort)` text — not a sequential number. Two consequences, both
   intentional:
   - Reordering cards in the `.tex` (e.g. inserting a new one in the
     middle of a topic) doesn't shift anyone else's id.
   - Editing a card's content changes its id, which resets its
     proficiency in the app. That's correct — if the question or answer
     changed, the user's old "I know this" signal shouldn't carry over.
5. **Manifest.** Every card's `{id, category, front, back}` is written to
   `assets/flashcards_manifest.json` in the exact shape the Flutter app
   already expects.

## Incremental rebuilds

`.build_cache.json` (written next to your assets folder) maps each card's
id to the content hash it was last rendered from. Re-running the script
after adding 2 new cards to a 129-card deck recompiles those 2, not 129 —
LaTeX compilation is the slow part, so this is the difference between a
~5 minute rebuild and a ~5 second one. `--force` bypasses the cache and
rebuilds everything (useful after changing `praeambel_karteikarten.tex`
itself, since that affects every card but isn't tracked in any single
card's hash).

## Usage

Requires on `PATH`: `latexmk`, `pdftoppm` (poppler-utils), `convert`
(ImageMagick), `cwebp` (libwebp) — plus whatever TeX packages
`praeambel_karteikarten.tex` needs, which you already have since you're
compiling this deck today.

```bash
python3 tools/build_flashcards.py \
  --source Karteikarten_Akademus.tex \
  --preamble-dir . \
  --out-assets ../flutter_application_3/assets
```

`--preamble-dir` should point at the folder containing
`praeambel_karteikarten.tex` and anything it `\includegraphics`s (I saw
`schema_ebene_gerade` and `schema_ebene_ebene` referenced in two cards) —
those get copied alongside each card's scratch compile so relative
`\input`/`\includegraphics` paths keep resolving.

Output:
```
<flutter-project>/assets/
  flashcards_manifest.json
  flashcards/
    analysis/
      analysis_fc65402a571405ca_front.webp
      analysis_fc65402a571405ca_back.webp
      ...
    geometrie/...
    stochastik/...
```

Run `flutter pub get` once afterward only if you add/remove asset
*folders*; adding files inside already-declared folders doesn't need it.

## What I couldn't run here, and why

I don't have `praeambel_karteikarten.tex` (only the main deck was
uploaded) or the two `schema_*` include images, and this sandbox has no
LaTeX toolchain — installing a full TeX Live here just to prove one
compile works isn't worth the time versus running it in your existing,
already-working LaTeX environment. What I *did* verify is the parsing
and id/category logic against your real file (shown above) — that's the
part most likely to have subtle bugs (mismatched braces, a card with no
tag above it, etc.), and it runs clean.

If you hit a LaTeX error on a specific card when you run this locally,
paste me the `latexmk` output and I'll help debug — the script's error
messages include the source line number of the offending card to make
that easy.
