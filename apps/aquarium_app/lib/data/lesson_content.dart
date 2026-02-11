/// Lesson content for the learning system
/// The "Duolingo for fishkeeping" curriculum
library;

import '../models/tank.dart'; // For TankType enum
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
    equipmentPath,
    fishHealthPath,
    speciesCarePath,
    advancedTopicsPath,
  ];

  // ==========================================
  // NITROGEN CYCLE PATH - The Most Important!
  // ==========================================
  static final nitrogenCyclePath = LearningPath(
    id: 'nitrogen_cycle',
    title: 'The Nitrogen Cycle',
    description:
        'The #1 thing every fishkeeper must understand. This is why fish die in new tanks.',
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
            content:
                "You buy a beautiful new tank, fill it with water, add some fish... and within a week, they're dead. Sound familiar? You're not alone. This happens to almost every beginner, and it's completely preventable.",
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'New Tank Syndrome is the #1 killer of aquarium fish. It happens because the tank hasn\'t developed the beneficial bacteria needed to process fish waste.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'What Actually Happens',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Fish produce waste. That waste breaks down into ammonia - a toxic chemical that burns fish gills and can kill within hours at high levels. In nature, bacteria consume this ammonia. In a new tank, those bacteria don\'t exist yet.',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content:
                'Ammonia is invisible. Your water can look crystal clear while being deadly toxic. This is why testing is essential.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'The Solution: Cycling',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                '"Cycling" your tank means growing colonies of beneficial bacteria before adding fish. These bacteria convert toxic ammonia into less harmful substances. This process takes 2-6 weeks - but it\'s worth the wait.',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'Patience is the most important skill in fishkeeping. A cycled tank is a stable tank.',
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
              explanation:
                  'New Tank Syndrome occurs when ammonia builds up because beneficial bacteria haven\'t established yet.',
            ),
            const QuizQuestion(
              id: 'nc_intro_q2',
              question:
                  'Can you tell if water has ammonia just by looking at it?',
              options: [
                'Yes, it turns green',
                'Yes, it becomes cloudy',
                'No, ammonia is invisible',
                'Yes, it smells bad',
              ],
              correctIndex: 2,
              explanation:
                  'Ammonia is colorless and odorless at typical aquarium levels. Only a test kit can detect it.',
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
              explanation:
                  'Cycling typically takes 2-6 weeks. Patience during this phase prevents fish deaths later.',
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
            content:
                'Fish waste, uneaten food, and decaying plants all produce ammonia. In a new tank, ammonia levels rise quickly because there\'s nothing to consume it.',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content:
                'Ammonia is highly toxic. Even 0.25 ppm can stress fish. Above 1 ppm is often fatal.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Stage 2: Nitrite (NO₂)',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'After 1-2 weeks, bacteria called Nitrosomonas start consuming ammonia. But they produce nitrite as a byproduct - which is also toxic to fish!',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'The nitrite spike is often the most dangerous phase. Fish can survive low ammonia but nitrite poisoning ("brown blood disease") is very harmful.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Stage 3: Nitrate (NO₃)',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'A second type of bacteria (Nitrobacter) converts nitrite into nitrate. Nitrate is much less toxic - fish can tolerate levels up to 20-40 ppm.',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'Nitrate doesn\'t just disappear - it builds up over time. This is why we do water changes: to remove accumulated nitrate.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'The Complete Picture',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• Fish waste → Ammonia (toxic)\n• Bacteria #1 → Nitrite (toxic)\n• Bacteria #2 → Nitrate (safer)\n• Water changes → Remove nitrate',
          ),
          const LessonSection(
            type: LessonSectionType.funFact,
            content:
                'In heavily planted tanks, live plants also absorb nitrate as fertilizer. Some aquarists with lots of plants rarely need water changes!',
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
              explanation:
                  'Ammonia is produced first, then converted to nitrite, then to nitrate.',
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
              explanation:
                  'Nitrate is the end product and is much less toxic. Fish can tolerate 20-40 ppm.',
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
              explanation:
                  'Nitrate builds up over time. Regular water changes are the primary way to remove it.',
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
            content:
                'The old method was to add "hardy" fish and hope they survive the ammonia spike. Today we know better. Fishless cycling grows your bacteria without harming any animals.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'What You\'ll Need',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• A test kit (API Master Test Kit recommended)\n• Ammonia source (pure ammonia or fish food)\n• Patience (4-6 weeks)\n• A running filter',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Step 1: Set Up Your Tank',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Install your filter, heater, and decorations. Fill with dechlorinated water. Let everything run for 24 hours to stabilize temperature.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Step 2: Add Ammonia',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Add pure ammonia (with no additives) until your test reads 2-4 ppm. Or drop in fish food and let it decay - less precise but works.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Step 3: Test & Wait',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Test every 2-3 days. You\'ll see ammonia rise, then fall as bacteria grow. Then nitrite spikes. Keep ammonia at 2-4 ppm throughout.',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'Your tank is cycled when: Ammonia drops to 0, Nitrite drops to 0, and Nitrate is present. This means both bacteria colonies are established.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Step 4: Add Fish Slowly',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Do a large water change to reduce nitrate, then add fish gradually. Your bacteria colony needs time to grow to handle increased bioload.',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'Bottled bacteria (like Seachem Stability) can speed up cycling, but isn\'t a magic fix. Still expect 2-4 weeks minimum.',
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
              explanation:
                  'A cycled tank processes ammonia to nitrite to nitrate. Zero ammonia + zero nitrite + some nitrate = cycled!',
            ),
            const QuizQuestion(
              id: 'nc_how_to_q2',
              question:
                  'What ammonia level should you maintain during fishless cycling?',
              options: ['0 ppm', '2-4 ppm', '10+ ppm', 'As high as possible'],
              correctIndex: 1,
              explanation:
                  '2-4 ppm provides enough food for bacteria without overdoing it. Too high can actually slow the process.',
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
              explanation:
                  'Adding fish gradually lets your bacteria colony grow to match the increased waste production.',
            ),
          ],
        ),
      ),

      // Lesson 4: Testing Your Water
      Lesson(
        id: 'nc_testing',
        pathId: 'nitrogen_cycle',
        title: 'Testing Your Water: API vs Strips',
        description: 'Choosing the right test kit and using it correctly',
        orderIndex: 3,
        xpReward: 50,
        estimatedMinutes: 5,
        prerequisites: ['nc_how_to'],
        sections: [
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Why Testing Isn\'t Optional',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'You can\'t see ammonia, nitrite, or nitrate. Your water can look crystal clear while being deadly toxic. Testing is the only way to know what\'s actually happening in your tank.',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content:
                'Relying on fish behavior alone is dangerous. By the time fish show stress symptoms, the water quality is already bad. Test regularly to catch problems early.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Test Strips: Quick but Questionable',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Test strips are convenient - just dip and compare colors. But they\'re less accurate than liquid tests, especially for ammonia. They also expire quickly and can give false readings if you wait too long to read them.',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '✅ Pros: Fast, easy, no mixing\n❌ Cons: Less accurate, more expensive per test, shorter shelf life',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Liquid Test Kits: The Gold Standard',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'The API Master Test Kit is the industry standard. It tests pH, ammonia, nitrite, and nitrate. While it takes 5 minutes instead of 30 seconds, the accuracy is worth it - especially during cycling.',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'A quality liquid test kit costs \$25-35 but lasts for 800+ tests. That\'s about 3-4 cents per test. Worth every penny.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'How to Test Correctly',
          ),
          const LessonSection(
            type: LessonSectionType.numberedList,
            content:
                '1. Use clean, dry test tubes (rinse with tank water if needed)\n2. Follow instructions exactly - drop counts matter!\n3. Shake reagent bottles before use\n4. Wait the full time before reading (5 minutes for nitrate)\n5. Read in natural light - artificial light distorts colors\n6. Don\'t trust the test if bottles are expired',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'Keep a testing log! Write down your results with dates. This helps you spot trends and troubleshoot problems.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Testing Schedule',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• During cycling: Every 2-3 days\n• New tank (first month): Weekly\n• Established tank: Every 2 weeks\n• After adding fish: 3 days later\n• If fish look stressed: Immediately!',
          ),
          const LessonSection(
            type: LessonSectionType.funFact,
            content:
                'Advanced aquarists often test less frequently than beginners. Once you truly understand your tank\'s patterns, you can rely more on observation. But keep that test kit handy for emergencies!',
          ),
        ],
        quiz: Quiz(
          id: 'nc_testing_quiz',
          lessonId: 'nc_testing',
          questions: [
            const QuizQuestion(
              id: 'nc_test_q1',
              question: 'Which type of test kit is generally more accurate?',
              options: [
                'Test strips',
                'Liquid test kits',
                'Digital meters',
                'They\'re all equally accurate',
              ],
              correctIndex: 1,
              explanation:
                  'Liquid test kits like the API Master Test Kit are more accurate and reliable than test strips, especially for critical parameters like ammonia.',
            ),
            const QuizQuestion(
              id: 'nc_test_q2',
              question: 'How often should you test during fishless cycling?',
              options: ['Daily', 'Every 2-3 days', 'Weekly', 'Monthly'],
              correctIndex: 1,
              explanation:
                  'Testing every 2-3 days during cycling lets you track the ammonia and nitrite spikes without wasting reagents.',
            ),
            const QuizQuestion(
              id: 'nc_test_q3',
              question:
                  'Why shouldn\'t you wait to test until fish look stressed?',
              options: [
                'Tests are cheaper when done regularly',
                'Fish show stress only after water quality is already bad',
                'The test kit expires faster',
                'It scares the fish',
              ],
              correctIndex: 1,
              explanation:
                  'By the time fish show visible stress, the water parameters have already reached dangerous levels. Regular testing catches problems early.',
            ),
            const QuizQuestion(
              id: 'nc_test_q4',
              question:
                  'What\'s the best lighting condition for reading test results?',
              options: [
                'Bright LED light',
                'Dim candlelight',
                'Natural daylight',
                'Blacklight',
              ],
              correctIndex: 2,
              explanation:
                  'Natural daylight provides the most accurate color reading. Artificial lights can distort the colors and lead to misreading results.',
            ),
            const QuizQuestion(
              id: 'nc_test_q5',
              question:
                  'How many tests does an API Master Test Kit typically provide?',
              options: ['About 50', 'About 200', 'About 800+', 'Unlimited'],
              correctIndex: 2,
              explanation:
                  'The API Master Test Kit provides 800+ tests across all parameters, making it incredibly cost-effective at about 3-4 cents per test.',
            ),
          ],
        ),
      ),

      // Lesson 5: Dealing with Cycle Spikes
      Lesson(
        id: 'nc_spikes',
        pathId: 'nitrogen_cycle',
        title: 'Cycle Emergency: Handling Spikes',
        description: 'What to do when ammonia or nitrite spike',
        orderIndex: 4,
        xpReward: 75,
        estimatedMinutes: 5,
        prerequisites: ['nc_testing'],
        sections: [
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'The Panic Moment',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'You test your water and see bright green (high ammonia) or purple (high nitrite). Your fish are gasping at the surface. Panic sets in. But don\'t worry - you can fix this!',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content:
                'Time is critical! Ammonia above 1 ppm or nitrite above 2 ppm can kill fish within hours. Act immediately.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Emergency Action Plan',
          ),
          const LessonSection(
            type: LessonSectionType.numberedList,
            content:
                '1. STOP FEEDING - No food for 24-48 hours. Food = more waste = more ammonia\n2. Massive water change - 50% immediately with temperature-matched, dechlorinated water\n3. Test again in 1 hour - If still high, do another 25-50% change\n4. Add Seachem Prime - Temporarily detoxifies ammonia/nitrite for 24-48 hours\n5. Increase aeration - Add an air stone or point filter output upward',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'Seachem Prime is your emergency best friend. It doesn\'t remove ammonia, but it temporarily makes it non-toxic. This buys you time for bacteria to catch up.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Why Did This Happen?',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• Added too many fish too fast\n• Overfeeding (most common!)\n• Cleaned filter media in tap water (killed bacteria)\n• Missed water changes\n• Dead fish or plant left decaying\n• Power outage killed beneficial bacteria',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Preventing Future Spikes',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Most spikes are preventable. Feed sparingly (fish can go a week without food). Add new fish gradually over weeks. Test regularly so you catch rising levels before they become dangerous.',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'Keep Seachem Prime on hand ALWAYS. It\'s cheap insurance that can save your fish\'s life. Don\'t wait until emergency - buy it now.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'The Recovery Phase',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'After stabilizing, test daily for a week. Resume light feeding after 48 hours - just 50% of normal amount. Your bacterial colony will rebuild, but it takes time. Patience is key.',
          ),
          const LessonSection(
            type: LessonSectionType.funFact,
            content:
                'Experienced fishkeepers have all been here. Every expert was once a beginner who crashed their cycle. You learn, you improve, and your fish survive!',
          ),
        ],
        quiz: Quiz(
          id: 'nc_spikes_quiz',
          lessonId: 'nc_spikes',
          questions: [
            const QuizQuestion(
              id: 'nc_spike_q1',
              question:
                  'What\'s the FIRST thing to do during an ammonia spike?',
              options: [
                'Add more fish',
                'Clean the entire tank',
                'Stop feeding and do a large water change',
                'Add salt',
              ],
              correctIndex: 2,
              explanation:
                  'Stop feeding immediately (no more waste) and do a 50% water change to dilute the ammonia. This is the fastest way to drop toxic levels.',
            ),
            const QuizQuestion(
              id: 'nc_spike_q2',
              question: 'What does Seachem Prime do?',
              options: [
                'Removes ammonia completely',
                'Temporarily detoxifies ammonia for 24-48 hours',
                'Adds beneficial bacteria',
                'Lowers pH',
              ],
              correctIndex: 1,
              explanation:
                  'Prime doesn\'t remove ammonia - it binds it into a non-toxic form temporarily. This gives your bacteria time to process it.',
            ),
            const QuizQuestion(
              id: 'nc_spike_q3',
              question: 'What\'s the most common cause of ammonia spikes?',
              options: [
                'Too much light',
                'Overfeeding',
                'Too many plants',
                'Cold water',
              ],
              correctIndex: 1,
              explanation:
                  'Overfeeding is the #1 cause of spikes. Excess food decays and produces huge amounts of ammonia. Feed sparingly!',
            ),
            const QuizQuestion(
              id: 'nc_spike_q4',
              question:
                  'During an emergency, how much water can you safely change?',
              options: [
                '10% maximum',
                '25% only',
                'Up to 50-75% if needed',
                'Never more than 15%',
              ],
              correctIndex: 2,
              explanation:
                  'In emergencies, large water changes (50-75%) are safe and necessary. Just match temperature and dechlorinate. Saving fish lives trumps normal rules.',
            ),
            const QuizQuestion(
              id: 'nc_spike_q5',
              question:
                  'After stabilizing ammonia, when should you resume feeding?',
              options: [
                'Immediately',
                'After 24 hours',
                'After 48 hours, at 50% normal amount',
                'After one week',
              ],
              correctIndex: 2,
              explanation:
                  'Wait 48 hours with no feeding, then resume at half portions. This prevents re-spiking while your bacteria rebuild.',
            ),
          ],
        ),
      ),

      // Lesson 6: Mini-Cycles and Restarts
      Lesson(
        id: 'nc_minicycle',
        pathId: 'nitrogen_cycle',
        title: 'Mini-Cycles: When Good Tanks Go Bad',
        description: 'Understanding and preventing bacterial crashes',
        orderIndex: 5,
        xpReward: 50,
        estimatedMinutes: 5,
        prerequisites: ['nc_spikes'],
        sections: [
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'What\'s a Mini-Cycle?',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Your tank was perfectly cycled for months. Then suddenly - ammonia or nitrite shows up again! This is called a "mini-cycle" - when your bacterial colony crashes and needs to rebuild.',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'Mini-cycles are different from New Tank Syndrome. The bacteria existed before, so they usually bounce back within days instead of weeks.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Common Triggers',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• Medications that kill bacteria (especially antibiotics)\n• Cleaning filter media in tap water (chlorine kills bacteria)\n• Power outages over 4+ hours (bacteria need oxygen)\n• Adding way too many fish at once\n• Removing an established filter\n• Major substrate disturbance',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'The Medication Problem',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Treating sick fish with antibiotics? They might kill your beneficial bacteria too. This is why hospital tanks exist - treat sick fish separately so your main tank\'s cycle stays intact.',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content:
                'If you must medicate your main tank, monitor ammonia/nitrite daily. Be ready for water changes and use Prime to detoxify.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'The Power Outage Scenario',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Beneficial bacteria need oxygen. If your filter stops for 4-6+ hours, bacteria start dying. When power returns, you might have a mini-cycle. Test your water after any extended outage.',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'During power outages, manually stir the water or use a battery-powered air pump. This keeps oxygen flowing and bacteria alive.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Recovery is Faster Than Initial Cycling',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Good news: mini-cycles typically resolve in 3-7 days, not 4-6 weeks. Some bacteria survived, and they multiply faster when re-colonizing familiar territory.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Prevention Checklist',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '✓ Clean filter media in old tank water only\n✓ Add new fish gradually (5-7 per week max)\n✓ Use hospital tanks for medications\n✓ Have battery backup or air pump for outages\n✓ Never replace all filter media at once',
          ),
          const LessonSection(
            type: LessonSectionType.funFact,
            content:
                'Some aquarists run two filters on important tanks. If one needs maintenance or fails, the other keeps the cycle going. Redundancy = stability!',
          ),
        ],
        quiz: Quiz(
          id: 'nc_minicycle_quiz',
          lessonId: 'nc_minicycle',
          questions: [
            const QuizQuestion(
              id: 'nc_mini_q1',
              question: 'What causes a mini-cycle?',
              options: [
                'Adding a single new fish',
                'Missing one water change',
                'Something that kills or reduces beneficial bacteria',
                'Testing the water too often',
              ],
              correctIndex: 2,
              explanation:
                  'Mini-cycles occur when something disrupts or kills your beneficial bacteria colony - medications, tap water rinses, power outages, etc.',
            ),
            const QuizQuestion(
              id: 'nc_mini_q2',
              question: 'How long does a mini-cycle typically last?',
              options: [
                '24 hours',
                '3-7 days',
                '4-6 weeks like initial cycling',
                'Several months',
              ],
              correctIndex: 1,
              explanation:
                  'Mini-cycles resolve much faster (3-7 days) than initial cycling because some bacteria survive and multiply quickly.',
            ),
            const QuizQuestion(
              id: 'nc_mini_q3',
              question: 'Why do medications sometimes cause mini-cycles?',
              options: [
                'They change the water color',
                'Antibiotics can kill beneficial bacteria too',
                'Fish eat less when medicated',
                'They raise the pH',
              ],
              correctIndex: 1,
              explanation:
                  'Antibiotics don\'t discriminate - they can kill beneficial bacteria along with disease bacteria. Always monitor parameters during medication.',
            ),
            const QuizQuestion(
              id: 'nc_mini_q4',
              question:
                  'How long can a filter be off before bacteria start dying?',
              options: ['30 minutes', '2 hours', '4-6 hours', '24 hours'],
              correctIndex: 2,
              explanation:
                  'Beneficial bacteria need oxygen. After 4-6 hours without flow, they begin to die off. Longer outages = higher risk of mini-cycle.',
            ),
            const QuizQuestion(
              id: 'nc_mini_q5',
              question: 'What should you NEVER use to clean filter media?',
              options: [
                'Old tank water',
                'Tap water (chlorinated)',
                'Dechlorinated water',
                'Water from another established tank',
              ],
              correctIndex: 1,
              explanation:
                  'Tap water contains chlorine that instantly kills beneficial bacteria. Always use old tank water to rinse filter media.',
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
            content:
                'pH measures how acidic or alkaline (basic) your water is. The scale runs from 0 (very acidic) to 14 (very alkaline), with 7 being neutral.',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'Most tropical fish thrive between pH 6.5-7.5. Some species prefer more acidic (tetras, discus) or alkaline (African cichlids) water.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Stability Over Perfection',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Here\'s the secret most beginners don\'t know: stable pH is more important than "perfect" pH. Fish can adapt to a range of pH levels, but sudden changes are stressful.',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content:
                'Avoid "pH adjusters" and chemicals. They cause dangerous swings. It\'s better to keep fish suited to your tap water\'s natural pH.',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'Test your tap water\'s pH. That\'s your baseline. Choose fish that thrive at that pH rather than fighting to change it.',
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
              explanation:
                  'Fish adapt to various pH levels, but sudden changes cause stress. Stability is key.',
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
            content:
                'Fish can\'t regulate their body temperature like we can. They depend entirely on their environment. Wrong temperature = stressed fish = sick fish.',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'Most tropical fish need 24-28°C (75-82°F). Coldwater fish like goldfish prefer 18-22°C (64-72°F). Always research your specific species.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Heaters and Thermometers',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'For tropical tanks, a reliable heater is essential. Get one rated for your tank size (usually 3-5 watts per litre). Always use a separate thermometer to verify - built-in heater dials are often inaccurate.',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'Place your heater near water flow (filter outlet) for even heat distribution. Avoid placing near windows where sunlight causes temperature swings.',
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
              explanation:
                  'Most tropical fish thrive at 24-28°C. Colder is for coldwater species, hotter is usually only for treating disease.',
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
            content:
                'Hardness refers to the mineral content in your water - mainly calcium and magnesium. There are two types: GH (General Hardness) and KH (Carbonate Hardness).',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'GH - General Hardness',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'GH measures calcium and magnesium ions. Fish need these minerals for healthy bones, scales, and egg development. Soft water has low GH; hard water has high GH.',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'Most tropical fish do well in GH 4-12 dGH. Livebearers (guppies, mollies) prefer harder water (10-20 dGH). Soft water fish (tetras, discus) prefer 2-8 dGH.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'KH - Carbonate Hardness',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'KH measures carbonates and bicarbonates - these act as a pH buffer. Higher KH means your pH is more stable and resistant to swings.',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content:
                'Low KH (below 3 dKH) can cause dangerous pH crashes, especially overnight when plants release CO2. If your KH is very low, consider adding crushed coral or baking soda.',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'Test your tap water first! Your local water company may have data online. Knowing your tap water hardness helps you choose compatible fish.',
          ),
          const LessonSection(
            type: LessonSectionType.funFact,
            content:
                'Some aquarists use rainwater or RO (reverse osmosis) water to create soft water for sensitive species. But for most beginners, tap water works fine!',
          ),
        ],
        quiz: Quiz(
          id: 'wp_hardness_quiz',
          lessonId: 'wp_hardness',
          questions: [
            const QuizQuestion(
              id: 'wp_hardness_q1',
              question: 'What does KH help stabilize?',
              options: ['Temperature', 'pH', 'Ammonia', 'Nitrate'],
              correctIndex: 1,
              explanation:
                  'KH (carbonate hardness) acts as a pH buffer, preventing dangerous pH swings.',
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
              explanation:
                  'Livebearers come from hard water environments and thrive at GH 10-20 dGH.',
            ),
          ],
        ),
      ),

      // Lesson 4: Chlorine and Chloramine
      Lesson(
        id: 'wp_chlorine',
        pathId: 'water_parameters',
        title: 'Chlorine vs Chloramine',
        description: 'Why tap water needs treatment before use',
        orderIndex: 3,
        xpReward: 50,
        estimatedMinutes: 5,
        prerequisites: ['wp_hardness'],
        sections: [
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'The Tap Water Problem',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Tap water is treated to be safe for humans - but that treatment makes it toxic to fish! Chlorine and chloramine are added to kill bacteria in pipes. Unfortunately, they also kill beneficial bacteria in your tank and harm fish gills.',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content:
                'Adding untreated tap water can kill fish within hours and crash your nitrogen cycle. ALWAYS dechlorinate - no exceptions!',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Chlorine: The Old Standard',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Chlorine is a gas dissolved in water. It\'s been used for decades to disinfect water. The good news? Chlorine naturally evaporates - leave tap water sitting for 24 hours and most chlorine will be gone.',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'BUT don\'t rely on evaporation! It takes 24+ hours and doesn\'t work for chloramine. Always use a dechlorinator - it works in seconds.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Chloramine: The Tougher Challenger',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Many cities now use chloramine - a combination of chlorine and ammonia. It\'s more stable (doesn\'t evaporate easily) and stays effective longer in pipes. Bad news for fishkeepers: it doesn\'t just disappear.',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• Doesn\'t evaporate like chlorine\n• Breaks down into ammonia (toxic!)\n• Requires special dechlorinators\n• Check your water company website to see if they use it',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Choosing a Dechlorinator',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Not all dechlorinators are equal. Basic ones handle chlorine. Better ones (like Seachem Prime) handle chlorine, chloramine, AND temporarily detoxify the ammonia released when chloramine breaks down.',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'Seachem Prime is the gold standard. It dechlorinates, detoxifies ammonia/nitrite, and detoxifies heavy metals. One bottle lasts forever - worth the investment.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'How to Use Dechlorinator',
          ),
          const LessonSection(
            type: LessonSectionType.numberedList,
            content:
                '1. Add correct dose to NEW water (follow bottle instructions)\n2. Wait just 1-2 minutes for it to work\n3. Match temperature to tank before adding\n4. Can dose directly to tank during water changes if needed\n5. Can\'t overdose moderately - 1.5x is safe',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Other Nasties in Tap Water',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Beyond chlorine/chloramine, tap water can contain heavy metals (copper, lead), nitrates (from agricultural runoff), and phosphates. A good water conditioner handles most of these.',
          ),
          const LessonSection(
            type: LessonSectionType.funFact,
            content:
                'Some cities occasionally "super-chlorinate" their water systems. If your tap water smells strongly of chlorine, add double the normal dose of dechlorinator that day.',
          ),
        ],
        quiz: Quiz(
          id: 'wp_chlorine_quiz',
          lessonId: 'wp_chlorine',
          questions: [
            const QuizQuestion(
              id: 'wp_chlor_q1',
              question:
                  'What\'s the difference between chlorine and chloramine?',
              options: [
                'They\'re the same thing',
                'Chlorine evaporates, chloramine doesn\'t',
                'Chloramine is safer for fish',
                'Chlorine is only used in saltwater',
              ],
              correctIndex: 1,
              explanation:
                  'Chlorine evaporates naturally over 24 hours. Chloramine (chlorine + ammonia) is much more stable and doesn\'t evaporate easily.',
            ),
            const QuizQuestion(
              id: 'wp_chlor_q2',
              question:
                  'Why is chloramine particularly dangerous for aquariums?',
              options: [
                'It turns water green',
                'It breaks down into toxic ammonia',
                'It makes fish sleepy',
                'It lowers oxygen levels',
              ],
              correctIndex: 1,
              explanation:
                  'Chloramine breaks down into ammonia, which is highly toxic to fish. This is why dechlorinators that handle chloramine are essential.',
            ),
            const QuizQuestion(
              id: 'wp_chlor_q3',
              question:
                  'Can you safely rely on letting tap water sit for 24 hours to dechlorinate?',
              options: [
                'Yes, always works perfectly',
                'No, doesn\'t work for chloramine',
                'Yes, but only for saltwater',
                'No, takes weeks not hours',
              ],
              correctIndex: 1,
              explanation:
                  'This old method only works for chlorine. If your water has chloramine (common in modern cities), sitting does nothing. Always use dechlorinator.',
            ),
            const QuizQuestion(
              id: 'wp_chlor_q4',
              question: 'What does Seachem Prime do?',
              options: [
                'Only removes chlorine',
                'Removes chlorine, chloramine, and detoxifies ammonia/heavy metals',
                'Adds beneficial bacteria',
                'Lowers pH',
              ],
              correctIndex: 1,
              explanation:
                  'Seachem Prime is comprehensive - handles chlorine, chloramine, temporarily detoxifies ammonia/nitrite, and binds heavy metals.',
            ),
            const QuizQuestion(
              id: 'wp_chlor_q5',
              question:
                  'How can you find out if your city uses chlorine or chloramine?',
              options: [
                'Taste the water',
                'Check your water company\'s website or call them',
                'Test with aquarium test kit',
                'It\'s always chloramine nowadays',
              ],
              correctIndex: 1,
              explanation:
                  'Your local water company publishes water quality reports. Call or check their website to see what disinfectants they use.',
            ),
          ],
        ),
      ),

      // Lesson 5: TDS (Total Dissolved Solids)
      Lesson(
        id: 'wp_tds',
        pathId: 'water_parameters',
        title: 'Understanding TDS',
        description: 'Total Dissolved Solids and what they mean',
        orderIndex: 4,
        xpReward: 50,
        estimatedMinutes: 4,
        prerequisites: ['wp_chlorine'],
        sections: [
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'What is TDS?',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'TDS stands for Total Dissolved Solids - basically everything dissolved in your water that isn\'t H₂O. This includes minerals (calcium, magnesium), salts, organic matter, and even a tiny bit of fish waste.',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'TDS is measured in ppm (parts per million). It gives you a quick snapshot of overall water quality without testing individual parameters.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Good vs Bad Dissolved Solids',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Not all solids are created equal! Minerals like calcium and magnesium are beneficial - fish need them. But organic waste, excess nitrates, and heavy metals are harmful. TDS doesn\'t distinguish between them.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Typical TDS Ranges',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• Tap water: 50-400 ppm (depends on location)\n• Freshwater aquarium: 150-500 ppm\n• RO/DI water: 0-10 ppm (pure)\n• Brackish water: 1,000-10,000 ppm\n• Saltwater: 35,000+ ppm',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Why Track TDS?',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'TDS creeps up over time as minerals and waste accumulate. Sudden jumps signal problems - overfeeding, dead fish, or decaying plants. Tracking TDS helps you know when water changes are needed.',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content:
                'If TDS rises 100+ ppm above normal in a week, something\'s wrong. Test ammonia, nitrite, and nitrate to identify the problem.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'TDS Meters',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'A cheap TDS meter (\$10-20) measures TDS in seconds. Not essential for beginners, but handy for tracking trends and verifying your RO/DI unit works correctly.',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'Test your tap water\'s TDS when you first start fishkeeping. This becomes your baseline. Then test your tank monthly to see how it changes.',
          ),
          const LessonSection(
            type: LessonSectionType.funFact,
            content:
                'Shrimp keepers obsess over TDS! Many shrimp species need very specific TDS ranges (150-250 ppm for Neocaridina). Too high or too low = molting problems.',
          ),
        ],
        quiz: Quiz(
          id: 'wp_tds_quiz',
          lessonId: 'wp_tds',
          questions: [
            const QuizQuestion(
              id: 'wp_tds_q1',
              question: 'What does TDS measure?',
              options: [
                'Only harmful chemicals',
                'Everything dissolved in water except H₂O',
                'Only beneficial minerals',
                'Water temperature',
              ],
              correctIndex: 1,
              explanation:
                  'TDS measures ALL dissolved solids - minerals, salts, organic matter, waste products, etc. It doesn\'t distinguish between good and bad.',
            ),
            const QuizQuestion(
              id: 'wp_tds_q2',
              question:
                  'What\'s a typical TDS range for a healthy freshwater aquarium?',
              options: ['0-10 ppm', '50-100 ppm', '150-500 ppm', '1,000+ ppm'],
              correctIndex: 2,
              explanation:
                  'Freshwater aquariums typically run 150-500 ppm. This includes natural minerals plus some accumulated waste between water changes.',
            ),
            const QuizQuestion(
              id: 'wp_tds_q3',
              question:
                  'If TDS suddenly jumps 100+ ppm in a week, what does this indicate?',
              options: [
                'Everything is perfect',
                'Something is wrong - overfeeding, decay, or waste buildup',
                'You need to add more fish',
                'The water is too cold',
              ],
              correctIndex: 1,
              explanation:
                  'Rapid TDS increases signal problems - excess waste, overfeeding, dead fish, or decaying matter. Time to investigate!',
            ),
            const QuizQuestion(
              id: 'wp_tds_q4',
              question: 'What does RO/DI water typically measure?',
              options: [
                '500-1000 ppm',
                '100-200 ppm',
                '0-10 ppm',
                'Same as tap water',
              ],
              correctIndex: 2,
              explanation:
                  'Reverse Osmosis / Deionization systems produce nearly pure water at 0-10 ppm TDS. This is used for sensitive species or remineralizing.',
            ),
            const QuizQuestion(
              id: 'wp_tds_q5',
              question: 'Why do shrimp keepers care so much about TDS?',
              options: [
                'They don\'t - it\'s not important',
                'Shrimp need very specific TDS ranges to molt properly',
                'It affects shrimp color only',
                'Higher TDS makes shrimp grow faster',
              ],
              correctIndex: 1,
              explanation:
                  'Many shrimp species (especially Caridina) need precise TDS ranges. Wrong TDS causes molting failures and death.',
            ),
          ],
        ),
      ),

      // Lesson 6: Seasonal Water Changes
      Lesson(
        id: 'wp_seasonal',
        pathId: 'water_parameters',
        title: 'Seasonal Water Challenges',
        description: 'How winter and summer affect your tank',
        orderIndex: 5,
        xpReward: 50,
        estimatedMinutes: 5,
        prerequisites: ['wp_tds'],
        sections: [
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Your Tank Lives in the Real World',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Seasons affect aquariums more than you\'d think! Room temperature, tap water temperature, and even water company treatment practices change throughout the year.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Summer Challenges',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• Heatwaves: Tank temperature can rise dangerously\n• Faster evaporation: Top off more frequently\n• Lower oxygen: Warm water holds less dissolved O₂\n• Algae blooms: More light + heat = algae explosion\n• Power outages: AC failures can cook your tank',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content:
                'Above 30°C (86°F), most tropical fish experience stress. Above 32°C (90°F) can be fatal. Monitor temperature closely during heatwaves!',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Cooling a Hot Tank',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• Float ice bottles (frozen water bottles) - cheap and effective\n• Increase surface agitation (more oxygen + cooling)\n• Point a fan at the water surface (evaporative cooling)\n• Close curtains to block direct sunlight\n• In emergencies: Small water changes with cooler water',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'Keep frozen water bottles ready during summer! Swap them 2-3 times daily during heatwaves. They can drop temperature by 2-3°C.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Winter Challenges',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• Tap water is COLD: 5-15°C vs your 24-28°C tank\n• Heater works harder: Higher electricity costs\n• Dry air: Faster evaporation from heating systems\n• Heater failures: Can kill fish overnight\n• Temperature shock during water changes',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'Never add cold tap water directly! Temperature shock can kill fish. Always warm new water to within 1-2°C of tank temperature.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Warming Water for Changes',
          ),
          const LessonSection(
            type: LessonSectionType.numberedList,
            content:
                '1. Fill bucket with cold tap water\n2. Add dechlorinator\n3. Add small amounts of hot water OR\n4. Use an aquarium heater in the bucket (wait 30 min) OR\n5. Let it sit in warm room for a few hours\n6. Test temperature before adding to tank',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Spring/Fall: The Sweet Spot',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Moderate seasons are easiest! Stable room temperature, tap water closer to tank temp, and less evaporation. This is the best time to introduce new fish or try breeding.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Water Company Seasonal Changes',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Some cities increase chlorination in summer or adjust pH seasonally. If you notice unusual fish behavior after water changes, test your tap water - it might have changed!',
          ),
          const LessonSection(
            type: LessonSectionType.funFact,
            content:
                'Some fish actually spawn based on seasonal cues! Gradually dropping temperature by 2-3°C over weeks can trigger breeding behavior in many species.',
          ),
        ],
        quiz: Quiz(
          id: 'wp_seasonal_quiz',
          lessonId: 'wp_seasonal',
          questions: [
            const QuizQuestion(
              id: 'wp_seas_q1',
              question: 'What temperature can be fatal for most tropical fish?',
              options: [
                'Above 24°C (75°F)',
                'Above 28°C (82°F)',
                'Above 32°C (90°F)',
                'Above 40°C (104°F)',
              ],
              correctIndex: 2,
              explanation:
                  'Above 32°C (90°F) is often fatal for tropical fish. They become stressed above 30°C and need immediate cooling.',
            ),
            const QuizQuestion(
              id: 'wp_seas_q2',
              question: 'What\'s the quickest way to cool an overheating tank?',
              options: [
                'Add ice cubes directly',
                'Float frozen water bottles',
                'Turn off all equipment',
                'Cover the tank with blankets',
              ],
              correctIndex: 1,
              explanation:
                  'Frozen water bottles cool gradually without temperature shock. Ice cubes directly in tank can shock fish. Bottles are safer and controllable.',
            ),
            const QuizQuestion(
              id: 'wp_seas_q3',
              question: 'Why is cold tap water dangerous in winter?',
              options: [
                'It has more chlorine',
                'Temperature shock can kill fish',
                'It contains ice crystals',
                'Fish don\'t need water changes in winter',
              ],
              correctIndex: 1,
              explanation:
                  'Adding cold water (5-15°C) to a warm tank (24-28°C) creates temperature shock that can kill fish. Always match temperatures!',
            ),
            const QuizQuestion(
              id: 'wp_seas_q4',
              question: 'Why does warm water hold less oxygen?',
              options: [
                'It\'s a physical property of water',
                'Hot water evaporates oxygen',
                'Fish breathe more in warm water',
                'It doesn\'t - that\'s a myth',
              ],
              correctIndex: 0,
              explanation:
                  'It\'s physics - warm water has lower oxygen solubility. This is why heatwaves can cause fish to gasp at the surface.',
            ),
            const QuizQuestion(
              id: 'wp_seas_q5',
              question: 'What season is best for introducing new fish?',
              options: [
                'Summer (easiest time)',
                'Winter (fish are less active)',
                'Spring/Fall (stable temperatures)',
                'Doesn\'t matter',
              ],
              correctIndex: 2,
              explanation:
                  'Spring and fall have stable temperatures and less stress from extreme heat/cold. This makes acclimation easier and reduces fish stress.',
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
            content:
                'Some fish forgive beginner mistakes. Others die at the slightest water quality issue. Start with hardy species that can handle the learning curve.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Great Beginner Fish',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• Guppies - colorful, active, breed easily\n• Platies - peaceful, many colors\n• Corydoras catfish - cute bottom-dwellers, social\n• Zebra danios - active schoolers, very hardy\n• Cherry barbs - peaceful, beautiful red color\n• Bristlenose plecos - algae eaters, interesting',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Fish to Avoid (For Now)',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• Discus - require pristine water quality\n• Oscars - grow huge, need massive tanks\n• Common plecos - grow to 60cm+\n• Goldfish in tropical tanks - different needs\n• Betta with fin-nippers - stress easily',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'Research BEFORE you buy. Know the adult size, tank requirements, and compatibility of any fish you\'re considering.',
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
            content:
                'You\'ve picked your fish - exciting! But the trip from store to tank is stressful for fish. Sudden changes in temperature or water chemistry can shock or kill them.',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content:
                'Never dump fish straight into your tank! The bag water and your tank water are likely very different in temperature, pH, and hardness.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Float Method (Simple)',
          ),
          const LessonSection(
            type: LessonSectionType.numberedList,
            content:
                '1. Float the sealed bag in your tank for 15-20 minutes (equalizes temperature)\n2. Open the bag and add a small cup of tank water\n3. Wait 5 minutes, then add another cup\n4. Repeat 3-4 times over 30-45 minutes\n5. Net the fish into the tank - discard the bag water',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Drip Method (Better)',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'For sensitive fish or big water parameter differences: Put fish and bag water in a bucket. Use airline tubing with a knot to drip tank water in slowly (2-3 drips per second) for 1-2 hours until the water volume doubles.',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'Never add store water to your tank! It may contain diseases, parasites, or medications. Always net the fish and discard the bag water.',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'Keep lights dim for the first few hours. New fish are stressed and bright lights make it worse. Let them explore and find hiding spots.',
          ),
        ],
        quiz: Quiz(
          id: 'ff_acclimation_quiz',
          lessonId: 'ff_acclimation',
          questions: [
            const QuizQuestion(
              id: 'ff_accl_q1',
              question:
                  'Why should you never add store bag water to your tank?',
              options: [
                'It\'s too cold',
                'It may contain diseases or parasites',
                'It has too much oxygen',
                'It\'s the wrong color',
              ],
              correctIndex: 1,
              explanation:
                  'Store water may carry diseases, parasites, or leftover medications that could harm your existing fish.',
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
              explanation:
                  'Floating allows the bag water temperature to slowly match your tank temperature.',
            ),
          ],
        ),
      ),

      // Lesson 3: Feeding Basics
      Lesson(
        id: 'ff_feeding',
        pathId: 'first_fish',
        title: 'Feeding 101: Less is More',
        description: 'How much, how often, and what to feed',
        orderIndex: 2,
        xpReward: 50,
        estimatedMinutes: 5,
        prerequisites: ['ff_acclimation'],
        sections: [
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'The #1 Mistake: Overfeeding',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'More fish die from overfeeding than underfeeding. Excess food decays into ammonia, clouds water, and feeds algae. Your fish\'s stomach is about the size of their eye - they don\'t need much!',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content:
                'Fish will ALWAYS act hungry. They\'re opportunistic feeders in nature - they eat whenever food is available because they don\'t know when the next meal comes. Don\'t be fooled!',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'The 2-Minute Rule',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Feed only what your fish can consume in 2 minutes. If food is still floating after 2 minutes, you fed too much. Net out the excess to prevent water quality problems.',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'Feed once or twice daily. Skip one day per week. Fish can easily go a week without food - you going on vacation is not an emergency!',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Types of Fish Food',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• Flakes: Good all-rounder, most fish accept them\n• Pellets: Less messy, better for larger fish\n• Frozen: Bloodworms, brine shrimp - high protein treat\n• Live: Stimulates hunting behavior but risk of parasites\n• Algae wafers: For bottom-feeders and plecos\n• Vegetables: Zucchini, cucumber for herbivores',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Variety is Important',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Don\'t feed the same food every day! Rotate between flakes, pellets, and frozen foods. This provides balanced nutrition and prevents dietary deficiencies.',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'Soak pellets for 10 seconds before feeding. This prevents them from expanding in fish stomachs (which can cause bloating) and ensures they sink for bottom-feeders.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Special Feeding Needs',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• Nocturnal fish: Feed after lights out (catfish, loaches)\n• Bottom-dwellers: Use sinking foods, not just flakes\n• Fry (baby fish): Need tiny food 3-4 times daily\n• Herbivores: 80% plant-based diet (plecos, some cichlids)\n• Carnivores: High-protein diet (bettas, oscars)',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Vacation Feeding',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Going away for a week? Don\'t use "vacation blocks" - they often pollute water. Instead: Have someone feed 2-3 times that week (pre-portion the food!), or just skip feeding entirely. Fish will be fine.',
          ),
          const LessonSection(
            type: LessonSectionType.funFact,
            content:
                'In nature, fish don\'t eat every day. They experience feast and famine. Your well-fed aquarium fish can easily handle a week without food - they\'ll just be extra excited when you return!',
          ),
        ],
        quiz: Quiz(
          id: 'ff_feeding_quiz',
          lessonId: 'ff_feeding',
          questions: [
            const QuizQuestion(
              id: 'ff_feed_q1',
              question: 'How much food should you feed at each feeding?',
              options: [
                'As much as they want',
                'What they can eat in 2 minutes',
                'Fill the water surface',
                'A full handful',
              ],
              correctIndex: 1,
              explanation:
                  'The 2-minute rule prevents overfeeding. If food remains after 2 minutes, you\'ve fed too much.',
            ),
            const QuizQuestion(
              id: 'ff_feed_q2',
              question: 'Why do fish always act hungry?',
              options: [
                'They\'re actually starving',
                'They\'re opportunistic feeders - eat whenever food is available',
                'The water makes them hungry',
                'They need constant food',
              ],
              correctIndex: 1,
              explanation:
                  'Fish are opportunistic - in nature they don\'t know when the next meal comes, so they eat whenever possible. This doesn\'t mean they need food!',
            ),
            const QuizQuestion(
              id: 'ff_feed_q3',
              question: 'How long can healthy adult fish go without food?',
              options: [
                '24 hours maximum',
                '2-3 days',
                'About a week',
                'Several months',
              ],
              correctIndex: 2,
              explanation:
                  'Healthy adult fish can easily go a week without food. This is much safer than overfeeding or using vacation blocks that pollute water.',
            ),
            const QuizQuestion(
              id: 'ff_feed_q4',
              question: 'Why soak pellets before feeding?',
              options: [
                'Makes them taste better',
                'Adds water to the tank',
                'Prevents bloating from expansion in fish stomachs',
                'Removes toxins',
              ],
              correctIndex: 2,
              explanation:
                  'Dry pellets expand when wet. Soaking them first prevents them from expanding inside fish stomachs, which can cause bloating.',
            ),
            const QuizQuestion(
              id: 'ff_feed_q5',
              question: 'What causes more fish deaths?',
              options: [
                'Underfeeding',
                'Overfeeding',
                'They\'re equally dangerous',
                'Neither causes deaths',
              ],
              correctIndex: 1,
              explanation:
                  'Overfeeding is far more dangerous! Excess food decays, creating ammonia and polluting water. Underfeeding rarely kills healthy fish.',
            ),
          ],
        ),
      ),

      // Lesson 4: Reading Fish Behavior
      Lesson(
        id: 'ff_behavior',
        pathId: 'first_fish',
        title: 'Reading Fish Behavior',
        description: 'Healthy vs stressed - spotting problems early',
        orderIndex: 3,
        xpReward: 50,
        estimatedMinutes: 6,
        prerequisites: ['ff_feeding'],
        sections: [
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Fish Can\'t Tell You They\'re Sick',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Your fish won\'t say "I don\'t feel well" - they communicate through behavior. Learning to read these signals lets you catch problems before they become life-threatening.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Signs of Healthy Fish',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '✅ Active swimming (species-appropriate)\n✅ Bright, vibrant colors\n✅ Clear eyes\n✅ Fins fully extended, not clamped\n✅ Regular eating behavior\n✅ Interacts with tankmates normally\n✅ Smooth, intact scales',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'Know your fish\'s normal behavior! Some species (like bettas) are naturally slow. Others (like danios) are hyperactive. Compare to their usual behavior, not other species.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Warning Signs: Stress',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '⚠️ Clamped fins (held tight to body)\n⚠️ Hiding constantly (when usually social)\n⚠️ Loss of appetite\n⚠️ Faded colors\n⚠️ Rapid gill movement\n⚠️ Gasping at surface\n⚠️ Rubbing against objects (flashing)',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content:
                'Gasping at the surface usually means low oxygen OR ammonia/nitrite poisoning. Test water immediately and increase aeration!',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Behavior-Based Diagnostics',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                '**Flashing (rubbing on objects):** Parasites irritating skin, or poor water quality burning gills.\n\n**Lethargy + clamped fins:** Usually water quality issues. Test ammonia/nitrite first.\n\n**Gulping air at surface:** Low oxygen, high ammonia, or high temperature.\n\n**Sitting on bottom:** Can be normal for some species, but if unusual = illness or stress.\n\n**Erratic swimming/spiraling:** Swim bladder issues, or neurological problems from poor water quality.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'The Daily Visual Inspection',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Spend 2 minutes daily just watching your tank. Count fish (make sure everyone\'s accounted for). Look for behavioral changes. This simple habit catches 90% of problems early.',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'Morning is the best time to observe. Fish are most active during feeding time, so you\'ll notice if someone\'s acting off.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'When in Doubt, Test',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Unusual behavior = test water parameters. 80% of fish health problems trace back to water quality. Before treating for disease, rule out ammonia, nitrite, or pH swings.',
          ),
          const LessonSection(
            type: LessonSectionType.funFact,
            content:
                'Some fish "play dead" when startled! Hatchetfish are famous for this - they\'ll float motionless on their side for minutes, then swim away like nothing happened. Don\'t panic immediately!',
          ),
        ],
        quiz: Quiz(
          id: 'ff_behavior_quiz',
          lessonId: 'ff_behavior',
          questions: [
            const QuizQuestion(
              id: 'ff_behav_q1',
              question: 'What does "clamped fins" mean?',
              options: [
                'Fins spread wide and beautiful',
                'Fins torn or damaged',
                'Fins held tight to body (stress signal)',
                'Missing fins',
              ],
              correctIndex: 2,
              explanation:
                  'Clamped fins are held tight against the body instead of extended. This is a classic stress signal.',
            ),
            const QuizQuestion(
              id: 'ff_behav_q2',
              question: 'Fish gasping at the surface usually indicates what?',
              options: [
                'They\'re happy',
                'Low oxygen or high ammonia/nitrite',
                'They\'re hungry',
                'Normal behavior',
              ],
              correctIndex: 1,
              explanation:
                  'Gasping at the surface is an emergency sign - either low dissolved oxygen or ammonia/nitrite poisoning. Test water immediately!',
            ),
            const QuizQuestion(
              id: 'ff_behav_q3',
              question: 'What should you do BEFORE treating for disease?',
              options: [
                'Add medication immediately',
                'Test water parameters',
                'Remove all decorations',
                'Stop water changes',
              ],
              correctIndex: 1,
              explanation:
                  '80% of fish health issues are water quality related. Always test parameters before assuming disease and medicating.',
            ),
            const QuizQuestion(
              id: 'ff_behav_q4',
              question: 'What is "flashing"?',
              options: [
                'Fish glowing in the dark',
                'Bright color changes',
                'Rubbing against objects',
                'Swimming very fast',
              ],
              correctIndex: 2,
              explanation:
                  'Flashing is when fish rub their bodies against rocks, plants, or decorations. Usually indicates parasites or water quality issues irritating skin.',
            ),
            const QuizQuestion(
              id: 'ff_behav_q5',
              question: 'When is the best time for daily fish observation?',
              options: [
                'Late at night',
                'Random times',
                'Morning during feeding time',
                'Doesn\'t matter',
              ],
              correctIndex: 2,
              explanation:
                  'Morning feeding time shows fish at their most active. You\'ll immediately notice if someone\'s not eating or behaving oddly.',
            ),
          ],
        ),
      ),

      // Lesson 5: Quarantine Tanks
      Lesson(
        id: 'ff_quarantine',
        pathId: 'first_fish',
        title: 'Quarantine Tanks: Insurance Policy',
        description: 'Why every fishkeeper needs a hospital tank',
        orderIndex: 4,
        xpReward: 75,
        estimatedMinutes: 5,
        prerequisites: ['ff_behavior'],
        sections: [
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'The Problem with "Just One Fish"',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'You buy a beautiful new fish from the store. Looks healthy! You add it to your tank. Two weeks later, your entire tank is battling ich because that new fish was carrying parasites. This nightmare is 100% preventable.',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'Quarantine tanks isolate new fish for 2-4 weeks BEFORE adding them to your main tank. This prevents disease spread and saves your entire collection.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'What is a Quarantine Tank?',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'A quarantine (QT) tank is a small, bare-bones tank used to isolate new fish or treat sick fish. It doesn\'t need to be fancy - a simple 10-20 liter tank with a sponge filter is perfect.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'QT Tank Setup',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• 10-40 liter tank (species-dependent)\n• Sponge filter (won\'t get clogged, gentle flow)\n• Heater\n• Bare bottom OR smooth gravel (easy to clean)\n• PVC pipe or simple hiding spot\n• NO substrate, NO plants (easier to medicate)\n• Keep it simple!',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'How to Use QT: New Fish',
          ),
          const LessonSection(
            type: LessonSectionType.numberedList,
            content:
                '1. Set up QT tank 24 hours before fish arrival\n2. Add new fish directly to QT (never main tank)\n3. Observe for 2-4 weeks\n4. Watch for disease, parasites, odd behavior\n5. If healthy after quarantine → add to main tank\n6. If sick → treat in QT, reset quarantine period',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'Seed your QT filter with media from your main tank! This instantly cycles the QT. Keep the sponge in your main filter when not in use - it stays cycled and ready.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Hospital Tank Use',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Your QT doubles as a hospital tank! Sick fish get isolated here for treatment. This protects healthy fish from disease AND prevents medications from harming beneficial bacteria in your main tank.',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content:
                'Many medications kill beneficial bacteria. Treating in your main tank can crash your cycle. Always use a hospital/QT tank for medications when possible.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: '"But I Don\'t Have Space!"',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'QT tanks don\'t need to run 24/7. Keep the equipment stored. When needed, fill the tank, add your cycled sponge filter, and you\'re ready in an hour. A 10-liter tank fits anywhere.',
          ),
          const LessonSection(
            type: LessonSectionType.funFact,
            content:
                'Advanced aquarists quarantine new PLANTS too! Snails, parasites, and algae hitchhike on plants. A 2-week plant quarantine in a separate container prevents unwanted guests.',
          ),
        ],
        quiz: Quiz(
          id: 'ff_quarantine_quiz',
          lessonId: 'ff_quarantine',
          questions: [
            const QuizQuestion(
              id: 'ff_quar_q1',
              question: 'How long should you quarantine new fish?',
              options: ['24 hours', '2-4 days', '2-4 weeks', 'Not necessary'],
              correctIndex: 2,
              explanation:
                  '2-4 weeks is the standard quarantine period. Most diseases show symptoms within this timeframe.',
            ),
            const QuizQuestion(
              id: 'ff_quar_q2',
              question: 'Why use a bare-bottom quarantine tank?',
              options: [
                'Looks prettier',
                'Saves money',
                'Easier to clean and medicate',
                'Fish prefer it',
              ],
              correctIndex: 2,
              explanation:
                  'Bare-bottom or minimal gravel makes cleaning easier and prevents medications from binding to substrate.',
            ),
            const QuizQuestion(
              id: 'ff_quar_q3',
              question: 'Why do medications harm main tanks?',
              options: [
                'They\'re bad for decorations',
                'They kill beneficial bacteria',
                'They stain the glass',
                'Fish don\'t like them',
              ],
              correctIndex: 1,
              explanation:
                  'Many medications (especially antibiotics) kill beneficial bacteria, potentially crashing your cycle. Hospital tanks prevent this.',
            ),
            const QuizQuestion(
              id: 'ff_quar_q4',
              question: 'How can you keep a QT tank cycled when not in use?',
              options: [
                'You can\'t - must cycle each time',
                'Keep the sponge filter running in your main tank',
                'Add ammonia daily',
                'Freeze the filter',
              ],
              correctIndex: 1,
              explanation:
                  'Store the sponge filter IN your main tank\'s filter when not needed. It stays cycled and ready for emergencies!',
            ),
            const QuizQuestion(
              id: 'ff_quar_q5',
              question:
                  'What happens if you skip quarantine and add a sick fish?',
              options: [
                'Only that fish gets sick',
                'It might infect your entire tank',
                'Nothing - fish are immune',
                'The disease dies in new water',
              ],
              correctIndex: 1,
              explanation:
                  'One infected fish can spread disease to your entire collection. Quarantine is insurance against losing everything.',
            ),
          ],
        ),
      ),

      // Lesson 6: Common Beginner Mistakes
      Lesson(
        id: 'ff_mistakes',
        pathId: 'first_fish',
        title: 'Common Mistakes (And How to Avoid Them)',
        description: 'Learn from other people\'s failures!',
        orderIndex: 5,
        xpReward: 50,
        estimatedMinutes: 6,
        prerequisites: ['ff_quarantine'],
        sections: [
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'We\'ve All Been There',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Every expert was once a beginner who made mistakes. The key is learning from them - and better yet, learning from OTHER people\'s mistakes before you make them yourself!',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Mistake #1: "The tank looks ready!"',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'You set up your tank, fill it with water, add decorations... it looks perfect! Time to add fish, right? WRONG. This is the #1 killer - not cycling your tank first.',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'Solution: Fishless cycle for 2-6 weeks before adding any fish. Test ammonia and nitrite - both must read 0 before fish are safe.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Mistake #2: Trusting the Pet Store',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                '"Put 20 goldfish in your 20-liter bowl!" "Clean the tank completely every week!" Pet store employees often give terrible advice - usually to make sales, not help fish.',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content:
                'Research BEFORE buying! Know the adult size, temperament, and requirements of any fish. Don\'t trust store advice blindly.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Mistake #3: Impulse Buying',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'That fish is SO pretty! You buy it, bring it home, then Google it. Oops - it grows to 40cm, eats small fish, and needs 200 liters. Now what?',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'Make a shopping list BEFORE visiting the store. Research compatibility, size, and care requirements at home where you can think clearly.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Mistake #4: Overcrowding',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                '"One inch of fish per gallon" is outdated and often wrong. A 12-inch oscar in a 12-gallon tank? Disaster! Consider adult size, bioload, and swimming space.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Mistake #5: Cleaning Too Much',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Beginners often think tanks should be SPOTLESS. So they scrub everything, replace all the water, rinse filter media in tap water... and crash the cycle. A little algae is normal!',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'Aquariums are ecosystems, not sterile environments. You\'re managing biology, not achieving hospital-level cleanliness.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Mistake #6: Chasing Perfect Parameters',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Spending hours trying to get pH exactly 7.0 with chemicals. Daily adjustments. Constant tweaking. Meanwhile, all these changes STRESS the fish!',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'Stability > Perfection. Fish adapt to a wide range of parameters, but hate sudden changes. Leave it alone!',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Mistake #7: Mixing Incompatible Fish',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Putting aggressive cichlids with peaceful tetras. Goldfish (cold water) with tropical fish. Tiny guppies with predatory oscars. Research compatibility FIRST!',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Mistake #8: Expecting Instant Results',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Fishkeeping requires patience. Cycling takes weeks. Plants grow slowly. Fish may take days to settle in. Rushing leads to dead fish.',
          ),
          const LessonSection(
            type: LessonSectionType.funFact,
            content:
                'The absolute #1 trait of successful fishkeepers? Patience. The ability to let things develop naturally instead of intervening constantly.',
          ),
        ],
        quiz: Quiz(
          id: 'ff_mistakes_quiz',
          lessonId: 'ff_mistakes',
          questions: [
            const QuizQuestion(
              id: 'ff_mist_q1',
              question: 'What\'s the #1 beginner mistake?',
              options: [
                'Buying too many decorations',
                'Not cycling the tank before adding fish',
                'Using the wrong gravel',
                'Feeding once a day',
              ],
              correctIndex: 1,
              explanation:
                  'Not cycling causes New Tank Syndrome - the #1 killer of fish. Always cycle first!',
            ),
            const QuizQuestion(
              id: 'ff_mist_q2',
              question: 'When should you research a fish?',
              options: [
                'After buying it',
                'BEFORE buying it',
                'When it gets sick',
                'Research isn\'t necessary',
              ],
              correctIndex: 1,
              explanation:
                  'Always research BEFORE purchasing! Know the size, temperament, and care requirements to avoid disasters.',
            ),
            const QuizQuestion(
              id: 'ff_mist_q3',
              question:
                  'What\'s more important: perfect parameters or stability?',
              options: [
                'Perfect parameters',
                'Stability',
                'Both are equally important',
                'Neither matters',
              ],
              correctIndex: 1,
              explanation:
                  'Stability is king! Fish adapt to various parameters but stress from constant changes kills. Stable "imperfect" water beats unstable "perfect" water.',
            ),
            const QuizQuestion(
              id: 'ff_mist_q4',
              question: 'Is the "1 inch of fish per gallon" rule reliable?',
              options: [
                'Yes, always use it',
                'No, it\'s outdated and often wrong',
                'Only for goldfish',
                'Only for tropical fish',
              ],
              correctIndex: 1,
              explanation:
                  'This rule is terrible! A 12-inch oscar needs WAY more than 12 gallons. Consider adult size, bioload, and swimming behavior instead.',
            ),
            const QuizQuestion(
              id: 'ff_mist_q5',
              question:
                  'Should you scrub your tank spotless and replace all water?',
              options: [
                'Yes, weekly',
                'Yes, daily',
                'No - this crashes your cycle',
                'Only in emergencies',
              ],
              correctIndex: 2,
              explanation:
                  'Over-cleaning kills beneficial bacteria and crashes your cycle. Aquariums are ecosystems, not sterile environments. Light maintenance only!',
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
            content:
                'Your filter removes particles and processes ammonia, but nitrate still builds up. Water changes are the only way to remove it and replenish trace minerals fish need.',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'Aim for 20-30% water change weekly. This keeps nitrate low without shocking fish with big parameter swings.',
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
                'Never replace all the water at once. Massive changes shock fish and can crash your cycle. 50% max in emergencies.',
          ),
        ],
        quiz: Quiz(
          id: 'maint_wc_quiz',
          lessonId: 'maint_water_changes',
          questions: [
            const QuizQuestion(
              id: 'maint_wc_q1',
              question: 'How much water should you change weekly?',
              options: ['5-10%', '20-30%', '50-75%', '100%'],
              correctIndex: 1,
              explanation:
                  '20-30% weekly keeps nitrate low without shocking fish with big parameter changes.',
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
                'Sponges and bio-media rarely need replacing - just rinse them. Carbon should be replaced monthly if used. If you must replace sponges, only do one at a time with weeks between.',
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
                'If using bleach: 1) Use 10:1 water to bleach ratio, 2) Soak only 15 minutes, 3) Rinse for 10+ minutes, 4) Soak in dechlorinated water overnight. Any bleach residue kills fish!',
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
                '✓ 20-30% water change with gravel vacuum\n✓ Clean inside glass (if needed)\n✓ Test water parameters (ammonia, nitrite, nitrate)\n✓ Remove dead plant leaves\n✓ Check filter flow (still strong?)\n✓ Top off evaporated water',
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
            content: 'Seasonal Tasks (Every 3-6 months)',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '✓ Replace filter cartridges (carbon, fine pads)\n✓ Deep clean canister filter if used\n✓ Replace air stones (they clog over time)\n✓ Check heater accuracy with separate thermometer\n✓ Inspect all tubing for cracks/algae buildup',
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
                'Weekly (20-30%)',
                'Monthly',
                'Only when water looks dirty',
              ],
              correctIndex: 1,
              explanation:
                  'Weekly 20-30% water changes are the gold standard. Consistent small changes beat infrequent large ones.',
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

  // ==========================================
  // PLANTED TANK PATH
  // ==========================================
  static final plantedTankPath = LearningPath(
    id: 'planted',
    title: 'Planted Tanks',
    description: 'Growing live aquatic plants',
    emoji: '🌿',
    recommendedFor: [ExperienceLevel.intermediate],
    relevantTankTypes: [
      TankType.freshwater,
    ], // Planted is a subset of freshwater
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
                'Aquasoil releases ammonia during the first 2-4 weeks! You MUST cycle it thoroughly before adding fish. Many beginners skip this and kill their fish.',
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
                'It\'s dead',
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
              question:
                  'Why does aquasoil need to be cycled before adding fish?',
              options: [
                'It\'s too soft',
                'It releases ammonia initially',
                'It changes color',
                'Fish don\'t like the texture',
              ],
              correctIndex: 1,
              explanation:
                  'Aquasoil releases ammonia for 2-4 weeks as organic matter breaks down. You must cycle it like a new tank before adding fish!',
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
                'Plants use CO2, light, and nutrients for photosynthesis. Atmospheric CO2 dissolves into water naturally, but only at 2-5 ppm - not much. Most demanding plants want 20-30 ppm for optimal growth.',
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
                'Excel can melt certain plants (Vallisneria, some mosses) and is toxic to shrimp at high doses. Start with half-dose and watch your plants.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'DIY CO2: The Middle Ground',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Yeast + sugar in a bottle produces CO2 via fermentation. Cheap but inconsistent - production varies daily, and it can crash overnight killing fish (CO2 becomes toxic at high levels).',
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
                'Takashi Amano, the godfather of aquascaping, ran CO2 on his legendary tanks. But he also said: "Nature doesn\'t use CO2 regulators - respect the plants\' natural needs first."',
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

  // ==========================================
  // EQUIPMENT ESSENTIALS PATH (NEW!)
  // ==========================================
  static final equipmentPath = LearningPath(
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
                  'Sponge filters use air bubbles rising to create water flow through the sponge. No electricity, no motor - just bubbles!',
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
                'The standard rule: 3-5 watts per liter. A 60-liter tank needs 180-300W. Go bigger in cold rooms, smaller in warm rooms. Undersizing means the heater runs constantly (shorter lifespan).',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'Two smaller heaters beat one large! A 60L tank with two 150W heaters is safer than one 300W. If one fails, the other provides backup. Plus, more even heating.',
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
              question: 'How many watts per liter do you need?',
              options: [
                '1 watt',
                '3-5 watts',
                '10+ watts',
                'Watts don\'t matter',
              ],
              correctIndex: 1,
              explanation:
                  '3-5 watts per liter is standard. A 60L tank needs 180-300W. Adjust based on room temperature.',
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

  // ==========================================
  // PATH 7: FISH HEALTH & DISEASE
  // ==========================================
  static final fishHealthPath = LearningPath(
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

  // ==========================================
  // PATH 8: SPECIES-SPECIFIC CARE
  // ==========================================
  static final speciesCarePath = LearningPath(
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
                'Minimum 5 gallons, heated to 78-80°F, filtered water. No bowls!',
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
                '20 gallons for the first goldfish, +10 gallons per additional fish. Fancy goldfish need less space than commons/comets.',
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

  // ==========================================
  // PATH 9: ADVANCED TOPICS
  // ==========================================
  static final advancedTopicsPath = LearningPath(
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
}
