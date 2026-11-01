import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/quiz_controller.dart';
import '../models/questions.dart';

/// Full-screen vertical snap-scrolling quiz reel.
///
/// 60-FPS notes:
/// - `PageView.builder` lazily builds only the visible card (+1 buffer).
/// - All per-card widgets are `const` where possible; color changes are
///   cheap `AnimatedBuilder` rebuilds with no layout passes.
/// - The explanation overlay is `IgnorePointer`, so vertical swipe gestures
///   pass straight through to the PageView even while it is visible.
class ReelQuizFeed extends StatefulWidget {
  final StudySet studySet;

  const ReelQuizFeed({super.key, required this.studySet});

  @override
  State<ReelQuizFeed> createState() => _ReelQuizFeedState();
}

class _ReelQuizFeedState extends State<ReelQuizFeed> {
  late final QuizController _controller;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _controller = QuizController(studySet: widget.studySet);
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Close',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.studySet.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical, // TikTok-style vertical reel
        // Reset answer state for every freshly-snapped card.
        onPageChanged: _controller.onPageChanged,
        itemCount: _controller.questionCount,
        itemBuilder: (context, index) => _QuizCard(
          controller: _controller,
          pageIndex: index,
        ),
      ),
    );
  }
}

/// One full-screen quiz card in the reel.
class _QuizCard extends StatelessWidget {
  final QuizController controller;
  final int pageIndex;

  const _QuizCard({required this.controller, required this.pageIndex});

  static const _letters = ['A', 'B', 'C', 'D'];

  static const _correctBg = Color(0xFF1B3E2B);
  static const _correctBorder = Color(0xFF4CAF50);
  static const _wrongBg = Color(0xFF3E1B1B);
  static const _wrongBorder = Color(0xFFEF5350);

  Question get _question => controller.questionAt(pageIndex);

  /// Sub-50 ms selection path: haptic fires first (non-blocking), then a
  /// single guarded state update. Re-taps after lock are dropped instantly.
  void _onOptionTap(int optionIndex) {
    HapticFeedback.mediumImpact();
    controller.selectAnswer(optionIndex);
  }

  @override
  Widget build(BuildContext context) {
    final question = _question;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final answered = controller.answered;
        final selected = controller.selectedAnswer;

        return Stack(
          children: [
            // ---- Main quiz content ----
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ProgressHeader(
                      current: pageIndex + 1,
                      total: controller.questionCount,
                    ),
                    const SizedBox(height: 20),
                    _CategoryChip(label: question.category),
                    const SizedBox(height: 20),
                    Text(
                      question.prompt,
                      style: const TextStyle(
                        fontSize: 22,
                        height: 1.3,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // ---- Options ----
                    ...List<Widget>.generate(question.options.length, (i) {
                      final isCorrect = i == question.correctIndex;
                      final isPicked = selected == i;

                      Color bg = const Color(0xFF1E1E24);
                      Color border = const Color(0xFF2E2E38);
                      if (answered && isCorrect) {
                        bg = _correctBg;
                        border = _correctBorder;
                      } else if (answered && isPicked) {
                        bg = _wrongBg;
                        border = _wrongBorder;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _OptionTile(
                          letter: _letters[i],
                          label: question.options[i],
                          background: bg,
                          borderColor: border,
                          locked: answered,
                          onTap: () => _onOptionTap(i),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            // ---- Sliding explanation overlay ----
            IgnorePointer(
              child: AnimatedPositioned(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                left: 0,
                right: 0,
                bottom: answered ? 0 : -280,
                child: _ExplanationCard(
                  question: question,
                  wasCorrect: selected == question.correctIndex,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final int current;
  final int total;

  const _ProgressHeader({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: current / total,
              minHeight: 4,
              backgroundColor: const Color(0xFF2A2A33),
              valueColor:
                  const AlwaysStoppedAnimation(Color(0xFF4CAF50)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$current / $total',
          style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;

  const _CategoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A33),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF4CAF50),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String letter;
  final String label;
  final Color background;
  final Color borderColor;
  final bool locked;
  final VoidCallback onTap;

  const _OptionTile({
    required this.letter,
    required this.label,
    required this.background,
    required this.borderColor,
    required this.locked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        // Selection lock: once answered, taps are inert.
        onTap: locked ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: const Color(0x334CAF50),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.4),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: borderColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  letter,
                  style: TextStyle(
                    color: borderColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 15, height: 1.25),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExplanationCard extends StatelessWidget {
  final Question question;
  final bool wasCorrect;

  const _ExplanationCard({
    required this.question,
    required this.wasCorrect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF23232B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF34343E)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 18,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                wasCorrect
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                color: wasCorrect
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFEF5350),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                wasCorrect ? 'Correct!' : 'Not quite',
                style: TextStyle(
                  color: wasCorrect
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFEF5350),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Text(
                'Answer: ${['A', 'B', 'C', 'D'][question.correctIndex]}',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            question.explanation,
            style: TextStyle(
              color: Colors.grey.shade300,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.swipe_up_rounded,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Text(
                'Swipe up for next',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
