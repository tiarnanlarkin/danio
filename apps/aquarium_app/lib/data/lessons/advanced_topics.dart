/// Lesson content - Advanced Topics
/// Part of the lazy-loaded lesson system
library;

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
          type: LessonSectionType.heading,
          content: 'The Livebearer Family',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Guppies, mollies, platies, and swordtails are livebearers — they give birth to fully-formed, free-swimming fry instead of laying eggs. They\'re the easiest fish to breed in the hobby. In fact, the hard part isn\'t getting them to breed — it\'s everything that comes after.',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              'Male:female ratio matters. Keep 1 male for every 2–3 females. Too many males constantly harassing females causes stress, disease, and death. A 1:1 ratio will wear females out.',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Gestation is approximately 28 days for guppies, slightly longer for mollies and platies — and it varies with temperature (warmer = faster). A gravid female develops a dark "gravid spot" near the tail and becomes noticeably rounder. When she squares off (the belly becomes boxy), birth is imminent.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Fry survival — Option 1: breeding box (separate the female before birth). Effective but stressful for the mother.\n• Fry survival — Option 2: heavily planted tank with java moss or guppy grass. More natural; some fry will be eaten, but it\'s lower stress.\n• First fry food: crushed flake and baby brine shrimp (BBS). BBS dramatically improves growth rate.\n• Feed fry 3–4 times daily in small amounts.',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'Basic colour genetics: in guppies, many colour patterns are X-linked (carried on the X chromosome). Males display the pattern; females carry it. Selective breeding involves tracking which females carry which traits.',
        ),
        const LessonSection(
          type: LessonSectionType.warning,
          content:
              'Culling ethics: don\'t release unwanted fry into local waterways — it\'s illegal in most countries and can devastate native ecosystems. Rehome through fish clubs, sell to shops, or feed to larger fish (if you can stomach it).',
        ),
      ],
      quiz: Quiz(
        id: 'at_breeding_live_quiz',
        lessonId: 'at_breeding_livebearers',
        questions: [
          const QuizQuestion(
            id: 'at_live_q1',
            question: 'What male-to-female ratio is recommended for livebearers?',
            options: [
              '3 males per female',
              '1 male per female',
              '1 male per 2–3 females',
              'Equal numbers of each',
            ],
            correctIndex: 2,
            explanation:
                'Keep 1 male per 2–3 females. Too many males constantly harass females, causing chronic stress. A 1:1 ratio will exhaust females over time.',
          ),
          const QuizQuestion(
            id: 'at_live_q2',
            question: 'How long is the approximate gestation period for guppies?',
            options: [
              '7 days',
              '28 days',
              '60 days',
              '90 days',
            ],
            correctIndex: 1,
            explanation:
                'Guppy gestation is approximately 28 days, varying with temperature. Warmer water shortens it slightly; cooler water lengthens it.',
          ),
          const QuizQuestion(
            id: 'at_live_q3',
            question: 'What food dramatically improves fry growth rate?',
            options: [
              'Large pellets',
              'Algae wafers',
              'Baby brine shrimp (BBS)',
              'Adult flake food',
            ],
            correctIndex: 2,
            explanation:
                'Baby brine shrimp (BBS) are high in protein and perfectly sized for fry. They dramatically improve growth rates compared to crushed flake alone.',
          ),
          const QuizQuestion(
            id: 'at_live_q4',
            question: 'Why should unwanted livebearer fry never be released into local waterways?',
            options: [
              'They will die immediately in cold water',
              'It is illegal in most countries and can devastate native ecosystems',
              'They will spread disease to wild fish',
              'They don\'t survive outside of aquariums',
            ],
            correctIndex: 1,
            explanation:
                'Releasing aquarium fish is illegal in most countries. Invasive livebearers (especially guppies and mollies) can outcompete native species and cause serious ecological damage.',
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
          type: LessonSectionType.heading,
          content: 'Conditioning Your Fish',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Before attempting to breed egg layers, "condition" both sexes for 1–2 weeks with high-protein live or frozen foods: bloodworms, brine shrimp, daphnia. This builds up nutrient reserves and triggers breeding readiness. Well-conditioned females become noticeably plumper with eggs.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Spawning Triggers',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Most egg layers need a trigger. A large cool water change (replacing 30–40% with slightly cooler water) mimics the rainy season and often initiates spawning. For some species, gradually raising temperature by 2–3°F over 24 hours works. Dawn light simulation (slowly brightening lighting) can also trigger spawning behaviour.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Egg scatterers (danios, tetras): scatter eggs randomly — remove parents IMMEDIATELY after spawning or they\'ll eat every egg\n• Egg depositors (corydoras): lay adhesive eggs on glass, leaves, or flat surfaces — parents usually leave eggs alone\n• Bubble nest builders (bettas, gouramis): male builds a foam nest at the surface and guards the eggs — remove the female after spawning',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Raising Fry',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Newly hatched fry absorb their yolk sac for the first 1–3 days. After that, they need microscopic food. Infusoria (single-celled organisms cultured in a jar of vegetable water) is ideal for the first few days. Then transition to baby brine shrimp, then crushed flake. Good beginner species: corydoras catfish and bristlenose plecos — both are egg depositors with reasonable fry survival.',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'Use a sponge filter in the breeding/fry tank. Regular filters will suck up fry. A gentle sponge filter provides aeration and biological filtration without becoming a fry trap.',
        ),
        const LessonSection(
          type: LessonSectionType.warning,
          content:
              'Many egg-laying fish will eat their own eggs immediately after spawning. With scatterers like danios and tetras, remove parents the moment spawning is complete.',
        ),
      ],
      quiz: Quiz(
        id: 'at_breeding_egg_quiz',
        lessonId: 'at_breeding_egg_layers',
        questions: [
          const QuizQuestion(
            id: 'at_egg_q1',
            question: 'What food is best for conditioning fish before breeding?',
            options: [
              'Flake food fed twice daily',
              'Algae wafers',
              'High-protein live or frozen food (bloodworms, brine shrimp)',
              'Vegetable matter only',
            ],
            correctIndex: 2,
            explanation:
                'High-protein live or frozen foods (bloodworms, brine shrimp, daphnia) build the nutrient reserves fish need for egg production and successful spawning.',
          ),
          const QuizQuestion(
            id: 'at_egg_q2',
            question: 'What is a common spawning trigger for egg-laying fish?',
            options: [
              'Stopping feeding for a week',
              'A large, slightly cool water change mimicking the rainy season',
              'Adding salt to the water',
              'Keeping lights off for 24 hours',
            ],
            correctIndex: 1,
            explanation:
                'A large, slightly cool water change mimics seasonal rainfall — a natural spawning trigger for many tropical fish. Combined with good conditioning, this often initiates breeding.',
          ),
          const QuizQuestion(
            id: 'at_egg_q3',
            question: 'What is the correct fry feeding sequence after egg layers hatch?',
            options: [
              'Crushed flake immediately from day one',
              'Baby brine shrimp → infusoria → large pellets',
              'Yolk sac absorption → infusoria → baby brine shrimp → crushed flake',
              'Adult food crushed finely from birth',
            ],
            correctIndex: 2,
            explanation:
                'Fry absorb their yolk sac for 1–3 days, then need infusoria (microscopic), then baby brine shrimp, then crushed flake as they grow. Rushing to large food causes starvation.',
          ),
          const QuizQuestion(
            id: 'at_egg_q4',
            question: 'What must you do immediately after egg scatterers (like danios) have spawned?',
            options: [
              'Add medication to prevent fungus',
              'Remove the parents — they will eat the eggs',
              'Raise the temperature to 90°F',
              'Do a 50% water change',
            ],
            correctIndex: 1,
            explanation:
                'Egg scatterers will eat their own eggs immediately. Remove parents the moment spawning is complete — every minute counts.',
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
          type: LessonSectionType.heading,
          content: 'Three Major Styles',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Iwagumi is the most iconic style: minimalist, clean, focused on carefully arranged stones with low carpet plants (like dwarf hairgrass or Monte Carlo). Pioneered by Takashi Amano, it looks serene but is technically demanding. Dutch style is the opposite — dense, colourful plant variety arranged in "streets" with no visible hardscape. Colour, texture, and contrast between plant groups do all the visual work. Nature style recreates natural landscapes: mountains, riverbeds, forests — using a mix of hardscape and plants together.',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              'Rule of thirds: place your focal point (main stone, driftwood, or plant group) at one of the four intersections of an imaginary 3×3 grid. Centred layouts look static; off-centre layouts feel dynamic.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Building the Scape',
        ),
        const LessonSection(
          type: LessonSectionType.numberedList,
          content:
              '1. Plan on paper or digitally before touching the tank\n2. Add substrate: nutrient-rich base layer (e.g. Aquasoil) topped with a cap layer of sand or fine gravel\n3. Place hardscape (rocks, driftwood) first — this is your foundation\n4. Add plants: carpet species foreground, stem plants midground, tall background plants\n5. Fill with water slowly (use a plate or bag to avoid disturbing the substrate)\n6. Patience: a fully grown-in scape takes 2–6 months',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'Odd numbers of rocks look more natural than even numbers. Three or five stones are more visually appealing than two or four — this is true in all natural landscapes.',
        ),
        const LessonSection(
          type: LessonSectionType.funFact,
          content:
              'Takashi Amano started the Nature Aquarium movement in the 1990s. His book "Nature Aquarium World" transformed the hobby worldwide. He also founded ADA (Aqua Design Amano), the premium aquascaping equipment brand.',
        ),
      ],
      quiz: Quiz(
        id: 'at_aquascape_quiz',
        lessonId: 'at_aquascaping',
        questions: [
          const QuizQuestion(
            id: 'at_aqua_q1',
            question: 'What defines the Iwagumi aquascaping style?',
            options: [
              'Dense, colourful plant streets with no hardscape',
              'A recreation of a specific natural riverbed biotope',
              'Minimalist stone-focused layout with carpet plants',
              'Random placement of driftwood and artificial plants',
            ],
            correctIndex: 2,
            explanation:
                'Iwagumi is minimalist and stone-focused. Carefully arranged rocks with low carpet plants create a serene, Japanese-influenced aesthetic.',
          ),
          const QuizQuestion(
            id: 'at_aqua_q2',
            question: 'Where should your focal point be placed according to the rule of thirds?',
            options: [
              'Dead centre of the tank',
              'In the back corner',
              'At one of the four intersections on a 3×3 grid',
              'On the left or right wall',
            ],
            correctIndex: 2,
            explanation:
                'The rule of thirds places key elements at the intersections of a 3×3 grid — off-centre. This creates visual tension and dynamism that a centred focal point can\'t achieve.',
          ),
          const QuizQuestion(
            id: 'at_aqua_q3',
            question: 'What order should you follow when building an aquascape?',
            options: [
              'Plants first, then rocks, then substrate',
              'Substrate first, then hardscape, then plants',
              'Hardscape first, then substrate, then plants',
              'Fill with water first, then add everything',
            ],
            correctIndex: 1,
            explanation:
                'Always substrate first (the foundation), then hardscape (rocks and wood), then plants. This ensures proper planting depth and stable hardscape positioning.',
          ),
          const QuizQuestion(
            id: 'at_aqua_q4',
            question: 'How long does it typically take for an aquascape to fully grow in?',
            options: [
              '1–2 weeks',
              '1 month',
              '2–6 months',
              '2 years',
            ],
            correctIndex: 2,
            explanation:
                'A fully grown aquascape takes 2–6 months depending on plants, lighting, and CO2. Patience is essential — the scape looks best after plants have filled in completely.',
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
          type: LessonSectionType.heading,
          content: 'What Is a Biotope?',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'A biotope aquarium recreates a specific natural habitat as accurately as possible — matching fish species, water chemistry, substrate, hardscape, and even plants to what you\'d actually find at that location. It\'s part science, part art. The goal isn\'t just "fish from Africa" — it\'s "this specific section of the Rio Negro in Brazil, circa the dry season."',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Three Popular Biotopes',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• **Amazon Blackwater:** Tannin-stained water (add Indian almond leaves, driftwood), pH 5.5–6.5, very soft water, sand substrate. Species: neon/cardinal tetras, angelfish, corydoras, apistogrammas.\n• **African Rift Lake (Malawi/Tanganyika):** Hard, alkaline pH 7.8–8.6, crushed coral or aragonite substrate, rock caves and stacks. Species: mbuna cichlids, peacock cichlids, Tropheus.\n• **Southeast Asian:** Moderate parameters, driftwood with java fern and crypts. Species: gouramis, rasboras, clown loaches, hillstream loaches.',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              'Research your chosen biotope thoroughly BEFORE buying anything. Species compatibility, water chemistry, and substrate all need to match the actual habitat. Getting this wrong means fish suffering in the wrong conditions.',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'Indian almond leaves (IAL) are the easiest way to start a blackwater biotope. They release tannins that lower pH, soften water, and have mild antibacterial properties. Replace them as they break down.',
        ),
        const LessonSection(
          type: LessonSectionType.funFact,
          content:
              'Biotope Aquarium Contests judge accuracy down to leaf litter species! Serious competitors research the exact location, season, and even flood level of the habitat they\'re recreating.',
        ),
      ],
      quiz: Quiz(
        id: 'at_biotope_quiz',
        lessonId: 'at_biotope',
        questions: [
          const QuizQuestion(
            id: 'at_bio_q1',
            question: 'What is the pH range for an Amazon blackwater biotope?',
            options: [
              'pH 7.8–8.6',
              'pH 7.0 exactly',
              'pH 5.5–6.5',
              'pH 8.5–9.5',
            ],
            correctIndex: 2,
            explanation:
                'Amazon blackwater rivers are soft and acidic — pH 5.5–6.5. Tannins from decaying leaves stain the water dark brown and lower pH naturally.',
          ),
          const QuizQuestion(
            id: 'at_bio_q2',
            question: 'What substrate is used in an African Rift Lake biotope?',
            options: [
              'Fine sand and Indian almond leaves',
              'Plain gravel',
              'Nutrient-rich planted tank substrate',
              'Crushed coral or aragonite',
            ],
            correctIndex: 3,
            explanation:
                'Crushed coral or aragonite releases minerals that maintain the hard, alkaline water (pH 7.8–8.6) that Rift Lake cichlids require. It also mimics the rocky lake bed.',
          ),
          const QuizQuestion(
            id: 'at_bio_q3',
            question: 'What fish would you find in a Southeast Asian biotope?',
            options: [
              'Tetras, angelfish, and piranhas',
              'Mbuna cichlids and Tropheus',
              'Gouramis, rasboras, and loaches',
              'Goldfish, koi, and oranda',
            ],
            correctIndex: 2,
            explanation:
                'Southeast Asian rivers are home to gouramis, rasboras, loaches (including clown and hillstream loaches), and many barb species.',
          ),
          const QuizQuestion(
            id: 'at_bio_q4',
            question: 'What natural material releases tannins for an Amazon blackwater setup?',
            options: [
              'Crushed coral',
              'Indian almond leaves',
              'Lava rock',
              'Play sand',
            ],
            correctIndex: 1,
            explanation:
                'Indian almond leaves release tannins that stain the water, lower pH, soften water, and have mild antibacterial properties — perfect for blackwater biotopes.',
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
          content: 'Emergency Scenarios',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• **Ammonia spike:** Do a 50% water change IMMEDIATELY. Dose a dechlorinator like Seachem Prime (detoxifies ammonia for 24–48 hours). Stop feeding. Find the cause: dead fish hidden somewhere? Overfeeding? Filter crashed?\n• **Fish gasping at surface:** Increase surface agitation — lower the water level so the filter outflow splashes, or add an airstone. Do a water change. Check temperature (warm water holds less oxygen).\n• **Ich (white spots):** Raise temperature to 86°F (30°C) gradually over 24 hours + add aquarium salt (1 tbsp per 5 gallons). Treat for 2 full weeks — the temperature breaks the ich life cycle.\n• **Power outage:** Wrap the tank in blankets for insulation. A battery-powered air pump is the most important emergency item you can own. Don\'t feed during the outage.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'More Emergencies',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• **Fish jumped out:** If still alive and moist, wet your hands first (dry hands damage the slime coat), then gently return to the tank. Dim lights, add tannins for stress reduction, watch closely for 24 hours. Add a lid!\n• **Cloudy water:** White/grey = bacterial bloom (new tank), usually harmless, resolves in days. Green = algae (reduce light duration). White + ammonia smell = bacterial overload — test and act fast.',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              'Test before acting. Cloudy water could be harmless (bacterial bloom) or deadly (ammonia). A 5-minute test prevents a 5-hour mistake.',
        ),
        const LessonSection(
          type: LessonSectionType.warning,
          content:
              'Never do a 100% water change in a crisis. It removes all beneficial bacteria and shocks fish with the chemistry difference. 50% maximum, done slowly.',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'Emergency kit every fishkeeper should have: Seachem Prime (ammonia detox), API Master Test Kit, aquarium salt, battery-powered air pump. These four items will save fish lives.',
        ),
      ],
      quiz: Quiz(
        id: 'at_trouble_quiz',
        lessonId: 'at_troubleshooting',
        questions: [
          const QuizQuestion(
            id: 'at_trouble_q1',
            question: 'What is the first thing to do during an ammonia spike?',
            options: [
              'Add aquarium salt',
              'Do a 50% water change immediately and dose Prime',
              'Turn off the filter',
              'Do a 100% water change',
            ],
            correctIndex: 1,
            explanation:
                'A 50% water change halves the ammonia concentration immediately. Seachem Prime detoxifies remaining ammonia for 24–48 hours while you find and fix the cause.',
          ),
          const QuizQuestion(
            id: 'at_trouble_q2',
            question: 'How do you treat ich (white spot disease)?',
            options: [
              'Do nothing — it resolves on its own',
              'Lower temperature to 65°F and add medication',
              'Raise temperature to 86°F gradually + aquarium salt for 2 weeks',
              'Do a 100% water change immediately',
            ],
            correctIndex: 2,
            explanation:
                'Heat (86°F) breaks the ich life cycle, and aquarium salt helps. Treat for 2 full weeks — ich has life stages where it\'s invisible but still present.',
          ),
          const QuizQuestion(
            id: 'at_trouble_q3',
            question: 'During a power outage, what is the single most important piece of emergency equipment?',
            options: [
              'A spare heater',
              'A battery-powered air pump',
              'A backup light',
              'A water testing kit',
            ],
            correctIndex: 1,
            explanation:
                'Fish can survive cold and dark, but they cannot survive without oxygen. A battery-powered air pump keeps the water oxygenated when the main filter goes down.',
          ),
          const QuizQuestion(
            id: 'at_trouble_q4',
            question: 'What do different types of cloudy water indicate?',
            options: [
              'All cloudy water is caused by ammonia',
              'All cloudy water is harmless bacterial bloom',
              'White/grey = bacterial bloom; green = algae; both need testing before acting',
              'Cloudy water always means the cycle has crashed',
            ],
            correctIndex: 2,
            explanation:
                'White/grey cloudy water is usually a harmless bacterial bloom in new tanks. Green cloudiness is algae. Always test parameters before treating — the cause determines the action.',
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
          type: LessonSectionType.heading,
          content: 'KH: The pH Guardian',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'KH (carbonate hardness) is your water\'s buffering capacity — its ability to resist pH changes. Low KH means unstable pH. In planted tanks, CO2 lowers pH during the day; respiration raises it overnight. With low KH, this swing can be dramatic and stressful for fish. KH below 4 dKH is a red flag for pH crashes.',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              'pH crash fix: if KH has been depleted, add crushed coral to the filter sock (slow, gentle buffer) or use baking soda as a temporary fix. Long-term: regular water changes replenish KH naturally.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'RO Water: Pure but Incomplete',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Reverse osmosis (RO) water has had virtually all minerals removed — it\'s almost pure H₂O. This sounds ideal, but it\'s actually useless without remineralisation. Fish and plants need minerals (calcium, magnesium, potassium). You must add them back using a remineraliser product (Salty Shrimp GH/KH+, Seachem Equilibrium) or simply mix RO with tap water at a ratio that achieves your target parameters.',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'TDS (Total Dissolved Solids) measures everything dissolved in water — minerals, organics, medications, waste byproducts. High TDS doesn\'t automatically mean bad water; low TDS doesn\'t mean clean water. Context matters. A shrimp keeper targeting TDS 200 has very different goals than someone with high-TDS tap water trying to lower it for cardinal tetras.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Test Kit Accuracy',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'API liquid test kits beat strips every time. One critical tip for the nitrate test: shake bottle #2 vigorously for 30 seconds MINIMUM before use. The reagents settle and precipitate — if you don\'t shake thoroughly, you\'ll consistently read falsely low nitrate. Many fishkeepers have killed fish trusting inaccurate nitrate readings.',
        ),
      ],
      quiz: Quiz(
        id: 'at_chem_quiz',
        lessonId: 'at_water_chem',
        questions: [
          const QuizQuestion(
            id: 'at_chem_q1',
            question: 'What is the role of KH in your aquarium?',
            options: [
              'KH measures calcium and magnesium concentration',
              'KH buffers pH — preventing dangerous swings, especially overnight in planted tanks',
              'KH removes chlorine from tap water',
              'KH measures total dissolved solids',
            ],
            correctIndex: 1,
            explanation:
                'KH is carbonate hardness — it buffers pH and prevents swings. Low KH (below 4 dKH) can lead to overnight pH crashes in planted tanks as CO2 levels change.',
          ),
          const QuizQuestion(
            id: 'at_chem_q2',
            question: 'What is the problem with using pure RO water without remineralisation?',
            options: [
              'RO water has too high a pH',
              'RO water has no minerals — fish and plants need minerals to survive',
              'RO water contains dangerous chemicals',
              'RO water is too cold for tropical fish',
            ],
            correctIndex: 1,
            explanation:
                'Pure RO water has had all minerals stripped out. Without remineralisation (adding back GH, KH, and trace minerals), fish and plants have none of the minerals essential for their biology.',
          ),
          const QuizQuestion(
            id: 'at_chem_q3',
            question: 'What does a high TDS reading tell you about your water?',
            options: [
              'The water is definitely unsafe for fish',
              'The water is clean and healthy',
              'A lot of substances are dissolved, but TDS alone doesn\'t tell you what they are',
              'The ammonia level is dangerously high',
            ],
            correctIndex: 2,
            explanation:
                'TDS measures everything dissolved — minerals, organics, waste. High TDS could be from healthy minerals or from accumulated waste. You need other tests to know which.',
          ),
          const QuizQuestion(
            id: 'at_chem_q4',
            question: 'Why must you shake the API Nitrate test Bottle #2 vigorously before use?',
            options: [
              'It\'s just a superstition — it makes no difference',
              'The reagents precipitate and settle — not shaking causes falsely low nitrate readings',
              'Shaking mixes in oxygen which activates the reagent',
              'The bottle needs to be warmed up by movement',
            ],
            correctIndex: 1,
            explanation:
                'API Nitrate Bottle #2 reagents settle and clump at the bottom. Without 30+ seconds of vigorous shaking, the active ingredient is too dilute and you\'ll read lower nitrate than actually exists — a potentially fatal error.',
          ),
        ],
      ),
    ),
  ],
);
