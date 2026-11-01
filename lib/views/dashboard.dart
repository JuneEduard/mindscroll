import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../controllers/quiz_controller.dart';
import '../models/questions.dart';
import '../theme/mindscroll_theme.dart';
import 'create_sheet.dart';
import 'folder_detail.dart';
import 'reel_quiz_feed.dart';
import 'study_set_card.dart';

/// Dashboard (Screen 1) — UI adapted from the Figma Make prototype.
/// Pure presentation layer; content comes from QuizController's mock data
/// and local StatefulWidget state (native state management only).
class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedNavigationIndex = 0;

  late final List<StudyFolder> _folders = [...QuizController.mockFolders];
  late final List<StudySet> _studySets = [...QuizController.mockStudySets];

  // ---- Derived stats ----
  int _setCount(String folderId) =>
      _studySets.where((s) => s.folderId == folderId).length;

  int _questionCount(String folderId) => _studySets
      .where((s) => s.folderId == folderId)
      .fold(0, (sum, s) => sum + s.questions.length);

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

  // ---- Create folder / study set (modal bottom sheet, per Figma) ----
  Future<void> _showCreateSheet({required bool isFolder}) async {
    final title = await CreateSheet.show(context, isFolder: isFolder);
    if (title == null || title.trim().isEmpty || !mounted) return;

    setState(() {
      if (isFolder) {
        _folders.add(
          StudyFolder(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: title.trim(),
          ),
        );
      } else {
        _studySets.insert(
          0,
          StudySet(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: title.trim(),
            folderId: _folders.first.id,
            source: StudySetSource.manual,
            questions: const [], // questions are added via Notes (next sprint)
          ),
        );
      }
    });

    _showMessage(isFolder ? 'Folder created' : 'Study set created');
  }

  // ---- Start quiz (kept from Sprint 1 — not part of the Figma mock) ----
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

  // ---- Folder detail (Figma v2) ----
  void _openFolder(StudyFolder folder) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FolderDetailScreen(
          folder: folder,
          allSets: _studySets, // live list — counts refresh on return
        ),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The create sheet lifts itself above the keyboard via its own
      // viewInsets padding. Resizing the body here would relayout the whole
      // dashboard (shrinkWrap grids + slivers) on EVERY keyboard animation
      // frame — that was the lag when creating folders/sets.
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList.list(
                children: [
                  _SectionHeader(
                    title: 'My Study Folders',
                    action: '+ New Folder',
                    onActionPressed: () => _showCreateSheet(isFolder: true),
                  ),
                  const SizedBox(height: 16),
                  // 2-row grid that scrolls horizontally once it exceeds
                  // the screen width. Row height = (container - spacing) / 2;
                  // 252 gives each card 120px, comfortably fitting the
                  // ~110px of content (padding + 2-line title + subtitle).
                  SizedBox(
                    height: 252,
                    child: GridView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: _folders.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            // childAspectRatio = crossAxis/mainAxis = height/width
                            // for a horizontal grid. 120/0.67 ≈ 180px wide cards.
                            childAspectRatio: 0.67,
                          ),
                      itemBuilder: (context, index) {
                        final folder = _folders[index];
                        return _FolderCard(
                          title: folder.name,
                          details:
                              '${_setCount(folder.id)} Sets • ${_questionCount(folder.id)} Qs',
                          onTap: () => _openFolder(folder),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
              sliver: SliverList.list(
                children: [
                  _SectionHeader(
                    title: 'Recent Study Sets',
                    action: '+ Create Study Set',
                    onActionPressed: () => _showCreateSheet(isFolder: false),
                  ),
                  const SizedBox(height: 12),
                  // Naturally-sized cards in a single column — a fixed-height
                  // grid would reintroduce the overflow problem.
                  Column(
                    children: [
                      for (
                        var index = 0;
                        index < _studySets.length;
                        index++
                      ) ...[
                        StudySetCard(
                          studySet: _studySets[index],
                          onStart: () => _startQuiz(_studySets[index]),
                        ),
                        if (index != _studySets.length - 1)
                          const SizedBox(height: 12),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNavigation(
        selectedIndex: _selectedNavigationIndex,
        onSelected: (index) {
          setState(() => _selectedNavigationIndex = index);
          if (index != 0) {
            _showMessage(index == 1 ? 'Notes selected' : 'Import PDF selected');
          }
        },
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 88,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'MindScroll',
                style: inter(
                  fontSize: 22,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Material(
              // Streak stays warm and distinct from the violet theme —
              // colors live in the MindScrollColors ThemeExtension.
              color: mindScrollColors(context).streakContainer,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _showMessage('Keep it going — day 6 is next!'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Text(
                    '🔥 5 Day Streak',
                    style: inter(
                      color: mindScrollColors(context).onStreakContainer,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              tooltip: 'Open settings',
              onPressed: () => _showMessage('Settings opened'),
              icon: SvgPicture.asset(
                'assets/icons/ca951.svg',
                width: 24,
                height: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header with action link
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.action,
    required this.onActionPressed,
  });

  final String title;
  final String action;
  final VoidCallback onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: inter(
              fontSize: 16,
              height: 22 / 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        // primary foreground comes from the theme's textButtonTheme.
        TextButton(
          onPressed: onActionPressed,
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            action,
            style: inter(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Folder card — Figma design has no progress bar, just title + details
// ---------------------------------------------------------------------------

class _FolderCard extends StatelessWidget {
  const _FolderCard({
    required this.title,
    required this.details,
    required this.onTap,
  });

  final String title;
  final String details;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📁 $title',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: inter(
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                details,
                style: inter(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Study set card
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// Bottom navigation — Figma SVG icons, 64px, top divider
// ---------------------------------------------------------------------------

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const items = [
    ('Home', 'assets/icons/4b3cc.svg'),
    ('Notes', 'assets/icons/cabe0.svg'),
    ('Import PDF', 'assets/icons/188cc.svg'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        child: Row(
          children: [
            for (var index = 0; index < items.length; index++)
              Expanded(
                child: _NavigationAction(
                  label: items[index].$1,
                  assetPath: items[index].$2,
                  selected: selectedIndex == index,
                  onTap: () => onSelected(index),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavigationAction extends StatelessWidget {
  const _NavigationAction({
    required this.label,
    required this.assetPath,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String assetPath;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = selected ? colors.primary : colors.onSurfaceVariant;

    return Semantics(
      selected: selected,
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              assetPath,
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: inter(
                color: color,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
