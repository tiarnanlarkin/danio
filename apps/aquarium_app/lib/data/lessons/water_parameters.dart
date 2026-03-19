/// Lesson content - Water Parameters
/// Part of the lazy-loaded lesson system
library;

import '../../models/tank.dart';
import '../../models/learning.dart';
import '../../models/user_profile.dart';

final waterParametersPath = LearningPath(
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
              'Avoid "pH adjusters" and chemicals. They cause dangerous swings. It\'s better to keep fish suited to your tap water\'s natural pH. If you do need to adjust pH, never change it by more than 0.2-0.3 per day. Use natural methods first: driftwood or almond leaves lower pH; crushed coral or limestone raise it. Chemical pH adjusters often cause pH swings that are more harmful than the original pH.',
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
              'For tropical tanks, a reliable heater is essential. Aim for 1-2 watts per litre for standard setups, or up to 2.5 for colder rooms. Always use a separate thermometer to verify — built-in heater dials are often inaccurate.',
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
              'Most tropical fish do well in GH 4-12 dGH (70-210 ppm). This is the ideal range for most tropical community tanks, and most tap water falls in this range. Livebearers (guppies, mollies) prefer harder water (10-20 dGH). Soft water fish (tetras, discus) prefer 2-8 dGH. If your GH is very high (>20°dGH), consider mixing with RO water. Very soft water (<3°dGH) needs remineralisation for most fish.',
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
              'KH (carbonate hardness) acts as your tank\'s pH buffer. If KH drops below 3°dKH, pH can crash suddenly — sometimes overnight — which is fatal. Test KH alongside pH. If KH is low, add a small amount of baking soda (1 tsp per 50L) to raise it gradually. Low KH (below 3 dKH) can cause dangerous pH crashes, especially overnight when plants release CO2. If your KH is very low, consider adding crushed coral or baking soda.',
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
              'Seachem Prime is the gold standard. It dechlorinates, detoxifies ammonia/nitrite, and detoxifies heavy metals. One bottle lasts forever - worth the investment. Water conditioners are generally safe in overdose — Seachem Prime, for example, can detoxify ammonia and nitrite at up to 5× the recommended dose. However, extremely high doses may temporarily reduce oxygen levels. As a rule, dose for the full tank volume, not the water change volume.',
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
            question: 'What\'s the difference between chlorine and chloramine?',
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
            question: 'Why is chloramine particularly dangerous for aquariums?',
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
