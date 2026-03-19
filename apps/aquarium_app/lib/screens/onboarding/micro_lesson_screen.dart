import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/user_profile.dart';
import '../../theme/app_theme.dart';

/// Screen 4 — Micro-Lesson: "The #1 Mistake"
///
/// Interactive lesson with a quiz question. Content variant is driven by
/// [experienceLevel]: beginner/intermediate get the nitrogen-cycle lesson,
/// expert gets the compatibility lesson.
///
/// Communicates completion via [onComplete].
class MicroLessonScreen extends StatefulWidget {
  final ExperienceLevel experienceLevel;
  final VoidCallback onComplete;

  const MicroLessonScreen({
    super.key,
    required this.experienceLevel,
    required this.onComplete,
  });

  @override
  State<MicroLessonScreen> createState() => _MicroLessonScreenState();
}

class _MicroLessonScreenState extends State<MicroLessonScreen>
    with TickerProviderStateMixin {
  int? _selectedAnswer;
  bool _answered = false;

  late final AnimationController _gotItController;
  late final CurvedAnimation _gotItOpacityCurve;
  late final Animation<double> _gotItOpacity;
  late final CurvedAnimation _gotItSlideCurve;
  late final Animation<Offset> _gotItSlide;

  AnimationController? _correctBounceController;
  CurvedAnimation? _correctBounceCurve;
  Animation<double>? _correctBounceScale;

  bool get _isAdvanced => widget.experienceLevel == ExperienceLevel.expert;
  int get _correctIndex => _isAdvanced ? 0 : 1;

  late final _LessonContent _content;

  @override
  void initState() {
    super.initState();

    _content = _isAdvanced ? _advancedContent : _beginnerContent;

    _gotItController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _gotItOpacityCurve = CurvedAnimation(
      parent: _gotItController,
      curve: AppCurves.standardDecelerate,
    );
    _gotItOpacity = _gotItOpacityCurve;
    _gotItSlideCurve = CurvedAnimation(
      parent: _gotItController,
      curve: AppCurves.standardDecelerate,
    );
    _gotItSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(_gotItSlideCurve);

    _correctBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _correctBounceCurve = CurvedAnimation(
      parent: _correctBounceController!,
      curve: Curves.easeOutBack,
    );
    _correctBounceScale = Tween<double>(begin: 1.0, end: 1.1).animate(_correctBounceCurve!);
  }

  @override
  void dispose() {
    _gotItOpacityCurve.dispose();
    _gotItSlideCurve.dispose();
    _gotItController.dispose();
    _correctBounceCurve?.dispose();
    _correctBounceController?.dispose();
    super.dispose();
  }

  void _onAnswerTap(int index) {
    if (_answered) return;

    HapticFeedback.lightImpact();
    setState(() {
      _selectedAnswer = index;
      _answered = true;
    });

    final reduceMotion = MediaQuery.of(context).disableAnimations;

    // Bounce the correct answer
    if (!reduceMotion) {
      _correctBounceController?.forward();
    }

    // Show "Got it" button after a short delay
    final delay = reduceMotion ? Duration.zero : const Duration(milliseconds: 200);
    Future.delayed(delay, () {
      if (mounted) {
        if (reduceMotion) {
          _gotItController.value = 1.0;
        } else {
          _gotItController.forward();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.onboardingWarmCream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),

              // Progress dots — dot 3 filled
              _ProgressDots(currentIndex: 2),

              const SizedBox(height: AppSpacing.lg),

              // Lesson badge
              Align(
                alignment: Alignment.centerLeft,
                child: ExcludeSemantics(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm2,
                      vertical: AppSpacing.xs2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.onboardingAmber.withAlpha(38), // ~15%
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      'Quick Lesson · 30 seconds',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Headline
              Semantics(
                header: true,
                child: Text(
                  _content.headline,
                  style: GoogleFonts.lora(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Body paragraphs
              ..._content.bodyParagraphs.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm2),
                    child: Text(
                      p,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary,
                        height: 1.6,
                      ),
                    ),
                  )),

              const SizedBox(height: AppSpacing.lg),

              // Question
              Text(
                _content.question,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Answer tiles
              ...List.generate(_content.answers.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _buildAnswerTile(i),
                );
              }),

              // Feedback text
              if (_answered) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  _selectedAnswer == _correctIndex
                      ? _content.correctFeedback
                      : _content.wrongFeedback,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.lg),

              // "Got it →" button (appears after answering)
              SlideTransition(
                position: _gotItSlide,
                child: FadeTransition(
                  opacity: _gotItOpacity,
                  child: Semantics(
                    button: true,
                    label: 'Got it',
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _answered
                            ? () {
                                HapticFeedback.mediumImpact();
                                widget.onComplete();
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.onboardingAmber,
                          foregroundColor: AppColors.textPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.lg),
                          ),
                          textStyle: GoogleFonts.nunito(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('Got it →'),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerTile(int index) {
    final answer = _content.answers[index];
    final isCorrect = index == _correctIndex;
    final isSelected = _selectedAnswer == index;

    Color bgColor;
    Color borderColor;
    Color textColor = AppColors.textPrimary;
    Widget? trailing;

    if (!_answered) {
      bgColor = AppColors.card;
      borderColor = AppColors.border;
    } else if (isCorrect) {
      bgColor = AppColors.successAlpha10;
      borderColor = AppColors.success;
      trailing = const Text('✓', style: TextStyle(fontSize: 20, color: AppColors.success));
    } else if (isSelected && !isCorrect) {
      bgColor = AppColors.surfaceVariant;
      borderColor = AppColors.border;
      textColor = AppColors.textSecondary;
      trailing = const Text('✗', style: TextStyle(fontSize: 20, color: AppColors.error));
    } else {
      bgColor = AppColors.surfaceVariant;
      borderColor = AppColors.border;
      textColor = AppColors.textSecondary;
    }

    Widget tile = Semantics(
      button: !_answered,
      label: answer.label,
      child: GestureDetector(
        onTap: !_answered ? () => _onAnswerTap(index) : null,
        child: AnimatedContainer(
          duration: AppDurations.medium1,
          curve: AppCurves.standard,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm2,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppRadius.md2),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              ExcludeSemantics(
                child: Text(
                  answer.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: AppSpacing.sm2),
              Expanded(
                child: Text(
                  answer.label,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );

    // Bounce animation on the correct answer when revealed
    if (_answered && isCorrect && _correctBounceScale != null) {
      tile = ScaleTransition(
        scale: _correctBounceScale!,
        child: tile,
      );
    }

    return tile;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Content data
// ─────────────────────────────────────────────────────────────────────────────

class _AnswerOption {
  final String emoji;
  final String label;

  const _AnswerOption({required this.emoji, required this.label});
}

class _LessonContent {
  final String headline;
  final List<String> bodyParagraphs;
  final String question;
  final List<_AnswerOption> answers;
  final String correctFeedback;
  final String wrongFeedback;

  const _LessonContent({
    required this.headline,
    required this.bodyParagraphs,
    required this.question,
    required this.answers,
    required this.correctFeedback,
    required this.wrongFeedback,
  });
}

const _beginnerContent = _LessonContent(
  headline: 'The #1 mistake that kills fish',
  bodyParagraphs: [
    "Most fish don't die from illness. They die from water that looks perfectly clean but isn't.",
    'New tanks need time to grow the invisible bacteria that make water safe. Skip this step and even the hardiest fish will struggle.',
    "It's called the nitrogen cycle — and it's the one thing worth getting right from the start.",
  ],
  question: 'Why do most beginner fish die in the first few weeks?',
  answers: [
    _AnswerOption(emoji: '🍽️', label: 'Overfeeding'),
    _AnswerOption(emoji: '💧', label: 'Uncycled water'),
    _AnswerOption(emoji: '🌡️', label: 'Wrong temperature'),
  ],
  correctFeedback:
      'Exactly right. Ammonia from fish waste builds up in new tanks before good bacteria arrive to neutralise it. Danio will help you track this.',
  wrongFeedback:
      "Actually, uncycled water is the most common culprit — but overfeeding and temperature matter too. We'll cover all of it.",
);

const _advancedContent = _LessonContent(
  headline: 'A common mistake even experienced keepers make',
  bodyParagraphs: [
    "Cross-species compatibility is the issue most keepers underestimate — even after years in the hobby.",
    "Aggression, water parameter overlap, and bioload all interact in ways that aren't obvious from individual species cards.",
    'Danio builds a compatibility map for your specific tank.',
  ],
  question: "What's the most underestimated cause of aggression in community tanks?",
  answers: [
    _AnswerOption(emoji: '🐠', label: 'Species mismatch'),
    _AnswerOption(emoji: '🏠', label: 'Tank size'),
    _AnswerOption(emoji: '🍽️', label: 'Feeding competition'),
  ],
  correctFeedback:
      "Right. Same-species aggression, fin-nipping species, and territory issues cause more problems than most keepers expect.",
  wrongFeedback:
      'Tank size matters, but species mismatch — including same-species aggression and incompatible temperaments — is the most common root cause.',
);

// ─────────────────────────────────────────────────────────────────────────────
// Progress dots (consistent with other screens)
// ─────────────────────────────────────────────────────────────────────────────

class _ProgressDots extends StatelessWidget {
  final int currentIndex;

  const _ProgressDots({required this.currentIndex});


  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Step ${currentIndex + 1} of 3',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          final isFilled = i <= currentIndex;
          return Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFilled ? AppColors.onboardingAmber : AppColors.border,
            ),
          );
        }),
      ),
    );
  }
}
