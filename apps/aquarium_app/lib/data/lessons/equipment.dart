/// Lesson content - Equipment
/// Part of the lazy-loaded lesson system
library;

import '../../models/tank.dart';
import '../../models/learning.dart';
import '../../models/user_profile.dart';

final equipmentPath = LearningPath(
  id: 'equipment',
  title: 'Equipment Essentials',
  description: 'Choosing and using aquarium equipment',
  emoji: '🔧',
  recommendedFor: [ExperienceLevel.beginner],
  orderIndex: 5,
  lessons: [
    // Lesson 1: Filter Types
    Lesson(
      id: 'eq_filters',
      pathId: 'equipment',
      title: 'Choosing the Right Filter',
      description: 'HOB, canister, sponge, or internal?',
      orderIndex: 0,
      xpReward: 50,
      estimatedMinutes: 6,
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Your Filter is Your Life Support',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'The filter isn\'t just about clean water - it\'s where your beneficial bacteria live! Choosing the wrong filter can make your life harder and stress your fish.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Hang-On-Back (HOB) Filters',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'The most popular choice! HOB filters hang on the tank rim, pull water up, pass it through media, and pour it back. Simple, accessible, effective.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '✅ Pros: Easy to maintain, good flow, affordable, accessible media\n❌ Cons: Can be noisy, takes up rim space, splashing can increase evaporation',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'For HOB filters, add extra sponge or bio-media! Most come with cartridges designed to sell replacements. Ditch the cartridge, add reusable media.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Canister Filters',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'External filters that sit in your cabinet. Water is pumped through multiple media chambers and returned via spray bar or nozzle. The professional choice for larger tanks.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '✅ Pros: Huge media capacity, quiet, customizable flow, hides equipment\n❌ Cons: Expensive, harder to maintain, potential for leaks, harder to prime',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Sponge Filters',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Simple foam cylinder powered by an air pump. Gentle flow makes them perfect for fry, shrimp, or hospital tanks. Also the most reliable - no mechanical parts to break!',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '✅ Pros: Cheap, gentle flow, great biological filtration, perfect for shrimp/fry, never breaks\n❌ Cons: Ugly, poor mechanical filtration, needs air pump, limited capacity',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Internal Filters',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Filter sits inside the tank, usually in a corner. Compact and good for small tanks, but takes up swimming space and can be an eyesore.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '✅ Pros: Affordable, easy setup, no external equipment\n❌ Cons: Takes up tank space, visible (ugly), limited media capacity',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Under-Gravel Filters (UGF)',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Old-school! A plate under gravel pulls water down through substrate. Mostly outdated - hard to clean, limits substrate choices, and modern options are better.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Which Should YOU Choose?',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Beginner, medium tank: HOB filter\n• Large tank (200L+): Canister filter\n• Shrimp/fry/hospital tank: Sponge filter\n• Small budget tank: Internal or sponge\n• Multiple small tanks: Sponge filters (share one air pump)',
        ),
        const LessonSection(
          type: LessonSectionType.funFact,
          content:
              'Many advanced aquarists run MULTIPLE filters! A sponge + HOB combo gives redundancy - if one fails, the other keeps your cycle alive.',
        ),
      ],
      quiz: Quiz(
        id: 'eq_filter_quiz',
        lessonId: 'eq_filters',
        questions: [
          const QuizQuestion(
            id: 'eq_filt_q1',
            question: 'Which filter type is best for shrimp and fry?',
            options: [
              'Canister - most powerful',
              'HOB - easy to use',
              'Sponge - gentle flow',
              'Internal - compact',
            ],
            correctIndex: 2,
            explanation:
                'Sponge filters provide gentle flow that won\'t suck up tiny shrimp or fry. They\'re the safest choice for delicate livestock.',
          ),
          const QuizQuestion(
            id: 'eq_filt_q2',
            question: 'What\'s the main advantage of canister filters?',
            options: [
              'Cheapest option',
              'Huge media capacity and customizable',
              'Easiest to maintain',
              'Never needs cleaning',
            ],
            correctIndex: 1,
            explanation:
                'Canisters hold massive amounts of media (mechanical, biological, chemical) and let you customize exactly what goes where.',
          ),
          const QuizQuestion(
            id: 'eq_filt_q3',
            question: 'Why do sponge filters need an air pump?',
            options: [
              'They don\'t',
              'Air bubbles lift water through the sponge',
              'To add oxygen only',
              'To heat the water',
            ],
            correctIndex: 1,
            explanation:
                'Sponge filters use an air pump (separate device) to push bubbles through the sponge, creating water flow. The filter itself has no motor — just the sponge and an airline.',
          ),
          const QuizQuestion(
            id: 'eq_filt_q4',
            question: 'What should you do with HOB filter cartridges?',
            options: [
              'Replace monthly as directed',
              'Replace weekly',
              'Never replace them',
              'Replace with reusable sponge/bio-media',
            ],
            correctIndex: 3,
            explanation:
                'Cartridges are a money trap! Replace them with reusable sponge and bio-media. Clean, don\'t replace. Your bacteria will thank you.',
          ),
          const QuizQuestion(
            id: 'eq_filt_q5',
            question: 'Why might you run multiple filters on one tank?',
            options: [
              'It looks cool',
              'Redundancy - if one fails, the other maintains the cycle',
              'Fish like more bubbles',
              'Required by law',
            ],
            correctIndex: 1,
            explanation:
                'Redundancy! If your main filter fails, a backup sponge or secondary filter keeps your cycle alive and prevents disasters.',
          ),
        ],
      ),
    ),

    // Lesson 2: Heaters
    Lesson(
      id: 'eq_heaters',
      pathId: 'equipment',
      title: 'Heater Selection and Safety',
      description: 'Keeping tropical fish warm (without cooking them)',
      orderIndex: 1,
      xpReward: 50,
      estimatedMinutes: 5,
      prerequisites: ['eq_filters'],
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Why Tropical Fish Need Heaters',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Tropical fish evolved in warm waters (24-28°C). Room temperature in most homes is 18-22°C - too cold! Without a heater, your fish become lethargic, stressed, and disease-prone.',
        ),
        const LessonSection(
          type: LessonSectionType.warning,
          content:
              'Heater failures kill tanks! They can fail "on" (cooking fish) or "off" (freezing fish). Always use a separate thermometer to monitor.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Sizing Your Heater',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'The standard rule: 1-2 watts per litre for modern tanks in typical indoor temperatures. A 60-litre tank typically needs 60-120W. Undersizing means the heater runs constantly (shorter lifespan). Add 0.5-1W/L for tanks in cold rooms or garages.',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'Two smaller heaters beat one large! A 60L tank with two 75W heaters is safer than one 150W. If one fails, the other provides backup. Plus, more even heating.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Types of Heaters',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Submersible: Fully underwater, horizontal or vertical, most common\n• Hang-on: Partially submerged, older style, less efficient\n• Substrate cable: For planted tanks, heats substrate\n• In-line: For canister filters, hidden in plumbing',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Preset vs Adjustable',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Preset heaters (25°C fixed) are cheap but inflexible. Adjustable heaters cost \$10 more but let you fine-tune temperature for specific species or treat disease (higher temps kill some parasites).',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Placement Matters',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '✓ Near filter output (distributes heat evenly)\n✓ Fully submerged (check minimum water line)\n✓ At an angle if possible (better heat distribution)\n❌ NOT near substrate (uneven heating)\n❌ NOT where fish can get trapped behind it',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Testing Your Heater',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Don\'t trust the dial! Set it to 25°C, wait 24 hours, then check with a separate thermometer. Adjust dial until the actual temperature matches. Heater dials are notoriously inaccurate.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Safety Tips',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• UNPLUG before putting hands in tank (electrical risk)\n• Wait 15 min after unplugging before removing (still hot!)\n• Replace every 2-3 years (they wear out)\n• Use a heater guard if you have large fish (prevents burns/damage)\n• Consider a controller for automatic shutoff',
        ),
        const LessonSection(
          type: LessonSectionType.funFact,
          content:
              'Some aquarists in tropical climates use CHILLERS instead of heaters! When room temp hits 30°C+, you need to cool the tank down. Expensive but necessary.',
        ),
      ],
      quiz: Quiz(
        id: 'eq_heater_quiz',
        lessonId: 'eq_heaters',
        questions: [
          const QuizQuestion(
            id: 'eq_heat_q1',
            question: 'How many watts per litre do you typically need?',
            options: [
              '0.5 watts',
              '1-2 watts per litre',
              '10+ watts',
              'Watts don\'t matter',
            ],
            correctIndex: 1,
            explanation:
                '1-2 watts per litre is standard for modern tanks in typical indoor temperatures. Add 0.5-1W/L extra for cold rooms.',
          ),
          const QuizQuestion(
            id: 'eq_heat_q2',
            question: 'Why use two smaller heaters instead of one large?',
            options: [
              'Looks better',
              'Cheaper',
              'Redundancy and more even heating',
              'Required by law',
            ],
            correctIndex: 2,
            explanation:
                'Two heaters provide backup if one fails, plus they distribute heat more evenly. Safer and more reliable!',
          ),
          const QuizQuestion(
            id: 'eq_heat_q3',
            question: 'Where should you place your heater?',
            options: [
              'Buried in substrate',
              'Near filter output for even heat distribution',
              'Floating at surface',
              'Outside the tank',
            ],
            correctIndex: 1,
            explanation:
                'Place heaters near filter output! The water flow distributes heat evenly throughout the tank.',
          ),
          const QuizQuestion(
            id: 'eq_heat_q4',
            question: 'Should you trust the heater\'s temperature dial?',
            options: [
              'Yes, always accurate',
              'No - verify with separate thermometer',
              'Only on expensive brands',
              'Doesn\'t matter',
            ],
            correctIndex: 1,
            explanation:
                'Heater dials are notoriously inaccurate! Always verify actual temperature with a separate thermometer.',
          ),
          const QuizQuestion(
            id: 'eq_heat_q5',
            question: 'How can a heater "fail"?',
            options: [
              'Only by turning off',
              'Only by turning on permanently',
              'Either stuck ON (cooking fish) or OFF (freezing them)',
              'Heaters never fail',
            ],
            correctIndex: 2,
            explanation:
                'Heaters can fail in two ways: stuck ON (overheating/cooking fish) or stuck OFF (freezing fish). Both are deadly - always monitor with a thermometer!',
          ),
        ],
      ),
    ),

    // Lesson 3: Lighting
    Lesson(
      id: 'eq_lighting',
      pathId: 'equipment',
      title: 'Lighting 101: What Fish Need',
      description: 'Choosing the right light (it\'s not about brightness!)',
      orderIndex: 2,
      xpReward: 50,
      estimatedMinutes: 5,
      prerequisites: ['eq_heaters'],
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Lighting: More Than Decoration',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Beginners think lighting is about seeing their fish. Wrong! Lighting affects fish behavior, plant growth, and algae levels. The wrong light creates problems.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'What Fish Actually Need',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Most fish don\'t need bright light - they actually prefer subdued lighting! In nature, many tropical fish live under dense canopy with dappled light. Bright lights stress them.',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              'Fish-only tanks need just enough light to see them clearly. 6-8 hours daily is plenty. More light = more algae with no benefit to fish.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'LED vs Fluorescent vs Incandescent',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• LED: Modern, efficient, long-lasting, low heat, dimmable\n• Fluorescent (T5/T8): Older standard, decent for plants, shorter lifespan\n• Incandescent: Outdated, hot, inefficient - avoid',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'Go LED! Initial cost is higher, but they last 5+ years, use 75% less electricity, and don\'t heat your water. They pay for themselves.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Color Temperature (Kelvin)',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              '6500K (daylight white) is the sweet spot for planted tanks - mimics natural sunlight. 8000K+ (blueish) makes fish colors pop but encourages algae. 3000K (warm/yellow) looks dingy.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Duration > Intensity',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Beginners buy super bright lights then run them 12 hours - algae city! Instead: moderate brightness, 6-8 hours daily on a timer. Consistency matters more than intensity.',
        ),
        const LessonSection(
          type: LessonSectionType.warning,
          content:
              'Never leave lights on 24/7! Fish need a day/night cycle for health. Constant light causes stress, aggression, and algae blooms.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Special Cases',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Planted tanks: Brighter light (but needs CO2 + ferts to balance)\n• Nocturnal fish: Moonlight LEDs for viewing at night\n• Breeding tanks: Dim lighting reduces stress\n• Algae problems: Reduce duration to 6 hours',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Do You Even Need a Light?',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'If your tank gets natural window light (not direct sun!) and you don\'t have plants, you might not need an aquarium light at all! Room light + window light can be enough.',
        ),
        const LessonSection(
          type: LessonSectionType.funFact,
          content:
              'Some fish actually spawn better with specific lighting! Killifish need gradual sunrise/sunset simulation. Advanced LED lights can program this - nature in a box!',
        ),
      ],
      quiz: Quiz(
        id: 'eq_lighting_quiz',
        lessonId: 'eq_lighting',
        questions: [
          const QuizQuestion(
            id: 'eq_light_q1',
            question: 'How many hours should aquarium lights run daily?',
            options: [
              '24 hours (constant)',
              '12-14 hours',
              '6-8 hours',
              '2-3 hours',
            ],
            correctIndex: 2,
            explanation:
                '6-8 hours is ideal for most tanks! Longer photoperiods just encourage algae without benefiting fish. Use a timer for consistency.',
          ),
          const QuizQuestion(
            id: 'eq_light_q2',
            question: 'Do fish need bright light?',
            options: [
              'Yes, as bright as possible',
              'No - most prefer subdued lighting',
              'Only at feeding time',
              'Only at night',
            ],
            correctIndex: 1,
            explanation:
                'Most fish come from shaded streams/rivers and prefer dim to moderate light. Bright lights stress them!',
          ),
          const QuizQuestion(
            id: 'eq_light_q3',
            question: 'What Kelvin rating mimics natural daylight?',
            options: [
              '3000K (warm yellow)',
              '6500K (daylight white)',
              '10000K (blue)',
              'Doesn\'t matter',
            ],
            correctIndex: 1,
            explanation:
                '6500K is ideal - it mimics natural sunlight and grows plants well while making colors look natural.',
          ),
          const QuizQuestion(
            id: 'eq_light_q4',
            question: 'Why are LED lights better than fluorescent?',
            options: [
              'They\'re not - fluorescent is better',
              'Longer lifespan, more efficient, low heat, dimmable',
              'Only because they look cool',
              'Required by law',
            ],
            correctIndex: 1,
            explanation:
                'LEDs last 5+ years, use 75% less electricity, don\'t heat water, and many are dimmable. Clear winner!',
          ),
          const QuizQuestion(
            id: 'eq_light_q5',
            question: 'Can you leave lights on 24/7?',
            options: [
              'Yes, fish love constant light',
              'No - fish need day/night cycle',
              'Only in planted tanks',
              'Only with LED lights',
            ],
            correctIndex: 1,
            explanation:
                'Never! Fish need a day/night cycle for health. Constant light causes stress, aggression, and algae explosions.',
          ),
        ],
      ),
    ),
  ],
);
