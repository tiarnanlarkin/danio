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
              'Minimum 10 gallons (40 litres) — bigger is always better. Heated to 78-82°F (25.6-27.8°C), filtered water. No bowls!',
        ),
        const LessonSection(
          type: LessonSectionType.warning,
          content:
              'Male bettas are aggressive to other males and long-finned fish. Keep one male per tank or choose a sorority of females.',
        ),
      ],
      quiz: Quiz(
        id: 'sc_betta_quiz',
        lessonId: 'sc_betta',
        questions: [
          const QuizQuestion(
            id: 'sc_betta_q1',
            question: 'What is the minimum recommended tank size for a betta?',
            options: [
              '1 gallon (a bowl)',
              '2.5 gallons',
              '5 gallons (19 litres)',
              '20 gallons',
            ],
            correctIndex: 2,
            explanation:
                'The minimum is 5 gallons (19 litres), with 10 gallons being ideal. Bettas need heated, filtered water — a bowl is not an appropriate home.',
          ),
          const QuizQuestion(
            id: 'sc_betta_q2',
            question: 'What temperature range do bettas need?',
            options: [
              '65-70°F (18-21°C)',
              '71-75°F (22-24°C)',
              '78-82°F (25.6-27.8°C)',
              '85-90°F (29-32°C)',
            ],
            correctIndex: 2,
            explanation:
                'Bettas are tropical fish that need warm water — 78-82°F (25.6-27.8°C). Room temperature is too cold for them.',
          ),
          const QuizQuestion(
            id: 'sc_betta_q3',
            question: 'What is true about betta fish in the wild?',
            options: [
              'They live in tiny puddles',
              'They inhabit rice paddies and slow streams',
              'They live in the ocean',
              'They only live in fast-moving rivers',
            ],
            correctIndex: 1,
            explanation:
                'Contrary to the myth, bettas don\'t live in puddles. In nature, they inhabit rice paddies, marshes, and slow-moving streams across Southeast Asia.',
          ),
          const QuizQuestion(
            id: 'sc_betta_q4',
            question: 'How should you house male bettas with other fish?',
            options: [
              'Multiple males together in a large tank',
              'One male per tank or a sorority of females',
              'Always keep them completely alone',
              'With any long-finned fish',
            ],
            correctIndex: 1,
            explanation:
                'Male bettas are aggressive to other males and may attack long-finned fish. Keep one male per tank or choose a carefully managed sorority of females.',
          ),
        ],
      ),
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
        questions: [
          const QuizQuestion(
            id: 'sc_gold_q1',
            question: 'How large can goldfish grow?',
            options: [
              '1-2 inches',
              '3-4 inches',
              '6-12 inches',
              '24 inches',
            ],
            correctIndex: 2,
            explanation:
                'Goldfish grow to 6-12 inches depending on variety. They\'re not small fish — commons and comets can reach 12+ inches and are really pond fish.',
          ),
          const QuizQuestion(
            id: 'sc_gold_q2',
            question: 'How long can goldfish live with proper care?',
            options: [
              '2-4 weeks',
              '1-2 years',
              '10-20 years',
              '50+ years',
            ],
            correctIndex: 2,
            explanation:
                'With proper care, goldfish live 10-20 years. The "dies in a week" myth comes from keeping them in tiny, unfiltered bowls.',
          ),
          const QuizQuestion(
            id: 'sc_gold_q3',
            question: 'How much tank space does the first fancy goldfish need?',
            options: [
              '5 gallons',
              '10 gallons',
              '20 gallons',
              '50 gallons',
            ],
            correctIndex: 2,
            explanation:
                'The first fancy goldfish needs 20 gallons, plus 10 additional gallons per extra fish. They produce a lot of waste and need powerful filtration.',
          ),
          const QuizQuestion(
            id: 'sc_gold_q4',
            question: 'What type of water do goldfish need?',
            options: [
              'Warm tropical water (80°F+)',
              'Coldwater — no heater needed',
              'Brackish water',
              'Very soft, acidic water',
            ],
            correctIndex: 1,
            explanation:
                'Goldfish are coldwater fish. They don\'t need a heater and actually prefer cooler temperatures than tropical fish.',
          ),
        ],
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
      quiz: Quiz(
        id: 'sc_tetras_quiz',
        lessonId: 'sc_tetras',
        questions: [
          const QuizQuestion(
            id: 'sc_tet_q1',
            question: 'What is the minimum group size for tetras?',
            options: [
              '1-2',
              '3-4',
              '6 or more',
              '10 or more',
            ],
            correctIndex: 2,
            explanation:
                'Tetras are schooling fish and need groups of at least 6 to feel secure and display natural behaviour. Smaller groups lead to stress and hiding.',
          ),
          const QuizQuestion(
            id: 'sc_tet_q2',
            question: 'Which of these are popular tetra species?',
            options: [
              'Neon, cardinal, ember, and black skirt',
              'Betta, gourami, and angelfish',
              'Oscar, discus, and ram',
              'Goldfish, koi, and oranda',
            ],
            correctIndex: 0,
            explanation:
                'Neon, cardinal, ember, and black skirt tetras are all popular, peaceful schooling fish great for community tanks.',
          ),
          const QuizQuestion(
            id: 'sc_tet_q3',
            question: 'What type of community fish are tetras?',
            options: [
              'Aggressive predators',
              'Large territorial cichlids',
              'Peaceful schooling fish',
              'Solitary bottom dwellers',
            ],
            correctIndex: 2,
            explanation:
                'Tetras are peaceful schooling fish that get along well with other community species. They\'re perfect for mixed community tanks.',
          ),
        ],
      ),
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
        questions: [
          const QuizQuestion(
            id: 'sc_cich_q1',
            question: 'What type of water do African cichlids need?',
            options: [
              'Soft, acidic water',
              'Hard, alkaline water',
              'Brackish water',
              'Pure RO water with no minerals',
            ],
            correctIndex: 1,
            explanation:
                'African cichlids (especially from Lake Malawi and Tanganyika) need hard, alkaline water. South American cichlids, by contrast, prefer softer, more acidic water.',
          ),
          const QuizQuestion(
            id: 'sc_cich_q2',
            question: 'What makes cichlids popular among fishkeepers?',
            options: [
              'They are the smallest aquarium fish',
              'They are the easiest fish to breed',
              'They have distinct personalities and interactive behaviour',
              'They never need feeding',
            ],
            correctIndex: 2,
            explanation:
                'Cichlids are known for their personality! They recognise their owners, display fascinating behaviours, and can be surprisingly interactive — making them rewarding to keep.',
          ),
          const QuizQuestion(
            id: 'sc_cich_q3',
            question: 'Why is it important to research specific cichlid species before buying?',
            options: [
              'All cichlids have identical care requirements',
              'Water chemistry, temperament, and size vary dramatically between species',
              'Cichlids are illegal in most countries',
              'They all need the same diet',
            ],
            correctIndex: 1,
            explanation:
                'Cichlids are incredibly diverse — from peaceful dwarf rams to aggressive Oscars. Water needs, temperament, tank size, and diet vary hugely between species and regions.',
          ),
        ],
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
      quiz: Quiz(
        id: 'sc_shrimp_quiz',
        lessonId: 'sc_shrimp',
        questions: [
          const QuizQuestion(
            id: 'sc_shrimp_q1',
            question: 'Which type of shrimp is considered hardy and breeds readily?',
            options: [
              'Crystal Red shrimp',
              'Cherry shrimp',
              'Amano shrimp',
              'Bamboo shrimp',
            ],
            correctIndex: 1,
            explanation:
                'Cherry shrimp (Neocaridina davidi) are the hardiest and most beginner-friendly. They adapt to a wide range of parameters and breed readily in established tanks.',
          ),
          const QuizQuestion(
            id: 'sc_shrimp_q2',
            question: 'What do more sensitive shrimp species like Crystal Reds require?',
            options: [
              'Brackish water',
              'Pristine water quality with specific parameters',
              'No filtration',
              'Extremely cold water',
            ],
            correctIndex: 1,
            explanation:
                'Crystal Red shrimp and other high-grade Caridina species need pristine water with very specific GH, KH, and pH. They\'re beautiful but not for beginners.',
          ),
          const QuizQuestion(
            id: 'sc_shrimp_q3',
            question: 'What secondary role do shrimp serve in a community tank?',
            options: [
              'They control the temperature',
              'They act as a cleanup crew eating algae and detritus',
              'They protect other fish from predators',
              'They oxygenate the water',
            ],
            correctIndex: 1,
            explanation:
                'Shrimp are excellent cleanup crew members — they graze on algae, biofilm, and uneaten food, helping keep the tank clean while being fascinating to watch.',
          ),
        ],
      ),
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
      quiz: Quiz(
        id: 'sc_snails_quiz',
        lessonId: 'sc_snails',
        questions: [
          const QuizQuestion(
            id: 'sc_snail_q1',
            question: 'Why are Nerite snails popular for algae control?',
            options: [
              'They reproduce very quickly',
              'They eat algae but cannot breed in freshwater',
              'They are the largest aquarium snails',
              'They eat other snails',
            ],
            correctIndex: 1,
            explanation:
                'Nerite snails are fantastic algae eaters, and since they need brackish water to breed, they won\'t overrun your freshwater tank — a perfect combination!',
          ),
          const QuizQuestion(
            id: 'sc_snail_q2',
            question: 'What should you be cautious about with Mystery snails?',
            options: [
              'They are venomous',
              'They can reproduce and may overrun your tank',
              'They eat live plants',
              'They attack fish',
            ],
            correctIndex: 1,
            explanation:
                'Mystery snails are beautiful and helpful, but unlike Nerites, they CAN reproduce in freshwater. Keep an eye on populations to prevent overbreeding.',
          ),
          const QuizQuestion(
            id: 'sc_snail_q3',
            question: 'What type of snails should you avoid introducing to your tank?',
            options: [
              'Nerite snails',
              'Mystery snails',
              'Pest snails (like bladder/pond snails)',
              'All snails without exception',
            ],
            correctIndex: 2,
            explanation:
                'Pest snails often hitchhike on plants and decorations. They multiply rapidly and can become a nuisance. Always inspect and quarantine new additions.',
          ),
        ],
      ),
    ),
  ],
);
