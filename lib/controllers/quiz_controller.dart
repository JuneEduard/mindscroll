import 'package:flutter/foundation.dart';

import '../models/questions.dart';

/// Native ChangeNotifier ViewModel — no third-party state packages.
///
/// Holds the active study set and the answer state for the currently
/// visible question card. UI layers listen via [AnimatedBuilder].
class QuizController extends ChangeNotifier {
  final StudySet studySet;

  QuizController({required this.studySet});

  // ---- Active question state ----
  int? _selectedAnswer; // null = unanswered (options unlocked)
  bool _answered = false;

  bool get answered => _answered;
  int? get selectedAnswer => _selectedAnswer;
  int get questionCount => studySet.questions.length;

  Question questionAt(int index) => studySet.questions[index];

  // ---- Feed paging state ----
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  /// Called by the PageView whenever the user snaps to a new card.
  /// Resets answer state so every card starts fresh (unlocked).
  void onPageChanged(int index) {
    _currentIndex = index;
    resetQuestion();
  }

  /// Lock-in selection logic. Guard clause keeps this < 50 ms:
  /// once answered, taps are ignored and no notifyListeners is fired.
  void selectAnswer(int optionIndex) {
    if (_answered) return; // selection lock
    _answered = true;
    _selectedAnswer = optionIndex;
    notifyListeners();
  }

  void resetQuestion() {
    _answered = false;
    _selectedAnswer = null;
    notifyListeners();
  }

  // ---- Mock content ----

  static const List<StudyFolder> mockFolders = [
    StudyFolder(id: 'comp4521', name: 'COMP4521 Mobile Dev'),
    StudyFolder(id: 'elec3300', name: 'ELEC3300 Systems'),
  ];

  static final List<StudySet> mockStudySets = [
    StudySet(
      id: 'l3-dart-basics',
      title: 'Lecture 3 - Dart Basics',
      folderId: 'comp4521',
      source: StudySetSource.manual,
      lastReviewed: 'Last reviewed yesterday',
      questions: const [
        Question(
          id: 'dart-1',
          category: 'Flutter',
          prompt:
              'Which widget cannot change its configuration once it is built?',
          options: [
            'StatefulWidget',
            'StatelessWidget',
            'InheritedWidget',
            'StreamBuilder',
          ],
          correctIndex: 1,
          explanation: 'A StatelessWidget is immutable — when its inputs change, Flutter rebuilds a brand new widget instead.',
        ),
        Question(
          id: 'dart-2',
          category: 'Dart',
          prompt: 'Which programming language is Flutter primarily written in?',
          options: ['Kotlin', 'Swift', 'Dart', 'TypeScript'],
          correctIndex: 2,
          explanation: "Flutter's framework and the Dart VM are written in Dart, which compiles to native code.",
        ),
        Question(
          id: 'dart-3',
          category: 'Tooling',
          prompt:
              'What does the pubspec.yaml file define in a Flutter project?',
          options: [
            'App signing keys',
            'Dependencies and assets',
            'Gradle build scripts',
            'Widget tree layout',
          ],
          correctIndex: 1,
          explanation: 'pubspec.yaml declares package dependencies, fonts, images and other assets for the app.',
        ),
      ],
    ),
    StudySet(
      id: 'l4-cross-platform',
      title: 'Lecture 4 - Cross-Platform',
      folderId: 'comp4521',
      source: StudySetSource.manual,
      lastReviewed: 'Last reviewed yesterday',
      questions: const [
        Question(
          id: 'cs-1',
          category: 'Algorithms',
          prompt: 'What is the time complexity of binary search on a sorted array of n elements?',
          options: ['O(n)', 'O(log n)', 'O(n log n)', 'O(1)'],
          correctIndex: 1,
          explanation: 'Binary search halves the search space on every step, so it takes at most log₂(n) comparisons — that is O(log n).',
        ),
        Question(
          id: 'cs-2',
          category: 'Data Structures',
          prompt:
              'Which data structure follows Last-In-First-Out (LIFO) ordering?',
          options: ['Queue', 'Linked List', 'Stack', 'Heap'],
          correctIndex: 2,
          explanation: 'A stack pushes and pops from the same end, so the last element added is the first one removed — LIFO.',
        ),
        Question(
          id: 'cs-3',
          category: 'Networks',
          prompt: 'Which protocol securely transfers web pages over an encrypted connection?',
          options: ['HTTP', 'FTP', 'SMTP', 'HTTPS'],
          correctIndex: 3,
          explanation: 'HTTPS wraps HTTP inside TLS/SSL encryption, protecting data in transit between browser and server.',
        ),
        Question(
          id: 'cs-4',
          category: 'Concurrency',
          prompt: 'What does a mutex primarily protect against?',
          options: [
            'Memory leaks',
            'Race conditions',
            'Deadlocks',
            'Stack overflows',
          ],
          correctIndex: 1,
          explanation: 'A mutex serializes access to shared resources so only one thread enters a critical section at a time.',
        ),
      ],
    ),
    StudySet(
      id: 'l5-local-db',
      title: 'Lecture 5 - Local DB',
      folderId: 'comp4521',
      source: StudySetSource.pdfAi,
      lastReviewed: 'Last reviewed 3 days ago',
      questions: const [
        Question(
          id: 'db-1',
          category: 'Flutter',
          prompt:
              'Which Flutter package provides local SQLite database storage?',
          options: ['sqflite', 'dio', 'provider', 'firebase_core'],
          correctIndex: 0,
          explanation: 'sqflite is the standard SQLite plugin for Flutter, giving you tables, queries and transactions on-device.',
        ),
        Question(
          id: 'db-2',
          category: 'SQL',
          prompt: 'In SQLite, which statement permanently saves the current transaction?',
          options: ['SAVE', 'COMMIT', 'FLUSH', 'PERSIST'],
          correctIndex: 1,
          explanation: 'COMMIT makes all changes in the current transaction permanent; ROLLBACK undoes them.',
        ),
        Question(
          id: 'db-3',
          category: 'Flutter',
          prompt: 'Which package is the standard choice for simple key-value local storage?',
          options: ['hive', 'path_provider', 'shared_preferences', 'drift'],
          correctIndex: 2,
          explanation: 'shared_preferences stores small key-value pairs (tokens, flags) backed by platform storage.',
        ),
        Question(
          id: 'db-4',
          category: 'Databases',
          prompt: 'What does a database migration do?',
          options: [
            'Backs up the database to the cloud',
            'Updates the schema between app versions',
            'Compresses stored rows',
            'Encrypts the whole database',
          ],
          correctIndex: 1,
          explanation: 'Migrations evolve the schema (new tables/columns) safely while preserving existing user data.',
        ),
      ],
    ),
    StudySet(
      id: 'elec-sampling',
      title: 'Lecture 2 - Signal Sampling',
      folderId: 'elec3300',
      source: StudySetSource.pdfAi,
      lastReviewed: 'Last reviewed 2 days ago',
      questions: const [
        Question(
          id: 'elec-1',
          category: 'Signals',
          prompt: 'What does ADC stand for?',
          options: [
            'Analog-to-Digital Converter',
            'Automatic Data Compression',
            'Alternating Direct Current',
            'Advanced Digital Circuit',
          ],
          correctIndex: 0,
          explanation: 'An ADC samples a continuous analog signal and quantizes it into digital values.',
        ),
        Question(
          id: 'elec-2',
          category: 'Signals',
          prompt: 'The Nyquist theorem says the sampling rate must be at least ___ the highest signal frequency.',
          options: ['Equal to', 'Twice', 'Four times', 'Half of'],
          correctIndex: 1,
          explanation: 'Sampling below 2× the highest frequency causes aliasing, where high frequencies masquerade as low ones.',
        ),
      ],
    ),
    StudySet(
      id: 'elec-circuits',
      title: 'Midterm Review - Circuits',
      folderId: 'elec3300',
      source: StudySetSource.manual,
      lastReviewed: 'Last reviewed last week',
      questions: const [
        Question(
          id: 'elec-3',
          category: 'Circuits',
          prompt: 'V = IR is the statement of which law?',
          options: [
            "Kirchhoff's Law",
            "Faraday's Law",
            "Ohm's Law",
            "Lenz's Law",
          ],
          correctIndex: 2,
          explanation: "Ohm's Law relates voltage, current and resistance in a resistor: V = I × R.",
        ),
        Question(
          id: 'elec-4',
          category: 'Circuits',
          prompt: 'What is the SI unit of electrical resistance?',
          options: ['Volt', 'Ampere', 'Watt', 'Ohm'],
          correctIndex: 3,
          explanation:
              'Resistance is measured in ohms (Ω), named after Georg Ohm.',
        ),
      ],
    ),
  ];
}
