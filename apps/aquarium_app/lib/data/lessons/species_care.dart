/// Lesson content - Species Care
/// Part of the lazy-loaded lesson system
library;

import '../../models/tank.dart';
import '../../models/learning.dart';
import '../../models/user_profile.dart';

final speciesCarePath = LearningPath(
  id: 'species_care',
  title: 'Species-Specific Care',
  description: 'Deep dives into popular fish species and their unique needs',
  emoji: '🐠',
  recommendedFor: [ExperienceLevel.beginner, ExperienceLevel.intermediate],
  orderIndex: 7,
  lessons: [
    Lesson(
      id: 'sc_betta',
      pathId: 'species_care',
      title: 'Betta Fish Care',
      description:
          'The beautiful Siamese fighting fish - more than just a cup fish!',
      orderIndex: 0,
      xpReward: 50,
      estimatedMinutes: 6,
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'The Betta Truth',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Bettas don\'t live in puddles! In nature, they inhabit rice paddies and slow streams. They need space, filtration, and warm water like any tropical fish.',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              'Minimum 5 gallons (19 litres), 10 gallons is ideal, heated to 78-82°F (25.6-27.8°C), filtered water. No bowls!',
        ),
        const LessonSection(
          type: LessonSectionType.warning,
          content:
              'Male bettas are aggressive to other males and long-finned fish. Keep one male per tank or choose a sorority of females.',
        ),
      ],
      quiz: Quiz(id: 'sc_betta_quiz', lessonId: 'sc_betta', questions: []),
    ),

    Lesson(
      id: 'sc_goldfish',
      pathId: 'species_care',
      title: 'Goldfish: The Misunderstood Fish',
      description: 'Goldfish are NOT beginner fish - they\'re messy giants!',
      orderIndex: 1,
      xpReward: 50,
      estimatedMinutes: 6,
      sections: [
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Goldfish grow to 6-12 inches and live 10-20 years (not 2 weeks!). They\'re coldwater fish that need huge tanks and powerful filtration.',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              '20 gallons for the first fancy goldfish, +10 gallons per additional fish. Commons and comets are pond fish that grow to 12"+ and should not be kept in typical home aquariums.',
        ),
      ],
      quiz: Quiz(
        id: 'sc_goldfish_quiz',
        lessonId: 'sc_goldfish',
        questions: [],
      ),
    ),

    Lesson(
      id: 'sc_tetras',
      pathId: 'species_care',
      title: 'Tetras: Community Tank Stars',
      description: 'Peaceful schooling fish perfect for community tanks',
      orderIndex: 2,
      xpReward: 50,
      estimatedMinutes: 5,
      sections: [
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Tetras are peaceful schoolers that need groups of 6+. Neon, cardinal, ember, and black skirt tetras are all excellent choices.',
        ),
      ],
      quiz: Quiz(id: 'sc_tetras_quiz', lessonId: 'sc_tetras', questions: []),
    ),

    Lesson(
      id: 'sc_cichlids',
      pathId: 'species_care',
      title: 'Cichlids: Personality Fish',
      description: 'From peaceful Rams to aggressive Oscars',
      orderIndex: 3,
      xpReward: 50,
      estimatedMinutes: 6,
      sections: [
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Cichlids have personality! African cichlids need hard water, South American need soft. Research your specific species.',
        ),
      ],
      quiz: Quiz(
        id: 'sc_cichlids_quiz',
        lessonId: 'sc_cichlids',
        questions: [],
      ),
    ),

    Lesson(
      id: 'sc_shrimp',
      pathId: 'species_care',
      title: 'Shrimp Keeping',
      description: 'Tiny cleanup crew with surprising complexity',
      orderIndex: 4,
      xpReward: 50,
      estimatedMinutes: 5,
      sections: [
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Cherry shrimp are hardy and breed readily. More sensitive species like Crystal Red require pristine water.',
        ),
      ],
      quiz: Quiz(id: 'sc_shrimp_quiz', lessonId: 'sc_shrimp', questions: []),
    ),

    Lesson(
      id: 'sc_snails',
      pathId: 'species_care',
      title: 'Snails: Cleanup Crew',
      description:
          'Algae eaters that won\'t overrun your tank (if chosen right!)',
      orderIndex: 5,
      xpReward: 50,
      estimatedMinutes: 5,
      sections: [
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Nerite snails eat algae but can\'t breed in freshwater. Mystery snails are beautiful but can reproduce. Avoid pest snails!',
        ),
      ],
      quiz: Quiz(id: 'sc_snails_quiz', lessonId: 'sc_snails', questions: []),
    ),
  ],
);
