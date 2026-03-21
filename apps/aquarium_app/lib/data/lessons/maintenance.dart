/// Lesson content - Maintenance
/// Part of the lazy-loaded lesson system
library;

import '../../models/learning.dart';
import '../../models/user_profile.dart';

final maintenancePath = LearningPath(
  id: 'maintenance',
  title: 'Tank Maintenance',
  description: 'Keeping your tank clean and healthy',
  emoji: '🧹',
  recommendedFor: [ExperienceLevel.beginner, ExperienceLevel.intermediate],
  orderIndex: 3,
  lessons: [
    Lesson(
      id: 'maint_water_changes',
      pathId: 'maintenance',
      title: 'Water Changes 101',
      description: 'The foundation of a healthy tank',
      orderIndex: 0,
      xpReward: 50,
      estimatedMinutes: 4,
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Why Water Changes Matter',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Your filter removes particles and processes ammonia, but nitrate still builds up. Water changes are the only way to remove it and replenish trace minerals fish need.',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              'Aim for 25-50% water change weekly. This keeps nitrate low and maintains stable water parameters. For established tanks with low bioload, 20-25% weekly is sufficient. For tanks with high bioload, overstocking, or during cycling, increase to 30-40% weekly. Never change more than 50% at once as it disrupts beneficial bacteria. Water changes of 50-75% are perfectly safe when the new water is temperature-matched and dechlorinated — larger changes actually help maintain stable water parameters. The old "never change more than 25%" advice is outdated. Many experienced aquarists do 50%+ weekly changes without issues.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'The Right Way',
        ),
        const LessonSection(
          type: LessonSectionType.numberedList,
          content:
              '1. Match temperature - new water should feel the same as tank water\n2. Add dechlorinator - tap water chlorine kills beneficial bacteria\n3. Use a gravel vacuum - removes debris while draining\n4. Don\'t overfill - leave room for the surface to breathe',
        ),
        const LessonSection(
          type: LessonSectionType.warning,
          content:
              'The key to safe water changes is simple: match the temperature and always add dechlorinator. As long as those two conditions are met, even 75%+ water changes won\'t harm your fish. In emergencies (ammonia or nitrite spikes), don\'t be afraid to do multiple large changes in one day.\n\nWater conditioners are generally safe in overdose — Seachem Prime, for example, can detoxify ammonia and nitrite at up to 5× the recommended dose. However, extremely high doses may temporarily reduce oxygen levels. As a rule, dose for the full tank volume, not the water change volume.',
        ),
      ],
      quiz: Quiz(
        id: 'maint_wc_quiz',
        lessonId: 'maint_water_changes',
        questions: [
          const QuizQuestion(
            id: 'maint_wc_q1',
            question: 'How much water should you change weekly?',
            options: ['5-10%', '25-50%', '80-100%', 'No water changes needed'],
            correctIndex: 1,
            explanation:
                '25-50% weekly keeps nitrate low and maintains stable water. Larger changes (50-75%) are also safe as long as the new water is temperature-matched and dechlorinated.',
          ),
        ],
      ),
    ),
    // Lesson 2: Filter Maintenance
    Lesson(
      id: 'maint_filter',
      pathId: 'maintenance',
      title: 'Filter Care',
      description: 'Keeping your filter healthy (without killing bacteria)',
      orderIndex: 1,
      xpReward: 50,
      estimatedMinutes: 4,
      prerequisites: ['maint_water_changes'],
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Your Filter is Alive',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Remember the nitrogen cycle? Most of your beneficial bacteria live in the filter media - the sponges, ceramic rings, and bio-balls inside your filter. These bacteria are keeping your fish alive!',
        ),
        const LessonSection(
          type: LessonSectionType.warning,
          content:
              'NEVER rinse filter media in tap water! Chlorine kills beneficial bacteria instantly. One mistake can crash your cycle and kill fish.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'How to Clean Filter Media',
        ),
        const LessonSection(
          type: LessonSectionType.numberedList,
          content:
              '1. During a water change, save some old tank water in a bucket\n2. Remove filter media and gently squeeze/swish in the OLD tank water\n3. You\'re removing gunk, not sterilizing - it should still look used\n4. Put media back and discard the dirty water\n5. Never replace all media at once - stagger replacements',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              'Only clean filter media when flow is noticeably reduced. Over-cleaning does more harm than good. Monthly is usually enough.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Replacing Media',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Never replace all filter media at once — this destroys your beneficial bacteria colony. When cleaning mechanical media (sponge/filter pad), rinse in OLD tank water (not tap water — chlorine kills bacteria). Replace no more than 1/3 of biological media per month. Sponges and bio-media rarely need replacing - just rinse them. Carbon should be replaced monthly if used. If you must replace sponges, only do one at a time with weeks between.',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'Consider adding extra bio-media (ceramic rings, bio-balls) to your filter. More surface area = more bacteria = more stable tank.',
        ),
      ],
      quiz: Quiz(
        id: 'maint_filter_quiz',
        lessonId: 'maint_filter',
        questions: [
          const QuizQuestion(
            id: 'maint_filter_q1',
            question: 'What should you use to rinse filter media?',
            options: [
              'Hot tap water',
              'Cold tap water',
              'Old tank water',
              'Soap and water',
            ],
            correctIndex: 2,
            explanation:
                'Always use old tank water! Tap water contains chlorine that kills beneficial bacteria.',
          ),
          const QuizQuestion(
            id: 'maint_filter_q2',
            question: 'How often should you clean filter media?',
            options: [
              'Daily',
              'Weekly',
              'When flow is reduced (usually monthly)',
              'Never',
            ],
            correctIndex: 2,
            explanation:
                'Only clean when necessary - when you notice reduced flow. Over-cleaning harms bacteria.',
          ),
        ],
      ),
    ),

    // Lesson 3: Gravel Vacuuming
    Lesson(
      id: 'maint_gravel_vac',
      pathId: 'maintenance',
      title: 'Gravel Vacuuming Mastery',
      description: 'Clean substrate without removing all water',
      orderIndex: 2,
      xpReward: 50,
      estimatedMinutes: 5,
      prerequisites: ['maint_filter'],
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'The Hidden Waste Trap',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Your substrate looks clean, but underneath? Uneaten food, fish waste, and decaying plant matter accumulate between gravel particles. This creates "dead zones" with low oxygen where harmful bacteria thrive.',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              'Gravel vacuuming removes trapped debris while doing your water change. Two tasks in one - brilliant!',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'How a Gravel Vacuum Works',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'A gravel vacuum (siphon) uses gravity and water flow to lift debris while leaving heavier gravel behind. The wide tube creates just enough suction to pull waste without sucking up substrate.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'The Technique',
        ),
        const LessonSection(
          type: LessonSectionType.numberedList,
          content:
              '1. Plunge the vacuum tube into gravel vertically\n2. Debris and some gravel get pulled up into the tube\n3. Gravel falls back down, debris stays suspended and exits\n4. Move to next section and repeat\n5. Work systematically - front to back, left to right',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'Watch the tube! If too much gravel is being pulled, lift the vacuum slightly. If nothing\'s happening, push deeper into substrate.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Starting the Siphon',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Method 1: Submerge entire vacuum in tank, put thumb over end, lift out with thumb sealed, position bucket below tank, release thumb - water flows!\n\nMethod 2: Use a pump bulb or manual pump to start flow.\n\nMethod 3: Suck on the tube (gross but works - just don\'t swallow!)',
        ),
        const LessonSection(
          type: LessonSectionType.warning,
          content:
              'NEVER vacuum around plant roots! You\'ll damage them and suck up your plants. Just vacuum open substrate areas.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'How Much to Vacuum?',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Lightly planted tanks: Vacuum all open areas weekly\n• Heavily planted: Vacuum front/open areas only, skip planted sections\n• Bare bottom: Siphon debris directly, much easier!\n• Sand: Hover vacuum above surface (sand is too light to vacuum through)',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Controlling Water Removal',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Siphoning is fast! A 60-liter tank can drain in minutes. Control flow by: pinching the tube, lifting the bucket end higher, or using a vacuum with a flow valve.',
        ),
        const LessonSection(
          type: LessonSectionType.funFact,
          content:
              'Some fishkeepers NEVER vacuum planted tanks - the plants\' roots consume the waste as fertilizer! If you have a jungle of plants, you might only need to vacuum open areas.',
        ),
      ],
      quiz: Quiz(
        id: 'maint_gravel_quiz',
        lessonId: 'maint_gravel_vac',
        questions: [
          const QuizQuestion(
            id: 'maint_grav_q1',
            question: 'What does gravel vacuuming remove?',
            options: [
              'Beneficial bacteria',
              'Trapped debris and waste between gravel',
              'All the water',
              'The gravel itself',
            ],
            correctIndex: 1,
            explanation:
                'Gravel vacuuming removes waste trapped between substrate particles while leaving gravel and beneficial bacteria intact.',
          ),
          const QuizQuestion(
            id: 'maint_grav_q2',
            question: 'Should you vacuum around plant roots?',
            options: [
              'Yes, thoroughly',
              'Yes, but gently',
              'No - you\'ll damage roots and suck up plants',
              'Only on weekends',
            ],
            correctIndex: 2,
            explanation:
                'Never vacuum planted areas! You\'ll damage roots and disturb plants. Just vacuum open substrate areas.',
          ),
          const QuizQuestion(
            id: 'maint_grav_q3',
            question: 'How do you vacuum sand substrate?',
            options: [
              'Same as gravel',
              'Hover vacuum above surface - sand is too light',
              'Use a stronger vacuum',
              'Can\'t vacuum sand',
            ],
            correctIndex: 1,
            explanation:
                'Sand is too fine to vacuum through. Hover the tube just above the sand surface to siphon debris without sucking up sand.',
          ),
          const QuizQuestion(
            id: 'maint_grav_q4',
            question: 'What creates "dead zones" in substrate?',
            options: [
              'Too much light',
              'Trapped waste with low oxygen',
              'Too many fish',
              'Cold water',
            ],
            correctIndex: 1,
            explanation:
                'Accumulating waste creates low-oxygen zones where harmful bacteria thrive. Regular vacuuming prevents this.',
          ),
          const QuizQuestion(
            id: 'maint_grav_q5',
            question: 'Can you vacuum while doing water changes?',
            options: [
              'No, separate tasks',
              'Yes - it\'s the best time!',
              'Only in emergencies',
              'Only in saltwater tanks',
            ],
            correctIndex: 1,
            explanation:
                'Gravel vacuuming and water changes are done simultaneously! The water you siphon out IS your water change. Perfect efficiency!',
          ),
        ],
      ),
    ),

    // Lesson 4: Algae Control
    Lesson(
      id: 'maint_algae',
      pathId: 'maintenance',
      title: 'Algae Control: The Battle',
      description: 'Understanding and fighting different algae types',
      orderIndex: 3,
      xpReward: 75,
      estimatedMinutes: 6,
      prerequisites: ['maint_gravel_vac'],
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Algae: The Eternal Struggle',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Every aquarist battles algae. It\'s not a sign of failure - it\'s a natural part of aquarium life. The key is controlling it, not eliminating it completely (which is impossible anyway).',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              'Algae grows when there\'s: excess light, excess nutrients, or an imbalance between the two. Fix the root cause, not just the symptoms.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Green Algae (Most Common)',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Green dust on glass, green water (pea soup), or green spot algae. Usually caused by excess light or high phosphates/nitrates.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Solution: Reduce light duration (6-7 hours max)\n• More frequent water changes (remove nutrients)\n• Add more fast-growing plants (out-compete algae)\n• Scrape glass regularly',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Brown Diatoms (Beginner\'s Algae)',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Brown dusty coating on everything. Common in new tanks (2-4 weeks old). Diatoms feed on silicates - often in new substrate or tap water.',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'Good news: Brown diatoms usually disappear on their own after 4-8 weeks as silicates are depleted. Just wipe them off surfaces and wait it out!',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Hair Algae (The Nightmare)',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Long, stringy green algae that grows on plants and decorations. Very hard to remove manually because it holds on tight. Often indicates excess nutrients + inconsistent CO2 levels.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Solution: Reduce feeding (less waste)\n• Spot-treat with liquid carbon (Excel)\n• Add algae eaters (Amano shrimp, Siamese algae eaters)\n• Manually remove as much as possible\n• Ensure consistent CO2 if using injection',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Black Beard Algae (BBA)',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Dark, hairy tufts on plant edges, wood, and equipment. Nearly impossible to remove manually. Thrives in low CO2, unstable conditions, and fluctuating parameters.',
        ),
        const LessonSection(
          type: LessonSectionType.warning,
          content:
              'BBA is the boss-level algae. Prevention is easier than cure. Stable parameters, consistent CO2, and good flow prevent it from starting.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Prevention is Better Than Cure',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '✓ Consistent lighting schedule (timer!)\n✓ Don\'t overstock fish\n✓ Don\'t overfeed\n✓ Regular water changes\n✓ Fast-growing plants (consume nutrients)\n✓ Good water flow (prevents dead spots)\n✓ Keep glass clean (algae spreads)',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Algae Eaters: The Cleanup Crew',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Nerite snails: Best for glass/diatoms\n• Amano shrimp: Hair algae specialists\n• Otocinclus catfish: Soft algae\n• Siamese algae eaters: Hair & black beard\n• Bristlenose plecos: General cleanup',
        ),
        const LessonSection(
          type: LessonSectionType.funFact,
          content:
              'Some algae is actually GOOD! It provides food for fry, snails, and shrimp. Many aquarists leave algae on the back glass to keep their cleanup crew happy.',
        ),
      ],
      quiz: Quiz(
        id: 'maint_algae_quiz',
        lessonId: 'maint_algae',
        questions: [
          const QuizQuestion(
            id: 'maint_alg_q1',
            question: 'What causes algae growth?',
            options: [
              'Too many fish only',
              'Excess light and/or nutrients',
              'Cold water',
              'Too much oxygen',
            ],
            correctIndex: 1,
            explanation:
                'Algae needs light and nutrients. Excess of either (or imbalance between them) causes algae blooms.',
          ),
          const QuizQuestion(
            id: 'maint_alg_q2',
            question: 'Brown diatoms in a new tank usually mean what?',
            options: [
              'Emergency - tank is dying',
              'Normal for new tanks - will pass in 4-8 weeks',
              'Need to restart tank',
              'Water is too hard',
            ],
            correctIndex: 1,
            explanation:
                'Brown diatoms are normal in new tanks. They feed on silicates and disappear naturally as silicates deplete. Just wait it out!',
          ),
          const QuizQuestion(
            id: 'maint_alg_q3',
            question: 'What\'s the hardest algae to eliminate?',
            options: [
              'Green dust',
              'Brown diatoms',
              'Black beard algae (BBA)',
              'Green water',
            ],
            correctIndex: 2,
            explanation:
                'Black beard algae is extremely stubborn and nearly impossible to remove manually. Prevention (stable parameters, good CO2) is key.',
          ),
          const QuizQuestion(
            id: 'maint_alg_q4',
            question: 'Which creature is best for eating hair algae?',
            options: ['Goldfish', 'Amano shrimp', 'Betta', 'Angelfish'],
            correctIndex: 1,
            explanation:
                'Amano shrimp are hair algae specialists! They\'re the best natural control for this stubborn algae type.',
          ),
          const QuizQuestion(
            id: 'maint_alg_q5',
            question: 'Should you aim to eliminate ALL algae?',
            options: [
              'Yes - spotless tanks only',
              'No - some algae is natural and even beneficial',
              'Yes - algae is always bad',
              'Only in planted tanks',
            ],
            correctIndex: 1,
            explanation:
                'Some algae is natural and provides food for snails, shrimp, and fry. Control it, don\'t obsess over total elimination.',
          ),
        ],
      ),
    ),

    // Lesson 5: Cleaning Glass and Decorations
    Lesson(
      id: 'maint_cleaning',
      pathId: 'maintenance',
      title: 'Safe Cleaning Techniques',
      description: 'Cleaning without harming fish or bacteria',
      orderIndex: 4,
      xpReward: 50,
      estimatedMinutes: 4,
      prerequisites: ['maint_algae'],
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'The Right Way to Clean',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Cleaning an aquarium is different from cleaning your bathroom. You\'re maintaining a living ecosystem, not sterilizing a surface. Wrong cleaning methods kill fish!',
        ),
        const LessonSection(
          type: LessonSectionType.warning,
          content:
              'NEVER use soap, detergent, or household cleaners in anything that touches your tank! Even trace amounts can kill fish.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Cleaning Glass: Inside',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Algae scraper: Rigid plastic blade for tough algae\n• Melamine sponge: "Magic eraser" works great (rinse well first!)\n• Magnetic cleaner: Scrub without getting hands wet\n• Credit card: Cheap scraper for spot cleaning\n• Razor blade: ONLY on glass tanks (will scratch acrylic)',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'Clean glass BEFORE water changes, not after. Debris falls to bottom → gravel vacuum sucks it up. Perfect workflow!',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Cleaning Glass: Outside',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Use regular glass cleaner ONLY on the outside, and spray onto cloth (never directly at tank). Even better: just use vinegar and water solution for streak-free shine.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Cleaning Decorations',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Rocks and decorations with algae? Remove them, scrub with a dedicated aquarium brush under tap water. Or soak in 10% bleach solution for 15 minutes, then rinse THOROUGHLY and soak in dechlorinator.',
        ),
        const LessonSection(
          type: LessonSectionType.warning,
          content:
              'If using bleach: Use a 5% bleach solution: 1 part unscented household bleach to 19 parts water (e.g., 50ml bleach + 950ml water). Dip plants for 2-3 minutes maximum. Rinse thoroughly under running water, then soak in dechlorinated water with a double dose of water conditioner for 15-30 minutes before adding to tank. Any bleach residue kills fish!',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Cleaning Fake Plants',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Remove and scrub under tap water. For tough algae, soak in 10% bleach for 10 minutes, rinse thoroughly, soak in dechlorinated water overnight. They\'ll look brand new!',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'What About Live Plants?',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Don\'t scrub live plants! Gently remove dead leaves by hand. Algae on plant leaves means nutrient imbalance - fix the root cause, don\'t scrub the symptom.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Equipment to Have',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Dedicated algae scraper (never used for anything else)\n• Old toothbrush (for tight spots)\n• Bucket labeled "AQUARIUM ONLY"\n• Microfiber cloths for outside glass',
        ),
        const LessonSection(
          type: LessonSectionType.funFact,
          content:
              'Some aquarists never clean their back glass - they let algae grow as a natural backdrop and food source. It actually looks good and keeps snails busy!',
        ),
      ],
      quiz: Quiz(
        id: 'maint_clean_quiz',
        lessonId: 'maint_cleaning',
        questions: [
          const QuizQuestion(
            id: 'maint_cln_q1',
            question: 'Can you use soap to clean aquarium decorations?',
            options: [
              'Yes, any soap works',
              'Only dish soap',
              'NEVER - even traces can kill fish',
              'Only if rinsed well',
            ],
            correctIndex: 2,
            explanation:
                'Never use soap, detergent, or household cleaners! Even tiny residues are toxic to fish. Use hot water, scrubbing, or diluted bleach (thoroughly rinsed).',
          ),
          const QuizQuestion(
            id: 'maint_cln_q2',
            question: 'When should you clean inside glass?',
            options: [
              'After water changes',
              'Before water changes',
              'Doesn\'t matter',
              'Never clean it',
            ],
            correctIndex: 1,
            explanation:
                'Clean glass BEFORE water changes so the debris falls down, then your gravel vacuum removes it during the water change. Efficient!',
          ),
          const QuizQuestion(
            id: 'maint_cln_q3',
            question:
                'If using bleach to clean decorations, what\'s essential?',
            options: [
              'Use pure bleach',
              'Soak for 24 hours',
              'Rinse thoroughly and soak in dechlorinated water',
              'Add it directly to tank',
            ],
            correctIndex: 2,
            explanation:
                'Bleach (10% solution) works great for killing algae, but you MUST rinse thoroughly for 10+ minutes and soak overnight in dechlorinated water. Any residue is deadly.',
          ),
          const QuizQuestion(
            id: 'maint_cln_q4',
            question: 'Can you use a razor blade on acrylic tanks?',
            options: [
              'Yes, works great',
              'No - it will scratch acrylic',
              'Only for outside',
              'Only on weekends',
            ],
            correctIndex: 1,
            explanation:
                'Razor blades are ONLY for glass tanks! They will scratch acrylic. Use plastic scrapers for acrylic.',
          ),
          const QuizQuestion(
            id: 'maint_cln_q5',
            question: 'Should you scrub algae off live plants?',
            options: [
              'Yes, gently',
              'Yes, vigorously',
              'No - fix nutrient imbalance instead',
              'Only plastic plants need scrubbing',
            ],
            correctIndex: 2,
            explanation:
                'Don\'t scrub live plants - you\'ll damage them. Algae on plants indicates nutrient/light imbalance. Fix the root cause!',
          ),
        ],
      ),
    ),

    // Lesson 6: Maintenance Schedule
    Lesson(
      id: 'maint_schedule',
      pathId: 'maintenance',
      title: 'Your Maintenance Routine',
      description: 'Daily, weekly, and monthly tasks',
      orderIndex: 5,
      xpReward: 50,
      estimatedMinutes: 5,
      prerequisites: ['maint_cleaning'],
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Consistency is Key',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Successful fishkeeping isn\'t about working harder - it\'s about working smarter. A consistent routine prevents problems before they start and keeps maintenance from becoming overwhelming.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Daily Tasks (5 minutes)',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '✓ Count fish (make sure everyone\'s present)\n✓ Observe behavior (anyone acting odd?)\n✓ Check temperature\n✓ Feed fish\n✓ Quick visual scan (equipment running? leaks?)',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'Do your daily check during feeding time. Fish are most active and you\'ll immediately notice if someone\'s not eating.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Weekly Tasks (30-45 minutes)',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '✓ 25-50% water change with gravel vacuum\n✓ Clean inside glass (if needed)\n✓ Test water parameters (ammonia, nitrite, nitrate)\n✓ Remove dead plant leaves\n✓ Check filter flow (still strong?)\n✓ Top off evaporated water',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              'Pick the same day each week. Sunday morning works for many people. Consistency prevents "I\'ll do it later" which becomes "I forgot for a month."',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Monthly Tasks (1-2 hours)',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '✓ Clean filter media (rinse in old tank water)\n✓ Check equipment (heater accurate? air pump working?)\n✓ Trim overgrown plants\n✓ Clean decorations if needed\n✓ Check light bulbs/LEDs (still bright enough?)\n✓ Test GH and KH\n✓ Review stocking (anyone outgrowing tank?)',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Seasonal Care Guide',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Seasons affect your tank more than you\'d think. Room temperature swings, daylight hours change, and your tank\'s needs shift with them. Here\'s what to watch for each season.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: '🌸 Spring: Post-Winter Check',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '✓ Test all parameters — ammonia, nitrite, nitrate, pH, GH/KH\n✓ Check heater accuracy with a separate thermometer (winter can knock them out of calibration)\n✓ Inspect filter flow — clean or replace media if clogged from winter\n✓ Increase feeding gradually as fish become more active\n✓ Resume weekly water changes if you slowed down over winter\n✓ Check for algae — longer daylight hours can trigger early blooms',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: '☀️ Summer: Heat Management',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '✓ Monitor temperature daily — room temps above 25°C can push tank water dangerously high\n✓ Keep frozen water bottles ready: swap 2-3 times daily during heatwaves (drops temp by 2-3°C each)\n✓ Reduce feeding slightly — fish metabolise food faster in warm water, producing more waste\n✓ Run lights for shorter periods or use a dimmer — excess light + heat = algae explosions\n✓ Ensure good surface agitation — warmer water holds less oxygen\n✓ Open cabinet doors to improve airflow around the filter and heater',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: '🍂 Autumn: Preparing for Cooler Months',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '✓ Check that your heater is working before you actually need it — don\'t wait for the first cold snap\n✓ Gradually reduce feeding as fish activity slows with dropping temperatures\n✓ Cut back lighting hours as natural daylight decreases\n✓ Deep clean the filter and check all equipment\n✓ Consider a timer for your heater if your home gets very cold at night\n✓ Vacuum the substrate thoroughly — organic buildup can cause problems over winter',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: '❄️ Winter: Cold Weather Protocol',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '✓ Check heater daily — heater failure in winter can be fatal within hours\n✓ Keep a backup heater (even a small one) ready to go\n✓ Reduce feeding to 2-3 times per week — fish are less active in cooler water\n✓ Don\'t overfeed to "keep them warm" — uneaten food rots and spikes ammonia\n✓ Insulate the back and sides of the tank with foam board if room temp drops below 18°C\n✓ Monitor for condensation on the lid — excessive condensation can drip and cause electrical issues near lights',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'A cheap digital thermometer with a temperature alert is one of the best investments you can make. Set it to alert you if the tank drops below or rises above your target range — it can save your fish while you\'re asleep or at work.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'What NOT to Do',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '❌ Don\'t clean everything at once (crashes cycle)\n❌ Don\'t skip testing during cycling phase\n❌ Don\'t replace all filter media at once\n❌ Don\'t clean filter same week as large water change\n❌ Don\'t overfeed to compensate for missed feedings',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Making it Easier',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Set phone reminders. Keep supplies organized in one place. Pre-measure dechlorinator. Use a Python water changer to eliminate buckets. Small optimizations make maintenance feel effortless.',
        ),
        const LessonSection(
          type: LessonSectionType.funFact,
          content:
              'Many aquarists find maintenance relaxing! It\'s 30 minutes of focused work with visible results. Some people meditate while watching their tank. It\'s aquarium therapy!',
        ),
      ],
      quiz: Quiz(
        id: 'maint_sched_quiz',
        lessonId: 'maint_schedule',
        questions: [
          const QuizQuestion(
            id: 'maint_sch_q1',
            question: 'How often should you do water changes?',
            options: [
              'Daily',
              'Weekly (25-50%)',
              'Monthly',
              'Only when water looks dirty',
            ],
            correctIndex: 1,
            explanation:
                'Weekly 25-50% water changes are the gold standard. Consistent changes beat infrequent large ones. Larger changes (50-75%) are also safe when water is temperature-matched and dechlorinated.',
          ),
          const QuizQuestion(
            id: 'maint_sch_q2',
            question: 'What\'s the most important daily task?',
            options: [
              'Testing water',
              'Observing fish behavior',
              'Cleaning glass',
              'Adjusting pH',
            ],
            correctIndex: 1,
            explanation:
                'Daily observation catches problems early! Count fish, watch behavior, check equipment. This 5-minute habit prevents disasters.',
          ),
          const QuizQuestion(
            id: 'maint_sch_q3',
            question:
                'Should you clean filter and do large water change same week?',
            options: [
              'Yes, get it all done',
              'No - too much bacterial disruption at once',
              'Only in emergencies',
              'Doesn\'t matter',
            ],
            correctIndex: 1,
            explanation:
                'Spread out major maintenance! Both tasks disrupt bacteria. Do them different weeks to maintain stability.',
          ),
          const QuizQuestion(
            id: 'maint_sch_q4',
            question: 'How often should filter media be cleaned?',
            options: [
              'Weekly',
              'Monthly (or when flow reduces)',
              'Daily',
              'Every 6 months',
            ],
            correctIndex: 1,
            explanation:
                'Clean filter media monthly or when you notice reduced flow. Over-cleaning harms bacteria; under-cleaning reduces filtration.',
          ),
          const QuizQuestion(
            id: 'maint_sch_q5',
            question: 'What makes maintenance routines successful?',
            options: [
              'Doing everything at once',
              'Consistency - same schedule weekly',
              'Random timing',
              'Only cleaning when problems arise',
            ],
            correctIndex: 1,
            explanation:
                'Consistency is everything! Pick a day/time and stick to it. Routine prevents problems and makes maintenance feel effortless.',
          ),
        ],
      ),
    ),
  ],
);
