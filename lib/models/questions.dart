// Data models for MindScroll quiz content.

class Question {
  final String id;
  final String category;
  final String prompt;
  final List<String> options; // exactly 4 choices (A, B, C, D)
  final int correctIndex;
  final String explanation;

  const Question({
    required this.id,
    required this.category,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

/// How a study set was created — drives the badge pill on the dashboard.
enum StudySetSource { manual, pdfAi }

extension StudySetSourceLabel on StudySetSource {
  String get label =>
      this == StudySetSource.pdfAi ? 'PDF (AI-Generated)' : 'Form-Created';
}

class StudySet {
  final String id;
  final String title;
  final String folderId;
  final StudySetSource source;
  final List<Question> questions;

  /// Human-readable review status shown on the dashboard tile,
  /// e.g. 'Last reviewed yesterday'.
  final String lastReviewed;

  const StudySet({
    required this.id,
    required this.title,
    required this.folderId,
    required this.source,
    required this.questions,
    this.lastReviewed = 'Not reviewed yet',
  });
}

class StudyFolder {
  final String id;
  final String name;

  const StudyFolder({required this.id, required this.name});
}
