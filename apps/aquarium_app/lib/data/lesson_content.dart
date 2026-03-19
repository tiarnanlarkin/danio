// TRACKED: CLEANUP-001 — This ~5K-line file duplicates content in data/lessons/.
// Still imported by: placement_test_screen.dart, placement_result_screen.dart,
// enhanced_placement_test_screen.dart. To remove: migrate those screens to use
// individual lesson files from data/lessons/, then delete this file.
// Tracked in: prd/danio-master-audit-consolidated.md → T3-01
/// Lesson content for the learning system
/// The "Duolingo for fishkeeping" curriculum
///
/// ⚠️ LEGACY FILE - 212KB startup cost
///
/// NEW APPROACH: Use lazy-loaded chunks in lib/data/lessons/
/// - Each learning path is a separate file (20-40KB each)
/// - Use LessonProvider for lazy loading (lib/providers/lesson_provider.dart)
///
/// This file remains for backward compatibility. Gradually migrate to:
/// - ref.watch(lessonProvider) for Riverpod screens
/// - lessonContentLazy.loadPath(pathId) for non-Riverpod code
library;

import '../models/tank.dart'; // For TankType enum
import '../models/learning.dart';
import '../models/user_profile.dart';

/// All learning paths available in the app
/// ⚠️ WARNING: Loading all paths at once = 347KB of data
/// Consider using LessonProvider for lazy loading instead
@Deprecated('Use LessonProvider or lesson_content_lazy.dart instead')
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
                  'Ammonia is invisible but detectable by smell at high concentrations. Even at lower levels that you can\'t smell, it\'s harmful to fish. Always use a test kit — your nose isn\'t reliable enough.',
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
                'After 1-2 weeks, beneficial bacteria start consuming ammonia. Modern research has shown Nitrospira is the primary bacteria responsible in most freshwater aquaria (older references often cite Nitrosomonas). But they produce nitrite as a byproduct - which is also toxic to fish!',
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
                'A second type of bacteria (Nitrospira) converts nitrite into nitrate. Nitrate is much less toxic - fish can tolerate levels up to 20-40 ppm.',
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
                'For tropical tanks, a reliable heater is essential. Get one rated for your tank size (usually 1-2 watts per litre (or 3-5 watts per gallon)). Always use a separate thermometer to verify - built-in heater dials are often inaccurate.',
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
                'Most tropical fish do well in GH 4-12 dGH. Livebearers (guppies, mollies) prefer harder water (10-16 dGH). Soft water fish (tetras, discus) prefer 2-8 dGH.',
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
                  'Livebearers come from hard water environments and thrive at GH 10-16 dGH.',
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
        quiz: Quiz(
          id: 'ff_choosing_quiz',
          lessonId: 'ff_choosing',
          questions: [
            const QuizQuestion(
              id: 'ff_choose_q1',
              question: 'Which of these fish is a great choice for beginners?',
              options: ['Discus', 'Zebra danios', 'Oscars', 'Common plecos'],
              correctIndex: 1,
              explanation:
                  'Zebra danios are extremely hardy, active schoolers that tolerate a wide range of water conditions - perfect for beginners learning the ropes.',
            ),
            const QuizQuestion(
              id: 'ff_choose_q2',
              question: 'Why should beginners avoid discus?',
              options: [
                'They are too small',
                'They require pristine water quality',
                'They are aggressive',
                'They only eat live food',
              ],
              correctIndex: 1,
              explanation:
                  'Discus are beautiful but demand near-perfect water quality. Small fluctuations that hardy fish shrug off can make discus seriously ill.',
            ),
            const QuizQuestion(
              id: 'ff_choose_q3',
              question:
                  'What does "hardy" mean when describing a fish species?',
              options: [
                'The fish is large and strong',
                'The fish can tolerate beginner mistakes and water quality fluctuations',
                'The fish is aggressive',
                'The fish does not need a filter',
              ],
              correctIndex: 1,
              explanation:
                  'Hardy fish can handle the water parameter swings and small mistakes that are inevitable when you are learning.',
            ),
            const QuizQuestion(
              id: 'ff_choose_q4',
              question: 'What should you always do before buying a new fish?',
              options: [
                'Ask the pet store employee',
                'Buy it if it looks healthy',
                'Research its adult size, tank needs, and compatibility',
                'Check if it matches your decor',
              ],
              correctIndex: 2,
              explanation:
                  'Research before you buy! Know how big it gets, what water it needs, and whether it gets along with your existing fish.',
            ),
          ],
        ),
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

      // Lesson 2.46: Choosing Your First Tank
      Lesson(
        id: 'ff_tank_selection',
        pathId: 'first_fish',
        title: 'Choosing Your First Tank',
        description: 'Pre-purchase guidance for beginners',
        orderIndex: 6,
        xpReward: 50,
        estimatedMinutes: 7,
        sections: [
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Bigger Is Better (Within Reason)',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'The single most impactful decision you\'ll make is tank size. Larger tanks are more stable — a small mistake in a 200-litre tank barely registers, but the same mistake in a 20-litre tank can be fatal. Water parameters fluctuate much more slowly in bigger volumes.',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'The sweet spot for beginners is 60–120 litres. It\'s large enough to be stable, small enough to be affordable and manageable.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Glass vs Acrylic',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• **Glass** — Cheaper, scratch-resistant, doesn\'t yellow over time. Heavier. The standard choice.\n• **Acrylic** — Lighter, clearer, moulded into interesting shapes. Scratches easily and costs more.',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'For your first tank, glass is almost always the right call. It\'s forgiving, affordable, and you\'ll spend less time worrying about scratches from cleaning.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'The Stand',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'A 60-litre tank filled with water, substrate, and decor weighs around 80 kg. Your furniture is not designed for that. You need a proper aquarium stand rated for the weight, or a very sturdy, level surface.',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content:
                'An uneven surface creates stress points on the glass that can cause cracks over time. Always use a spirit level when setting up.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Where to Put It',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• **Away from windows** — Sunlight causes algae explosions and temperature swings\n• **Away from radiators/heaters** — Temperature stability is critical\n• **Near a power socket** — You\'ll need one for the filter, heater, and light\n• **Where you can enjoy it** — You\'ll look at this tank every day!',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Budget Expectations',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'A realistic starter setup (60L tank, filter, heater, thermometer, substrate, decor, water conditioner, test kit) runs roughly £150–£300. The fish themselves are often the cheapest part. Don\'t blow your budget on the tank and skimp on the filter — a good filter is the heart of your aquarium.',
          ),
          const LessonSection(
            type: LessonSectionType.funFact,
            content:
                'The nitrogen cycle lesson earlier? That\'s exactly why you shouldn\'t rush. Buy your tank first, set it up, cycle it, THEN buy fish. Patience literally saves lives.',
          ),
        ],
        quiz: Quiz(
          id: 'ff_tank_selection_quiz',
          lessonId: 'ff_tank_selection',
          questions: [
            const QuizQuestion(
              id: 'ff_tank_q1',
              question: 'What is the recommended tank size range for beginners?',
              options: [
                '5–15 litres',
                '20–40 litres',
                '60–120 litres',
                '200+ litres',
              ],
              correctIndex: 2,
              explanation:
                  '60–120 litres is the sweet spot — stable enough to be forgiving, small enough to be affordable.',
            ),
            const QuizQuestion(
              id: 'ff_tank_q2',
              question: 'Why should you avoid placing a tank near a window?',
              options: [
                'It makes the tank too dark',
                'Sunlight causes algae blooms and temperature swings',
                'Fish get stressed by seeing outside',
                'The glass can crack from UV light',
              ],
              correctIndex: 1,
              explanation:
                  'Direct sunlight fuels rapid algae growth and causes daily temperature fluctuations that stress fish.',
            ),
            const QuizQuestion(
              id: 'ff_tank_q3',
              question: 'Why is glass usually recommended over acrylic for beginners?',
              options: [
                'Glass is clearer',
                'Glass is lighter',
                'Glass is cheaper and scratch-resistant',
                'Glass holds more water',
              ],
              correctIndex: 2,
              explanation:
                  'Glass tanks cost less and resist scratches from cleaning tools — ideal for your first setup.',
            ),
          ],
        ),
      ),

      // Lesson 2.47: Stocking Your Tank
      Lesson(
        id: 'ff_stocking',
        pathId: 'first_fish',
        title: 'Stocking Your Tank',
        description: 'How many fish, and which ones get along?',
        orderIndex: 7,
        xpReward: 50,
        estimatedMinutes: 8,
        sections: [
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'The Inch-Per-Gallon Myth',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'You\'ve probably heard the rule: "one inch of fish per gallon." It\'s everywhere, and it\'s wrong. A 30-centimetre Oscar in a 30-litre tank? That\'s a disaster waiting to happen. This rule ignores fish body shape, activity level, bioload (waste production), and social needs.',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'Better approach: research the adult size, bioload, and social needs of each species, then stock gradually while testing water. There is no universal formula.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Cycling First, Always',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'This cannot be overstated: do not add fish to an uncycled tank. Without established bacteria, ammonia from fish waste builds up and kills them. Cycle your tank with a fishless method (ammonia source + time) or with just 2–3 hardy fish for 4–6 weeks before adding more.',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content:
                'Adding too many fish at once to a new tank is the #1 cause of "New Tank Syndrome" deaths. Start small, be patient.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Introducing Fish Gradually',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• **Week 1–2:** Add 2–3 small hardy fish only (e.g. zebra danios)\n• **Week 3–4:** Test water — if ammonia/nitrite are 0, add 2–3 more\n• **Week 5+:** Continue adding slowly, testing between each batch\n• **Rule of thumb:** Never add more than 25% of your planned stock at once',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Compatibility Basics',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• Match **temperament** — peaceful with peaceful, semi-aggressive with semi-aggressive\n• Match **temperature needs** — tropical (24–26°C) vs coldwater (18–22°C)\n• Match **water parameters** — soft/acidic vs hard/alkaline species\n• Consider **swimming zones** — top, middle, and bottom dwellers reduce competition',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'A good community mix: a school of top-dwellers (e.g. ember tetras), a school of mid-dwellers (e.g. harlequin rasboras), and bottom-dwellers (e.g. corydoras catfish). Three layers of activity, minimal conflict.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Warning Signs of Overstocking',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• Constantly high nitrates (above 40 ppm even after water changes)\n• Aggressive behaviour from normally peaceful fish\n• Excessive algae growth\n• Cloudy water that won\'t clear\n• Fish hovering at the surface gasping (low oxygen from overcrowding)',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'If you notice these signs, reduce feeding immediately, increase water change frequency, and consider rehoming some fish. It\'s better to have fewer happy fish than too many stressed ones.',
          ),
        ],
        quiz: Quiz(
          id: 'ff_stocking_quiz',
          lessonId: 'ff_stocking',
          questions: [
            const QuizQuestion(
              id: 'ff_stock_q1',
              question: 'Why is the "one inch per gallon" rule unreliable?',
              options: [
                'It recommends too few fish',
                'It ignores bioload, body shape, and social needs',
                'It only works for saltwater tanks',
                'Fish don\'t grow in aquariums',
              ],
              correctIndex: 1,
              explanation:
                  'This oversimplified rule ignores that a slim tetra and a chunky cichlid of the same length produce very different waste loads.',
            ),
            const QuizQuestion(
              id: 'ff_stock_q2',
              question: 'What is the recommended maximum percentage of stock to add at once?',
              options: [
                '10%',
                '25%',
                '50%',
                '100%',
              ],
              correctIndex: 1,
              explanation:
                  'Never add more than 25% of your planned total at once. This gives the biofilter time to adjust to the increased waste.',
            ),
            const QuizQuestion(
              id: 'ff_stock_q3',
              question: 'Which is a warning sign of overstocking?',
              options: [
                'Fish swimming at different speeds',
                'Water crystal clear with no algae',
                'Constantly high nitrates above 40 ppm',
                'Fish hiding during the day',
              ],
              correctIndex: 2,
              explanation:
                  'Nitrates that won\'t stay below 40 ppm even with regular water changes are a clear indicator of too much waste production for your filtration.',
            ),
          ],
        ),
      ),

      // Lesson 2.48: Practical Maintenance Skills
      Lesson(
        id: 'ff_practical_skills',
        pathId: 'first_fish',
        title: 'Essential Maintenance Skills',
        description: 'Gravel vacuuming, siphons, substrate rinsing, water changes',
        orderIndex: 8,
        xpReward: 50,
        estimatedMinutes: 9,
        sections: [
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'The Weekly Water Change',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'A weekly 25–30% water change is the single most important maintenance task. It removes accumulated nitrates, replenishes minerals, and keeps your water clean. It sounds simple, but doing it correctly makes all the difference.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Step-by-Step Water Change',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• **Step 1:** Turn off the heater and filter\n• **Step 2:** Treat new water with dechlorinator — always prepare water FIRST\n• **Step 3:** Match the temperature to within 1°C of tank water\n• **Step 4:** Use a gravel vacuum to siphon out 25–30% of the water\n• **Step 5:** Clean the substrate as you go (push the vacuum into the gravel and watch debris get pulled out)\n• **Step 6:** Slowly pour in the treated new water\n• **Step 7:** Turn the heater and filter back on',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content:
                'Never use hot tap water to speed things up. UK hot water passes through a copper boiler which adds dissolved copper — toxic to invertebrates and harmful to fish. Use cold water and a kettle if needed.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'How to Start a Siphon',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'The gravel vacuum uses a siphon to pull water out. To start it: submerge the entire tube and hose in the tank, put your thumb over the hose end, lift it into your bucket, and release. Gravity does the rest. Some vacuums have a squeeze bulb that makes this even easier.',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'Place the bucket below the tank level. The greater the height difference, the stronger the siphon. If the siphon stops, just repeat the priming step.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Gravel Vacuuming Technique',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Push the vacuum tube into the substrate and watch dirty water and debris flow out. When the water runs clear, move to the next section. Don\'t vacuum the entire substrate every week — rotate through sections so you don\'t disturb too much beneficial bacteria at once.',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'Don\'t dig too deep. The top 2–3 cm of gravel is where waste accumulates. Deeper layers house most of your beneficial bacteria.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Rinsing Substrate Before Setup',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Brand new gravel or sand is covered in dust that will turn your tank cloudy. Before adding it to the tank, rinse it: put a small amount in a bucket, fill with water, stir, pour off the cloudy water, and repeat until the water runs clear. This can take 5–10 rinses for dusty substrates.',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content:
                'Never use soap or detergent to rinse substrate or any aquarium item. Even trace amounts are toxic to fish. Water only, always.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Equipment Maintenance',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• **Filter media:** Rinse in OLD tank water during water changes, never tap water (chlorine kills bacteria)\n• **Filter pad:** Replace when water flow is noticeably reduced (monthly-ish)\n• **Heater:** Check temperature daily, replace every 2–3 years\n• **Glass:** Wipe algae with an aquarium-safe scraper, not kitchen sponges',
          ),
          const LessonSection(
            type: LessonSectionType.funFact,
            content:
                'The bacteria that live in your filter media do 90% of the work keeping your water safe. Treat them well — they\'re your tank\'s most important residents!',
          ),
        ],
        quiz: Quiz(
          id: 'ff_practical_skills_quiz',
          lessonId: 'ff_practical_skills',
          questions: [
            const QuizQuestion(
              id: 'ff_skills_q1',
              question: 'How much water should you change per week?',
              options: [
                '10%',
                '25–30%',
                '50%',
                '100%',
              ],
              correctIndex: 1,
              explanation:
                  '25–30% weekly is the sweet spot — enough to remove nitrates without disrupting the bacterial colony or causing parameter swings.',
            ),
            const QuizQuestion(
              id: 'ff_skills_q2',
              question: 'Why should you rinse filter media in old tank water instead of tap water?',
              options: [
                'It removes more debris',
                'Tap water is too cold',
                'Chlorine in tap water kills beneficial bacteria',
                'Old water has more nutrients',
              ],
              correctIndex: 2,
              explanation:
                  'Chlorine and chloramine in tap water kill the beneficial bacteria living on your filter media. Old tank water is chlorine-free.',
            ),
            const QuizQuestion(
              id: 'ff_skills_q3',
              question: 'Why shouldn\'t you use hot tap water for water changes?',
              options: [
                'It\'s too hot for fish',
                'It dissolves copper from the boiler, which is toxic',
                'It causes temperature shock',
                'It removes oxygen from the water',
              ],
              correctIndex: 1,
              explanation:
                  'UK hot water passes through copper pipes and boilers, leaching dissolved copper that is toxic to invertebrates and harmful to fish.',
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
                'Never replace all the water at once. Massive changes shock fish and can crash your cycle. Stick to 25-30% for routine changes. In emergencies (ammonia spike, disease treatment), larger changes of 50-75% are safe - just match temperature and dechlorinate.',
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
                'Excel is lethal to shrimp and other invertebrates even at recommended doses. If you keep shrimp, snails, or crayfish, do NOT use Excel — consider pressurized CO2 or non-algaecide alternatives instead. It can also melt certain plants (Vallisneria, some mosses).',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'DIY CO2: The Middle Ground',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Yeast + sugar in a bottle produces CO2 via fermentation. Cheap but inconsistent - production varies daily, and can crash overnight. A sudden CO2 spike drops pH rapidly (potentially lethal), while a CO2 dump when production surges can suffocate fish. Not recommended for tanks under 40 litres where swings hit harder.',
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
                  'DIY CO2 is unpredictable - production varies daily and can spike or crash overnight. A CO2 dump drops pH rapidly (potentially lethal), making it risky especially in smaller tanks.',
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
                'The standard rule: 1-2 watts per litre (or 3-5 watts per gallon). A 60-litre tank needs 60-120W. Go bigger in cold rooms, smaller in warm rooms. Undersizing means the heater runs constantly (shorter lifespan).',
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
                  '1-2 watts per litre (or 3-5 watts per gallon) is standard. A 60L tank needs 60-120W. Adjust based on room temperature.',
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

      // Lesson 2.46: Choosing Your First Tank
      Lesson(
        id: 'eq_tank_selection',
        pathId: 'equipment',
        title: 'Choosing Your First Tank',
        description: 'Pre-purchase guidance for picking the perfect starter tank',
        orderIndex: 3,
        xpReward: 50,
        estimatedMinutes: 7,
        sections: [
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Before You Buy Anything',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Walking into an aquarium shop for the first time is exciting — and overwhelming. Tanks of every size, shapes you\'ve never imagined, and shelves of equipment you didn\'t know existed. Before you hand over any money, let\'s talk about what actually matters.',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'Your tank choice affects everything else: which fish you can keep, how much maintenance you\'ll do, and whether your fish thrive or struggle. Get this right and everything else gets easier.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Tank Size: Why Bigger Is Easier',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'The single most common beginner mistake is buying a tank that\'s too small. It seems logical — "I\'m a beginner, I should start small" — but in fishkeeping, smaller tanks are actually harder to maintain.',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• **Below 20 litres (5 gallons):** Extremely difficult. Water parameters swing wildly, temperature is unstable, and very few fish can live comfortably. Avoid as a first tank.\n• **40+ litres (10+ gallons):** Suitable for a single betta or a small group of nano fish.\n• **60–120 litres (15–30 gallons):** The sweet spot for beginners. Stable parameters, good fish selection, forgiving of minor mistakes.\n• **120+ litres (30+ gallons):** Even more stable and gives you more stocking options. Only downside is cost and space.',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'Think of it like this: a drop of pollution in a teacup is much more concentrated than the same drop in a swimming pool. Larger volumes dilute problems and give you more time to fix them.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Glass vs Acrylic',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Most starter tanks are glass, and for good reason — it\'s affordable, scratch-resistant, and doesn\'t yellow over time. Acrylic tanks are lighter and clearer, but they scratch easily and cost significantly more.',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• **Glass:** Heavier, more affordable, scratch-resistant, can develop tiny leaks at seams over many years\n• **Acrylic:** Lighter, optically clearer, more impact-resistant, scratches easily (even cleaning with the wrong cloth can mark it)',
          ),
          const LessonSection(
            type: LessonSectionType.funFact,
            content:
                'Acrylic tanks can weigh up to 50% less than glass tanks of the same size. This matters for very large tanks — a 400-litre glass tank can weigh over 400 kg with water!',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Where to Put Your Tank',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Placement matters more than most people think. Your tank needs a level, sturdy surface that can handle the weight (water weighs roughly 1 kg per litre, plus the tank itself and substrate).',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• **Away from windows:** Direct sunlight causes temperature fluctuations and algae explosions\n• **Away from radiators and heaters:** Stable temperature is critical for fish health\n• **Away from doors:** Vibrations and temperature drafts from opening doors stress fish\n• **Near a power socket:** You\'ll need one for your filter, heater, and light\n• **On a proper stand:** Aquarium stands are designed for the weight and water movement. A regular table or bookshelf is risky.',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content:
                'A 120-litre tank with water, substrate, and stand can weigh over 200 kg. Make sure your floor can handle it — especially if you live in an older building or flat.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Budget Expectations',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'The tank itself is usually the cheapest part. Here\'s a realistic breakdown for a 60–120 litre beginner setup:',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• **Tank + stand:** £80–200\n• **Filter:** £20–60\n• **Heater:** £15–30\n• **Thermometer:** £5–10\n• **Light:** Often included, otherwise £15–40\n• **Substrate (gravel/sand):** £10–25\n• **Water conditioner + test kit:** £20–35\n• **Decor (plants, caves, hides):** £15–40\n• **First fish:** £5–25\n\n**Total realistic budget: £200–450** for a good starter setup.',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'Second-hand tanks can save you a lot — check local marketplace listings. Just inspect carefully for scratches, leaks, and silicone condition.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Common Beginner Mistakes',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'These mistakes are so common they\'re almost a rite of passage. Save yourself the heartache and learn from others:',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• **Buying too small:** The "it\'s just for one fish" trap. Even a single betta benefits from a 20-litre tank.\n• **Impulse buying fish on the same day as the tank:** Your tank needs to cycle for 2–6 weeks before fish can safely move in.\n• **Skipping the water conditioner:** Tap water contains chlorine and chloramine that kill fish and beneficial bacteria.\n• **Choosing a tank based on looks alone:** That cool bow-front or hexagonal tank might look great but is harder to clean and has less swimming space than a standard rectangular tank.\n• **Forgetting about the stand:** A wobbly table under a heavy water-filled glass box is an accident waiting to happen.',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'A rectangular tank is always the best choice for beginners. It maximises swimming space, is easiest to clean, and provides the most stable water conditions.',
          ),
        ],
        quiz: Quiz(
          id: 'eq_tank_selection_quiz',
          lessonId: 'eq_tank_selection',
          questions: [
            const QuizQuestion(
              id: 'eq_tank_q1',
              question: 'Why is a larger tank generally easier for beginners?',
              options: [
                'It looks better',
                'Larger water volumes are more stable and forgiving of mistakes',
                'Larger tanks need less equipment',
                'Fish grow faster in bigger tanks',
              ],
              correctIndex: 1,
              explanation:
                  'Larger volumes of water dilute waste and changes more slowly, giving you more time to notice and fix problems before they become dangerous.',
            ),
            const QuizQuestion(
              id: 'eq_tank_q2',
              question: 'Where should you NOT place your aquarium?',
              options: [
                'Near a power socket',
                'On a proper aquarium stand',
                'In direct sunlight by a window',
                'Against an interior wall',
              ],
              correctIndex: 2,
              explanation:
                  'Direct sunlight causes temperature swings and triggers algae blooms. Always place your tank away from windows and heat sources.',
            ),
            const QuizQuestion(
              id: 'eq_tank_q3',
              question: 'Which tank shape is best for beginners?',
              options: [
                'Bow-front',
                'Hexagonal',
                'Rectangular',
                'Cylindrical',
              ],
              correctIndex: 2,
              explanation:
                  'Rectangular tanks maximise swimming space, are easiest to clean and maintain, and provide the most stable water conditions.',
            ),
          ],
        ),
      ),

      // Lesson 2.47: Stocking Your Tank
      Lesson(
        id: 'eq_stocking',
        pathId: 'equipment',
        title: 'Stocking Your Tank',
        description: 'How to choose compatible fish and avoid overstocking',
        orderIndex: 4,
        xpReward: 50,
        estimatedMinutes: 7,
        sections: [
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'The Most Exciting Part — and the Most Dangerous',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Picking fish for your new tank is the fun part. It\'s also where most beginners make expensive mistakes that cost fish their lives. Let\'s make sure you get it right.',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'Before you buy a single fish, your tank must be fully cycled. A cycled tank has established colonies of beneficial bacteria that can process fish waste. No cycling = no fish. Period.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'The "Inch Per Gallon" Myth',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'You\'ve probably heard the rule: "one inch of fish per gallon of water." It sounds simple and useful — but it\'s dangerously misleading.',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• A 30 cm (12 inch) goldfish produces far more waste than six 5 cm (2 inch) tetras — same "inches" but massively different bioload\n• A tall, thin fish and a wide, round fish have the same length but very different space needs\n• Schooling fish need to be in groups — you can\'t keep "one inch" of a species that needs to be in a group of six\n• This rule ignores adult size. That 2 cm baby pleco will grow to 40 cm',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content:
                'The inch-per-gallon "rule" has killed more fish than it has helped. Always research the adult size, bioload, and social needs of every species individually.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Cycling Comes First',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'This is so important it bears repeating: your tank must be cycled before any fish go in. The nitrogen cycle takes 2–6 weeks to establish. During this time, beneficial bacteria grow and colonise your filter and substrate.',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'You can cycle with or without fish. Fishless cycling (using ammonia or fish food) is safer and doesn\'t put any fish at risk. Your test kit is your best friend during this process — watch for ammonia and nitrite to spike and then drop to zero.',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'Tip: You can speed up cycling by borrowing some filter media or substrate from an established, healthy tank. The beneficial bacteria will colonise your new filter much faster.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Introducing Fish Gradually',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Even in a fully cycled tank, don\'t add all your fish at once. The bacterial colony can only handle so much waste at once. Adding too many fish overwhelms the system and causes an ammonia spike.',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• **Week 1:** Add 2–3 small fish (or one slightly larger fish)\n• **Week 2:** Test water parameters. If ammonia and nitrite are zero, add a few more\n• **Week 3 onwards:** Continue adding fish gradually, testing between additions\n• **Rule of thumb:** Add no more than 25% of your planned total stocking per week',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'Acclimation matters! Float the fish bag in your tank for 15 minutes to equalise temperature, then gradually mix tank water into the bag over 30 minutes before releasing.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Compatibility Basics',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Not all fish get along. Before adding any species to your tank, check these three things:',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• **Temperament:** Peaceful community fish (tetras, rasboras, corydoras) should live with other peaceful fish. Don\'t mix aggressive or semi-aggressive species with gentle community fish.\n• **Size:** A general rule — don\'t keep fish with tank mates that can fit in their mouth. Tiny fish will eventually become lunch.\n• **Water parameters:** Check temperature range, pH preference, and hardness. Fish from different environments (e.g., African rift lake cichlids and Amazon tetras) need very different water chemistry.',
          ),
          const LessonSection(
            type: LessonSectionType.funFact,
            content:
                'Corydoras catfish are one of the best community additions. They\'re peaceful, active, and clean up food that falls to the bottom. Keep them in groups of at least 6 — they\'re social creatures!',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Warning Signs of Overstocking',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'An overstocked tank is a ticking time bomb. Watch for these signs:',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• **Constant high nitrates:** If weekly water changes can\'t keep nitrates below 40 ppm, you have too many fish\n• **Aggression increasing:** Fish fighting more as they compete for limited territory\n• **Excessive algae:** More fish = more waste = more nutrients for algae\n• **Cloudy water that won\'t clear:** Usually a sign of excess biological load\n• **Fish hiding all the time:** Stressed from overcrowding and lack of personal space',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'The best approach: research every species before buying. Know its adult size, minimum tank size, preferred water parameters, temperament, and whether it needs to be kept in a group. Then plan your stocking list and check compatibility.',
          ),
        ],
        quiz: Quiz(
          id: 'eq_stocking_quiz',
          lessonId: 'eq_stocking',
          questions: [
            const QuizQuestion(
              id: 'eq_stocking_q1',
              question: 'Why is the "inch per gallon" rule unreliable?',
              options: [
                'Fish don\'t grow in captivity',
                'It ignores differences in waste production, adult size, and social needs between species',
                'It only works for saltwater tanks',
                'It was disproven in the 1990s',
              ],
              correctIndex: 1,
              explanation:
                  'The rule treats all fish as equal, but a 30 cm goldfish produces far more waste than six 5 cm tetras. Different species have wildly different bioloads and space needs.',
            ),
            const QuizQuestion(
              id: 'eq_stocking_q2',
              question: 'When can you add fish to a new tank?',
              options: [
                'As soon as the water clears',
                'After the tank has been cycling for at least 2–6 weeks and tests show zero ammonia and nitrite',
                'After 24 hours of running the filter',
                'When the water reaches room temperature',
              ],
              correctIndex: 1,
              explanation:
                  'The nitrogen cycle takes 2–6 weeks to establish beneficial bacteria colonies. You should only add fish once ammonia and nitrite readings are consistently zero.',
            ),
            const QuizQuestion(
              id: 'eq_stocking_q3',
              question: 'What is a sign that your tank might be overstocked?',
              options: [
                'Fish are eating enthusiastically',
                'Nitrates stay high even after weekly water changes',
                'The filter is running quietly',
                'Plants are growing well',
              ],
              correctIndex: 1,
              explanation:
                  'If regular water changes can\'t keep nitrates below 40 ppm, your tank is producing more waste than the filtration and maintenance can handle — a clear sign of overstocking.',
            ),
          ],
        ),
      ),

      // Lesson 2.48: Essential Maintenance Skills
      Lesson(
        id: 'eq_maintenance_skills',
        pathId: 'equipment',
        title: 'Essential Maintenance Skills',
        description: 'Hands-on techniques every fishkeeper needs to know',
        orderIndex: 5,
        xpReward: 50,
        estimatedMinutes: 8,
        sections: [
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'The Skills That Keep Fish Alive',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'You can read about water parameters and the nitrogen cycle all day, but at some point you need to get your hands wet. These are the practical skills every fishkeeper uses regularly — and doing them properly makes the difference between a thriving tank and a struggling one.',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'Consistency beats intensity. A modest 25% water change every week is far better than an emergency 80% change once a month.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'How to Do a Water Change (Step by Step)',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Weekly partial water changes are the single most important maintenance task. They remove nitrates, replenish minerals, and keep your water fresh.',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '1. **Turn off the heater and filter** — a heater running in low water can crack; a filter without water can burn out\n2. **Prepare replacement water** — fill a clean bucket, add water conditioner, and match the temperature to your tank\n3. **Remove 25–30% of the water** — use a siphon or jug. Don\'t remove more than 30% in a single session unless it\'s an emergency\n4. **Clean the substrate** while draining — more on this below\n5. **Refill slowly** — pour new water in gently to avoid disturbing fish and substrate. Pouring onto a plate or your hand disperses the flow\n6. **Turn equipment back on** — wait a few minutes for the water to equalise, then switch everything on\n7. **Test the water** — check parameters to make sure everything looks good',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'Never use hot tap water to speed up temperature matching. In the UK, hot water passes through copper pipes and boilers, leaching dissolved copper that is toxic to fish — especially invertebrates.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'How to Gravel Vacuum',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'A gravel vacuum (also called a siphon) is your best friend. It removes water and cleans the substrate at the same time — basically a two-for-one maintenance tool.',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• Insert the wide end into the gravel and twist slightly — you\'ll see debris and dirty water get sucked up\n• When the water flowing out runs clear, move to the next section\n• Don\'t vacuum the entire substrate every week — rotate through sections (e.g., one quarter per week) so you don\'t disturb too much beneficial bacteria\n• Only vacuum the top 2–3 cm of gravel. Deeper layers are where most of your beneficial bacteria live\n• For sand substrate, hover the vacuum just above the surface — sand is lighter and will get sucked up if you push in too deep',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'How to Start a Siphon',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Starting a siphon for the first time can feel awkward, but it\'s straightforward once you know the technique:',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• **Method 1 — Submerge and lift:** Fill the entire siphon tube with water (submerge it fully), put your thumb over the end, and place that end in your waste bucket below the tank level. Remove your thumb and gravity does the rest.\n• **Method 2 — Squeeze bulb:** Many modern siphons have a squeeze bulb. Submerge the vacuum end, squeeze the bulb a few times, and water will start flowing.\n• **Method 3 — Shake method:** Submerge the vacuum end, hold the tube end below the tank, and quickly move the vacuum end up and down in the water to start the flow.\n\n⚠️ Never start a siphon by sucking on the tube with your mouth. Aquarium water contains bacteria that can make you ill.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Rinsing Substrate Before Setup',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'New gravel and sand are coated in fine dust from manufacturing. If you add them straight to your tank, you\'ll get a cloudy mess that can take days to clear.',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• Put a small amount of substrate in a bucket (don\'t rinse the whole bag at once — it gets too heavy)\n• Fill the bucket with water, stir vigorously, and pour off the cloudy water\n• Repeat until the water runs clear — this can take 5–10 rinses for dusty substrates\n• Only then add it to your tank\n\n⚠️ Use water only — never soap or detergent. Even trace amounts are lethal to fish.',
          ),
          const LessonSection(
            type: LessonSectionType.funFact,
            content:
                'Some planted tank substrates (like aquasoil) should NOT be pre-rinsed — the cloudiness is temporary and the nutrients in the dust are beneficial. Always check the manufacturer\'s instructions!',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Filter Maintenance Basics',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Your filter is the heart of your tank\'s ecosystem. The beneficial bacteria living on the filter media are doing most of the work keeping your water safe. Look after them!',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• **Mechanical media (sponge/pad):** Rinse in OLD tank water during a water change, never under tap water. Chlorine kills beneficial bacteria.\n• **Biological media (ceramic rings, bio-balls):** Rinse gently in old tank water. Replace only when they\'re physically falling apart — not on a schedule.\n• **Chemical media (carbon):** Replace monthly as directed. Remove during medication treatment — carbon absorbs the medication.\n• **Flow check:** If water flow noticeably decreases, it\'s time to clean or replace the mechanical media.',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content:
                'Never clean all your filter media at once. Replace or clean one component at a time, spaced weeks apart. This preserves enough bacteria to keep your cycle going.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Tools Every Beginner Needs',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'You don\'t need to spend a fortune, but a few basic tools make maintenance much easier:',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• **Gravel vacuum/siphon:** Essential. Get one appropriate for your tank size.\n• **Water conditioner:** Removes chlorine and chloramine from tap water. Non-negotiable.\n• **Liquid test kit:** Drop tests (API Freshwater Master Kit) are more accurate than test strips and last for hundreds of tests.\n• **Bucket:** Dedicated to aquarium use only — never one that\'s had soap or chemicals in it.\n• **Thermometer:** A basic glass or digital thermometer to monitor water temperature.\n• **Algae scraper:** For cleaning the glass. Avoid kitchen sponges (soap residue).\n• **Net:** For moving fish or removing debris. Get a soft mesh one to avoid injuring fish.\n• **Towels:** Aquariums are wet. Keep a dedicated towel nearby — you\'ll use it every time.',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'Set up a maintenance routine and stick to it. Weekly water changes, monthly filter checks, and daily visual inspections. Your fish will reward you with years of health and colour.',
          ),
        ],
        quiz: Quiz(
          id: 'eq_maintenance_skills_quiz',
          lessonId: 'eq_maintenance_skills',
          questions: [
            const QuizQuestion(
              id: 'eq_maint_q1',
              question: 'How much water should you change per week?',
              options: [
                '10%',
                '25–30%',
                '50%',
                '100%',
              ],
              correctIndex: 1,
              explanation:
                  '25–30% weekly is the sweet spot — enough to remove nitrates without disrupting beneficial bacteria or causing parameter swings.',
            ),
            const QuizQuestion(
              id: 'eq_maint_q2',
              question: 'Why should you rinse filter media in old tank water instead of tap water?',
              options: [
                'Old water cleans more effectively',
                'Tap water is too cold and shocks the bacteria',
                'Chlorine in tap water kills beneficial bacteria',
                'Old water has nutrients that feed the bacteria',
              ],
              correctIndex: 2,
              explanation:
                  'Chlorine and chloramine in tap water are specifically designed to kill bacteria — including the beneficial ones in your filter. Old tank water is chlorine-free and safe for rinsing.',
            ),
            const QuizQuestion(
              id: 'eq_maint_q3',
              question: 'What should you never do when starting a siphon?',
              options: [
                'Use a bucket',
                'Start it by sucking on the tube with your mouth',
                'Submerge the tube fully first',
                'Place the waste bucket below the tank level',
              ],
              correctIndex: 1,
              explanation:
                  'Aquarium water contains bacteria that can make you ill. Always use one of the safe methods: submerge-and-lift, squeeze bulb, or the shake method.',
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
                'Stress is the single biggest trigger for fish disease. Poor water quality, overcrowding, aggressive tankmates, and sudden parameter changes all weaken your fish\'s immune system. Eliminate stress sources and most problems disappear!',
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

      // Lesson 34: Ich
      Lesson(
        id: 'fh_ich',
        pathId: 'fish_health',
        title: 'Ich: The White Spot Killer',
        description: 'Identify and treat the most common fish disease',
        orderIndex: 1,
        xpReward: 50,
        estimatedMinutes: 8,
        sections: [
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Recognising Ich',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Ichthyophthirius multifiliis — commonly called "ich" or "white spot" — is the most widespread fish disease in the aquarium hobby. It looks like someone sprinkled fine salt grains over your fish\'s body, fins, and gills. Infected fish will often "flash" (rub against objects), clamped their fins, breathe rapidly, and become lethargic. Every aquarium will encounter ich eventually — the parasite is nearly omnipresent, but only attacks when fish are stressed.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'The 3-Stage Lifecycle',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'Ich has three lifecycle stages: (1) Trophont — the white spot you see, feeding on your fish\'s skin and gills. (2) Tomont — falls off the fish, encysts on surfaces, and multiplies (up to 1,000 new parasites from one spot!). (3) Theront — free-swimming stage that seeks a new host. You can ONLY kill ich during the free-swimming theront stage!',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Treatment: Heat and Salt',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'The most reliable treatment is the "heat and salt" method. Raise the temperature to 30°C (86°F) gradually — no more than 1°C per hour — to speed up the parasite\'s lifecycle. Add aquarium salt at 1 tablespoon per 20 litres. The heat accelerates the lifecycle so parasites reach the vulnerable free-swimming stage faster, while the salt is toxic to theronts. Maintain this for 10-14 days after the last visible spot disappears. Never stop early — parasites can survive in the tomont cyst stage.',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content:
                'Some fish are sensitive to heat (rummynose tetras, cool-water species) and salt (scaleless fish like loaches and Corydoras). For these, use a commercial ich medication (containing formalin or malachite green) at half dose, or raise temperature alone (29-30°C) without salt.',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'Prevention beats cure every time. Quarantine new fish for 2-4 weeks. Maintain stable water quality. Avoid sudden temperature drops (common in winter). Healthy, unstressed fish can often fight off ich without treatment.',
          ),
        ],
        quiz: Quiz(
          id: 'fh_ich_quiz',
          lessonId: 'fh_ich',
          questions: [
            const QuizQuestion(
              id: 'fh_ich_q1',
              question: 'During which stage of the ich lifecycle can the parasite be killed with medication?',
              options: [
                'When attached to the fish (white spots)',
                'When encysted on surfaces (tomont stage)',
                'When free-swimming (theront stage)',
                'It can be killed at any stage',
              ],
              correctIndex: 2,
              explanation:
                  'Only the free-swimming theront stage is vulnerable. The white spots are protected by being attached to the fish, and cysts are protected on surfaces.',
            ),
            const QuizQuestion(
              id: 'fh_ich_q2',
              question: 'Why do you raise the temperature when treating ich?',
              options: [
                'Heat directly kills the parasite',
                'It speeds up the lifecycle so parasites reach the vulnerable stage faster',
                'It makes the salt work better',
                'It makes the fish\'s immune system stronger',
              ],
              correctIndex: 1,
              explanation:
                  'Higher temperatures accelerate the parasite\'s lifecycle, forcing it into the free-swimming (treatable) stage sooner. This shortens the overall treatment time.',
            ),
            const QuizQuestion(
              id: 'fh_ich_q3',
              question: 'True or False: You should stop ich treatment as soon as the white spots disappear.',
              options: [
                'True',
                'False',
              ],
              correctIndex: 1,
              explanation:
                  'False! Continue treatment for 10-14 days after the last visible spot. Parasites in the cyst (tomont) stage can survive and reinfect your fish.',
            ),
          ],
        ),
      ),

      // Lesson 35: Fin Rot
      Lesson(
        id: 'fh_fin_rot',
        pathId: 'fish_health',
        title: 'Fin Rot & Bacterial Infections',
        description: 'Bacterial diseases and how to treat them',
        orderIndex: 2,
        xpReward: 50,
        estimatedMinutes: 8,
        sections: [
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'What Is Fin Rot?',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Fin rot is a bacterial infection (usually Aeromonas or Pseudomonas) that eats away at your fish\'s fins, starting from the edges and progressing inward. The affected fin tissue turns opaque, white, or reddish before disintegrating. In severe cases, the infection reaches the body (body rot), which is far more dangerous. Fin rot is almost always a sign of poor water quality — ammonia, nitrite, or nitrate at elevated levels, or water that hasn\'t been changed in weeks.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Fin Rot vs Fin Nipping: Know the Difference',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'Fin rot causes ragged, disintegrating edges with discolouration — the fins look "melting" and uneven. Fin nipping creates clean, V-shaped notches in specific fins (often the tail). Fin rot affects multiple fins simultaneously. If only one fin is damaged and it\'s the same fish every time, suspect a bully, not bacteria.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Treatment Protocol',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Step 1: Test your water and fix any problems (water change, filter check). Fin rot cannot be cured permanently if the underlying cause remains. Step 2: Do a 30-50% water change. Step 3: For mild cases, clean water and aquarium salt (1 tbsp per 20 litres) may be enough — fins regenerate quickly. Step 4: For moderate to severe cases, treat with a broad-spectrum antibacterial (Furan-2, API Fin & Body Cure, or kanamycin). Always treat in a hospital tank. Fins regrow in 2-4 weeks with clean water.',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content:
                'If fin rot keeps returning despite treatment, the root cause is environmental. Chronic fin rot means chronic water quality problems. Check for overfeeding, overcrowding, inadequate filtration, or a cycled filter that crashed.',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'Betta fish are particularly prone to fin rot due to their large, delicate fins. Ensure betta tanks are heated (24-28°C), filtered with gentle flow, and kept pristine. Velvet is commonly misdiagnosed as fin rot — shine a flashlight on the fish to check for a golden shimmer.',
          ),
        ],
        quiz: Quiz(
          id: 'fh_finrot_quiz',
          lessonId: 'fh_fin_rot',
          questions: [
            const QuizQuestion(
              id: 'fh_fin_q1',
              question: 'What is the first step in treating fin rot?',
              options: [
                'Add medication immediately',
                'Test water and fix any parameter problems',
                'Raise the temperature to 30°C',
                'Remove all other fish from the tank',
              ],
              correctIndex: 1,
              explanation:
                  'Fin rot is caused by poor water quality. If you don\'t fix the water, the bacteria will keep coming back no matter how much medication you add.',
            ),
            const QuizQuestion(
              id: 'fh_fin_q2',
              question: 'How can you tell fin rot apart from fin nipping?',
              options: [
                'Fin rot only affects the tail fin',
                'Fin rot causes ragged, disintegrating edges across multiple fins; nipping creates clean V-shaped notches',
                'There is no difference',
                'Fin nipping happens faster than fin rot',
              ],
              correctIndex: 1,
              explanation:
                  'Fin rot melts fin tissue unevenly across multiple fins. Fin nipping creates clean, bite-shaped chunks missing from specific fins.',
            ),
          ],
        ),
      ),

      // Lesson 36: Fungal Infections
      Lesson(
        id: 'fh_fungal',
        pathId: 'fish_health',
        title: 'Fungal Infections',
        description: 'Cotton-like growths and how to treat them',
        orderIndex: 3,
        xpReward: 50,
        estimatedMinutes: 7,
        sections: [
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Cotton Wool Disease',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Fungal infections in aquarium fish appear as white, grey, or brownish cotton-like growths on the skin, fins, mouth, or gills. The most common is Saprolegnia — a water mould (technically an oomycete, not a true fungus, but treated the same). Fungal infections are almost always secondary — they attack tissue that\'s already been damaged by injury, rough handling, or another disease. A healthy fish with intact slime coat is nearly immune.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Common Causes',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• **Physical injury:** Net damage, aggression from tankmates, sharp decor edges\n• **Poor water quality:** High ammonia/nitrite weakens the slime coat\n• **Cold water:** Low temperatures suppress the immune system and promote fungal growth\n• **Uneaten food:** Decaying food provides a breeding ground for fungi\n• **Previous infection:** Fin rot or ich damage leaves tissue vulnerable to fungal colonisation',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Treatment',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Treat with antifungal medications: methylene blue, API Fungus Cure, or PimaFix (natural melaleuca-based). Methylene blue is highly effective and safe — it also protects eggs and fry from fungal infections. Apply in a hospital tank at the recommended dose. For mouth fungus (Columnaris — actually bacterial despite the name), antibacterial treatment (Furan-2) is required instead of antifungal. Improve water quality with water changes. Remove any sharp decor that may have caused the initial injury.',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content:
                'Methylene blue stains everything blue — including silicone, plastic plants, and your fingers. It also kills beneficial bacteria, so ONLY use it in a hospital tank, never in your main display.',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'Prevention is straightforward: maintain excellent water quality, avoid sharp or rough decorations (smooth river rocks and silk plants are safest), use a soft net, and quarantine new arrivals. A healthy slime coat is your fish\'s best defence against fungal infection.',
          ),
        ],
        quiz: Quiz(
          id: 'fh_fungal_quiz',
          lessonId: 'fh_fungal',
          questions: [
            const QuizQuestion(
              id: 'fh_fung_q1',
              question: 'Fungal infections in fish are usually:',
              options: [
                'The primary cause of illness',
                'Secondary to injury or other disease',
                'Caused by feeding too much protein',
                'Only found in cold water tanks',
              ],
              correctIndex: 1,
              explanation:
                  'Fungi attack damaged tissue. They\'re opportunists that colonise injuries, wounds, or tissue already weakened by bacterial infections.',
            ),
            const QuizQuestion(
              id: 'fh_fung_q2',
              question: 'Why should you never use methylene blue in your main display tank?',
              options: [
                'It makes fish too blue to see',
                'It kills beneficial bacteria that maintain the nitrogen cycle',
                'It raises the pH too high',
                'It dissolves silicone seals',
              ],
              correctIndex: 1,
              explanation:
                  'Methylene blue is a potent antibacterial that will kill the beneficial bacteria in your filter, crashing the nitrogen cycle. Always use it in a separate hospital tank.',
            ),
          ],
        ),
      ),

      // Lesson 37: Parasites
      Lesson(
        id: 'fh_parasites',
        pathId: 'fish_health',
        title: 'Parasites: Identification & Treatment',
        description: 'Flukes, worms, and other freeloaders',
        orderIndex: 4,
        xpReward: 50,
        estimatedMinutes: 8,
        sections: [
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'External Parasites',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'External parasites are freeloaders that attach to or live on your fish\'s skin, fins, or gills. The telltale signs: "flashing" (rubbing against objects), clamped fins, rapid gill movement, excessive mucus production, and visible parasites on the body. Common culprits include gill flukes (monogenean trematodes), anchor worms (crustacean parasites), fish lice (Argulus), and velvet (Oödinium — technically a dinoflagellate protozoan).',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Common Parasite Types',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• **Gill flukes:** Microscopic flatworms on gills. Cause rapid breathing, gasping. Treat with Praziquantel (API General Cure).\n• **Anchor worms:** Visible threads hanging from fish. Actually crustaceans, not worms. Treat with potassium permanganate or carefully remove with tweezers.\n• **Fish lice:** Disc-shaped parasites visible on skin. Cause red sores. Treat with organophosphate insecticides (Dimilin).\n• **Velvet (Oödinium):** Golden dust on skin. Photosynthetic — dim the lights! Treat with copper-based meds.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Internal Parasites',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Internal parasites live inside the fish — tapeworms, roundworms (Camallanus), and protozoans (Hexamita/spironucleus). Signs: bloated belly despite normal feeding, stringy white faeces, weight loss, hollow belly, or a red worm visibly protruding from the vent (Camallanus is diagnostic). Treat internal parasites with Praziquantel (tapeworms) or Fenbendazole/Levamisole (roundworms). Medicated anti-parasite food is available, but sick fish often won\'t eat — medicating the water may be necessary.',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'Praziquantel (found in API General Cure) is the single most useful anti-parasite medication for freshwater aquariums. It treats tapeworms, flukes, and many other parasites. It\'s safe for most fish and doesn\'t harm the filter. Keep a pack on hand.',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content:
                'Camallanus worms are increasingly common in the hobby, often introduced via live food (blackworms, tubifex) or wild-caught fish. If one fish has them, assume all tankmates are infected. Treat the entire tank, not just the visibly affected fish.',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'The easiest way to avoid most parasites: quarantine every new fish for 2-4 weeks and avoid feeding live foods from unreliable sources. Frozen foods are safe (freezing kills parasites). Most parasite outbreaks trace back to a new fish or live food addition.',
          ),
        ],
        quiz: Quiz(
          id: 'fh_parasites_quiz',
          lessonId: 'fh_parasites',
          questions: [
            const QuizQuestion(
              id: 'fh_para_q1',
              question: 'What is "flashing" in fish a sign of?',
              options: [
                'Playing or exercising',
                'Parasite irritation — the fish is rubbing against objects to relieve itching',
                'Attempting to jump out of the tank',
                'A mating behaviour',
              ],
              correctIndex: 1,
              explanation:
                  'Flashing (rubbing against gravel, wood, or glass) is a classic sign of external parasite irritation. It\'s the fish equivalent of scratching an itch.',
            ),
            const QuizQuestion(
              id: 'fh_para_q2',
              question: 'What medication is the most versatile anti-parasite treatment for freshwater fish?',
              options: [
                'Methylene blue',
                'Praziquantel (API General Cure)',
                'Aquarium salt',
                'Seachem Prime',
              ],
              correctIndex: 1,
              explanation:
                  'Praziquantel treats tapeworms, flukes, and many other parasites. It\'s filter-safe, effective, and the most broadly useful anti-parasite medication for freshwater.',
            ),
            const QuizQuestion(
              id: 'fh_para_q3',
              question: 'What are "stringy white faeces" a symptom of?',
              options: [
                'Overfeeding',
                'Internal parasites',
                'Swim bladder disease',
                'Constipation from dry food',
              ],
              correctIndex: 1,
              explanation:
                  'Stringy white, mucousy faeces that persist for days are a hallmark sign of internal parasites (often tapeworms or Hexamita). Normal faeces are coloured and disintegrate.',
            ),
          ],
        ),
      ),

      // Lesson 38: Hospital Tank
      Lesson(
        id: 'fh_hospital_tank',
        pathId: 'fish_health',
        title: 'Hospital Tank Setup',
        description: 'Treat sick fish without harming your display tank',
        orderIndex: 5,
        xpReward: 50,
        estimatedMinutes: 7,
        sections: [
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Your Fish\'s ICU',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'A hospital tank (sometimes called a quarantine tank or QT) is the single most important piece of equipment that most hobbyists don\'t have. It\'s a small, bare-bottom tank dedicated to treating sick fish or quarantining new arrivals. Without one, you\'re forced to medicate your entire display tank — killing beneficial bacteria, stressing healthy fish, and potentially harming plants and invertebrates.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Setting Up Your Hospital Tank',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'Hospital tank essentials: 38-40 litre (10-gallon) tank, bare bottom (no substrate — easier to clean and see waste), sponge filter (gentle, biological filtration), adjustable heater, dim lighting or cover (reduces stress), and PVC pipes or terracotta pots for hiding spots. Keep it running with a sponge filter seeded from your main tank\'s filter so it\'s always cycled and ready.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Quarantine Protocol',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Every new fish should go through quarantine before entering your display tank. Duration: 2-4 weeks minimum. During quarantine, observe for signs of disease, treat preventively if needed (many experienced aquarists do a Praziquantel treatment as a precaution), and feed high-quality food to build the fish\'s strength. This prevents 90% of disease introductions. It seems like extra work, but treating a disease outbreak in your main tank is 10x more work.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Using the Hospital Tank for Treatment',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'When moving a sick fish to the hospital tank, match the water parameters (temperature, pH, GH) as closely as possible to the display tank. A net transfer is stressful — consider using a container to move the fish with some tank water. Once in the hospital tank, treat with the appropriate medication at the recommended dose. Perform 25-50% daily water changes before each medication dose. After treatment, observe for 1 week before returning the fish to the main tank.',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content:
                'Never transfer filter media from your hospital tank back to your main tank after treating with medications. The media may contain residual medication or pathogens. Keep hospital tank media completely separate.',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'Keep a dedicated hospital tank running year-round if possible. A seeded sponge filter keeps the cycle alive, and a bare-bottom setup means zero maintenance when not in use. When disease strikes, you\'ll be glad it\'s ready to go.',
          ),
        ],
        quiz: Quiz(
          id: 'fh_hospital_quiz',
          lessonId: 'fh_hospital_tank',
          questions: [
            const QuizQuestion(
              id: 'fh_hosp_q1',
              question: 'Why should a hospital tank have no substrate?',
              options: [
                'Substrate makes the water too hard',
                'It\'s easier to see waste and clean the tank without substrate',
                'Fish hide in substrate when sick',
                'Substrate absorbs medications',
              ],
              correctIndex: 1,
              explanation:
                  'A bare bottom lets you see exactly how much the fish is eating, spot waste immediately, and keep the tank clean with minimal effort. Medication doses are also easier to calculate accurately.',
            ),
            const QuizQuestion(
              id: 'fh_hosp_q2',
              question: 'How long should new fish be quarantined?',
              options: [
                '24-48 hours',
                '1 week',
                '2-4 weeks',
                'Quarantine is unnecessary',
              ],
              correctIndex: 2,
              explanation:
                  '2-4 weeks is the standard quarantine period. Many diseases have incubation periods of 1-3 weeks, so shorter quarantine periods risk missing asymptomatic infections.',
            ),
            const QuizQuestion(
              id: 'fh_hosp_q3',
              question: 'True or False: You should return hospital tank filter media to your main tank after treatment.',
              options: [
                'True',
                'False',
              ],
              correctIndex: 1,
              explanation:
                  'False! Hospital tank media may contain residual medication or pathogens. Keep hospital and main tank filter media completely separate to protect your display tank.',
            ),
          ],
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
      // ----- BETTA FISH (sc_betta) -----
      Lesson(
        id: 'sc_betta',
        pathId: 'species_care',
        title: 'Betta Fish Care',
        description:
            'The beautiful Siamese fighting fish - more than just a cup fish!',
        orderIndex: 0,
        xpReward: 50,
        estimatedMinutes: 10,
        sections: [
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'The Betta Truth',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Let\'s start by busting the biggest myth in fishkeeping: bettas do NOT live in puddles. In the wild, Betta splendens inhabit shallow rice paddies, marshes, and slow-moving streams across Southeast Asia. Sure, these waters aren\'t deep — but they\'re vast, warm, and teeming with life. A tiny unheated bowl is nothing like their natural habitat.',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'Minimum tank size: 19 litres (5 gallons). Temperature: 24-28°C (75-82°F). pH: 6.5-7.5. Filtered and heated — always.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Tank Setup & Filtration',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Bettas are labyrinth fish, meaning they breathe air from the surface. But that doesn\'t mean they don\'t need a filter! They still produce waste, and ammonia burns their gills just like any other fish. The trick is choosing a filter with gentle flow — bettas hate strong currents. A sponge filter is ideal: it provides biological filtration without blowing your betta across the tank.',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'Baffle your filter output with a sponge pre-filter or by directing the flow against the glass. Your betta should be able to swim comfortably, not fight the current.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Diet: More Than Just Pellets',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'A healthy betta needs variety. High-quality betta pellets should be the staple (2-3 pellets, twice daily — overfeeding is the #1 cause of bloating), but supplement with frozen or live foods: bloodworms, brine shrimp, and daphnia. Avoid freeze-dried foods as they can cause constipation — soak them first if you must use them.',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content:
                'Never feed your betta flake food meant for community tanks. It sinks too fast, and bettas are surface feeders. Uneaten flakes rot and spike ammonia. Also, skip the "betta feeding block" — it\'s a myth product that just pollutes the water.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Betta Varieties',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Bettas come in stunning varieties. Halfmoon tails fan out 180 degrees like a flowing dress. Crowntails have spiky, ray-extended fins that look like royalty. Plakats have short, powerful fins — they\'re closer to wild-type and are more active swimmers. Veiltails are the most common pet-store variety with long, drooping tails. Each type has slightly different care needs — long-finned varieties are slower and more prone to fin damage.',
          ),
          const LessonSection(
            type: LessonSectionType.funFact,
            content:
                'Betta fights were so popular in Thailand (formerly Siam) that the King taxed them! The species name "splendens" means "splendid" — and watching a halfmoon betta flare, you can see why.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Common Diseases',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Velvet (Oödinium) is a golden dust-like parasite that\'s often missed until it\'s advanced. Shine a flashlight on your betta — if you see a gold shimmer, it\'s velvet. Fin rot (bacterial) eats away at those beautiful fins, turning edges black or red. Both are usually caused by poor water quality or cold water. Keep your betta warm and your water clean, and these problems become rare.',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'Indian Almond Leaves (Catappa leaves) release tannins that mimic bettas\' natural blackwater habitat. They lower pH slightly, have mild antifungal/antibacterial properties, and most bettas love building bubble nests under them.',
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
                '1 litre (a bowl)',
                '5 litres (a vase)',
                '19 litres (5 gallons)',
                '40 litres (10 gallons)',
              ],
              correctIndex: 3,
              explanation:
                  '40 litres (10 gallons) is the minimum. Bettas need heated, filtered water — a bowl provides neither.',
            ),
            const QuizQuestion(
              id: 'sc_betta_q2',
              question: 'Why should you avoid giving bettas flake food?',
              options: [
                'It\'s toxic to them',
                'It sinks too fast and they\'re surface feeders',
                'It makes them aggressive',
                'It dissolves their fins',
              ],
              correctIndex: 1,
              explanation:
                  'Bettas are surface feeders. Flake food sinks before they can eat it all, and uneaten flakes pollute the water.',
            ),
            const QuizQuestion(
              id: 'sc_betta_q3',
              question: 'What type of filter is ideal for a betta tank?',
              options: [
                'Power filter with strong flow',
                'Canister filter',
                'Sponge filter with gentle flow',
                'No filter — bettas don\'t need one',
              ],
              correctIndex: 2,
              explanation:
                  'Sponge filters provide biological filtration with very gentle flow. Bettas hate strong currents and still need filtration for ammonia control.',
            ),
            const QuizQuestion(
              id: 'sc_betta_q4',
              question: 'True or False: Bettas live in puddles in the wild.',
              options: [
                'True',
                'False',
              ],
              correctIndex: 1,
              explanation:
                  'False! Bettas live in rice paddies, marshes, and slow streams — vast, shallow, warm habitats. Not tiny puddles.',
            ),
          ],
        ),
      ),

      // ----- GOLDFISH (sc_goldfish) -----
      Lesson(
        id: 'sc_goldfish',
        pathId: 'species_care',
        title: 'Goldfish: The Misunderstood Fish',
        description: 'Goldfish are NOT beginner fish — they\'re messy giants!',
        orderIndex: 1,
        xpReward: 50,
        estimatedMinutes: 10,
        sections: [
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Tiny Bowl, Massive Fish',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'The fairground goldfish in a plastic bag is one of the worst marketing campaigns in pet history. That 2cm fish will grow to 15-30cm depending on variety, and can live 10-20 years with proper care. The "goldfish bowl" is essentially a slow death sentence — no filtration, no swimming room, no oxygen exchange, and ammonia builds up lethally fast.',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                '75 litres (20 gallons) for the first goldfish. Add 38 litres (10 gallons) per additional fish. Fancy varieties need even more space because they\'re less agile swimmers.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Fancy vs Common: Know the Difference',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'There are two main groups. Common goldfish (comets, shubunkins) are hardy, fast swimmers that can exceed 30cm. They\'re suited to large tanks or outdoor ponds. Fancy goldfish (orandas, ranchu, lionheads, ryukin) have rounded bodies and exaggerated fins — gorgeous, but they\'re slower, less hardy, and prone to swim bladder issues. Never mix the two: commons are too fast and outcompete fancies for food.',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content:
                'Fancy goldfish are especially prone to swim bladder disorder from eating dry food that expands in their gut. Soak pellets before feeding, and include shelled peas (squished) in their diet to prevent constipation.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Filtration: They Need Serious Power',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Goldfish produce more waste per gram of body weight than almost any other aquarium fish. A filter rated for a tropical tank will struggle with goldfish. Aim for a filter that turns over the tank volume 6-10 times per hour. Cannister filters or large hang-on-back filters are your best bet. And despite the myth, goldfish do NOT do better in cold water — they thrive at 18-22°C (64-72°F). Room-temperature water in a cold house can dip dangerously low.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Diet: They\'re Pigs',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Goldfish are constant grazers with no real stomach — food passes through them quickly. Feed sinking pellets (not floating — they gulp air at the surface, causing buoyancy problems). Supplement with blanched vegetables: peas, spinach, zucchini, and cucumber. Avoid bread, crackers, and biscuit crumbs — these swell in their gut and can be fatal.',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'Feed 1-2 times daily, only what they can consume in 2 minutes. Overfeeding is the #1 killer of goldfish. A hungry fish is a healthy fish.',
          ),
          const LessonSection(
            type: LessonSectionType.funFact,
            content:
                'The oldest recorded goldfish, "Tish," lived to 43 years! Most goldfish die young because they\'re kept in bowls. With proper care, 15-20 years is entirely achievable.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'The Pond Option',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'If you have outdoor space, a goldfish pond is often better than any indoor tank. Commons and comets thrive in ponds year-round (at least 60cm deep for winter survival). Fancy goldfish can go in ponds too during warmer months, but bring them indoors when temperatures drop below 10°C — they\'re not as cold-hardy. A pond gives them the swimming space they desperately need.',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'Add a piece of cuttlebone to your goldfish tank or pond. It slowly releases calcium, which is essential for bone and scale health, and goldfish will nibble on it naturally.',
          ),
        ],
        quiz: Quiz(
          id: 'sc_goldfish_quiz',
          lessonId: 'sc_goldfish',
          questions: [
            const QuizQuestion(
              id: 'sc_gold_q1',
              question: 'What is the minimum tank size for a single goldfish?',
              options: [
                '10 litres (2.5 gallons)',
                '19 litres (5 gallons)',
                '38 litres (10 gallons)',
                '75 litres (20 gallons)',
              ],
              correctIndex: 3,
              explanation:
                  '75 litres (20 gallons) is the minimum for the first goldfish. They grow large and produce enormous amounts of waste.',
            ),
            const QuizQuestion(
              id: 'sc_gold_q2',
              question: 'Why should you feed goldfish sinking pellets instead of floating ones?',
              options: [
                'Sinking pellets are more nutritious',
                'Floating pellets dissolve too quickly',
                'Floating pellets cause fish to gulp air, leading to buoyancy problems',
                'Goldfish can\'t see food at the surface',
              ],
              correctIndex: 2,
              explanation:
                  'When goldfish eat at the surface they swallow air, which can cause swim bladder disorder. Sinking pellets prevent this.',
            ),
            const QuizQuestion(
              id: 'sc_gold_q3',
              question: 'How long can a goldfish live with proper care?',
              options: [
                '1-2 years',
                '3-5 years',
                '10-20 years',
                '30-40 years',
              ],
              correctIndex: 2,
              explanation:
                  '10-20 years is normal with proper care. The myth that they die quickly comes from bowl-keeping, not the fish\'s natural lifespan.',
            ),
            const QuizQuestion(
              id: 'sc_gold_q4',
              question: 'True or False: Common and fancy goldfish can be kept together safely.',
              options: [
                'True',
                'False',
              ],
              correctIndex: 1,
              explanation:
                  'False! Common goldfish are much faster swimmers and will outcompete fancies for every scrap of food. Keep them separately.',
            ),
          ],
        ),
      ),

      // ----- TETRAS (sc_tetras) -----
      Lesson(
        id: 'sc_tetras',
        pathId: 'species_care',
        title: 'Tetras: Community Tank Stars',
        description: 'Peaceful schooling fish perfect for community tanks',
        orderIndex: 2,
        xpReward: 50,
        estimatedMinutes: 10,
        sections: [
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'The Schooling Rule',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Here\'s the golden rule of tetra keeping: never keep fewer than 6. Tetras are shoaling fish — they evolved to stay in tight groups for safety from predators. A lone tetra is a stressed tetra, and a stressed tetra is a dead tetra. In groups of 6 or more, they\'re confident, active, and display their best colours. Bigger groups (10-15) are even better if your tank allows it.',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'Minimum group size: 6. Ideal: 10+. Water: 22-26°C (72-79°F), pH 6.0-7.5. Most tetras prefer soft, slightly acidic water.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Popular Tetra Species',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Neon tetras are the classics — that iridescent blue stripe and red tail are unmistakable. They stay small (2.5cm) and are peaceful, but sensitive to water quality. Cardinal tetras look similar but grow larger (5cm), have a longer red stripe, and are slightly hardier once established. Ember tetras are tiny (2cm) fireballs of orange that look stunning in planted tanks. Black skirt tetras are larger (5cm) and more robust, but can be nippy — avoid keeping them with long-finned fish.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Setting Up a Tetra Tank',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Tetras shine in planted tanks with dim to moderate lighting. Dark substrate makes their colours pop — think black or dark brown sand. Add plenty of plants: Java moss, Amazon swords, Vallisneria, and floating plants like Salvinia that dapple the light. Leave open swimming space in the middle. A gentle sponge filter or hang-on-back with a pre-filter sponge prevents tiny fry from being sucked in.',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content:
                'Avoid keeping tetras with large, predatory, or fin-nipping fish. Angelfish will eat small neons, and tiger barbs will shred their fins. Good tankmates include Corydoras catfish, small rasboras, peaceful gouramis, and other tetra species.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Feeding & Diet',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Tetras are micro-predators in the wild — they eat tiny insects, crustaceans, and zooplankton. In your tank, they\'ll accept high-quality micro pellets and crushed flake food as staples. Supplement 2-3 times per week with frozen bloodworms, brine shrimp, or daphnia. Feed small amounts — their mouths are tiny, and uneaten food sinks and rots. A pinch that\'s consumed in 60 seconds is plenty.',
          ),
          const LessonSection(
            type: LessonSectionType.funFact,
            content:
                'Neon tetras can create a "schooling shimmer" — when predators approach, the group\'s coordinated movements and reflective scales create a flashing effect that confuses attackers. It\'s called "confusion effect" and it\'s why a tight school is harder for predators to target.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Breeding Tetras',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Tetras are egg scatterers that don\'t care for their young — they\'ll eat their own eggs given the chance. To breed them, set up a dedicated spawning tank with very soft, acidic water (pH 5.5-6.5), a spawning mop or Java moss, and dim lighting. Condition the parents with live foods for a week. After spawning, remove the adults immediately. Eggs hatch in 24-36 hours, and fry are free-swimming after 3-4 days. Feed them infusoria or liquid fry food until they\'re large enough for baby brine shrimp.',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'If your tetras aren\'t showing full colour, check your water parameters. Pale, washed-out tetras are almost always stressed — usually from water that\'s too hard, too alkaline, or has elevated ammonia/nitrite.',
          ),
        ],
        quiz: Quiz(
          id: 'sc_tetras_quiz',
          lessonId: 'sc_tetras',
          questions: [
            const QuizQuestion(
              id: 'sc_tetra_q1',
              question: 'What is the minimum group size for tetras?',
              options: [
                '2-3',
                '4-5',
                '6 or more',
                '1 is fine if the tank is small',
              ],
              correctIndex: 2,
              explanation:
                  'Never keep fewer than 6 tetras. They\'re schooling fish that need a group to feel secure and display natural behaviour.',
            ),
            const QuizQuestion(
              id: 'sc_tetra_q2',
              question: 'What tankmate should you avoid keeping with neon tetras?',
              options: [
                'Corydoras catfish',
                'Harlequin rasboras',
                'Angelfish',
                'Other tetra species',
              ],
              correctIndex: 2,
              explanation:
                  'Angelfish are predators that will eat small tetras. Neons are essentially angelfish snacks in disguise.',
            ),
            const QuizQuestion(
              id: 'sc_tetra_q3',
              question: 'How can you tell the difference between neon and cardinal tetras?',
              options: [
                'Cardinals are bigger with a longer red stripe',
                'Neons are bigger with a longer red stripe',
                'They\'re the same fish with different names',
                'Cardinals have no blue stripe',
              ],
              correctIndex: 0,
              explanation:
                  'Cardinal tetras grow larger (5cm vs 2.5cm) and their red stripe extends the full body length. In neons, the red only covers the rear half.',
            ),
          ],
        ),
      ),

      // ----- CICHLIDS (sc_cichlids) -----
      Lesson(
        id: 'sc_cichlids',
        pathId: 'species_care',
        title: 'Cichlids: Personality Fish',
        description: 'From peaceful Rams to aggressive Oscars',
        orderIndex: 3,
        xpReward: 50,
        estimatedMinutes: 10,
        sections: [
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Africa vs South America: Two Different Worlds',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Cichlids are one of the most diverse fish families on Earth — over 3,000 species! But before you buy any, you need to know which "camp" they belong to, because African and South American cichlids demand completely different water chemistry. Mixing them is like putting a desert lizard in a rainforest tank — it ends badly.',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'African cichlids (especially Rift Lake): pH 7.8-8.6, GH 10-20°, temperature 24-28°C. South American cichlids: pH 6.0-7.0, GH 3-8°, temperature 24-28°C. Never mix these groups.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'African Cichlids: The Rock-Dwellers',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'African cichlids from Lake Malawi and Lake Tanganyika are the most popular. They\'re colourful, active, and territorial — think underwater bird-watching. They need hard, alkaline water (use crushed coral or limestone in the substrate to buffer pH). Provide lots of rockwork with caves and crevices — each fish will claim a territory. Mbuna (rock-dwellers) are aggressive herbivores, while Haps (open-water swimmers) are piscivores. Stock heavily — "overstocking" actually reduces aggression by preventing any single fish from dominating the whole tank.',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content:
                'Lake Malawi cichlids should be overstocked to spread aggression — but this means you need exceptional filtration (turnover 8-10x per hour) and larger, more frequent water changes. A 200-litre minimum for a Malawi community is realistic.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'South American Cichlids: The Garden Dwellers',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'South American cichlids prefer soft, acidic water with lots of plants and driftwood. This group includes angelfish, discus, rams, oscars, and severums. They\'re generally less aggressive than Africans, but some (like Oscars) grow enormous and will eat anything that fits in their mouth. German Blue Rams and Bolivian Rams are excellent beginner cichlids — they\'re small (5cm), colourful, and relatively peaceful in a community setup.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Beginner-Friendly Cichlids',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• **German Blue Ram** (Mikrogeophagus ramirezi): 5cm, peaceful community fish, needs warm water (27-29°C)\n• **Bolivian Ram**: 8cm, hardier than Blue Rams, accepts wider temperature range\n• **Kribensis** (Pelvicachromis pulcher): 10cm, cave spawner, excellent for smaller tanks\n• **Keyhole Cichlid**: 12cm, gentle temperament, very peaceful\n• **Firemouth Cichlid**: 15cm, stunning red throat display, moderate aggression',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Advanced Cichlids: Proceed with Caution',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Oscars grow to 35cm and need a 380-litre (100-gallon) tank minimum — they\'re intelligent, personable, and will redecorate your tank by moving rocks and uprooting plants. Discus are the "king of the aquarium" — stunning disc-shaped fish that demand pristine water, high temperatures (28-30°C), and soft, acidic conditions. They\'re not for beginners, but they\'re the ultimate cichlid achievement.',
          ),
          const LessonSection(
            type: LessonSectionType.funFact,
            content:
                'Cichlids are devoted parents! Most species care for their eggs and fry — some even carry them in their mouths (mouthbrooding). This parental care is rare among fish and is one reason cichlids are so fascinating.',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'When introducing cichlids to a new tank, rearrange the décor before adding each new fish. This breaks up established territories and reduces aggression toward newcomers. Adding them all at once is even better.',
          ),
        ],
        quiz: Quiz(
          id: 'sc_cichlids_quiz',
          lessonId: 'sc_cichlids',
          questions: [
            const QuizQuestion(
              id: 'sc_cich_q1',
              question: 'What pH range do Lake Malawi African cichlids need?',
              options: [
                '5.5-6.5',
                '6.5-7.0',
                '7.0-7.5',
                '7.8-8.6',
              ],
              correctIndex: 3,
              explanation:
                  'African Rift Lake cichlids need hard, alkaline water with pH 7.8-8.6. South Americans need the opposite — soft and acidic.',
            ),
            const QuizQuestion(
              id: 'sc_cich_q2',
              question: 'Why is "overstocking" actually recommended for African cichlid tanks?',
              options: [
                'They need more food competition',
                'It spreads aggression so no single fish dominates',
                'The filter needs more fish waste to work properly',
                'It makes the colours brighter',
              ],
              correctIndex: 1,
              explanation:
                  'In an African cichlid tank, more fish means aggression is spread across many targets instead of one fish being bullied to death. But filtration must be exceptional.',
            ),
            const QuizQuestion(
              id: 'sc_cich_q3',
              question: 'What is the minimum tank size for a single Oscar?',
              options: [
                '75 litres (20 gallons)',
                '150 litres (40 gallons)',
                '380 litres (100 gallons)',
                '570 litres (150 gallons)',
              ],
              correctIndex: 2,
              explanation:
                  'Oscars grow to 35cm and produce massive waste. 380 litres (100 gallons) is the minimum for one Oscar, with a powerful filter.',
            ),
            const QuizQuestion(
              id: 'sc_cich_q4',
              question: 'True or False: You can mix African and South American cichlids in the same tank.',
              options: [
                'True — they\'re all cichlids',
                'False — they need completely different water chemistry',
              ],
              correctIndex: 1,
              explanation:
                  'False! Africans need hard, alkaline water (pH 7.8-8.6) while South Americans need soft, acidic water (pH 6.0-7.0). Mixing them means one group is always in the wrong parameters.',
            ),
          ],
        ),
      ),

      // ----- SHRIMP (sc_shrimp) -----
      Lesson(
        id: 'sc_shrimp',
        pathId: 'species_care',
        title: 'Shrimp Keeping',
        description: 'Tiny cleanup crew with surprising complexity',
        orderIndex: 4,
        xpReward: 50,
        estimatedMinutes: 8,
        sections: [
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'More Than Just Cleanup Crew',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Aquarium shrimp are fascinating creatures that deserve more credit than they get. Cherry shrimp (Neocaridina davidi) are the gateway drug — they\'re hardy, breed like mad, and come in stunning colours from deep red ("Fire Red") to neon yellow ("Golden Back"). But once you\'re hooked, you\'ll discover a whole world from high-grade Crystal Red shrimp to Sulawesi dwarf shrimp. Each type has specific needs.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Cherry Shrimp: The Hardy Starter',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Cherry shrimp tolerate a wide range: 18-28°C, pH 6.5-8.0, GH 4-8°, KH 3-8°. They\'re omnivores that eat algae, biofilm, leftover fish food, and specialised shrimp pellets. A group of 10+ will keep a planted tank surprisingly clean. They breed readily — females carry eggs under their tail for 3-4 weeks before releasing tiny, fully-formed miniature shrimp. No special setup needed.',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'Cherry shrimp parameters: 18-28°C, pH 6.5-8.0, GH 4-8°, KH 3-8°. Crystal shrimp parameters: 20-24°C, pH 6.2-6.8, GH 4-6°, KH 1-3°. Crystal shrimp are far more demanding.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Crystal Red & Black Shrimp',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Crystal Red (CRS) and Crystal Black (CBS) shrimp are the show ponies of the shrimp world. Graded by intensity of colour and pattern (S, SS, SSS, Mosura), top-grade specimens sell for eye-watering prices. They need pristine, cool water (20-24°C), very soft and slightly acidic conditions, and a mature, well-planted tank. Start with lower grades (C or B) — they\'re hardier and cheaper while you learn.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Water Parameters: GH and KH Are Everything',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Shrimp need calcium for their exoskeleton (GH) and carbonate buffering (KH) for stable pH. If GH is too low, molting fails and shrimp die. If KH is too high, pH swings stress them. Use a GH/KH test kit — it\'s non-negotiable for shrimp keepers. Remineralise RO water with a dedicated shrimp mineral supplement (like Salty Shrimp GH+) rather than guessing.',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content:
                'Copper is lethal to shrimp — even trace amounts from tap water treatments or fish medications can wipe out a colony. Check medication labels before using anything in a shrimp tank. Some fish medications contain copper sulphate.',
          ),
          const LessonSection(
            type: LessonSectionType.funFact,
            content:
                'When a shrimp molts, it sheds its entire exoskeleton in one piece — like taking off a suit of armour. The discarded shell is packed with calcium and shrimp will often eat it to recover minerals. Leave it in the tank!',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'Safe tankmates for shrimp include small, non-aggressive fish: ember tetras, celestial pearl danios, otocinclus catfish, and small rasboras. Avoid loaches (especially Yo-Yo and Clown loaches), large cichlids, and anything with a big enough mouth to eat them.',
          ),
        ],
        quiz: Quiz(
          id: 'sc_shrimp_quiz',
          lessonId: 'sc_shrimp',
          questions: [
            const QuizQuestion(
              id: 'sc_shrimp_q1',
              question: 'Which mineral is critical for shrimp molting?',
              options: [
                'Iron',
                'Potassium',
                'Calcium (measured as GH)',
                'Sodium',
              ],
              correctIndex: 2,
              explanation:
                  'Calcium, measured as General Hardness (GH), is essential for shrimp to build and shed their exoskeleton. Low GH leads to failed molts and death.',
            ),
            const QuizQuestion(
              id: 'sc_shrimp_q2',
              question: 'What should you do with a shed shrimp exoskeleton?',
              options: [
                'Remove it immediately',
                'Leave it — shrimp eat it for calcium',
                'Crush it and add it to the filter',
                'It means the shrimp is dying',
              ],
              correctIndex: 1,
              explanation:
                  'Leave shed exoskeletons in the tank! They\'re rich in calcium and shrimp will consume them to recover minerals after molting.',
            ),
            const QuizQuestion(
              id: 'sc_shrimp_q3',
              question: 'Why are Crystal Red shrimp harder to keep than Cherry shrimp?',
              options: [
                'They need more food',
                'They require more precise water parameters (lower temperature, softer water)',
                'They\'re more aggressive',
                'They need saltwater',
              ],
              correctIndex: 1,
              explanation:
                  'CRS need cooler (20-24°C), softer (GH 4-6°), more acidic (pH 6.2-6.8) water than cherries, making them much less forgiving of parameter swings.',
            ),
          ],
        ),
      ),

      // ----- SNAILS (sc_snails) -----
      Lesson(
        id: 'sc_snails',
        pathId: 'species_care',
        title: 'Snails: Cleanup Crew',
        description:
            'Algae eaters that won\'t overrun your tank (if chosen right!)',
        orderIndex: 5,
        xpReward: 50,
        estimatedMinutes: 8,
        sections: [
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'The Good, The Bad, and The Pest-y',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Snails get a bad reputation because most people\'s first experience is a pest snail explosion. But the right snail species are invaluable tank citizens — they clean algae off glass, eat decaying plant matter, stir the substrate, and look genuinely cool doing it. The secret is choosing the right species.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Nerite Snails: The Best Algae Eater',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Nerite snails are the gold standard for algae control. They devour green spot algae, diatoms, and biofilm with impressive efficiency. They\'re small (2-3cm), peaceful, and — here\'s the killer feature — they cannot breed in freshwater. Their eggs need brackish water to hatch, so you\'ll never get a population explosion. You might see white sesame-seed-like eggs on surfaces, but they simply won\'t develop. Tiger nerites, zebra nerites, and horned nerites all have stunning shell patterns.',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'Nerite snails: best algae eaters, can\'t breed in freshwater, need pH 7.0-8.0 and GH 5-12°. Calcium supplementation is important — thin, pitting shells mean calcium deficiency.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Mystery / Apple Snails: The Beauties',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Mystery snails (Pomacea bridgesii — NOT Pomacea canaliculata, which is an invasive pest) come in gorgeous colours: blue, ivory, gold, magenta, and chestnut. They\'re larger (5cm shell diameter) and can breed in freshwater, laying pink-ish egg clutches above the waterline. Simply remove the clutch if you don\'t want babies — they\'re easy to spot and scrape off. They have a trapdoor (operculum) that seals their shell when threatened, and they\'ll occasionally "surf" to the top of the tank for air.',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content:
                'Avoid Malaysian Trumpet Snails (Melanoides tuberculata). They reproduce asexually and burrow into the substrate. A few hitchhikers can become hundreds in weeks. They\'re almost impossible to eradicate once established. If you see a cone-shaped spiral shell — remove it immediately.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Calcium: The Essential Supplement',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'All snails need calcium to build and maintain their shells. If you see thin, cracking, or pitting shells, your water is too soft. Add crushed cuttlebone, a piece of limestone, or liquid calcium supplements. Most tap water has enough calcium, but if you use RO water or have very soft water, supplementation is essential. GH of at least 5° is recommended for all snail species.',
          ),
          const LessonSection(
            type: LessonSectionType.funFact,
            content:
                'Assassin snails (Clea helena) are the biological solution to pest snails. They\'re beautiful striped cone-shaped snails that actively hunt and eat other snails. Add a few to a pest snail-infested tank and watch the population gradually decline. They won\'t breed fast enough to become pests themselves.',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'If you find mystery snail eggs (pinkish clutch above the waterline), just scrape them off with a card or your fingernail and dispose of them. No babies, no problem. This is one of the reasons mystery snails are considered "responsible" — population control is entirely in your hands.',
          ),
        ],
        quiz: Quiz(
          id: 'sc_snails_quiz',
          lessonId: 'sc_snails',
          questions: [
            const QuizQuestion(
              id: 'sc_snail_q1',
              question: 'Why are Nerite snails ideal for algae control?',
              options: [
                'They reproduce the fastest',
                'They\'re the cheapest snail species',
                'They can\'t breed in freshwater, so they won\'t overrun your tank',
                'They eat all types of algae including blue-green algae',
              ],
              correctIndex: 2,
              explanation:
                  'Nerite snails need brackish water to breed, so they\'re self-limiting in freshwater. No population explosions — just reliable algae eating.',
            ),
            const QuizQuestion(
              id: 'sc_snail_q2',
              question: 'What does it mean if your snail\'s shell is thin and pitting?',
              options: [
                'The snail is too old',
                'Calcium deficiency — your water is too soft',
                'The snail has a parasite',
                'The water is too warm',
              ],
              correctIndex: 1,
              explanation:
                  'Thin, pitting shells are a classic sign of calcium deficiency. Increase GH or add calcium supplements like cuttlebone or limestone.',
            ),
            const QuizQuestion(
              id: 'sc_snail_q3',
              question: 'What type of snail should you avoid introducing to your tank?',
              options: [
                'Nerite snails',
                'Mystery snails',
                'Malaysian Trumpet Snails',
                'Assassin snails',
              ],
              correctIndex: 2,
              explanation:
                  'Malaysian Trumpet Snails reproduce asexually and can quickly overrun a tank. They burrow into substrate and are extremely difficult to eradicate.',
            ),
          ],
        ),
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
      // ----- BREEDING LIVEBEARERS -----
      Lesson(
        id: 'at_breeding_livebearers',
        pathId: 'advanced_topics',
        title: 'Breeding Basics: Livebearers',
        description:
            'Guppies, mollies, and platies — easy first breeding projects',
        orderIndex: 0,
        xpReward: 75,
        estimatedMinutes: 12,
        sections: [
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'The Easiest Fish to Breed',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'If there were an award for "fish most likely to reproduce while you\'re not looking," livebearers would win every time. Guppies, mollies, platies, and swordtails give birth to free-swimming fry (no eggs!), and they\'re so prolific that the real challenge isn\'t getting them to breed — it\'s managing the population explosion that follows. A single female guppy can produce 20-60 fry every 4-6 weeks.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Sexing Your Fish',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'The easiest way to sex livebearers is by the anal fin. Males have a modified anal fin called a gonopodium — it\'s thin, pointed, and rod-like. Females have a normal, fan-shaped anal fin. Females are also noticeably larger and rounder, especially when gravid (pregnant). In guppies, males are the colourful ones with flowing tails, while females are larger but drab — grey or silver. Once you know what to look for, you can sex them at 2-3 months old.',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'The gestation period for most livebearers is 28-35 days. Females can store sperm and produce multiple batches from a single mating — up to 6 months later! This is why "just one female" isn\'t safe.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Caring for the Pregnant Female',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'A gravid female develops a dark "gravid spot" near her anal fin — this darkens as the fry develop. In the final days, you can actually see the eyes of the fry through her belly. Move her to a breeding box or separate tank before she gives birth. Keep the water pristine (ammonia and nitrite at 0), feed high-quality food (frozen bloodworms, brine shrimp), and maintain stable temperature (25-27°C for guppies). Stress can cause premature birth or absorption of the fry.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Fry Care: The Critical First Weeks',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Newborn fry are tiny and immediately hunted by every fish in the tank — including their own parents. Separate them as soon as possible. Feed freshly hatched baby brine shrimp (the gold standard), liquid fry food, or crushed flake so fine it\'s essentially powder. Feed 3-4 small meals daily. Keep the water warm (26-28°C) and clean — fry are extremely sensitive to ammonia. In 4-6 weeks they\'ll be large enough to rejoin the main tank.',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content:
                'Never use a breeding net or box long-term. The confined space stresses the female and often leads to miscarriage. Use it only in the final 1-2 days before birth, then return her to the main tank. A dedicated 40-litre breeding tank with lots of Java moss is far better.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Population Control',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'One guppy pair can produce 2,000+ fry per year. Unless you\'re breeding for sale, keep only males or only females to prevent uncontrolled breeding. Many aquarists keep all-male tanks — no babies, maximum colour. If you want both sexes, accept that you\'ll need to manage (give away, sell, or feed to larger predatory fish) the offspring regularly.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Genetics: Why Babies Look Different',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Guppy genetics are fascinating. Colour, pattern, and tail shape are all inherited traits, but a single female carrying sperm from multiple males can produce fry with wildly different appearances in the same drop. Selective breeding over generations can fix desirable traits — this is how breeders developed the fancy guppy varieties you see today. It takes patience (6-8 generations), but watching your own line develop is incredibly rewarding.',
          ),
          const LessonSection(
            type: LessonSectionType.funFact,
            content:
                'Female guppies can produce up to 6 batches of fry from a single mating — storing the male\'s sperm in a specialised organ for months. No wonder they\'re so successful in the wild!',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'If you\'re raising fry, set up a "green water" culture or Java moss culture in a sunny window. The microorganisms that grow in green water are the perfect first food for fry — it\'s free, and it never runs out.',
          ),
        ],
        quiz: Quiz(
          id: 'at_breeding_live_quiz',
          lessonId: 'at_breeding_livebearers',
          questions: [
            const QuizQuestion(
              id: 'at_live_q1',
              question: 'How can you tell a male livebearer from a female?',
              options: [
                'Males are always larger',
                'Males have a thin, rod-like anal fin called a gonopodium',
                'Females are more colourful',
                'There is no visible difference',
              ],
              correctIndex: 1,
              explanation:
                  'The gonopodium is the telltale sign — a thin, pointed, modified anal fin used to transfer sperm. Females have a normal fan-shaped anal fin.',
            ),
            const QuizQuestion(
              id: 'at_live_q2',
              question: 'How long is the gestation period for most livebearers?',
              options: [
                '7-14 days',
                '15-20 days',
                '28-35 days',
                '50-60 days',
              ],
              correctIndex: 2,
              explanation:
                  '28-35 days is typical for guppies, mollies, and platies. Watch for the darkening gravid spot as the birth approaches.',
            ),
            const QuizQuestion(
              id: 'at_live_q3',
              question: 'True or False: A female guppy can store sperm and produce multiple batches of fry from a single mating.',
              options: [
                'True',
                'False',
              ],
              correctIndex: 0,
              explanation:
                  'True! Females can store sperm for up to 6 months and produce multiple batches — this is why one mating leads to many batches of fry.',
            ),
          ],
        ),
      ),

      // ----- BREEDING EGG LAYERS -----
      Lesson(
        id: 'at_breeding_egg_layers',
        pathId: 'advanced_topics',
        title: 'Breeding: Egg Layers',
        description: 'From tetras to cichlids — raising egg-laying species',
        orderIndex: 1,
        xpReward: 75,
        estimatedMinutes: 12,
        sections: [
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'A Different Ball Game',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Breeding egg-laying fish is more challenging than livebearers because you need to trigger spawning, protect the eggs, and raise microscopic fry. But the satisfaction of seeing your first batch of tetra fry or watching cichlid parents herd their babies around the tank is unbeatable. Each species has different requirements, but there are common principles.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Conditioning Breeders',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Before breeding, condition your fish with high-quality live or frozen foods for 1-2 weeks. Bloodworms, brine shrimp, white worms, and daphnia are excellent. The goal is to get them into peak physical condition — well-fed fish produce more eggs and higher-quality fry. Separate males and females during conditioning so they\'re eager to spawn when reunited.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Spawning Triggers',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Most egg layers need specific triggers to spawn. Common triggers include: a slight temperature increase (1-2°C), a large water change (50-70%) with slightly cooler water, softening the water (using RO), and adjusting the photoperiod (longer light hours). For many tetras, adding a spawning mop (dark green yarn tied to a cork) or Java moss gives them a place to scatter their eggs. Different species respond to different triggers — research your specific fish.',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content:
                'Many egg-laying fish eat their own eggs and fry. Tetras, barbs, and many others have no parental instinct. Remove the parents immediately after spawning, or use a mesh divider. Cichlids are the exception — many are devoted parents.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Species-Specific Techniques',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• **Tetras:** Scatter eggs on spawning mops or Java moss. Remove parents after spawning. Eggs hatch in 24-48 hours.\n• **Gouramis:** Males build bubble nests at the surface. Remove female after spawning — male guards the nest.\n• **Cichlids:** Many lay eggs on flat stones or in caves. Both parents often guard eggs and fry. Don\'t separate parents!\n• **Killifish:** Some lay eggs in substrate that can survive dry periods. Eggs are sometimes shipped in damp peat moss!',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Hatching & First Foods',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Most eggs hatch in 24-72 hours depending on species and temperature. Fry initially absorb their yolk sac and don\'t need food for the first 1-3 days. After that, they need microscopic food: infusoria (cultured from hay or potato in jar water), liquid fry food, or freshly hatched baby brine shrimp. At 5-7 days, most fry can take crushed flakes or micro worms. The first two weeks are the danger zone — most losses happen here from starvation or poor water quality.',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'Fry are extremely sensitive to ammonia and nitrite. Test water daily in the rearing tank. Use aged, dechlorinated water for water changes — never raw tap water. Small daily water changes (10-15%) are safer than occasional large ones.',
          ),
          const LessonSection(
            type: LessonSectionType.funFact,
            content:
                'Betta fish males build elaborate bubble nests and will diligently tend to them, collecting any eggs that fall and returning them to the nest. After the fry hatch, he guards them until they\'re free-swimming — then he may eat them. Nature is pragmatic!',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'Start an infusoria culture 1-2 weeks before you plan to breed. Put a piece of blanched lettuce or a crushed snail shell in a jar of tank water in a sunny window. Within a week you\'ll have a cloudy culture full of microscopic organisms — free fry food.',
          ),
        ],
        quiz: Quiz(
          id: 'at_breeding_egg_quiz',
          lessonId: 'at_breeding_egg_layers',
          questions: [
            const QuizQuestion(
              id: 'at_egg_q1',
              question: 'What should you do with most egg-laying fish after they spawn?',
              options: [
                'Leave them to guard the eggs',
                'Feed them extra to prevent egg-eating',
                'Remove the parents — most will eat their own eggs',
                'Turn off the filter',
              ],
              correctIndex: 2,
              explanation:
                  'Most egg-laying fish have no parental instinct and will happily eat their own eggs. Remove parents after spawning (cichlids being the main exception).',
            ),
            const QuizQuestion(
              id: 'at_egg_q2',
              question: 'How long can most newly hatched fry survive on their yolk sac before needing food?',
              options: [
                'Immediately — they need food right away',
                '1-3 days',
                '1 week',
                '2 weeks',
              ],
              correctIndex: 1,
              explanation:
                  'Most fry absorb their yolk sac over 1-3 days before needing external food. Start with infusoria or liquid fry food.',
            ),
            const QuizQuestion(
              id: 'at_egg_q3',
              question: 'What common spawning trigger works for many tetra species?',
              options: [
                'Adding salt to the water',
                'A large water change with slightly cooler water',
                'Raising the pH to 8.0',
                'Turning off all lights for 3 days',
              ],
              correctIndex: 1,
              explanation:
                  'A 50-70% water change with water 1-2°C cooler simulates rainfall and triggers spawning in many tetra and barb species.',
            ),
          ],
        ),
      ),

      // ----- AQUASCAPING -----
      Lesson(
        id: 'at_aquascaping',
        pathId: 'advanced_topics',
        title: 'Aquascaping Fundamentals',
        description:
            'Create underwater landscapes using Iwagumi, Dutch, and Nature styles',
        orderIndex: 2,
        xpReward: 75,
        estimatedMinutes: 12,
        sections: [
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Underwater Gardening as Art',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Aquascaping is the craft of arranging aquatic plants, rocks, driftwood, and substrate to create beautiful underwater landscapes. It\'s been elevated to an art form by pioneers like Takashi Amano, whose Nature Aquarium style inspired a global movement. Whether you want a minimalist Japanese rock garden or a lush Dutch plant street, the fundamentals are the same: balance, depth, and intentionality.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'The Three Major Styles',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Iwagumi is the Japanese minimalist style — dominated by carefully arranged stones, with low-growing carpet plants and minimal hardscape. It uses odd-numbered stone groupings (3 or 5) with a clear "father stone" (the largest, or Oyaishi) positioned slightly off-centre. Dutch style is the opposite: a lush, garden-like arrangement with dense "streets" of plants organised by height and colour, terraced from front to back, with no hardscape visible. Nature/Amano style combines elements of both — creating natural-looking scenes that evoke real landscapes like mountains, forests, or riverbanks.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Substrate: The Foundation',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Your substrate does more than look pretty — it feeds your plants. Use a nutrient-rich planted tank substrate (like ADA Aqua Soil, Seachem Flourite, or Tropica Soil) capped with a thin layer of fine gravel or sand. The nutrient layer feeds plant roots, while the cap prevents the nutrient soil from clouding the water. Avoid standard gravel — it\'s inert and offers no nutrition. For carpet plants, use a fine-grain substrate (2-3mm) so plants can root easily.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'CO₂: Do You Need It?',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Pressurised CO₂ is the single biggest upgrade you can make to a planted tank. It accelerates plant growth dramatically, enables you to grow demanding species, and helps prevent algae by giving plants a competitive advantage. Without CO₂, you\'re limited to low-tech plants: Anubias, Java fern, Vallisneria, Cryptocoryne, and mosses. With CO₂, you can grow carpet plants (HC Cuba, Monte Carlo), stem plants (Rotala, Ludwigia), and the more demanding species. Target 20-30 ppm CO₂ — use a drop checker with a 4 dKH solution to monitor.',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'Low-tech tanks: no CO₂, limited plant selection, slower growth, easier maintenance. High-tech tanks: pressurised CO₂, wider plant range, faster growth, weekly trimming and fertilising required. Both can look stunning.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Plant Selection: Think in Layers',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• **Foreground:** Low carpet plants — Monte Carlo, HC Cuba, Eleocharis parvula, Glossostigma\n• **Midground:** Bushy plants — Cryptocoryne, Anubias, Bucephalandra, Staurogyne repens\n• **Background:** Tall stem plants — Rotala rotundifolia, Ludwigia repens, Hygrophila, Vallisneria\n• **Hardscape:** Seiryu stone, lava rock, dragon stone, Malaysian driftwood, spider wood',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Lighting: More Isn\'t Always Better',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Too much light without enough CO₂ and nutrients = algae. Low-tech tanks need 3-5 watts per gallon (or a PAR reading of 30-50 at substrate). High-tech tanks can handle 5-8 watts per gallon (PAR 50-80). Run lights for 6-8 hours daily — longer doesn\'t help and encourages algae. Use a timer for consistency. Many aquascapers start low and gradually increase light duration/intensity over weeks.',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content:
                'Never start a new planted tank with high light and no CO₂. The plants can\'t keep up with the energy from the light, and algae will take over within days. Start low, establish the plants, then increase gradually.',
          ),
          const LessonSection(
            type: LessonSectionType.funFact,
            content:
                'Takashi Amano, the father of modern aquascaping, used a species of freshwater shrimp (now named "Amano shrimp" in his honour — Caridina multidentata) as his primary algae control. His book "Nature Aquarium World" (1994) launched aquascaping as a global hobby.',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'The "golden rule" of aquascaping: the golden ratio (1:1.618). Place your focal point off-centre — about 38% from one side. This creates natural visual tension and looks far more appealing than a perfectly centred layout.',
          ),
        ],
        quiz: Quiz(
          id: 'at_aquascape_quiz',
          lessonId: 'at_aquascaping',
          questions: [
            const QuizQuestion(
              id: 'at_aqua_q1',
              question: 'What happens if you have high-intensity lighting without CO₂ in a planted tank?',
              options: [
                'Plants grow faster',
                'Fish become more colourful',
                'Algae takes over because plants can\'t use the excess light energy',
                'Nothing — light intensity doesn\'t matter',
              ],
              correctIndex: 2,
              explanation:
                  'Without CO₂, plants can\'t photosynthesise fast enough to use the light energy. The excess light energy fuels algae growth instead. Start with low light and increase gradually.',
            ),
            const QuizQuestion(
              id: 'at_aqua_q2',
              question: 'In Iwagumi style, why are stones arranged in odd numbers?',
              options: [
                'It\'s cheaper to buy 3 than 4',
                'Odd numbers create more natural, asymmetric compositions',
                'Even numbers bring bad luck',
                'There\'s no reason — it\'s just tradition',
              ],
              correctIndex: 1,
              explanation:
                  'Odd-numbered groupings create natural asymmetry that avoids looking rigid or artificial. Three or five stones arranged with varying heights and textures create visual depth.',
            ),
            const QuizQuestion(
              id: 'at_aqua_q3',
              question: 'How long should aquarium lights run per day?',
              options: [
                '12-14 hours',
                '6-8 hours',
                '24 hours for maximum plant growth',
                '3-4 hours to save electricity',
              ],
              correctIndex: 1,
              explanation:
                  '6-8 hours is ideal. More than 8 hours encourages algae without significantly benefiting plant growth. Use a timer for consistency.',
            ),
          ],
        ),
      ),

      // ----- BIOTOPE -----
      Lesson(
        id: 'at_biotope',
        pathId: 'advanced_topics',
        title: 'Biotope Aquariums',
        description: 'Recreate specific natural habitats accurately',
        orderIndex: 3,
        xpReward: 75,
        estimatedMinutes: 10,
        sections: [
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Nature in a Box',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'A biotope aquarium is a tank that faithfully recreates a specific natural habitat — the water chemistry, substrate, plants, hardscape, and fish species all come from the same geographic location. No mixing Amazon plants with Asian fish. No using seiryu stone in a West African setup. The goal is accuracy: when someone looks at your tank, they should be able to say "that\'s definitely a Rio Negro blackwater stream." It\'s the most authentic and rewarding style of fishkeeping.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Popular Biotope Setups',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• **Amazon Blackwater:** pH 4.5-6.0, very soft water, driftwood, leaf litter (oak, almond), floating plants. Fish: cardinal tetras, rummy-nose tetras, discus, hatchetfish, Corydoras\n• **Southeast Asian Stream:** pH 6.5-7.0, smooth river stones, bamboo, mosses. Fish: harlequin rasboras, cherry barbs, sparkling gourami, dwarf loaches\n• **Lake Malawi Rocky:** pH 7.8-8.6, hard alkaline water, limestone rock piles, sand substrate. Fish: mbuna cichlids, synodontis catfish\n• **West African River:** pH 6.0-7.0, moderate hardness, driftwood caves, Anubias and Bolbitis. Fish: kribensis, African butterfly fish, Congo tetras',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Sourcing Authentic Materials',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Authenticity matters in biotope keeping. Collect leaves from native trees (oak, beech, almond, magnolia — boiled before use) instead of buying imports. For substrate, match what\'s found in the natural habitat: fine sand for river systems, leaf litter for forest streams, crushed coral for Rift Lake setups. Driftwood should be aquarium-safe and species-appropriate — Malaysian driftwood for Asian setups, mopani or redmoor for South American. Avoid dyed or artificially coloured substrates.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Creating Blackwater',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Blackwater habitats (Amazon, Borneo peat swamps) have tea-coloured water from tannins released by decaying leaves and wood. You can replicate this by adding Indian Almond Leaves (Catappa), alder cones, or rooibos tea bags to your filter. The water turns amber, pH drops to 5.0-6.0, and many South American and Asian species thrive in these conditions. Don\'t worry about the colour — clear water isn\'t natural for these fish!',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'Biotope golden rule: every element in the tank — water, substrate, plants, hardscape, and fish — must come from the same geographic location. Research before you set up, not after.',
          ),
          const LessonSection(
            type: LessonSectionType.funFact,
            content:
                'The International Biotope Aquarium Design Contest (IBAC) is the world championship of biotope aquaria. Entrants submit detailed habitat documentation including GPS coordinates, water parameter data, and species lists. The judging is incredibly strict — accuracy is everything.',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'Start with a Google Images search of your chosen habitat. Study the riverbed, bank vegetation, water colour, and fish behaviour. Then replicate what you see — not what you imagine. Real habitats are always more beautiful than imagined ones.',
          ),
        ],
        quiz: Quiz(
          id: 'at_biotope_quiz',
          lessonId: 'at_biotope',
          questions: [
            const QuizQuestion(
              id: 'at_bio_q1',
              question: 'What defines a biotope aquarium compared to other aquascaping styles?',
              options: [
                'It must be very large',
                'Every element must come from the same geographic location',
                'It cannot contain live plants',
                'It must use only artificial decorations',
              ],
              correctIndex: 1,
              explanation:
                  'A biotope faithfully recreates a specific natural habitat — all water chemistry, plants, hardscape, and fish must match the real location.',
            ),
            const QuizQuestion(
              id: 'at_bio_q2',
              question: 'What gives Amazon blackwater its characteristic tea colour?',
              options: [
                'Iron in the substrate',
                'Tannins released by decaying leaves and wood',
                'Algae growth',
                'Fish waste',
              ],
              correctIndex: 1,
              explanation:
                  'Tannins from decaying leaves and wood leach into the water, creating the amber/blackwater colour. This is natural and beneficial for many species.',
            ),
            const QuizQuestion(
              id: 'at_bio_q3',
              question: 'What water parameters does a Lake Malawi biotope need?',
              options: [
                'Soft and acidic (pH 6.0-6.5)',
                'Very hard and alkaline (pH 7.8-8.6)',
                'Neutral pH 7.0 with moderate hardness',
                'Brackish water',
              ],
              correctIndex: 1,
              explanation:
                  'Lake Malawi is a Rift Lake with very hard, alkaline water (pH 7.8-8.6). This is completely different from Amazon or Asian habitats.',
            ),
          ],
        ),
      ),

      // ----- TROUBLESHOOTING -----
      Lesson(
        id: 'at_troubleshooting',
        pathId: 'advanced_topics',
        title: 'Troubleshooting: Emergency Guide',
        description: 'Fix crashes, spikes, and disasters fast',
        orderIndex: 4,
        xpReward: 75,
        estimatedMinutes: 14,
        sections: [
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'When Things Go Wrong',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Every fishkeeper faces emergencies. The difference between a minor hiccup and a mass die-off is knowing what to do and acting quickly. This guide covers the most common disasters and their protocols. Print it, screenshot it, memorise it — because in a real emergency, you won\'t have time to Google.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Ammonia Spike Protocol',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Ammonia (NH₃) is the most toxic substance in your aquarium. Any detectable level is an emergency. Symptoms: fish gasping at the surface, red/purple gills, clamped fins, lethargy. Action plan: (1) Do a 50% water change immediately with dechlorinated water matching the temperature. (2) Add a bacterial starter (Seachem Stability or FritzZyme) to boost biological filtration. (3) Stop feeding for 3 days — fish can go weeks without food. (4) Test daily until ammonia reads 0. (5) Find the cause: overfeeding, dead fish, dead plant, or filter failure.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Nitrite Spike Protocol',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Nitrite (NO₂⁻) is the middle step in the nitrogen cycle and it\'s nearly as toxic as ammonia. It enters the fish\'s bloodstream and prevents oxygen transport — essentially suffocating the fish from the inside. This is called "brown blood disease." Symptoms: fish hovering near the surface, brownish gills, rapid gill movement. Action: 50% water change immediately. Add aquarium salt at 1 tablespoon per 20 litres — the chloride ions compete with nitrite for absorption in the gills, reducing its toxicity. Continue testing daily.',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'Emergency essentials every fishkeeper should have: dechlorinator, API Freshwater Master Test Kit, aquarium salt, Seachem Prime (ammonia/nitrite detoxifier), spare filter media, and a 10-litre container for emergency water changes.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Algae: Identify Before You Treat',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• **Green spot algae:** Hard green dots on glass. Caused by excess light. Solution: reduce light duration, add nerite snails, scrape with a razor.\n• **Brown diatoms:** Brownish dust on surfaces. Normal in new tanks (first 2-4 weeks). Usually clears on its own. Otocinclus catfish eat it.\n• **Black beard algae:** Dark, tufty growth on plants and hardscape. Caused by low CO₂ or fluctuating CO₂. Solution: increase CO₂, dose liquid carbon (Excel), reduce light. Siamese algae eaters are the best biological control.\n• **Blue-green "algae":** Actually cyanobacteria. Smells bad. Caused by excess nutrients and poor circulation. Solution: increase flow, reduce feeding, dose with erythromycin (last resort). Blackout treatment (cover tank for 3 days) also works.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Disease Identification Quick Guide',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• **Ich (white spot):** White salt-like spots, flashing against objects. Treat with heat (30°C) + salt or commercial ich medication.\n• **Velvet:** Gold dust appearance, clamped fins. Dim the lights (it\'s photosynthetic), treat with copper-based medication.\n• **Fin rot:** Fins fraying from edges, turning black/red. Fix water quality first, then treat with antibacterial medication if needed.\n• **Dropsy:** Fish extremely bloated, scales pineconing outward. Usually internal bacterial infection. Quarantine and treat with kanamycin. Prognosis is often poor.\n• **Columnaris:** White/grey cottony patches on mouth, fins, body. Very contagious and fast-moving. Treat with Furan-2 or kanamycin immediately. Can kill in 24-48 hours.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Quarantine & Hospital Tank',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Every fishkeeper needs a hospital tank — a small, bare-bottom tank (40 litres) with a heater, sponge filter, and hiding spot. No substrate (easier to see waste and medicate accurately). Quarantine ALL new fish for 2-4 weeks before adding to your display tank. This single habit prevents 90% of disease introductions. For hospital use, match the water parameters to the display tank when moving a sick fish — sudden parameter changes add lethal stress on top of illness.',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content:
                'Never add medications to your main display tank. Medications kill beneficial bacteria, crashing your cycle. Always treat in a separate hospital tank. The only exception is aquarium salt in very small doses.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Medication Guide',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Aquarium salt (NaCl): effective for ich, nitrite poisoning, and some parasites. Dose at 1 tablespoon per 20 litres. Never use with scaleless fish (loaches, catfish). Methylene blue: antifungal and antiparasitic, safe for eggs and fry. Tints water blue — use in hospital tank only. API General Cure, Furan-2, and Kanaplex are the "big three" commercial treatments — General Cure for parasites, Furan-2 for bacterial infections, Kanaplex for internal infections. Always complete the full treatment course, even if the fish looks better.',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'Seachem Prime is a lifesaver in emergencies — it temporarily detoxifies ammonia and nitrite for 24-48 hours, buying you time to fix the root cause. Keep a bottle on hand at all times.',
          ),
        ],
        quiz: Quiz(
          id: 'at_trouble_quiz',
          lessonId: 'at_troubleshooting',
          questions: [
            const QuizQuestion(
              id: 'at_trouble_q1',
              question: 'Your ammonia test reads 0.5 ppm. What should you do first?',
              options: [
                'Add medication',
                'Do a 50% water change immediately',
                'Wait a few days and test again',
                'Add more fish to boost the cycle',
              ],
              correctIndex: 1,
              explanation:
                  'Any detectable ammonia is an emergency. A 50% water change halves the concentration immediately. Then stop feeding and find the cause.',
            ),
            const QuizQuestion(
              id: 'at_trouble_q2',
              question: 'Why do you add aquarium salt during a nitrite spike?',
              options: [
                'Salt kills nitrite directly',
                'Chloride ions compete with nitrite for absorption in the fish\'s gills',
                'Salt makes the water clearer',
                'Salt kills the beneficial bacteria causing the spike',
              ],
              correctIndex: 1,
              explanation:
                  'Chloride ions from salt compete with nitrite for uptake in the gills, reducing the amount of nitrite that enters the fish\'s bloodstream. It\'s a protective measure, not a cure.',
            ),
            const QuizQuestion(
              id: 'at_trouble_q3',
              question: 'Why should you never add medications to your main display tank?',
              options: [
                'Medications are too expensive for large tanks',
                'They kill beneficial bacteria, crashing the nitrogen cycle',
                'Fish will become immune to medications',
                'Medications discolour the tank permanently',
              ],
              correctIndex: 1,
              explanation:
                  'Most fish medications are antibacterial or antiparasitic and will kill the beneficial bacteria in your filter, crashing the nitrogen cycle. Always treat in a separate hospital tank.',
            ),
            const QuizQuestion(
              id: 'at_trouble_q4',
              question: 'What is "black beard algae" usually caused by?',
              options: [
                'Too many snails',
                'Low CO₂ or fluctuating CO₂ levels',
                'Water that\'s too hard',
                'Feeding too much protein',
              ],
              correctIndex: 1,
              explanation:
                  'Black beard algae thrives when CO₂ is low or fluctuating — the plants can\'t outcompete it. Increase CO₂ stability and reduce light to combat it.',
            ),
          ],
        ),
      ),

      // ----- ADVANCED WATER CHEMISTRY -----
      Lesson(
        id: 'at_water_chem',
        pathId: 'advanced_topics',
        title: 'Advanced Water Chemistry',
        description: 'Master GH, KH, TDS, and buffering capacity',
        orderIndex: 5,
        xpReward: 75,
        estimatedMinutes: 14,
        sections: [
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Beyond pH: The Full Picture',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Most beginners test only pH, but pH is just the surface. The real story lies in what\'s driving it: General Hardness (GH), Carbonate Hardness (KH), Total Dissolved Solids (TDS), and the relationship between CO₂, carbonates, and pH. Understanding these parameters — and how they interact — lets you create ideal conditions for any species and troubleshoot problems you couldn\'t see before.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'GH: General Hardness',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'GH measures the concentration of calcium and magnesium ions in your water — the minerals that matter most for fish health, snail shells, and shrimp exoskeletons. Measured in degrees (°dGH) or ppm (1°dGH = 17.9 ppm). Soft water has GH 0-4° (suitable for South American fish, tetras, rasboras). Moderate water has GH 5-12° (good for most community fish). Hard water has GH 13+° (ideal for African cichlids, livebearers, goldfish). You can raise GH with crushed coral, limestone, or commercial GH supplements. Lowering it requires RO water or peat filtration.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'KH: Carbonate Hardness (Buffering Capacity)',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'KH measures carbonate and bicarbonate ions — your water\'s acid-buffering system. Think of KH as a shock absorber for pH. High KH (5-10+) means pH stays stable even when acids are added. Low KH (0-3) means pH can crash suddenly, which is lethal. The KH-CO₂-pH relationship is key: more CO₂ in the water lowers pH, and KH determines how much pH drops. With KH of 4°, adding CO₂ to 30 ppm drops pH to about 6.6. With KH of 1°, the same CO₂ would crash pH to dangerous levels.',
          ),
          const LessonSection(
            type: LessonSectionType.keyPoint,
            content:
                'The relationship: Higher CO₂ → lower pH. Higher KH → more stable pH. Target KH 3-5° for planted tanks with CO₂ injection. Below KH 2°, pH swings become dangerous.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'TDS: Total Dissolved Solids',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'TDS is the total concentration of everything dissolved in your water: minerals, organics, salts, waste — everything. Measured in ppm with an inexpensive TDS meter. Tap water typically reads 150-400 ppm. Pure RO water reads 0 ppm. TDS is most useful as a trend indicator: a sudden spike means something is wrong (overfeeding, dead fish, substrate disturbance). For shrimp keepers, TDS matters a lot — Crystal Red shrimp prefer 100-200 ppm, while some Sulawesi shrimp need specific TDS ranges.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Remineralising RO Water',
          ),
          const LessonSection(
            type: LessonSectionType.text,
            content:
                'Reverse osmosis (RO) water strips everything — GH 0, KH 0, TDS 0. It\'s a blank canvas, which is brilliant if your tap water is unsuitable for your target species. But you MUST remineralise it before adding fish — pure RO water has no minerals for osmoregulation and will kill them. Use a dedicated remineraliser (Salty Shrimp GH+, Equilibrium, or Seachem Replenish) at the manufacturer\'s recommended dose. Target the GH and KH your species need. Always test after mixing.',
          ),
          const LessonSection(
            type: LessonSectionType.warning,
            content:
                'Never change water parameters by more than 0.5 pH units or 2° GH per day. Fish cannot adapt to sudden changes — osmoregulatory shock can be fatal. Adjust gradually over days, not hours.',
          ),
          const LessonSection(
            type: LessonSectionType.heading,
            content: 'Testing Equipment Recommendations',
          ),
          const LessonSection(
            type: LessonSectionType.bulletList,
            content:
                '• **API Freshwater Master Test Kit:** The essential liquid test kit for ammonia, nitrite, nitrate, pH (high and low). Accurate, affordable, lasts ~2 years.\n• **GH/KH test kit:** API makes one — essential for anyone keeping shrimp, snails, or cichlids.\n• **TDS meter:** Digital pen-style, under £10. Instant readings.\n• **pH pen/meter:** More accurate than strips for planted tank pH monitoring.\n• **Avoid test strips:** They\'re inaccurate and give vague ranges. Liquid tests cost more but give actual numbers.',
          ),
          const LessonSection(
            type: LessonSectionType.funFact,
            content:
                'The "rule of 1.2" for planted tanks with CO₂: if you know your KH and pH, you can estimate CO₂ levels. CO₂ (in ppm) = 3 × KH × 10^(7-pH). At KH 4° and pH 6.6, you get roughly 30 ppm CO₂ — the sweet spot for most planted tanks. A drop checker with 4 dKH solution does this visually (green = good CO₂).',
          ),
          const LessonSection(
            type: LessonSectionType.tip,
            content:
                'Stable water chemistry is always better than "perfect" water chemistry. If your fish are healthy, breeding, and colourful in pH 7.8 water, don\'t try to lower it to 6.5 because a care sheet says so. Match fish to your water, not water to fish. Adjusting parameters creates stress and risk.',
          ),
        ],
        quiz: Quiz(
          id: 'at_chem_quiz',
          lessonId: 'at_water_chem',
          questions: [
            const QuizQuestion(
              id: 'at_chem_q1',
              question: 'What does KH (carbonate hardness) measure?',
              options: [
                'Calcium and magnesium levels',
                'Carbonate and bicarbonate ions (acid-buffering capacity)',
                'Total waste dissolved in water',
                'Oxygen levels',
              ],
              correctIndex: 1,
              explanation:
                  'KH measures carbonate/bicarbonate ions — your water\'s ability to resist pH changes. GH measures calcium/magnesium. They\'re different parameters.',
            ),
            const QuizQuestion(
              id: 'at_chem_q2',
              question: 'What is the maximum safe pH change per day?',
              options: [
                'Any amount is fine if done gradually',
                '0.5 pH units',
                '2.0 pH units',
                '0.1 pH units',
              ],
              correctIndex: 1,
              explanation:
                  'Never change pH by more than 0.5 units per day. Rapid pH shifts cause osmoregulatory shock, which can be fatal to fish.',
            ),
            const QuizQuestion(
              id: 'at_chem_q3',
              question: 'Why must you remineralise RO water before adding fish?',
              options: [
                'RO water is too cold',
                'Pure RO water has no minerals — fish need them for osmoregulation',
                'RO water contains harmful chemicals',
                'Fish won\'t eat in RO water',
              ],
              correctIndex: 1,
              explanation:
                  'RO water has zero GH, KH, and TDS. Fish use dissolved minerals for osmoregulation (maintaining internal salt/water balance). Without minerals, they cannot survive long-term.',
            ),
            const QuizQuestion(
              id: 'at_chem_q4',
              question: 'What is TDS a useful indicator of?',
              options: [
                'Exact species of bacteria in the tank',
                'Overall trend of dissolved substances — spikes indicate problems',
                'The colour of the water',
                'How many fish you can keep',
              ],
              correctIndex: 1,
              explanation:
                  'TDS measures total dissolved substances. A sudden spike (not explained by a water change or mineral addition) usually means waste buildup, overfeeding, or a dead organism.',
            ),
          ],
        ),
      ),
    ],
  );
}
