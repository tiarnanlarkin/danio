/// Lesson content for the learning system
/// The "Duolingo for fishkeeping" curriculum

import '../models/learning.dart';
import '../models/user_profile.dart';

/// All learning paths available in the app
class LessonContent {
  static List<LearningPath> get allPaths => [
    nitrogenCyclePath,
    waterParametersPath,
    firstFishPath,
    maintenancePath,
    plantedTankPath,
  ];

  // ==========================================
  // NITROGEN CYCLE PATH - The Most Important!
  // ==========================================
  static final nitrogenCyclePath = LearningPath(
    id: 'nitrogen_cycle',
    title: 'The Nitrogen Cycle',
    description: 'The #1 thing every fishkeeper must understand. This is why fish die in new tanks.',
    emoji: '🔄',
    recommendedFor: [ExperienceLevel.beginner],
    orderIndex: 0,
    lessons: [
      // Lesson 1: What is the Nitrogen Cycle?
      Lesson(
        id: 'nc_intro',
        pathId: 'nitrogen_cycle',
        title: 'Why New Tanks Kill Fish',
        description: 'The hidden danger in every new aquarium',
        orderIndex: 0,
        xpReward: 50,
        estimatedMinutes: 4,
        sections: [
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'The Most Common Mistake',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content: "You buy a beautiful new tank, fill it with water, add some fish... and within a week, they're dead. Sound familiar? You're not alone. This happens to almost every beginner, and it's completely preventable.",
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content: 'New Tank Syndrome is the #1 killer of aquarium fish. It happens because the tank hasn\'t developed the beneficial bacteria needed to process fish waste.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'What Actually Happens',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content: 'Fish produce waste. That waste breaks down into ammonia - a toxic chemical that burns fish gills and can kill within hours at high levels. In nature, bacteria consume this ammonia. In a new tank, those bacteria don\'t exist yet.',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content: 'Ammonia is invisible. Your water can look crystal clear while being deadly toxic. This is why testing is essential.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'The Solution: Cycling',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content: '"Cycling" your tank means growing colonies of beneficial bacteria before adding fish. These bacteria convert toxic ammonia into less harmful substances. This process takes 2-6 weeks - but it\'s worth the wait.',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content: 'Patience is the most important skill in fishkeeping. A cycled tank is a stable tank.',
          ),
        ],
        quiz: Quiz(
          id: 'nc_intro_quiz',
          lessonId: 'nc_intro',
          questions: [
            const QuizQuestion(
              id: 'nc_intro_q1',
              question: 'What is "New Tank Syndrome"?',
              options: [
                'When a tank leaks water',
                'Fish dying due to lack of beneficial bacteria',
                'Algae growing too fast',
                'The tank being too cold',
              ],
              correctIndex: 1,
              explanation: 'New Tank Syndrome occurs when ammonia builds up because beneficial bacteria haven\'t established yet.',
            ),
            const QuizQuestion(
              id: 'nc_intro_q2',
              question: 'Can you tell if water has ammonia just by looking at it?',
              options: [
                'Yes, it turns green',
                'Yes, it becomes cloudy',
                'No, ammonia is invisible',
                'Yes, it smells bad',
              ],
              correctIndex: 2,
              explanation: 'Ammonia is colorless and odorless at typical aquarium levels. Only a test kit can detect it.',
            ),
            const QuizQuestion(
              id: 'nc_intro_q3',
              question: 'How long does it typically take to cycle a new tank?',
              options: [
                '1-2 days',
                '2-6 weeks',
                '6 months',
                'Tanks don\'t need cycling',
              ],
              correctIndex: 1,
              explanation: 'Cycling typically takes 2-6 weeks. Patience during this phase prevents fish deaths later.',
            ),
          ],
        ),
      ),

      // Lesson 2: The Three Stages
      Lesson(
        id: 'nc_stages',
        pathId: 'nitrogen_cycle',
        title: 'Ammonia → Nitrite → Nitrate',
        description: 'Understanding the three stages of the cycle',
        orderIndex: 1,
        xpReward: 50,
        estimatedMinutes: 5,
        prerequisites: ['nc_intro'],
        sections: [
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Stage 1: Ammonia (NH₃)',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content: 'Fish waste, uneaten food, and decaying plants all produce ammonia. In a new tank, ammonia levels rise quickly because there\'s nothing to consume it.',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content: 'Ammonia is highly toxic. Even 0.25 ppm can stress fish. Above 1 ppm is often fatal.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Stage 2: Nitrite (NO₂)',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content: 'After 1-2 weeks, bacteria called Nitrosomonas start consuming ammonia. But they produce nitrite as a byproduct - which is also toxic to fish!',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content: 'The nitrite spike is often the most dangerous phase. Fish can survive low ammonia but nitrite poisoning ("brown blood disease") is very harmful.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Stage 3: Nitrate (NO₃)',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content: 'A second type of bacteria (Nitrobacter) converts nitrite into nitrate. Nitrate is much less toxic - fish can tolerate levels up to 20-40 ppm.',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content: 'Nitrate doesn\'t just disappear - it builds up over time. This is why we do water changes: to remove accumulated nitrate.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'The Complete Picture',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content: '• Fish waste → Ammonia (toxic)\n• Bacteria #1 → Nitrite (toxic)\n• Bacteria #2 → Nitrate (safer)\n• Water changes → Remove nitrate',
          ),
          const LessonSection(
            type: LessonSectionType.funFact,
            content: 'In heavily planted tanks, live plants also absorb nitrate as fertilizer. Some aquarists with lots of plants rarely need water changes!',
          ),
        ],
        quiz: Quiz(
          id: 'nc_stages_quiz',
          lessonId: 'nc_stages',
          questions: [
            const QuizQuestion(
              id: 'nc_stages_q1',
              question: 'What\'s the correct order of the nitrogen cycle?',
              options: [
                'Nitrate → Nitrite → Ammonia',
                'Nitrite → Ammonia → Nitrate',
                'Ammonia → Nitrite → Nitrate',
                'Ammonia → Nitrate → Nitrite',
              ],
              correctIndex: 2,
              explanation: 'Ammonia is produced first, then converted to nitrite, then to nitrate.',
            ),
            const QuizQuestion(
              id: 'nc_stages_q2',
              question: 'Which is the safest for fish at typical levels?',
              options: [
                'Ammonia',
                'Nitrite',
                'Nitrate',
                'They\'re all equally dangerous',
              ],
              correctIndex: 2,
              explanation: 'Nitrate is the end product and is much less toxic. Fish can tolerate 20-40 ppm.',
            ),
            const QuizQuestion(
              id: 'nc_stages_q3',
              question: 'How do we remove nitrate from the tank?',
              options: [
                'It evaporates naturally',
                'The filter removes it',
                'Water changes',
                'It converts to oxygen',
              ],
              correctIndex: 2,
              explanation: 'Nitrate builds up over time. Regular water changes are the primary way to remove it.',
            ),
          ],
        ),
      ),

      // Lesson 3: How to Cycle Your Tank
      Lesson(
        id: 'nc_how_to',
        pathId: 'nitrogen_cycle',
        title: 'How to Cycle Your Tank',
        description: 'Step-by-step guide to fishless cycling',
        orderIndex: 2,
        xpReward: 75,
        estimatedMinutes: 6,
        prerequisites: ['nc_stages'],
        sections: [
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Fishless Cycling: The Humane Way',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content: 'The old method was to add "hardy" fish and hope they survive the ammonia spike. Today we know better. Fishless cycling grows your bacteria without harming any animals.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'What You\'ll Need',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content: '• A test kit (API Master Test Kit recommended)\n• Ammonia source (pure ammonia or fish food)\n• Patience (4-6 weeks)\n• A running filter',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Step 1: Set Up Your Tank',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content: 'Install your filter, heater, and decorations. Fill with dechlorinated water. Let everything run for 24 hours to stabilize temperature.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Step 2: Add Ammonia',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content: 'Add pure ammonia (with no additives) until your test reads 2-4 ppm. Or drop in fish food and let it decay - less precise but works.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Step 3: Test & Wait',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content: 'Test every 2-3 days. You\'ll see ammonia rise, then fall as bacteria grow. Then nitrite spikes. Keep ammonia at 2-4 ppm throughout.',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content: 'Your tank is cycled when: Ammonia drops to 0, Nitrite drops to 0, and Nitrate is present. This means both bacteria colonies are established.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Step 4: Add Fish Slowly',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content: 'Do a large water change to reduce nitrate, then add fish gradually. Your bacteria colony needs time to grow to handle increased bioload.',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content: 'Bottled bacteria (like Seachem Stability) can speed up cycling, but isn\'t a magic fix. Still expect 2-4 weeks minimum.',
          ),
        ],
        quiz: Quiz(
          id: 'nc_how_to_quiz',
          lessonId: 'nc_how_to',
          questions: [
            const QuizQuestion(
              id: 'nc_how_to_q1',
              question: 'How do you know your tank is fully cycled?',
              options: [
                'The water looks clear',
                'It\'s been running for a week',
                'Ammonia and nitrite are 0, nitrate is present',
                'The filter is making bubbles',
              ],
              correctIndex: 2,
              explanation: 'A cycled tank processes ammonia to nitrite to nitrate. Zero ammonia + zero nitrite + some nitrate = cycled!',
            ),
            const QuizQuestion(
              id: 'nc_how_to_q2',
              question: 'What ammonia level should you maintain during fishless cycling?',
              options: [
                '0 ppm',
                '2-4 ppm',
                '10+ ppm',
                'As high as possible',
              ],
              correctIndex: 1,
              explanation: '2-4 ppm provides enough food for bacteria without overdoing it. Too high can actually slow the process.',
            ),
            const QuizQuestion(
              id: 'nc_how_to_q3',
              question: 'After cycling, should you add all your fish at once?',
              options: [
                'Yes, the tank is ready',
                'No, add them gradually over weeks',
                'Only if they\'re small fish',
                'It doesn\'t matter',
              ],
              correctIndex: 1,
              explanation: 'Adding fish gradually lets your bacteria colony grow to match the increased waste production.',
            ),
          ],
        ),
      ),
    ],
  );

  // ==========================================
  // WATER PARAMETERS PATH
  // ==========================================
  static final waterParametersPath = LearningPath(
    id: 'water_parameters',
    title: 'Water Parameters 101',
    description: 'Understanding pH, temperature, hardness and more',
    emoji: '💧',
    recommendedFor: [ExperienceLevel.beginner],
    orderIndex: 1,
    lessons: [
      Lesson(
        id: 'wp_ph',
        pathId: 'water_parameters',
        title: 'pH: Acid vs Alkaline',
        description: 'What pH means and why it matters',
        orderIndex: 0,
        xpReward: 50,
        estimatedMinutes: 4,
        sections: [
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'The pH Scale',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content: 'pH measures how acidic or alkaline (basic) your water is. The scale runs from 0 (very acidic) to 14 (very alkaline), with 7 being neutral.',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content: 'Most tropical fish thrive between pH 6.5-7.5. Some species prefer more acidic (tetras, discus) or alkaline (African cichlids) water.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Stability Over Perfection',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content: 'Here\'s the secret most beginners don\'t know: stable pH is more important than "perfect" pH. Fish can adapt to a range of pH levels, but sudden changes are stressful.',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content: 'Avoid "pH adjusters" and chemicals. They cause dangerous swings. It\'s better to keep fish suited to your tap water\'s natural pH.',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content: 'Test your tap water\'s pH. That\'s your baseline. Choose fish that thrive at that pH rather than fighting to change it.',
          ),
        ],
        quiz: Quiz(
          id: 'wp_ph_quiz',
          lessonId: 'wp_ph',
          questions: [
            const QuizQuestion(
              id: 'wp_ph_q1',
              question: 'What pH is considered neutral?',
              options: ['0', '5', '7', '14'],
              correctIndex: 2,
              explanation: 'pH 7 is neutral - neither acidic nor alkaline.',
            ),
            const QuizQuestion(
              id: 'wp_ph_q2',
              question: 'What\'s more important for fish health?',
              options: [
                'Having exactly pH 7.0',
                'Stable pH with minimal fluctuations',
                'Low pH below 6.0',
                'High pH above 8.0',
              ],
              correctIndex: 1,
              explanation: 'Fish adapt to various pH levels, but sudden changes cause stress. Stability is key.',
            ),
          ],
        ),
      ),
      Lesson(
        id: 'wp_temp',
        pathId: 'water_parameters',
        title: 'Temperature Control',
        description: 'Keeping your tank at the right temperature',
        orderIndex: 1,
        xpReward: 50,
        estimatedMinutes: 4,
        prerequisites: ['wp_ph'],
        sections: [
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Fish Are Cold-Blooded',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content: 'Fish can\'t regulate their body temperature like we can. They depend entirely on their environment. Wrong temperature = stressed fish = sick fish.',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content: 'Most tropical fish need 24-28°C (75-82°F). Coldwater fish like goldfish prefer 18-22°C (64-72°F). Always research your specific species.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Heaters and Thermometers',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content: 'For tropical tanks, a reliable heater is essential. Get one rated for your tank size (usually 3-5 watts per litre). Always use a separate thermometer to verify - built-in heater dials are often inaccurate.',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content: 'Place your heater near water flow (filter outlet) for even heat distribution. Avoid placing near windows where sunlight causes temperature swings.',
          ),
        ],
        quiz: Quiz(
          id: 'wp_temp_quiz',
          lessonId: 'wp_temp',
          questions: [
            const QuizQuestion(
              id: 'wp_temp_q1',
              question: 'What temperature range do most tropical fish need?',
              options: [
                '10-15°C (50-59°F)',
                '18-22°C (64-72°F)',
                '24-28°C (75-82°F)',
                '30-35°C (86-95°F)',
              ],
              correctIndex: 2,
              explanation: 'Most tropical fish thrive at 24-28°C. Colder is for coldwater species, hotter is usually only for treating disease.',
            ),
          ],
        ),
      ),
      // Lesson 3: GH and KH
      Lesson(
        id: 'wp_hardness',
        pathId: 'water_parameters',
        title: 'Water Hardness (GH & KH)',
        description: 'Understanding mineral content in your water',
        orderIndex: 2,
        xpReward: 50,
        estimatedMinutes: 5,
        prerequisites: ['wp_temp'],
        sections: [
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'What is Water Hardness?',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content: 'Hardness refers to the mineral content in your water - mainly calcium and magnesium. There are two types: GH (General Hardness) and KH (Carbonate Hardness).',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'GH - General Hardness',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content: 'GH measures calcium and magnesium ions. Fish need these minerals for healthy bones, scales, and egg development. Soft water has low GH; hard water has high GH.',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content: 'Most tropical fish do well in GH 4-12 dGH. Livebearers (guppies, mollies) prefer harder water (10-20 dGH). Soft water fish (tetras, discus) prefer 2-8 dGH.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'KH - Carbonate Hardness',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content: 'KH measures carbonates and bicarbonates - these act as a pH buffer. Higher KH means your pH is more stable and resistant to swings.',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content: 'Low KH (below 3 dKH) can cause dangerous pH crashes, especially overnight when plants release CO2. If your KH is very low, consider adding crushed coral or baking soda.',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content: 'Test your tap water first! Your local water company may have data online. Knowing your tap water hardness helps you choose compatible fish.',
          ),
          const LessonSection(
            type: LessonSectionType.funFact,
            content: 'Some aquarists use rainwater or RO (reverse osmosis) water to create soft water for sensitive species. But for most beginners, tap water works fine!',
          ),
        ],
        quiz: Quiz(
          id: 'wp_hardness_quiz',
          lessonId: 'wp_hardness',
          questions: [
            const QuizQuestion(
              id: 'wp_hardness_q1',
              question: 'What does KH help stabilize?',
              options: [
                'Temperature',
                'pH',
                'Ammonia',
                'Nitrate',
              ],
              correctIndex: 1,
              explanation: 'KH (carbonate hardness) acts as a pH buffer, preventing dangerous pH swings.',
            ),
            const QuizQuestion(
              id: 'wp_hardness_q2',
              question: 'Which fish prefer harder water (high GH)?',
              options: [
                'Tetras and discus',
                'Bettas',
                'Livebearers like guppies and mollies',
                'Corydoras catfish',
              ],
              correctIndex: 2,
              explanation: 'Livebearers come from hard water environments and thrive at GH 10-20 dGH.',
            ),
          ],
        ),
      ),
    ],
  );

  // ==========================================
  // FIRST FISH PATH
  // ==========================================
  static final firstFishPath = LearningPath(
    id: 'first_fish',
    title: 'Your First Fish',
    description: 'Choosing and caring for beginner-friendly fish',
    emoji: '🐠',
    recommendedFor: [ExperienceLevel.beginner],
    orderIndex: 2,
    lessons: [
      Lesson(
        id: 'ff_choosing',
        pathId: 'first_fish',
        title: 'Choosing Hardy Species',
        description: 'Best fish for beginners',
        orderIndex: 0,
        xpReward: 50,
        estimatedMinutes: 5,
        sections: [
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Not All Fish Are Equal',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content: 'Some fish forgive beginner mistakes. Others die at the slightest water quality issue. Start with hardy species that can handle the learning curve.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Great Beginner Fish',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content: '• Guppies - colorful, active, breed easily\n• Platies - peaceful, many colors\n• Corydoras catfish - cute bottom-dwellers, social\n• Zebra danios - active schoolers, very hardy\n• Cherry barbs - peaceful, beautiful red color\n• Bristlenose plecos - algae eaters, interesting',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Fish to Avoid (For Now)',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content: '• Discus - require pristine water quality\n• Oscars - grow huge, need massive tanks\n• Common plecos - grow to 60cm+\n• Goldfish in tropical tanks - different needs\n• Betta with fin-nippers - stress easily',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content: 'Research BEFORE you buy. Know the adult size, tank requirements, and compatibility of any fish you\'re considering.',
          ),
        ],
      ),
      // Lesson 2: Acclimation
      Lesson(
        id: 'ff_acclimation',
        pathId: 'first_fish',
        title: 'Bringing Fish Home',
        description: 'How to safely acclimate new fish',
        orderIndex: 1,
        xpReward: 50,
        estimatedMinutes: 5,
        prerequisites: ['ff_choosing'],
        sections: [
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'The Journey Home',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content: 'You\'ve picked your fish - exciting! But the trip from store to tank is stressful for fish. Sudden changes in temperature or water chemistry can shock or kill them.',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content: 'Never dump fish straight into your tank! The bag water and your tank water are likely very different in temperature, pH, and hardness.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Float Method (Simple)',
          ),
          const LessonSection(
            type: LessonSectionType.numberedList,
            content: '1. Float the sealed bag in your tank for 15-20 minutes (equalizes temperature)\n2. Open the bag and add a small cup of tank water\n3. Wait 5 minutes, then add another cup\n4. Repeat 3-4 times over 30-45 minutes\n5. Net the fish into the tank - discard the bag water',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Drip Method (Better)',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content: 'For sensitive fish or big water parameter differences: Put fish and bag water in a bucket. Use airline tubing with a knot to drip tank water in slowly (2-3 drips per second) for 1-2 hours until the water volume doubles.',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content: 'Never add store water to your tank! It may contain diseases, parasites, or medications. Always net the fish and discard the bag water.',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content: 'Keep lights dim for the first few hours. New fish are stressed and bright lights make it worse. Let them explore and find hiding spots.',
          ),
        ],
        quiz: Quiz(
          id: 'ff_acclimation_quiz',
          lessonId: 'ff_acclimation',
          questions: [
            const QuizQuestion(
              id: 'ff_accl_q1',
              question: 'Why should you never add store bag water to your tank?',
              options: [
                'It\'s too cold',
                'It may contain diseases or parasites',
                'It has too much oxygen',
                'It\'s the wrong color',
              ],
              correctIndex: 1,
              explanation: 'Store water may carry diseases, parasites, or leftover medications that could harm your existing fish.',
            ),
            const QuizQuestion(
              id: 'ff_accl_q2',
              question: 'What does floating the bag accomplish?',
              options: [
                'Removes chlorine',
                'Feeds the fish',
                'Equalizes temperature',
                'Adds oxygen',
              ],
              correctIndex: 2,
              explanation: 'Floating allows the bag water temperature to slowly match your tank temperature.',
            ),
          ],
        ),
      ),
    ],
  );

  // ==========================================
  // MAINTENANCE PATH
  // ==========================================
  static final maintenancePath = LearningPath(
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
            content: 'Your filter removes particles and processes ammonia, but nitrate still builds up. Water changes are the only way to remove it and replenish trace minerals fish need.',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content: 'Aim for 20-30% water change weekly. This keeps nitrate low without shocking fish with big parameter swings.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'The Right Way',
          ),
          const LessonSection(
            type: LessonSectionType.numberedList,
            content: '1. Match temperature - new water should feel the same as tank water\n2. Add dechlorinator - tap water chlorine kills beneficial bacteria\n3. Use a gravel vacuum - removes debris while draining\n4. Don\'t overfill - leave room for the surface to breathe',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content: 'Never replace all the water at once. Massive changes shock fish and can crash your cycle. 50% max in emergencies.',
          ),
        ],
        quiz: Quiz(
          id: 'maint_wc_quiz',
          lessonId: 'maint_water_changes',
          questions: [
            const QuizQuestion(
              id: 'maint_wc_q1',
              question: 'How much water should you change weekly?',
              options: [
                '5-10%',
                '20-30%',
                '50-75%',
                '100%',
              ],
              correctIndex: 1,
              explanation: '20-30% weekly keeps nitrate low without shocking fish with big parameter changes.',
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
            content: 'Remember the nitrogen cycle? Most of your beneficial bacteria live in the filter media - the sponges, ceramic rings, and bio-balls inside your filter. These bacteria are keeping your fish alive!',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content: 'NEVER rinse filter media in tap water! Chlorine kills beneficial bacteria instantly. One mistake can crash your cycle and kill fish.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'How to Clean Filter Media',
          ),
          const LessonSection(
            type: LessonSectionType.numberedList,
            content: '1. During a water change, save some old tank water in a bucket\n2. Remove filter media and gently squeeze/swish in the OLD tank water\n3. You\'re removing gunk, not sterilizing - it should still look used\n4. Put media back and discard the dirty water\n5. Never replace all media at once - stagger replacements',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content: 'Only clean filter media when flow is noticeably reduced. Over-cleaning does more harm than good. Monthly is usually enough.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Replacing Media',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content: 'Sponges and bio-media rarely need replacing - just rinse them. Carbon should be replaced monthly if used. If you must replace sponges, only do one at a time with weeks between.',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content: 'Consider adding extra bio-media (ceramic rings, bio-balls) to your filter. More surface area = more bacteria = more stable tank.',
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
              explanation: 'Always use old tank water! Tap water contains chlorine that kills beneficial bacteria.',
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
              explanation: 'Only clean when necessary - when you notice reduced flow. Over-cleaning harms bacteria.',
            ),
          ],
        ),
      ),
    ],
  );

  // ==========================================
  // PLANTED TANK PATH
  // ==========================================
  static final plantedTankPath = LearningPath(
    id: 'planted',
    title: 'Planted Tanks',
    description: 'Growing live aquatic plants',
    emoji: '🌿',
    recommendedFor: [ExperienceLevel.intermediate],
    relevantTankTypes: [TankType.planted],
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
            content: 'Live plants aren\'t just decoration. They absorb nitrate, produce oxygen, provide hiding spots for fish, and compete with algae for nutrients.',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content: '• Natural filtration - absorb ammonia and nitrate\n• Oxygen production - especially during daylight\n• Stress reduction - fish feel safer with cover\n• Algae control - out-compete algae for nutrients\n• Natural beauty - nothing beats a planted tank',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Easy Starter Plants',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content: '• Java fern - attach to wood, low light\n• Anubias - slow growing, nearly indestructible\n• Java moss - great for shrimp, easy\n• Amazon sword - impressive centerpiece\n• Cryptocoryne - variety of sizes and colors',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content: 'Start with "low tech" plants that don\'t need CO2 injection or special lighting. Master these before going high-tech.',
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
              explanation: 'Plants absorb nitrate and ammonia as fertilizer, providing natural filtration.',
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
            content: 'Plants need three things to grow: light, CO2, and nutrients. These must be balanced - too much of one without the others causes algae problems.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Lighting Basics',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content: 'For low-tech planted tanks, aim for 6-8 hours of moderate light daily. Too much light without CO2 injection = algae explosion.',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content: 'A timer is essential! Consistent photoperiod (light schedule) prevents algae and keeps plants healthy. Set it and forget it.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Nutrients',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content: 'Fish waste provides some nutrients, but planted tanks often need supplements. Root feeders (swords, crypts) benefit from root tabs. Stem plants prefer liquid fertilizers.',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content: '• Macro nutrients: Nitrogen, Phosphorus, Potassium (NPK)\n• Micro nutrients: Iron, manganese, etc.\n• Root tabs: Slow-release fertilizer for substrate\n• Liquid ferts: Dose into water column weekly',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content: 'Start with less fertilizer than recommended. It\'s easier to add more than to fix algae from over-fertilizing.',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content: 'For beginners: Get a basic all-in-one liquid fertilizer and dose once a week. Keep it simple until you understand your tank\'s needs.',
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
              explanation: 'Light, CO2, and nutrients must be balanced. Excess light without CO2 feeds algae instead of plants.',
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
              explanation: 'All correct! Timers save power, give fish rest, and maintain consistent light that prevents algae.',
            ),
          ],
        ),
      ),
    ],
  );
}
