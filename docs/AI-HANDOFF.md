# MindScroll — AI Handoff

> Shared state file for switching between AI coding assistants
> (**Kimi Code CLI ↔ Claude Code**), e.g. when one runs out of credits.

## Rules

- **Read first.** At session start, read the Snapshot and the newest Handoff
  log entries before touching code.
- **Update before you stop.** Refresh the Snapshot in place and prepend one
  new entry to the Handoff log. Never rewrite or delete another assistant's
  entries.
- **Record facts, not intentions:** timestamps, commit hashes, exact commands
  run, test results, known-broken areas. Long-form engineering narrative
  belongs in [`progress-log.md`](progress-log.md), not here.
- **Keep it short.** This file is a relay baton, not a report.

## Sprint start protocol

Use a **new chat per sprint** and stay in that chat for the sprint's related
work. A sprint boundary is a context boundary — the handoff file makes the new
chat cheap.

1. **Before switching:** commit pending work (code *and* docs). A clean working
   tree is the real handoff; uncommitted files don't travel.
2. **Open the chat with:** *“Read `docs/AI-HANDOFF.md` and
   `docs/progress-log.md`, then start Sprint N.”*
3. **Confirm scope** from the proposal task mapping in `progress-log.md` and
   the roadmap in `README.md`. Do not trust older status prose — the Snapshot
   below is authoritative.
4. **Baseline before coding:** run `flutter analyze` (expect 0 issues) and
   `flutter test` (currently 5/5 passing), so any later failure is clearly
   attributable to the sprint's changes.
5. **Agree on a short task list**, then update the Snapshot's *Sprint status*
   and *Current focus* sections before the first code change.
6. **During the sprint:** prepend a handoff entry whenever progress is logged
   or the assistant is switched — not only at sprint end.
7. **End of sprint:** re-run both checks, commit, update `progress-log.md`
   (including the AI-usage log), and move completed items out of *Next steps*
   in the Snapshot.

If resuming a sprint mid-way in the same chat, re-read this file first when
the other assistant has edited it.

## Snapshot

- **Last updated:** 2026-11-02 00:01 HKT (UTC+8) by Kimi Code CLI
- **Branch / HEAD:** `master` @ `b0dd9a1` — *Theme: centralized Midnight Violet
  M3 theme, edge-to-edge insets*, committed 2026-11-01 22:44 HKT
  (1 commit ahead of `origin/master`, not pushed)
- **Working tree:** UNCOMMITTED changes — theme refactor completion + docs:
  - Code: `lib/views/reel_quiz_feed.dart` (finished theme-role conversion:
    option tiles, progress header, category chip, explanation card now read
    `Theme.of(context).colorScheme`; removed last hardcoded `#121212`
    scaffold bg), plus `dart format lib` whitespace normalization across all
    of `lib/`.
  - Docs: `README.md` + `docs/progress-log.md` reconciled with the Midnight
    Violet theme (dropped stale `AppColors` / `#121212` / `#6200EE`
    references, fixed test count 4/4 → 5/5); `?? docs/AI-HANDOFF.md`.
- **Verification (last run 2026-11-02 00:01 HKT):**
  - `flutter analyze` — no issues
  - `flutter test` — 5/5 passing
  - Debug build compiles; **not yet re-run on a device** since the theme
    refactor
- **Sprint status:** Sprint 1 (dashboard, reel feed, folder detail) complete;
  Sprint 2 (edit/delete sets, SQLite offline storage) not started

## Current focus / open items

- `b0dd9a1` refactored colors into `lib/theme/mindscroll_theme.dart` (Midnight
  Violet M3 `ColorScheme`, component sub-themes, `MindScrollColors` extension
  for the streak accent). Views now read `Theme.of(context)` roles.
- Theme conversion is now **complete across all views** — the only remaining
  `Color(0x…)` literals in `lib/views/` are the intentional pedagogical
  answer-feedback constants in `reel_quiz_feed.dart` (`_correctBg #1B3E2B`,
  `_correctBorder #4CAF50`, `_wrongBg #3E1B1B`, `_wrongBorder #EF5350`) plus
  the matching green progress/category accents. Kept deliberately (universal
  correct/incorrect semantics), documented in code.
- Pending commit: the reel theme-conversion completion + `dart format`
  normalization + the reconciled docs (`README.md`, `progress-log.md`,
  `AI-HANDOFF.md`).
- No known code-level blockers.

## Next steps

1. Commit (and push, if the user wants) the pending code + docs updates.
2. Run the app on device once to sanity-check the theme on hardware.
3. Begin Sprint 2: edit/delete study sets, SQLite persistence.

## Environment notes

- Flutter SDK: `C:\Projects\flutter_sdk\flutter` (Windows, Git Bash shell)
- Target device: Android, wireless adb (`adb-9eb0028f-52LqU1._adb-tls-connect._tcp`)
- Standard checks: `flutter analyze`, `flutter test`; use `flutter run --profile`
  for performance work (debug/JIT is not representative).

## Handoff log (newest first)

### 2026-11-02 00:01 HKT — Kimi Code CLI (theme conversion completed)

- Finished the `reel_quiz_feed.dart` theme-role conversion that was left
  mid-edit: option tiles (`#1E1E24`/`#2E2E38` → `surfaceContainer`/
  `outlineVariant`), progress-header track (`#2A2A33` →
  `surfaceContainerHighest`), category-chip bg, and the explanation card
  (`#23232B`/`#34343E` → `surfaceContainerHigh`/`outlineVariant`); grey text
  shades → `onSurface`/`onSurfaceVariant`. Removed the last hardcoded
  `#121212` scaffold background (now inherits `surfaceContainerLowest`).
- Kept the pedagogical answer-feedback colors as named constants
  (`_correctBg`/`_correctBorder`/`_wrongBg`/`_wrongBorder`) — intentional
  exception, documented in code.
- Ran `dart format lib` (whitespace normalization across all of `lib/`).
- Reconciled stale docs: `README.md` + `progress-log.md` now describe the
  Midnight Violet theme (dropped `AppColors`/`#121212`/`#6200EE`), test count
  corrected to 5/5.
- Verified: `flutter analyze` clean, `flutter test` 5/5 passing.
- **Left uncommitted:** all of the above (code + docs).
- **Next:** commit + push, on-device theme smoke test, then Sprint 2.

### 2026-11-01 22:55 HKT — Claude Code (handoff log refresh)

- Updated the Snapshot to the live working tree: `M README.md`,
  `M docs/progress-log.md`, `?? docs/AI-HANDOFF.md` — docs only, no code
  changes since `b0dd9a1`.
- Added discovery pointers to this file in `docs/progress-log.md` (intro
  block) and `README.md` (project structure).
- Verification is unchanged (last run 22:40–22:47 HKT): `flutter analyze`
  clean, `flutter test` 5/5 passing; on-device smoke test still pending.
- **Next:** commit these docs, reconcile the stale theme sections in
  `README.md` / `progress-log.md`, then start Sprint 2.

### 2026-11-01 22:48–22:54 HKT — Claude Code

- Fixed the debug-build failure from the in-progress theme refactor: current
  Flutter SDK takes `CardThemeData` / `DialogThemeData` for
  `ThemeData.cardTheme` / `dialogTheme`; migrated both in
  `lib/theme/mindscroll_theme.dart`.
- Verified: `flutter analyze` clean, `flutter test` 5/5 passing.
- Committed the theme refactor as `b0dd9a1` at 22:44 HKT (centralized theme,
  edge-to-edge insets) in the project's existing commit style.
- Added the Claude Code section to the AI Tool Usage Log; created this file.
- Added the *Sprint start protocol* section (new-chat-per-sprint workflow,
  baseline checks, snapshot/handoff update discipline).
- **Left uncommitted:** `docs/progress-log.md`, `docs/AI-HANDOFF.md`.
- **Next:** commit docs, reconcile stale README/log sections, device smoke test.

### 2026-11-01 21:59 HKT — Kimi Code CLI (last known state)

- Last commit: `b44fad6` at 21:59 HKT — reel `ParentDataWidget` crash,
  keyboard relayout lag, bundled Inter fonts.
- Left an in-progress centralized-theme refactor in the working tree
  (`lib/theme/`, views migrating from `AppColors` to `Theme.of(context)`);
  it did not compile against the installed Flutter SDK. Picked up and
  committed by Claude Code as `b0dd9a1`.
- No other outstanding work known at handoff time.
