import 'package:flutter/material.dart';

import '../models/questions.dart';
import '../theme/mindscroll_theme.dart';

/// Study set tile shared by the dashboard and the folder detail screen.
class StudySetCard extends StatelessWidget {
  const StudySetCard({
    super.key,
    required this.studySet,
    required this.onStart,
  });

  final StudySet studySet;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isAi = studySet.source == StudySetSource.pdfAi;

    return Container(
      constraints: const BoxConstraints(minHeight: 132),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studySet.title,
                  style: inter(
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    // AI badge: primaryContainer/onPrimaryContainer;
                    // manual badge: surfaceContainerHigh/onSurfaceVariant.
                    color: isAi
                        ? colors.primaryContainer
                        : colors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    studySet.source.label,
                    style: inter(
                      color: isAi
                          ? colors.onPrimaryContainer
                          : colors.onSurfaceVariant,
                      fontSize: 11,
                      height: 14 / 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${studySet.questions.length} Questions',
                  style: inter(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  studySet.lastReviewed,
                  style: inter(
                    color: colors.onSurfaceVariant,
                    fontSize: 11,
                    height: 14 / 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 78,
            height: 36,
            // primary/onPrimary from the ColorScheme (onPrimary text).
            child: FilledButton(
              onPressed: onStart,
              style: FilledButton.styleFrom(padding: EdgeInsets.zero),
              child: Text(
                '▶ Start',
                style: inter(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
