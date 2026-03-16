/// Lesson content - First Fish
/// Part of the lazy-loaded lesson system
library;

import '../../models/tank.dart';
import '../../models/learning.dart';
import '../../models/user_profile.dart';

final firstFishPath = LearningPath(
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
            question: 'What does "hardy" mean when describing a fish species?',
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
            question: 'Why should you never add store bag water to your tank?',
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
