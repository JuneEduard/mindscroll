# MindScroll — Sprint 1 Progress Log

> Companion log for the project report. Covers all work completed in Sprint 1,
> mapped to the proposal tasks. All development was verified with
> `flutter analyze` (0 issues) and widget tests (all passing) at each step.

## Proposal Task Mapping

### ✅ Task 1.1 — 60-FPS Vertical Snap-Scrolling Feed Engine (`lib/views/reel_quiz_feed.dart`)

- Full-screen `PageView.builder(scrollDirection: Axis.vertical)` reel with
  page snapping; lazily builds only the visible card (+1 buffer) to hold 60 FPS.
- Responsive quiz cards: progress header (bar + `n / total`), category chip,
  question prompt, four A–D option tiles.
- **Sub-50ms selection logic** (`QuizController.selectAnswer`):
  - Selection lock via guard clause (`if (_answered) return;`) — re-taps are
    dropped with zero rebuilds; taps also inert at the widget layer (`onTap: locked ? null : onTap`).
  - `HapticFeedback.mediumImpact()` fires **before** the state update (non-blocking).
  - Correct option → `#1B3E2B` background + `#4CAF50` border; incorrect pick →
    `#3E1B1B` background + red border; correct answer also revealed after a wrong pick.
  - Sliding explanation overlay (`AnimatedPositioned`, 320ms `easeOutCubic`),
    wrapped in `IgnorePointer` so vertical swipes pass through to the `PageView`.
  - **Auto-reset**: `onPageChanged → controller.onPageChanged(index) →
    resetQuestion()` — every freshly-snapped card starts unlocked.
- Top AppBar `Icons.close` pops back to the dashboard.
- Business logic kept in `lib/controllers/quiz_controller.dart`
  (native `ChangeNotifier`, MVVM); 15 mock questions across 5 sets.

### ✅ Task 1.2 — Home Dashboard (`lib/views/dashboard.dart`)

- Figma-prototype UI adapted into the project: header (22pt Inter title,
  `🔥 5 Day Streak` pill `#352319`/`#FF6D00`, settings gear), **My Study
  Folders** section, **Recent Study Sets** section, fixed 64px bottom action
  bar (Home / Notes / Import PDF) with custom Figma SVG icons.
- Purple Material 3 dark theme (`#121212` background, `#1E1E24` surface,
  `#6200EE` primary, `#BB86FC` accent) via `AppColors` tokens + Inter `TextTheme`.
- Tapping **▶ Start** on any study set pushes `ReelQuizFeed` (empty sets show
  a guard snackbar instead of an empty screen).

### ✅ Follow-up Features (post-prototype UI updates)

- **Study folder creation** ("+ New Folder") and **manual study set creation**
  ("+ Create Study Set") via modal bottom sheet (`lib/views/create_sheet.dart`).
- **2-row horizontally scrollable folder grid** — horizontal `GridView`,
  120px rows / ~180px cards.
- **Folder detail screen** (`lib/views/folder_detail.dart`, from Figma v2):
  header card with 📁 tile, live Study-sets / Questions metrics, in-folder set
  list, empty-folder state, in-folder set creation; shares the dashboard's
  live list so counts refresh on return.
- Source badges on set tiles: `Form-Created` (gray) / `PDF (AI-Generated)` (purple).

## Engineering Log — Bugs Found & Fixed

1. **Folder card overflow ("BOTTOM OVERFLOWED")** — root cause: fixed pixel
   budgets (`mainAxisExtent` / `SizedBox` + `Spacer`) vs font-metric-dependent
   content. Fixed by switching to content-sized layouts (half-width column
   grid, then horizontal grid with verified row headroom). Also caught the
   same bug class inside the Figma Make exports themselves.
2. **`'_dependents.isEmpty': is not true` crash on dialog/sheet Cancel** —
   root cause: `TextEditingController` disposed from `showDialog(...).then()`
   while the exit animation kept the `TextField` alive. Fixed with the
   "dialog/sheet owns its controller" pattern (dispose in own `dispose()`);
   regression-tested.
3. **Horizontal `GridView childAspectRatio` inversion** — Flutter defines it
   as *cross-axis ÷ main-axis* (height ÷ width for horizontal grids), not
   width ÷ height; produced 66px-wide cards and 80px overflows. Diagnosed with
   a render-tree geometry probe.
4. **Figma export regressions repaired during adaptation**: dispose-after-await
   pattern, fixed-extent grids, and regex-parsed question counts (replaced
   with real model data).

## Architecture & Constraints

- **State management: strictly native Flutter** — `StatefulWidget` +
  `ChangeNotifier` only. Removed accidentally-added Riverpod/hooks packages
  from `pubspec.yaml`; only UI packages (`google_fonts`, `flutter_svg`) added.
- MVVM: models in `lib/models/`, ViewModel in `lib/controllers/`, views in
  `lib/views/`.
- Shared widgets extracted: `CreateSheet`, `StudySetCard` (used by dashboard
  and folder detail).

## Verification (final state)

- `flutter analyze` — **No issues found!**
- `flutter test` — **4/4 widget tests passing**:
  dashboard renders per Figma design; cancelling create sheets does not throw
  (regression); tapping a folder opens its detail screen; creating a folder
  adds it to the grid.
- Live runtime verified via VM-service integration (widget inspector + memory).

## Tooling

- `tool/figma_sync.dart` — Figma REST API design-token sync (colors/text
  styles → `lib/design_tokens.dart`); avoids repeated manual zip downloads.
- `Figma/` exports gitignored (design snapshots, not app source).
