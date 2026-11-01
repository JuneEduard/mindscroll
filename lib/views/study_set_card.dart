import 'package:flutter/material.dart';
import '../main.dart';
import '../models/questions.dart';

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
    return Container(
      constraints: const BoxConstraints(minHeight: 132),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
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
                    color: studySet.source == StudySetSource.pdfAi
                        ? const Color(0xFF342447)
                        : const Color(0xFF35353D),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    studySet.source.label,
                    style: inter(
                      color: studySet.source == StudySetSource.pdfAi
                          ? AppColors.accent
                          : AppColors.secondaryText,
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
                    color: AppColors.secondaryText,
                    fontSize: 12,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  studySet.lastReviewed,
                  style: inter(
                    color: AppColors.secondaryText,
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
            child: FilledButton(
              onPressed: onStart,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                '▶ Start',
                style: inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
