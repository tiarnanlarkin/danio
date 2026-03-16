/// Lesson content - Fish Health
/// Part of the lazy-loaded lesson system
library;

import '../../models/tank.dart';
import '../../models/learning.dart';
import '../../models/user_profile.dart';

final fishHealthPath = LearningPath(
  id: 'fish_health',
  title: 'Fish Health & Disease',
  description:
      'Prevent, identify, and treat common fish diseases. Keep your fish healthy!',
  emoji: '🏥',
  recommendedFor: [ExperienceLevel.intermediate],
  orderIndex: 6,
  lessons: [
    // Lesson 33: Disease Prevention 101
    Lesson(
      id: 'fh_prevention',
      pathId: 'fish_health',
      title: 'Disease Prevention 101',
      description: 'An ounce of prevention is worth a pound of cure',
      orderIndex: 0,
      xpReward: 50,
      estimatedMinutes: 5,
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Prevention is Key',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Most fish diseases are preventable! Sick fish are usually the result of poor water quality, stress, or poor nutrition - not bad luck.',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              '90% of fish disease is caused by stress. Eliminate stress sources and most problems disappear!',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'The Prevention Triangle',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• **Water Quality**: Test weekly, do water changes religiously\n• **Nutrition**: Varied diet, not just flakes\n• **Stress Reduction**: Proper tank mates, hiding spots, stable conditions',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'Quarantine new fish for 2-4 weeks before adding to your main tank. This prevents disease introduction and gives you time to observe!',
        ),
      ],
      quiz: Quiz(
        id: 'fh_prevention_quiz',
        lessonId: 'fh_prevention',
        questions: [
          const QuizQuestion(
            id: 'fh_prev_q1',
            question: 'What causes most fish disease?',
            options: [
              'Bad luck',
              'Stress and poor water quality',
              'Genetics',
              'Temperature',
            ],
            correctIndex: 1,
            explanation:
                'Stress weakens immune systems, making fish vulnerable. Fix the environment, not just the symptoms!',
          ),
        ],
      ),
    ),

    // Lessons 34-38 (condensed for space - would be fully expanded in production)
    Lesson(
      id: 'fh_ich',
      pathId: 'fish_health',
      title: 'Ich: The White Spot Killer',
      description: 'Identify and treat the most common fish disease',
      orderIndex: 1,
      xpReward: 50,
      estimatedMinutes: 6,
      sections: [
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Ich (Ichthyophthirius) looks like salt sprinkled on your fish. It\'s a parasite that attacks stressed fish.',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              'Ich has a 3-stage lifecycle. You can only kill it during the free-swimming stage!',
        ),
      ],
      quiz: Quiz(id: 'fh_ich_quiz', lessonId: 'fh_ich', questions: []),
    ),

    Lesson(
      id: 'fh_fin_rot',
      pathId: 'fish_health',
      title: 'Fin Rot & Bacterial Infections',
      description: 'Bacterial diseases and how to treat them',
      orderIndex: 2,
      xpReward: 50,
      estimatedMinutes: 5,
      sections: [
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Fin rot starts at edges and works inward. Caused by bacteria in poor water conditions.',
        ),
      ],
      quiz: Quiz(id: 'fh_finrot_quiz', lessonId: 'fh_fin_rot', questions: []),
    ),

    Lesson(
      id: 'fh_fungal',
      pathId: 'fish_health',
      title: 'Fungal Infections',
      description: 'Cotton-like growths and how to treat them',
      orderIndex: 3,
      xpReward: 50,
      estimatedMinutes: 5,
      sections: [
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Fungus looks like cotton balls on fish. Usually secondary to injury or stress.',
        ),
      ],
      quiz: Quiz(id: 'fh_fungal_quiz', lessonId: 'fh_fungal', questions: []),
    ),

    Lesson(
      id: 'fh_parasites',
      pathId: 'fish_health',
      title: 'Parasites: Identification & Treatment',
      description: 'Flukes, worms, and other freeloaders',
      orderIndex: 4,
      xpReward: 50,
      estimatedMinutes: 6,
      sections: [
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'External parasites cause flashing (rubbing), clamped fins, and rapid breathing.',
        ),
      ],
      quiz: Quiz(
        id: 'fh_parasites_quiz',
        lessonId: 'fh_parasites',
        questions: [],
      ),
    ),

    Lesson(
      id: 'fh_hospital_tank',
      pathId: 'fish_health',
      title: 'Hospital Tank Setup',
      description: 'Treat sick fish without harming your display tank',
      orderIndex: 5,
      xpReward: 50,
      estimatedMinutes: 5,
      sections: [
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'A hospital tank lets you medicate sick fish without harming beneficial bacteria or other tank mates.',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'Keep a 10-gallon tank with sponge filter ready. It\'s aquarium insurance!',
        ),
      ],
      quiz: Quiz(
        id: 'fh_hospital_quiz',
        lessonId: 'fh_hospital_tank',
        questions: [],
      ),
    ),
  ],
);
