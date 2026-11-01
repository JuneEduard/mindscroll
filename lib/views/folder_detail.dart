import 'package:flutter/material.dart';
import '../models/questions.dart';
import '../theme/mindscroll_theme.dart';
import 'create_sheet.dart';
import 'reel_quiz_feed.dart';
import 'study_set_card.dart';

/// Folder detail screen (from the Figma v2 prototype): header card with
/// folder metrics, the study sets inside the folder, and an empty state.
///
/// [allSets] is the dashboard's live list — sets created here are inserted
/// into it, so the dashboard's folder counts refresh on return.
class FolderDetailScreen extends StatefulWidget {
  const FolderDetailScreen({
    super.key,
    required this.folder,
    required this.allSets,
  });

  final StudyFolder folder;
  final List<StudySet> allSets;

  @override
  State<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends State<FolderDetailScreen> {
  List<StudySet> get _sets =>
      widget.allSets.where((s) => s.folderId == widget.folder.id).toList();

  int get _totalQuestions =>
      _sets.fold(0, (sum, s) => sum + s.questions.length);

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 2400),
        ),
      );
  }

  Future<void> _createStudySet() async {
    final title = await CreateSheet.show(context, isFolder: false);
    if (title == null || title.trim().isEmpty || !mounted) return;

    setState(() {
      widget.allSets.insert(
        0,
        StudySet(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title.trim(),
          folderId: widget.folder.id,
          source: StudySetSource.manual,
          questions: const [], // questions are added via Notes (next sprint)
        ),
      );
    });
    _showMessage('Study set created');
  }

  // ---- Start quiz (Sprint 1 functionality, not in the Figma mock) ----
  void _startQuiz(StudySet studySet) {
    if (studySet.questions.isEmpty) {
      _showMessage('No questions yet — add some via Notes');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReelQuizFeed(studySet: studySet)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sets = _sets;

    return Scaffold(
      // See dashboard.dart — avoid per-frame relayout when the keyboard
      // opens for the create sheet.
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        // Colors come from the theme's appBarTheme
        // (surfaceContainerLowest / onSurface, no surface tint).
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          'Folder',
          style: inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Folder options',
            onPressed: () => _showMessage('Folder options opened'),
            icon: const Icon(Icons.more_horiz),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            // ---- Folder header card ----
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('📁', style: TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.folder.name,
                    style: inter(
                      fontSize: 22,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _FolderMetric(
                          label: 'Study sets',
                          value: '${sets.length}',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FolderMetric(
                          label: 'Questions',
                          value: '$_totalQuestions',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // ---- Study sets in this folder ----
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Study Sets',
                    style: inter(
                      fontSize: 16,
                      height: 22 / 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                // primary foreground comes from the theme's textButtonTheme.
                TextButton(
                  onPressed: _createStudySet,
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    '+ Create Study Set',
                    style: inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (sets.isEmpty)
              _EmptyFolderState(onCreatePressed: _createStudySet)
            else
              Column(
                children: [
                  for (var index = 0; index < sets.length; index++) ...[
                    StudySetCard(
                      studySet: sets[index],
                      onStart: () => _startQuiz(sets[index]),
                    ),
                    if (index != sets.length - 1)
                      const SizedBox(height: 12),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _FolderMetric extends StatelessWidget {
  const _FolderMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: inter(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyFolderState extends StatelessWidget {
  const _EmptyFolderState({required this.onCreatePressed});

  final VoidCallback onCreatePressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.menu_book_outlined,
            color: Theme.of(context).colorScheme.primary,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'No study sets yet',
            style: inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Create your first set to start studying this folder.',
            textAlign: TextAlign.center,
            style: inter(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          // primary/onPrimary from the ColorScheme.
          FilledButton(
            onPressed: onCreatePressed,
            child: const Text('Create Study Set'),
          ),
        ],
      ),
    );
  }
}
