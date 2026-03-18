/// Lesson content - Advanced Topics
/// Part of the lazy-loaded lesson system
library;

import '../../models/tank.dart';
import '../../models/learning.dart';
import '../../models/user_profile.dart';

final advancedTopicsPath = LearningPath(
  id: 'advanced_topics',
  title: 'Advanced Topics',
  description:
      'Master-level fishkeeping: breeding, aquascaping, and troubleshooting',
  emoji: '🎓',
  recommendedFor: [ExperienceLevel.expert],
  orderIndex: 8,
  lessons: [
    Lesson(
      id: 'at_breeding_livebearers',
      pathId: 'advanced_topics',
      title: 'Breeding Basics: Livebearers',
      description:
          'Guppies, mollies, and platies - easy first breeding projects',
      orderIndex: 0,
      xpReward: 75,
      estimatedMinutes: 7,
      sections: [
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Livebearers give birth to free-swimming fry (no eggs!). They\'re so easy they\'ll breed without any help from you.',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              'The challenge isn\'t breeding - it\'s keeping the fry alive! Provide hiding spots (plants) and feed micro foods.',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'Breeding box or nursery net protects fry from being eaten. Feed 3-4 times daily for fast growth.',
        ),
      ],
      quiz: Quiz(
        id: 'at_breeding_live_quiz',
        lessonId: 'at_breeding_livebearers',
        questions: [
          const QuizQuestion(
            id: 'at_live_q1',
            question: 'How do livebearers reproduce compared to most other fish?',
            options: [
              'They lay eggs on leaves',
              'They build bubble nests',
              'They give birth to free-swimming fry',
              'They mouthbrood their eggs',
            ],
            correctIndex: 2,
            explanation:
                'Livebearers like guppies, mollies, and platies give birth to live, free-swimming fry — no eggs involved!',
          ),
          const QuizQuestion(
            id: 'at_live_q2',
            question: 'What is the main challenge when breeding livebearers?',
            options: [
              'Getting them to breed',
              'Keeping the fry alive',
              'Maintaining water temperature',
              'Finding compatible pairs',
            ],
            correctIndex: 1,
            explanation:
                'The real challenge isn\'t breeding — they\'ll do that on their own! It\'s keeping the tiny fry alive by providing hiding spots and micro foods.',
          ),
          const QuizQuestion(
            id: 'at_live_q3',
            question: 'How often should you feed fry for optimal growth?',
            options: [
              'Once a day',
              'Twice a day',
              '3-4 times daily',
              'Once every other day',
            ],
            correctIndex: 2,
            explanation:
                'Feed fry 3-4 times daily with micro foods for fast, healthy growth. Small, frequent meals are much better than one large one.',
          ),
          const QuizQuestion(
            id: 'at_live_q4',
            question: 'What tool helps protect livebearer fry from being eaten by adults?',
            options: [
              'A UV steriliser',
              'A breeding box or nursery net',
              'A stronger filter',
              'A larger tank',
            ],
            correctIndex: 1,
            explanation:
                'A breeding box or nursery net separates fry from adult fish, giving them a safe space to grow until they\'re large enough to avoid being eaten.',
          ),
        ],
      ),
    ),

    Lesson(
      id: 'at_breeding_egg_layers',
      pathId: 'advanced_topics',
      title: 'Breeding: Egg Layers',
      description: 'From tetras to cichlids - raising egg-laying species',
      orderIndex: 1,
      xpReward: 75,
      estimatedMinutes: 8,
      sections: [
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Egg layers require more setup: spawning mops, caves, or flat stones depending on species. Water parameters must be perfect.',
        ),
        const LessonSection(
          type: LessonSectionType.warning,
          content:
              'Many fish eat their own eggs! Remove parents or use dividers after spawning.',
        ),
      ],
      quiz: Quiz(
        id: 'at_breeding_egg_quiz',
        lessonId: 'at_breeding_egg_layers',
        questions: [
          const QuizQuestion(
            id: 'at_egg_q1',
            question: 'What setup do egg-laying fish need for breeding?',
            options: [
              'A breeding box is always sufficient',
              'Spawning mops, caves, or flat stones depending on species',
              'No special setup needed',
              'A heater set to 35°C',
            ],
            correctIndex: 1,
            explanation:
                'Egg layers are species-specific — they need the right spawning surface: mops for scatterers, caves for cave spawners, flat stones for egg depositors.',
          ),
          const QuizQuestion(
            id: 'at_egg_q2',
            question: 'What should you do after egg-laying fish have spawned?',
            options: [
              'Leave the parents in to guard the eggs',
              'Remove the parents or use a divider to protect the eggs',
              'Immediately add medication to the water',
              'Turn off the filter',
            ],
            correctIndex: 1,
            explanation:
                'Many egg-laying fish eat their own eggs! Remove parents or use dividers after spawning to give the eggs a chance to develop.',
          ),
          const QuizQuestion(
            id: 'at_egg_q3',
            question: 'What must be perfect for egg layers to breed successfully?',
            options: [
              'Lighting duration',
              'Tank decoration colour',
              'Water parameters',
              'Number of tank mates',
            ],
            correctIndex: 2,
            explanation:
                'Water parameters (temperature, pH, hardness) must be spot-on for egg layers to trigger spawning. Different species have different requirements.',
          ),
        ],
      ),
    ),

    Lesson(
      id: 'at_aquascaping',
      pathId: 'advanced_topics',
      title: 'Aquascaping Fundamentals',
      description:
          'Create underwater landscapes using Iwagumi, Dutch, and Nature styles',
      orderIndex: 2,
      xpReward: 75,
      estimatedMinutes: 8,
      sections: [
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Aquascaping is underwater gardening. Use the rule of thirds, focal points, and layered depth to create stunning tanks.',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              'Iwagumi (stones), Dutch (plant streets), Nature (Takashi Amano style) - each has principles you can learn!',
        ),
      ],
      quiz: Quiz(
        id: 'at_aquascape_quiz',
        lessonId: 'at_aquascaping',
        questions: [
          const QuizQuestion(
            id: 'at_aqua_q1',
            question: 'What is aquascaping?',
            options: [
              'A method of filtering water with plants',
              'The art of creating underwater landscapes in an aquarium',
              'A technique for breeding fish with plants',
              'A type of fish feeding schedule',
            ],
            correctIndex: 1,
            explanation:
                'Aquascaping is underwater gardening — designing and creating beautiful landscapes using plants, rocks, wood, and other materials within an aquarium.',
          ),
          const QuizQuestion(
            id: 'at_aqua_q2',
            question: 'Which design principle is important in aquascaping?',
            options: [
              'Symmetrical layouts',
              'The rule of thirds and focal points',
              'Using as many plant species as possible',
              'Filling every inch of the tank',
            ],
            correctIndex: 1,
            explanation:
                'The rule of thirds and focal points create visual depth and balance. Like photography, placing key elements off-centre creates a more appealing composition.',
          ),
          const QuizQuestion(
            id: 'at_aqua_q3',
            question: 'Who is the famous aquascaper associated with the Nature style?',
            options: [
              'David Attenborough',
              'Takashi Amano',
              'Jacques Cousteau',
              'Steve Jobs',
            ],
            correctIndex: 1,
            explanation:
                'Takashi Amano pioneered the Nature style of aquascaping, creating stunning, natural-looking planted tanks that inspired the modern aquascaping movement.',
          ),
          const QuizQuestion(
            id: 'at_aqua_q4',
            question: 'What defines the Iwagumi aquascaping style?',
            options: [
              'Dense planted "streets" of plants',
              'A nature-style layout with wood and moss',
              'Stone-focused layouts with minimal plants',
              'A biotope recreation of a specific river',
            ],
            correctIndex: 2,
            explanation:
                'Iwagumi focuses on carefully arranged stones as the primary hardscape, with minimal, low-growing plants like carpet plants complementing the rockwork.',
          ),
        ],
      ),
    ),

    Lesson(
      id: 'at_biotope',
      pathId: 'advanced_topics',
      title: 'Biotope Aquariums',
      description: 'Recreate specific natural habitats accurately',
      orderIndex: 3,
      xpReward: 75,
      estimatedMinutes: 7,
      sections: [
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Biotope tanks recreate real locations: Amazon blackwater, Lake Malawi rift, Asian rice paddy. Only species from that location, matching water chemistry.',
        ),
        const LessonSection(
          type: LessonSectionType.funFact,
          content:
              'Biotope Aquarium Contests judge accuracy down to leaf litter species! Ultra-nerdy but beautiful.',
        ),
      ],
      quiz: Quiz(
        id: 'at_biotope_quiz',
        lessonId: 'at_biotope',
        questions: [
          const QuizQuestion(
            id: 'at_bio_q1',
            question: 'What is a biotope aquarium?',
            options: [
              'Any planted tank with fish and plants',
              'A tank that recreates a specific natural habitat with matching species and water chemistry',
              'A tank with artificial decorations',
              'A brackish water tank',
            ],
            correctIndex: 1,
            explanation:
                'Biotope tanks recreate real natural locations — only using species and water chemistry from that specific habitat.',
          ),
          const QuizQuestion(
            id: 'at_bio_q2',
            question: 'Which of these is an example of a biotope setup?',
            options: [
              'A community tank with fish from different continents',
              'Amazon blackwater with only South American species',
              'A reef tank with coral and clownfish',
              'A goldfish bowl with a plant',
            ],
            correctIndex: 1,
            explanation:
                'An Amazon blackwater biotope uses only species, water chemistry, and materials from that specific South American ecosystem.',
          ),
          const QuizQuestion(
            id: 'at_bio_q3',
            question: 'In biotope contests, what level of detail is judged?',
            options: [
              'Only the fish species',
              'Only the water parameters',
              'Accuracy down to leaf litter species',
              'Only the overall appearance',
            ],
            correctIndex: 2,
            explanation:
                'Biotope Aquarium Contests judge accuracy down to leaf litter species! It\'s a meticulous art form that values scientific accuracy as much as beauty.',
          ),
        ],
      ),
    ),

    Lesson(
      id: 'at_troubleshooting',
      pathId: 'advanced_topics',
      title: 'Troubleshooting: Emergency Guide',
      description: 'Fix crashes, spikes, and disasters fast',
      orderIndex: 4,
      xpReward: 75,
      estimatedMinutes: 9,
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'When Things Go Wrong',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Ammonia spike? 50% water change immediately. Cloudy water? Test parameters first - could be bacterial bloom (harmless) or ammonia (deadly).',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              'Never panic-clean! Gradual changes are safer than drastic ones. Test, then act.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• **Ammonia spike:** 50% water change + stop feeding\n• **Algae bloom:** Reduce light to 6 hours\n• **Cloudy water:** Test first, usually resolves in days\n• **Dead fish:** Remove immediately, test water, check tank mates',
        ),
      ],
      quiz: Quiz(
        id: 'at_trouble_quiz',
        lessonId: 'at_troubleshooting',
        questions: [
          const QuizQuestion(
            id: 'at_trouble_q1',
            question: 'What should you do FIRST in response to an ammonia spike?',
            options: [
              'Add medication',
              'Do a 50% water change immediately and stop feeding',
              'Turn off the filter',
              'Add more fish to dilute the ammonia',
            ],
            correctIndex: 1,
            explanation:
                'A 50% water change dilutes toxic ammonia immediately. Stopping feeding reduces waste production. Never add more fish to an ammonia crisis!',
          ),
          const QuizQuestion(
            id: 'at_trouble_q2',
            question: 'What should you do when your tank water is cloudy?',
            options: [
              'Do a 100% water change and replace all water',
              'Add chemicals to clear the water',
              'Test parameters first — it could be a harmless bacterial bloom',
              'Turn off all equipment',
            ],
            correctIndex: 2,
            explanation:
                'Cloudy water could be a harmless bacterial bloom (which resolves on its own) or a deadly ammonia spike. Always test before taking action.',
          ),
          const QuizQuestion(
            id: 'at_trouble_q3',
            question: 'If you have an algae bloom, what should you do?',
            options: [
              'Add more fertiliser',
              'Reduce lighting to 6 hours per day',
              'Do nothing and wait',
              'Replace all the water',
            ],
            correctIndex: 1,
            explanation:
                'Reducing light duration to 6 hours starves algae of the light it needs to grow. This is often the simplest and most effective fix.',
          ),
          const QuizQuestion(
            id: 'at_trouble_q4',
            question: 'Why should you "never panic-clean" your aquarium?',
            options: [
              'It takes too much time',
              'Gradual changes are safer than drastic ones for fish',
              'It makes the water too clean',
              'It removes all the algae fish need',
            ],
            correctIndex: 1,
            explanation:
                'Drastic changes can shock fish and crash the nitrogen cycle. Test first, then make gradual corrections. Slow and steady saves fish.',
          ),
        ],
      ),
    ),

    Lesson(
      id: 'at_water_chem',
      pathId: 'advanced_topics',
      title: 'Advanced Water Chemistry',
      description: 'Master GH, KH, TDS, and buffering capacity',
      orderIndex: 5,
      xpReward: 75,
      estimatedMinutes: 10,
      sections: [
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Beyond pH: GH (hardness) measures calcium/magnesium, KH (alkalinity) is buffering capacity, TDS is total dissolved solids. Each matters for different species.',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              'Stable water > perfect water. Don\'t chase numbers if fish are thriving. Match fish to your water, not water to random fish.',
        ),
      ],
      quiz: Quiz(
        id: 'at_chem_quiz',
        lessonId: 'at_water_chem',
        questions: [
          const QuizQuestion(
            id: 'at_chem_q1',
            question: 'What does GH (General Hardness) measure?',
            options: [
              'The pH level of the water',
              'Calcium and magnesium levels',
              'Buffering capacity',
              'Total dissolved ammonia',
            ],
            correctIndex: 1,
            explanation:
                'GH measures the concentration of calcium and magnesium ions. It affects fish health, breeding, and which species thrive in your water.',
          ),
          const QuizQuestion(
            id: 'at_chem_q2',
            question: 'What is KH (carbonate hardness) responsible for?',
            options: [
              'Making water harder for fish to breathe',
              'Buffering capacity — stabilising pH against changes',
              'Removing chlorine from tap water',
              'Measuring dissolved oxygen',
            ],
            correctIndex: 1,
            explanation:
                'KH is your water\'s buffering capacity. Higher KH means pH is more stable and resistant to swings. Low KH can lead to dangerous pH crashes.',
          ),
          const QuizQuestion(
            id: 'at_chem_q3',
            question: 'What does TDS stand for and what does it measure?',
            options: [
              'Total Dissolved Solids — all dissolved substances in water',
              'Temperature Dissolved Salt — water salinity',
              'Tank Disease Score — bacterial levels',
              'Total Daily Surface — water evaporation rate',
            ],
            correctIndex: 0,
            explanation:
                'TDS (Total Dissolved Solids) measures everything dissolved in your water — minerals, organics, and more. Useful for monitoring water quality over time.',
          ),
          const QuizQuestion(
            id: 'at_chem_q4',
            question: 'What is more important for fish health?',
            options: [
              'Having perfect water parameters that constantly change',
              'Having stable water even if it\'s not "textbook" perfect',
              'Matching pH to 7.0 exactly',
              'Using RO water for every tank',
            ],
            correctIndex: 1,
            explanation:
                'Stable water is far better than perfect-but-fluctuating water. Match fish to your tap water rather than chasing ideal numbers with constant adjustments.',
          ),
        ],
      ),
    ),
  ],
);
