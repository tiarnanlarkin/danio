/// Lesson content - Nitrogen Cycle
/// Part of the lazy-loaded lesson system
library;

import '../../models/tank.dart';
import '../../models/learning.dart';
import '../../models/user_profile.dart';

final nitrogenCyclePath = LearningPath(
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
                  'Ammonia is colorless at typical aquarium levels — you can\'t see it. While it does have a faint smell, you can\'t reliably detect dangerous levels by nose alone. Only a test kit gives accurate readings.',
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
                'Ammonia is highly toxic. Even 0.5 ppm can stress fish; levels above 2 ppm are dangerous for most species.',
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
                'Modern research shows Nitrospira bacteria (not just the traditionally cited Nitrobacter) handle most nitrite-to-nitrate conversion in aquarium filters. The science has evolved — the key point is that these beneficial bacteria need time, oxygen, and surface area to colonise your filter.',
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

