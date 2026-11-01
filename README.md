# MindScroll — Doomscrolling with a purpose

**COMP4521 Mobile Application Development · Group 10**

MindScroll is a mobile microlearning application that replaces mindless
"doomscrolling" with short-form vertical quiz reels. It keeps the familiar
swipe-up format of Instagram Reels / YouTube Shorts, but fills the feed with
bite-sized educational questions instead — turning wasted scroll time into
study time.

## Background

Mobile interaction has shifted toward high-frequency, short-duration content,
leading to the widespread phenomenon of **doomscrolling** — excessive,
mindless scrolling that harms health, studies and social interaction. At the
same time, **microlearning** (1–5 minute lessons) has proven effective at
maximising engagement. MindScroll combines both trends: it acknowledges the
short attention span of users and channels it into useful educational content
in the same short-form vertical format people are already addicted to.

Existing platforms each solve part of the problem — **Brilliant.org** offers
interactive problem-solving but locks content behind subscriptions and
disallows user materials; **Quizlet** supports user-generated study sets but
offers little contextual explanation; **Duolingo** gamifies learning with
daily streaks but encourages superficial engagement. MindScroll combines their
strengths (own study materials, gamification, psychological retention
mechanisms), stays free, and adds AI-assisted question generation.

## Objectives

**Primary**

1. Responsive Flutter UI with a study-set dashboard and a full-screen vertical
   feed, achieving **60 FPS** with smooth question transitions.
2. Offline-first study-set management — manual creation, editing, deletion and
   organisation of sets (MCQ, T/F, etc.).

**Secondary**

1. Automated document ingestion: PDF text extraction + AI question generation.
2. Response validation engine: locked selection, haptic feedback, and green/red
   visual states with an explanation overlay.
3. Daily streak habit tracker that incentivises studying every day.

## Features

| Functional requirement | Status |
|---|---|
| Home dashboard with folders, study sets, question counts | ✅ Implemented (Sprint 1) |
| Reel-style vertical quiz feed (`PageView`) | ✅ Implemented (Sprint 1) |
| Interactive answer validation: lock, haptics, green/red states, explanation | ✅ Implemented (Sprint 1, < 100 ms feedback path) |
| Manual study set & folder creation UI | ✅ Implemented (Sprint 1) |
| Folder detail screen with live metrics | ✅ Implemented (Sprint 1) |
| Edit / delete sets and questions | 🔜 Sprint 2 |
| Offline SQLite storage (survives app restart) | 🔜 Sprint 2 |
| PDF text extraction | 🔜 Sprint 3 |
| AI question generation (DeepSeek-compatible API) | 🔜 Sprint 3 |
| Daily streak tracking logic | 🔜 Sprint 4 |

## Screens

1. **Dashboard** — daily streak header, study folder grid, recent study sets
   with source badges, bottom navigation (Home / Notes / Import PDF).
2. **Vertical Reel Quiz Feed** — full-screen swipe feed; category tag, question
   counter, locked-tap answer validation, haptic feedback, sliding explanation
   card.
3. **Study Set Creation** *(planned)* — manual authoring of questions, answer
   formats, keys and explanations.
4. **Note Creation** *(planned)* — in-app notes usable as AI generation input.

## Tech Stack & Architecture

- **Flutter SDK + Dart**, targeting Android (expandable to iOS/desktop/web).
- **Material Design 3** dark theme — the centralized "Midnight Violet"
  `ColorScheme` in `lib/theme/mindscroll_theme.dart` (Inter typeface, bundled
  locally under `fonts/` — SIL OFL). Views read `Theme.of(context).colorScheme`
  roles; no hardcoded hex in the UI.
- **MVVM pattern** with a strict layered architecture:
  - *Presentation* (`lib/views/`) — declarative widgets; dashboard, reel feed,
    folder detail, shared `CreateSheet` / `StudySetCard`.
  - *Business logic* (`lib/controllers/`) — native Flutter state management
    (`ChangeNotifier` + `AnimatedBuilder`); quiz engine handles selection lock,
    correctness, haptics trigger point and explanation visibility.
  - *Models* (`lib/models/`) — `Question`, `StudySet`, `StudyFolder`.
  - *Local data* — SQLite engine + Shared Preferences *(Sprint 2)*.
  - *External services* — DeepSeek-compatible AI API, OS file picker
    *(Sprint 3)*.
- **No third-party state-management packages** — native `StatefulWidget` /
  `ChangeNotifier` only.

## Project Structure

```
lib/
├── main.dart                  # App entry, wires in the theme
├── theme/mindscroll_theme.dart # Midnight Violet M3 ColorScheme + theme
├── models/questions.dart      # Question, StudySet, StudyFolder, StudySetSource
├── controllers/
│   └── quiz_controller.dart   # ChangeNotifier ViewModel + mock content
└── views/
    ├── dashboard.dart         # Home screen
    ├── reel_quiz_feed.dart    # Vertical snap-scrolling quiz reel
    ├── folder_detail.dart     # Folder contents + metrics
    ├── create_sheet.dart      # Shared create folder/set bottom sheet
    └── study_set_card.dart    # Shared study set tile
tool/
└── figma_sync.dart            # Figma REST API → design tokens sync
fonts/                         # Bundled Inter (OFL)
docs/progress-log.md           # Sprint 1 engineering log
docs/AI-HANDOFF.md             # Shared state for switching AI assistants
```

## Getting Started

```bash
flutter pub get
flutter run            # on a connected emulator/device
```

For performance work, use a **profile build** — debug mode runs on the JIT
compiler and is not representative:

```bash
flutter run --profile
```

## Testing

```bash
flutter analyze   # static analysis (0 issues expected)
flutter test      # widget tests: design render, sheet-cancel regression,
                  # folder navigation, folder creation
```

## Roadmap (proposal schedule)

| Period | Tasks | Milestone | Status |
|---|---|---|---|
| 28 Oct – 03 Nov | 1.1, 1.2 | Flutter UI & reel feed working and usable | ✅ Done |
| 04 Nov – 10 Nov | 2.1, 2.2 | Offline storage & SQLite operational | 🔜 |
| 11 Nov – 17 Nov | 3.1, 4.1 | PDF & AI ingestion integrated | 🔜 |
| 18 Nov – 27 Nov | 4.2 | Streak tracker completed | 🔜 |

## Generative AI Usage Acknowledgement

Generative AI tools were used in the development of this project:

- **Brainstorming & concept structuring** — refining the microlearning idea and
  comparing technologies (Google Gemini, NotebookLM); **Figma Make** used to
  speed up design/prototyping of screen layouts.
- **Development assistance** — an AI coding assistant (Kimi Code CLI) was used
  for code generation, bug diagnosis (overflow root causes, widget lifecycle
  crashes), Figma-export adaptation, and tooling (DevTools VM-service
  integration, Figma token sync).
- **In-app pipeline (planned)** — a DeepSeek-compatible AI API will generate
  quiz questions from extracted PDF/notes text at runtime.

## License & Credits

- Inter typeface © The Inter Project Authors, licensed under the
  [SIL Open Font License 1.1](fonts/OFL.txt).
- Course project for COMP4521, HKUST. Group 10.
