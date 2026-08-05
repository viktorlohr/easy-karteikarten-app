# Image-based flashcard prototype

This replaces the markdown/LaTeX-parsing flashcard system with a pure
image viewer: every front and back is a pre-rendered `.webp` (e.g. a
compiled LaTeX snippet), and there's no in-app editor — cards come from a
static JSON manifest bundled as an asset.

## 1. Delete these from your project

```
lib/markdown/                                   (entire folder)
lib/presentation/screens/category_overview_screen.dart
lib/presentation/screens/flashcard_editor_screen.dart
lib/presentation/widgets/snippets/               (entire folder)
lib/storage/shared_pref_storage.dart             (replaced by proficiency_storage.dart)
lib/constants/app_spacing.dart                   (only the editor used this — optional to keep)
assets/predefined_flashcards.json                (replaced by flashcards_manifest.json)
```

## 2. Copy these in (overwrite existing files of the same name)

```
pubspec.yaml
assets/flashcards_manifest.json
lib/main.dart
lib/constants/categories.dart
lib/models/flashcard.dart
lib/services/flashcard_service.dart
lib/storage/proficiency_storage.dart
lib/presentation/screens/topic_selection_screen.dart
lib/presentation/screens/category_flashcard_screen.dart
lib/presentation/screens/stats_screen.dart
lib/presentation/screens/grid_selection_screen.dart
lib/presentation/screens/privacy_info_screen.dart
lib/presentation/widgets/app_chrome.dart
```

The last four in that list are byte-identical to what you already have —
they're included only so the whole `lib/` tree is consistent and nothing
references a deleted file.

## 3. Run

```
flutter pub get
```

This drops `shared_preferences` (still used, now only for proficiency),
`meta`, `cupertino_icons`, and `flutter`/`flutter_test`/`flutter_lints`.
`flutter_markdown_plus`, `markdown`, `flutter_math_fork`, `file_picker`,
and `flutter_svg` are all gone — nothing in the new flow parses text.

## What changed, structurally

- **`Flashcard`** is now just `{id, category, frontImage, backImage}` —
  two asset paths, nothing else. No `front`/`back` strings, no `tags`
  list (category is now a plain field), no markdown to render.
- **Proficiency moved out of the card model.** Since cards are static
  bundled content (not user-created), there's nothing to "save" for a
  card except how well the user knows it. `ProficiencyStorage` persists
  `{cardId: 0-4}` in `SharedPreferences`, separate from the manifest.
- **`FlashcardService`** reads `assets/flashcards_manifest.json` once
  (cached in memory), filters by category, and merges in live
  proficiency for sorting (weakest cards first) — no import/export/CRUD.
- **Navigation:** `TopicSelectionScreen` → tap a category →
  `CategoryFlashcardScreen(category: ...)` directly. The overview/list
  screen is gone; `CategoryFlashcardScreen` now loads its own cards in
  `initState` instead of receiving `initialCards`/`initialIndex`.
- **Card faces** render via `Image.asset(...)` wrapped in an
  `InteractiveViewer` (pinch-zoom) instead of `AppMarkdown` in a
  scrollable column — appropriate since a compiled LaTeX image can't
  reflow the way text could.
- **`StatsScreen`** no longer carries the card list forward; "Nochmal
  üben" just re-navigates to `CategoryFlashcardScreen(category: topic)`,
  which reloads and re-shuffles by current proficiency itself.

## Manifest format (`assets/flashcards_manifest.json`)

```json
[
  {
    "id": "analysis_001",
    "category": "Analysis",
    "front": "assets/flashcards/analysis/analysis_001_front.webp",
    "back": "assets/flashcards/analysis/analysis_001_back.webp"
  }
]
```

`category` must exactly match one of the strings in
`lib/constants/categories.dart` (`Analysis`, `Geometrie`, `Stochastik`).
`id` must be unique — it's the key proficiency is stored under, so if you
regenerate a card's image, keep the same id or the user's progress on
that card resets.

The four sample entries in the manifest point at `.webp` files that
don't exist yet in this bundle — drop your real compiled images into
`assets/flashcards/<category>/` with matching filenames (or edit the
manifest's paths), and make sure each subfolder is listed under
`flutter: assets:` in `pubspec.yaml` (already done for the three
categories here).
