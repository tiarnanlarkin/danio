import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/learning.dart';
import '../models/spaced_repetition.dart';
import '../providers/lesson_provider.dart';
import '../providers/spaced_repetition_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/core/app_button.dart';
import '../widgets/core/bubble_loader.dart';
import 'lesson/lesson_quiz_widget.dart';
import 'spaced_repetition_practice/spaced_repetition_practice_screen.dart';

class DebugQaLessonQuizScreen extends ConsumerStatefulWidget {
  final String state;
  final String pathId;

  const DebugQaLessonQuizScreen({
    super.key,
    required this.state,
    this.pathId = 'nitrogen_cycle',
  });

  @override
  ConsumerState<DebugQaLessonQuizScreen> createState() =>
      _DebugQaLessonQuizScreenState();
}

class _DebugQaLessonQuizScreenState
    extends ConsumerState<DebugQaLessonQuizScreen> {
  late final Future<Lesson> _lessonFuture;
  bool _showHint = false;
  int? _selectedAnswer;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _lessonFuture = Future<Lesson>(_loadLesson);
  }

  Future<Lesson> _loadLesson() async {
    await ref.read(lessonProvider.notifier).loadPath(widget.pathId);
    final path = ref.read(lessonProvider).getPath(widget.pathId);
    if (path == null) {
      throw StateError('QA path not found: ${widget.pathId}');
    }

    for (final lesson in path.lessons) {
      if (lesson.quiz != null && lesson.quiz!.questions.isNotEmpty) {
        final question = lesson.quiz!.questions.first;
        if (widget.state == 'selected-correct') {
          _selectedAnswer = question.correctIndex;
          _answered = true;
        }
        return lesson;
      }
    }

    throw StateError('QA path has no quiz lessons: ${widget.pathId}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QA Lesson Quiz')),
      body: FutureBuilder<Lesson>(
        future: _lessonFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: BubbleLoader());
          }
          if (snapshot.hasError) {
            return _DebugQaError(message: '${snapshot.error}');
          }

          final lesson = snapshot.requireData;
          return LessonQuizWidget(
            lesson: lesson,
            isPracticeMode: false,
            currentQuizQuestion: 0,
            correctAnswers: _answered ? 1 : 0,
            selectedAnswer: _selectedAnswer,
            answered: _answered,
            showHint: _showHint,
            forceShowHintControls: true,
            onSelectAnswer: (index) {
              setState(() {
                _selectedAnswer = index;
              });
            },
            onShowHint: () {
              setState(() {
                _showHint = true;
              });
            },
            onCheckOrAdvance:
                ({
                  required selectedAnswer,
                  required isCorrect,
                  required isLastQuestion,
                }) async {
                  setState(() {
                    _answered = true;
                  });
                },
          );
        },
      ),
    );
  }
}

class DebugQaPracticeSessionScreen extends ConsumerStatefulWidget {
  final String pathId;

  const DebugQaPracticeSessionScreen({
    super.key,
    this.pathId = 'nitrogen_cycle',
  });

  @override
  ConsumerState<DebugQaPracticeSessionScreen> createState() =>
      _DebugQaPracticeSessionScreenState();
}

class _DebugQaPracticeSessionScreenState
    extends ConsumerState<DebugQaPracticeSessionScreen> {
  late final Future<void> _seedFuture;

  @override
  void initState() {
    super.initState();
    _seedFuture = Future<void>(_seedAndStart);
  }

  Future<void> _seedAndStart() async {
    final lessonNotifier = ref.read(lessonProvider.notifier);
    await lessonNotifier.loadPath(widget.pathId);

    final path = ref.read(lessonProvider).getPath(widget.pathId);
    if (path == null) {
      throw StateError('QA path not found: ${widget.pathId}');
    }

    Lesson? lessonWithQuiz;
    for (final lesson in path.lessons) {
      if (lesson.quiz != null && lesson.quiz!.questions.isNotEmpty) {
        lessonWithQuiz = lesson;
        break;
      }
    }
    if (lessonWithQuiz == null) {
      throw StateError('QA path has no quiz lessons: ${widget.pathId}');
    }

    final srNotifier = ref.read(spacedRepetitionProvider.notifier);
    await srNotifier.resetAll();
    await srNotifier.createCard(
      conceptId: '${lessonWithQuiz.id}_quiz_q0',
      conceptType: ConceptType.quizQuestion,
    );
    await srNotifier.startSession(mode: ReviewSessionMode.standard);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _seedFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(title: const Text('QA Practice Session')),
            body: const Center(child: BubbleLoader()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('QA Practice Session')),
            body: _DebugQaError(message: '${snapshot.error}'),
          );
        }
        return const SpacedRepetitionPracticeScreen();
      },
    );
  }
}

class _DebugQaError extends StatelessWidget {
  final String message;

  const _DebugQaError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Close',
              onPressed: () => Navigator.of(context).maybePop(),
              variant: AppButtonVariant.secondary,
            ),
          ],
        ),
      ),
    );
  }
}
