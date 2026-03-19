/// Lesson content - Planted Tank
/// Part of the lazy-loaded lesson system
library;

import '../../models/tank.dart';
import '../../models/learning.dart';
import '../../models/user_profile.dart';

final plantedTankPath = LearningPath(
  id: 'planted',
  title: 'Planted Tanks',
  description: 'Growing live aquatic plants',
  emoji: '🌿',
  recommendedFor: [ExperienceLevel.intermediate],
  relevantTankTypes: [TankType.freshwater], // Planted is a subset of freshwater
  orderIndex: 4,
  lessons: [
    Lesson(
      id: 'planted_basics',
      pathId: 'planted',
      title: 'Why Live Plants?',
      description: 'Benefits of a planted aquarium',
      orderIndex: 0,
      xpReward: 50,
      estimatedMinutes: 4,
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Plants Are Amazing',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Live plants aren\'t just decoration. They absorb nitrate, produce oxygen, provide hiding spots for fish, and compete with algae for nutrients.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Natural filtration - absorb ammonia and nitrate\n• Oxygen production - especially during daylight\n• Stress reduction - fish feel safer with cover\n• Algae control - out-compete algae for nutrients\n• Natural beauty - nothing beats a planted tank',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Easy Starter Plants',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Java fern - attach to wood, low light\n• Anubias - slow growing, nearly indestructible\n• Java moss - great for shrimp, easy\n• Amazon sword - impressive centerpiece\n• Cryptocoryne - variety of sizes and colors',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'Start with "low tech" plants that don\'t need CO2 injection or special lighting. Master these before going high-tech.',
        ),
      ],
      quiz: Quiz(
        id: 'planted_basics_quiz',
        lessonId: 'planted_basics',
        questions: [
          const QuizQuestion(
            id: 'planted_q1',
            question: 'How do plants help with water quality?',
            options: [
              'They add oxygen only',
              'They absorb nitrate and ammonia',
              'They make the water harder',
              'They increase pH',
            ],
            correctIndex: 1,
            explanation:
                'Plants absorb nitrate and ammonia as fertilizer, providing natural filtration.',
          ),
        ],
      ),
    ),
    // Lesson 2: Light and Nutrients
    Lesson(
      id: 'planted_light',
      pathId: 'planted',
      title: 'Light & Nutrients',
      description: 'What plants need to thrive',
      orderIndex: 1,
      xpReward: 50,
      estimatedMinutes: 5,
      prerequisites: ['planted_basics'],
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'The Plant Growth Triangle',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Plants need three things to grow: light, CO2, and nutrients. These must be balanced - too much of one without the others causes algae problems.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Lighting Basics',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'For low-tech planted tanks, aim for 6-8 hours of moderate light daily. Too much light without CO2 injection = algae explosion.',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              'A timer is essential! Consistent photoperiod (light schedule) prevents algae and keeps plants healthy. Set it and forget it.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Nutrients',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Fish waste provides some nutrients, but planted tanks often need supplements. Root feeders (swords, crypts) benefit from root tabs. Stem plants prefer liquid fertilizers.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Macro nutrients: Nitrogen, Phosphorus, Potassium (NPK)\n• Micro nutrients: Iron, manganese, etc.\n• Root tabs: Slow-release fertilizer for substrate\n• Liquid ferts: Dose into water column weekly',
        ),
        const LessonSection(
          type: LessonSectionType.warning,
          content:
              'Start with less fertilizer than recommended. It\'s easier to add more than to fix algae from over-fertilizing.',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'For beginners: Get a basic all-in-one liquid fertilizer and dose once a week. Keep it simple until you understand your tank\'s needs.',
        ),
      ],
      quiz: Quiz(
        id: 'planted_light_quiz',
        lessonId: 'planted_light',
        questions: [
          const QuizQuestion(
            id: 'planted_light_q1',
            question: 'What happens with too much light but no CO2?',
            options: [
              'Plants grow faster',
              'Fish get stressed',
              'Algae explosion',
              'Water gets cloudy',
            ],
            correctIndex: 2,
            explanation:
                'Light, CO2, and nutrients must be balanced. Excess light without CO2 feeds algae instead of plants.',
          ),
          const QuizQuestion(
            id: 'planted_light_q2',
            question: 'Why use a timer for lights?',
            options: [
              'To save electricity',
              'Consistent photoperiod prevents algae',
              'Fish need darkness to sleep',
              'All of the above',
            ],
            correctIndex: 3,
            explanation:
                'All correct! Timers save power, give fish rest, and maintain consistent light that prevents algae.',
          ),
        ],
      ),
    ),

    // Lesson 3: Substrate Types
    Lesson(
      id: 'planted_substrate',
      pathId: 'planted',
      title: 'Substrate: The Foundation',
      description: 'Gravel vs sand vs aquasoil - choosing wisely',
      orderIndex: 2,
      xpReward: 50,
      estimatedMinutes: 5,
      prerequisites: ['planted_light'],
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'The Ground Beneath Everything',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Substrate isn\'t just decoration - it\'s where root-feeding plants get nutrients, where beneficial bacteria colonize, and what sets the foundation for your entire aquascape.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Regular Gravel: The Basic Choice',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Standard aquarium gravel is inert - it doesn\'t add or remove anything from your water. It provides anchoring for plants but no nutrients.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '✅ Pros: Cheap, easy to clean, wide color choices\n❌ Cons: No nutrients for plants, root-feeders need root tabs',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Sand: The Natural Look',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Fine sand looks natural and works great for certain plants (cryptocoryne love it). But it compacts easily, creating anaerobic pockets where harmful gases build up.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '✅ Pros: Natural appearance, good for some plants, fish love it\n❌ Cons: Compacts easily, can trap debris, harder to clean, no nutrients',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'If using sand, add Malaysian trumpet snails! They burrow constantly, which prevents dangerous compaction by aerating the substrate.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Aquasoil: The Plant Powerhouse',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Specialized planted tank substrate (ADA Aquasoil, Fluval Stratum) is nutrient-rich, lowers pH, and grows plants like crazy. This is the choice for serious planted tanks.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '✅ Pros: Rich in nutrients, lowers pH (good for many plants), excellent for root-feeders, great for planted tanks\n❌ Cons: Expensive, breaks down over time (2-3 years), can\'t be cleaned/vacuumed initially',
        ),
        const LessonSection(
          type: LessonSectionType.warning,
          content:
              'Aquasoil releases ammonia during the first 2-6 weeks! You MUST cycle it thoroughly before adding fish. Many beginners skip this and kill their fish.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'DIY: Dirt Capped with Sand/Gravel',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'The "Walstad method" uses organic potting soil capped with 2-3cm of sand. Extremely nutrient-rich and cheap, but messy if disturbed and can cause algae blooms.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Choosing for Your Setup',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Low-tech planted: Gravel + root tabs\n• High-tech planted: Aquasoil\n• Carpet plants (HC, Monte Carlo): Aquasoil or sand\n• Stem plants: Any substrate (they feed from water column)\n• Budget conscious: Gravel + liquid ferts',
        ),
        const LessonSection(
          type: LessonSectionType.funFact,
          content:
              'Some aquascapers use different substrates in different areas! Aquasoil in planted sections, sand in foreground for contrast. Mix and match for aesthetics and function.',
        ),
      ],
      quiz: Quiz(
        id: 'planted_substrate_quiz',
        lessonId: 'planted_substrate',
        questions: [
          const QuizQuestion(
            id: 'plant_sub_q1',
            question: 'What does "inert" substrate mean?',
            options: [
              'It actively releases nutrients',
              'It doesn\'t affect water chemistry or provide nutrients',
              'It kills plants',
              'It\'s the best type',
            ],
            correctIndex: 1,
            explanation:
                'Inert substrate (like regular gravel) doesn\'t add or remove anything from your water. It\'s chemically neutral.',
          ),
          const QuizQuestion(
            id: 'plant_sub_q2',
            question: 'What\'s the main problem with sand substrate?',
            options: [
              'Too expensive',
              'Compacts easily, creating anaerobic pockets',
              'Plants hate it',
              'Fish can\'t swim over it',
            ],
            correctIndex: 1,
            explanation:
                'Sand compacts easily, creating low-oxygen zones where harmful gases build up. Malaysian trumpet snails help by burrowing and aerating.',
          ),
          const QuizQuestion(
            id: 'plant_sub_q3',
            question: 'Why does aquasoil need to be cycled before adding fish?',
            options: [
              'It\'s too soft',
              'It releases ammonia initially',
              'It changes color',
              'Fish don\'t like the texture',
            ],
            correctIndex: 1,
            explanation:
                'Aquasoil releases ammonia for 2-6 weeks as organic matter breaks down. You must cycle it like a new tank before adding fish!',
          ),
          const QuizQuestion(
            id: 'plant_sub_q4',
            question: 'Which substrate is best for low-budget planted tanks?',
            options: [
              'Expensive aquasoil only',
              'Pure sand',
              'Gravel with root tabs',
              'No substrate',
            ],
            correctIndex: 2,
            explanation:
                'Regular gravel plus root tabs for root-feeders works great! Add liquid fertilizer for stem plants. Affordable and effective.',
          ),
          const QuizQuestion(
            id: 'plant_sub_q5',
            question: 'What helps prevent sand compaction?',
            options: [
              'Daily stirring with stick',
              'Malaysian trumpet snails (burrow constantly)',
              'Adding more sand on top',
              'Can\'t be prevented',
            ],
            correctIndex: 1,
            explanation:
                'Malaysian trumpet snails burrow constantly, aerating sand and preventing dangerous compaction. They\'re the planted tank\'s best friend!',
          ),
        ],
      ),
    ),

    // Lesson 4: CO2 Injection
    Lesson(
      id: 'planted_co2',
      pathId: 'planted',
      title: 'CO2: Is It Worth It?',
      description: 'Understanding carbon dioxide injection',
      orderIndex: 3,
      xpReward: 75,
      estimatedMinutes: 6,
      prerequisites: ['planted_substrate'],
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'The CO2 Controversy',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Walk into any planted tank forum and mention CO2 - half the people swear it\'s essential, the other half say it\'s overkill. Who\'s right? Both, depending on your goals.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Why Plants Need CO2',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Plants use CO2, light, and nutrients for photosynthesis. Atmospheric CO2 dissolves into water naturally, but only at 3-5 ppm - not much. Most demanding plants want 20-30 ppm for optimal growth.',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              'The CO2-Light-Nutrients triangle must balance! High light + low CO2 = algae explosion. Adding CO2 lets you use brighter lights and grow demanding species.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Low-Tech (No CO2): The Easy Path',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '✅ Pros: Cheaper, simpler, more stable\n✅ Grow: Java fern, Anubias, Crypts, most stems\n❌ Can\'t grow: Carpet plants, HC Cuba, demanding reds',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Low-tech tanks work beautifully! Just use moderate light (6-7 hours), easy plants, and liquid fertilizer. Many stunning tanks are low-tech.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Liquid Carbon (Seachem Excel)',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Excel isn\'t actually CO2 - it\'s glutaraldehyde, which plants can use as a carbon source. It helps, but it\'s not as effective as pressurized CO2. Also kills some algae!',
        ),
        const LessonSection(
          type: LessonSectionType.warning,
          content:
              'Excel (glutaraldehyde) is NOT SAFE for shrimp tanks at any dose. Even trace amounts can kill shrimp. If you have shrimp, use alternative CO2 methods like pressurized CO2 or stick with low-tech plants. Excel can also melt certain plants (Vallisneria, some mosses).',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'DIY CO2: The Middle Ground',
        ),
        const LessonSection(
          type: LessonSectionType.warning,
          content:
              'DIY CO2 systems are unpredictable and can crash — if the yeast stops producing CO2 while plants have adapted to high CO2 levels, pH swings can occur. In severe cases, a sudden die-off of plants can deplete oxygen overnight, potentially suffocating fish. Always ensure good surface agitation as a safety net, monitor pH regularly, and never rely on DIY CO2 as your only carbon source in a stocked tank. Pressurized CO2 with a regulator and drop checker is far safer.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Pressurized CO2: The Professional Setup',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'A CO2 cylinder, regulator, needle valve, and diffuser provide precise control. Expensive upfront (\$150-300) but the results are stunning - vivid colors, fast growth, carpet plants.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '✅ Pros: Precise control, consistent, grows anything, amazing results\n❌ Cons: Expensive, requires monitoring, can kill fish if overdosed',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'Use a drop checker! This glass indicator shows your CO2 level - blue (too low), green (perfect), yellow (dangerous). Essential for safety.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Should YOU Use CO2?',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Start low-tech. Master easy plants, learn aquascaping, get comfortable with fertilizers. THEN consider CO2 if you want to grow demanding species or create competition-level aquascapes.',
        ),
        const LessonSection(
          type: LessonSectionType.funFact,
          content:
              'The world\'s largest planted aquarium (the Oceanário de Lisboa in Portugal) holds 5 million litres and uses over 8,000 individual plants — maintained by a full-time team of aquascapers.',
        ),
      ],
      quiz: Quiz(
        id: 'planted_co2_quiz',
        lessonId: 'planted_co2',
        questions: [
          const QuizQuestion(
            id: 'plant_co2_q1',
            question: 'What happens with high light but low CO2?',
            options: [
              'Plants grow faster',
              'Algae explosion',
              'Water turns blue',
              'Fish grow faster',
            ],
            correctIndex: 1,
            explanation:
                'Light, CO2, and nutrients must balance! High light with low CO2 means excess light energy with nowhere to go - algae loves this.',
          ),
          const QuizQuestion(
            id: 'plant_co2_q2',
            question: 'What is Seachem Excel?',
            options: [
              'Pure CO2 in liquid form',
              'Glutaraldehyde (carbon source + mild algaecide)',
              'Plant fertilizer',
              'pH buffer',
            ],
            correctIndex: 1,
            explanation:
                'Excel is glutaraldehyde - not true CO2, but plants can use it as a carbon source. It also kills some algae types.',
          ),
          const QuizQuestion(
            id: 'plant_co2_q3',
            question: 'What\'s the main problem with DIY yeast CO2?',
            options: [
              'Too expensive',
              'Inconsistent production, can crash overnight',
              'Doesn\'t work at all',
              'Too powerful',
            ],
            correctIndex: 1,
            explanation:
                'DIY CO2 is unpredictable - production varies daily and can spike or crash overnight, potentially killing fish.',
          ),
          const QuizQuestion(
            id: 'plant_co2_q4',
            question: 'What does a drop checker do?',
            options: [
              'Measures temperature',
              'Shows CO2 level (blue/green/yellow)',
              'Feeds fish automatically',
              'Tests pH',
            ],
            correctIndex: 1,
            explanation:
                'Drop checkers visually show CO2 levels: blue = too low, green = perfect, yellow = dangerously high. Essential safety tool!',
          ),
          const QuizQuestion(
            id: 'plant_co2_q5',
            question: 'Should beginners start with pressurized CO2?',
            options: [
              'Yes, immediately',
              'No - master low-tech first',
              'Only if they have lots of money',
              'Doesn\'t matter',
            ],
            correctIndex: 1,
            explanation:
                'Master low-tech planted tanks first! Learn plant care, fertilization, and aquascaping basics before investing in complex CO2 systems.',
          ),
        ],
      ),
    ),

    // Lesson 5: Plant Propagation
    Lesson(
      id: 'planted_propagation',
      pathId: 'planted',
      title: 'Plant Propagation: Growing Your Own',
      description: 'Multiply your plants for free!',
      orderIndex: 4,
      xpReward: 50,
      estimatedMinutes: 5,
      prerequisites: ['planted_co2'],
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Why Buy When You Can Grow?',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Plants are expensive! But here\'s the secret: one healthy plant becomes dozens through propagation. Learn these simple techniques and you\'ll never buy plants again.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Stem Plants: Trimming = Multiplying',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Rotala, bacopa, ludwigia, and most stem plants propagate effortlessly. Just cut the stem, replant the top portion, and BOTH pieces grow! The cut stem sprouts new shoots, the cutting develops roots.',
        ),
        const LessonSection(
          type: LessonSectionType.numberedList,
          content:
              '1. Cut stem with sharp scissors (clean cut prevents rot)\n2. Remove bottom 1-2 leaves from cutting\n3. Plant cutting 2-3cm into substrate\n4. Original stem will sprout 2+ new shoots\n5. Wait 2-3 weeks, repeat - exponential growth!',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'When trimming stem plants, cut just above a node (leaf junction). This encourages bushier growth and creates better cuttings.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Rhizome Plants: Division',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Anubias, Java fern, and similar plants grow from a horizontal stem (rhizome). Cut the rhizome into sections (each with 3-4 leaves) and you\'ve got new plants!',
        ),
        const LessonSection(
          type: LessonSectionType.warning,
          content:
              'Never bury rhizomes in substrate! They\'ll rot. Attach to rocks or driftwood with thread or superglue gel. Roots will grab on naturally.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Runners and Offshoots',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Some plants (Vallisneria, Amazon swords, some crypts) send out runners with baby plantlets. Let them grow 4-5 leaves, then cut the runner - free plant!',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Adventitious Plantlets',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Java fern and some other plants grow baby plants on their leaves! These drop off naturally or can be gently removed and attached elsewhere. Nature\'s cloning!',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Mosses: The Easiest',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Java moss, Christmas moss, etc. propagate ridiculously easily. Tear off a small piece, attach it anywhere, and it grows. You literally can\'t kill it by dividing it.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Creating a Plant Farm',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Dedicated plant growing tanks with high light, CO2, and fertilizers produce trimmings weekly! Some aquarists sell excess plants online - their hobby pays for itself.',
        ),
        const LessonSection(
          type: LessonSectionType.funFact,
          content:
              'One Amazon sword can produce 30+ baby plants in a year via runners. Buy one plant, wait a year, have enough to fill 5 tanks! Patience = free plants.',
        ),
      ],
      quiz: Quiz(
        id: 'planted_propagation_quiz',
        lessonId: 'planted_propagation',
        questions: [
          const QuizQuestion(
            id: 'plant_prop_q1',
            question: 'How do you propagate stem plants?',
            options: [
              'Cut stem and replant the top portion',
              'Pull them up by roots',
              'Leave them alone',
              'Add special chemicals',
            ],
            correctIndex: 0,
            explanation:
                'Cut the stem, replant the top cutting - both pieces continue growing! The original sprouts new shoots, the cutting develops roots.',
          ),
          const QuizQuestion(
            id: 'plant_prop_q2',
            question: 'Should you bury Anubias rhizomes in substrate?',
            options: [
              'Yes, deeply',
              'Yes, just a bit',
              'No - they\'ll rot if buried',
              'Doesn\'t matter',
            ],
            correctIndex: 2,
            explanation:
                'NEVER bury rhizomes! They need water flow and will rot if buried. Attach them to rocks or wood instead.',
          ),
          const QuizQuestion(
            id: 'plant_prop_q3',
            question: 'What are runners?',
            options: [
              'Fish that swim fast',
              'Stems that grow horizontally and produce baby plants',
              'Root vegetables',
              'Types of filters',
            ],
            correctIndex: 1,
            explanation:
                'Runners are horizontal stems (like strawberry runners) that produce baby plantlets. Swords, vals, and crypts do this!',
          ),
          const QuizQuestion(
            id: 'plant_prop_q4',
            question: 'When can you separate a baby plant from a runner?',
            options: [
              'Immediately',
              'After it has 1-2 leaves',
              'After it has 4-5 leaves and roots',
              'Never separate them',
            ],
            correctIndex: 2,
            explanation:
                'Wait until the baby has 4-5 leaves and visible roots. Then cut the runner - the plantlet can survive independently!',
          ),
          const QuizQuestion(
            id: 'plant_prop_q5',
            question: 'What\'s the easiest plant to propagate?',
            options: [
              'Java moss (tear and attach anywhere)',
              'Difficult carpet plants',
              'Lotus flowers',
              'Can\'t propagate plants',
            ],
            correctIndex: 0,
            explanation:
                'Mosses are ridiculously easy! Tear off any piece, attach it to anything, and it grows. Nearly indestructible.',
          ),
        ],
      ),
    ),
  ],
);
