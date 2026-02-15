import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import 'first_tank_wizard_screen.dart';

/// Experience assessment quiz to personalize onboarding
class ExperienceAssessmentScreen extends StatefulWidget {
  const ExperienceAssessmentScreen({super.key});

  @override
  State<ExperienceAssessmentScreen> createState() =>
      _ExperienceAssessmentScreenState();
}

class _ExperienceAssessmentScreenState
    extends State<ExperienceAssessmentScreen> {
  int _currentQuestion = 0;
  final Map<int, String> _answers = {};
  ExperienceLevel? _determinedLevel;

  final List<_AssessmentQuestion> _questions = const [
    _AssessmentQuestion(
      question: 'Have you kept fish before?',
      options: {
        'never': 'Never - this is my first time!',
        'past': 'Yes, but it\'s been a while',
        'current': 'Yes, I have fish right now',
        'expert': 'Yes, for many years',
      },
    ),
    _AssessmentQuestion(
      question: 'How familiar are you with water parameters?',
      options: {
        'never': 'What are those?',
        'basic': 'I know pH and maybe temperature',
        'intermediate': 'pH, ammonia, nitrites, nitrates',
        'expert': 'I could write a book on water chemistry',
      },
    ),
    _AssessmentQuestion(
      question: 'What type of tank interests you most?',
      options: {
        'beginner': 'Small freshwater (betta, guppies)',
        'intermediate': 'Community tank with variety',
        'advanced': 'Planted aquascape or cichlid biotope',
        'expert': 'Reef tank or breeding project',
      },
    ),
    _AssessmentQuestion(
      question: 'How often can you dedicate time to tank maintenance?',
      options: {
        'minimal': 'A few minutes per week',
        'basic': '15-30 minutes per week',
        'regular': '1-2 hours per week',
        'dedicated': 'Several hours - this is my hobby!',
      },
    ),
  ];

  ExperienceLevel _calculateLevel() {
    if (_answers.isEmpty) return ExperienceLevel.beginner;

    int neverCount = 0;
    int basicCount = 0;
    int intermediateCount = 0;
    int expertCount = 0;

    for (final answer in _answers.values) {
      if (answer.contains('never') ||
          answer == 'beginner' ||
          answer == 'minimal') {
        neverCount++;
      } else if (answer.contains('basic') || answer == 'past') {
        basicCount++;
      } else if (answer.contains('intermediate') ||
          answer == 'current' ||
          answer == 'regular') {
        intermediateCount++;
      } else if (answer.contains('expert') ||
          answer == 'advanced' ||
          answer == 'dedicated') {
        expertCount++;
      }
    }

    // Determine level based on predominant answers
    if (expertCount >= 2) return ExperienceLevel.expert;
    if (intermediateCount >= 2) return ExperienceLevel.intermediate;
    if (basicCount >= 2 || (basicCount >= 1 && neverCount <= 1)) {
      return ExperienceLevel.beginner;
    }
    return ExperienceLevel.beginner;
  }

  String _getRecommendation(ExperienceLevel level) {
    switch (level) {
      case ExperienceLevel.beginner:
        return 'Perfect! We\'ll start you with the basics and guide you step-by-step.';
      case ExperienceLevel.intermediate:
        return 'Great! We\'ll help you refine your skills and explore new techniques.';
      case ExperienceLevel.expert:
        return 'Awesome! We\'ll focus on advanced topics and help you track your projects.';
    }
  }

  List<String> _getRecommendedPaths(ExperienceLevel level) {
    switch (level) {
      case ExperienceLevel.beginner:
        return [
          'Aquarium Basics',
          'The Nitrogen Cycle',
          'First Fish Selection',
          'Water Parameters 101',
        ];
      case ExperienceLevel.intermediate:
        return [
          'Advanced Filtration',
          'Community Tank Dynamics',
          'Live Plants Basics',
          'Disease Prevention',
        ];
      case ExperienceLevel.expert:
        return [
          'Breeding Techniques',
          'Aquascaping Masterclass',
          'Advanced Water Chemistry',
          'Biotope Design',
        ];
    }
  }

  void _nextQuestion() {
    if (_currentQuestion < _questions.length - 1) {
      setState(() => _currentQuestion++);
    } else {
      setState(() {
        _determinedLevel = _calculateLevel();
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestion > 0) {
      setState(() => _currentQuestion--);
    }
  }

  void _selectAnswer(String key) {
    setState(() {
      _answers[_currentQuestion] = key;
    });
    // Auto-advance after selection (with small delay for visual feedback)
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _nextQuestion();
    });
  }

  void _startJourney() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            FirstTankWizardScreen(experienceLevel: _determinedLevel!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_determinedLevel != null) {
      return _buildResultScreen();
    }

    final question = _questions[_currentQuestion];
    final progress = (_currentQuestion + 1) / _questions.length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.xl),

                    // Question counter
                    Text(
                      'Question ${_currentQuestion + 1} of ${_questions.length}',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Question
                    Text(
                      question.question,
                      style: AppTypography.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Options
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          final optionsList = question.options.entries.toList();
                          return ListView.builder(
                            itemCount: optionsList.length,
                            itemBuilder: (context, index) {
                              final entry = optionsList[index];
                              final isSelected =
                                  _answers[_currentQuestion] == entry.key;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => _selectAnswer(entry.key),
                                    borderRadius: AppRadius.mediumRadius,
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.border,
                                          width: 2,
                                        ),
                                        borderRadius: AppRadius.mediumRadius,
                                        color: isSelected
                                            ? AppOverlays.primary10
                                            : AppColors.surface,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              entry.value,
                                              style: AppTypography.bodyLarge
                                                  .copyWith(
                                                    color: isSelected
                                                        ? AppColors.primary
                                                        : AppColors.textPrimary,
                                                    fontWeight: isSelected
                                                        ? FontWeight.w600
                                                        : FontWeight.normal,
                                                  ),
                                            ),
                                          ),
                                          if (isSelected)
                                            Icon(
                                              Icons.check_circle,
                                              color: AppColors.primary,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),

                    // Navigation
                    if (_currentQuestion > 0)
                      OutlinedButton(
                        onPressed: _previousQuestion,
                        child: const Text('Back'),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    final level = _determinedLevel!;
    final recommendation = _getRecommendation(level);
    final paths = _getRecommendedPaths(level);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // Celebration icon
              Icon(
                Icons.celebration_rounded,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Level badge
              Text(
                _getLevelName(level),
                style: AppTypography.headlineLarge.copyWith(
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),

              // Recommendation
              Text(
                recommendation,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Recommended learning paths
              Text(
                'We recommend starting with:',
                style: AppTypography.titleMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              ...paths.map(
                (path) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.school_rounded,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(path, style: AppTypography.bodyMedium),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Continue button
              ElevatedButton(
                onPressed: _startJourney,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Start My Journey!'),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  String _getLevelName(ExperienceLevel level) {
    switch (level) {
      case ExperienceLevel.beginner:
        return '🐟 Beginner Aquarist';
      case ExperienceLevel.intermediate:
        return '🐠 Experienced Keeper';
      case ExperienceLevel.expert:
        return '🦈 Aquarium Expert';
    }
  }
}

class _AssessmentQuestion {
  final String question;
  final Map<String, String> options;

  const _AssessmentQuestion({required this.question, required this.options});
}
