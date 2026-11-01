import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/mindscroll_theme.dart';

/// Modal bottom sheet for creating a folder or study set.
///
/// Owns its TextEditingController and disposes it in its own dispose(), so
/// it can never be disposed while the sheet (or its exit animation) is
/// still alive. Returns the entered title, or null if dismissed.
class CreateSheet extends StatefulWidget {
  const CreateSheet({super.key, required this.isFolder});

  final bool isFolder;

  static Future<String?> show(BuildContext context, {required bool isFolder}) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        // Android 15 draws behind the system nav bar (edge-to-edge). Lift the
        // sheet above whichever is taller: the keyboard or the nav bar —
        // summing would double-count the shared region.
        final bottom =
            math.max(
              MediaQuery.viewInsetsOf(context).bottom, // keyboard
              MediaQuery.paddingOf(context).bottom, // system nav bar
            ) +
            16;
        return Padding(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: bottom),
          child: CreateSheet(isFolder: isFolder),
        );
      },
    );
  }

  @override
  State<CreateSheet> createState() => _CreateSheetState();
}

class _CreateSheetState extends State<CreateSheet> {
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.isFolder ? 'New Folder' : 'Create Study Set',
                    style: inter(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Title',
              style: inter(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) Navigator.pop(context, value);
              },
              // Colors come from the theme's inputDecorationTheme
              // (surfaceContainerLowest fill, outline/primary/error borders).
              decoration: InputDecoration(
                hintText: widget.isFolder
                    ? 'e.g. COMP4521 Mobile Dev'
                    : 'e.g. Lecture 6',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                // primary/onPrimary come from the ColorScheme.
                FilledButton(
                  onPressed: () {
                    final title = _titleController.text.trim();
                    if (title.isNotEmpty) Navigator.pop(context, title);
                  },
                  child: const Text('Create'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
