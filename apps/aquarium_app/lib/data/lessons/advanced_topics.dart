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
          questions: [],
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
          questions: [],
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
          questions: [],
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
          questions: [],
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
          questions: [],
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
          questions: [],
        ),
      ),
    ],
  );
