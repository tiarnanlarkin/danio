/// Placement test content - 20 questions across all learning paths
/// Used to assess user knowledge and skip appropriate lessons

import '../models/placement_test.dart';

class PlacementTestContent {
  /// The main placement test for new users
  static final PlacementTest defaultTest = PlacementTest(
    id: 'initial_placement',
    title: 'Knowledge Assessment',
    description: 'Let\'s see what you already know! This helps us skip stuff you\'ve mastered.',
    questions: _allQuestions,
  );

  /// All 20 placement questions (4 per learning path)
  static final List<PlacementQuestion> _allQuestions = [
    // ===========================================
    // NITROGEN CYCLE PATH (4 questions)
    // ===========================================
    
    // Question 1: Beginner level
    const PlacementQuestion(
      id: 'nc_q1',
      pathId: 'nitrogen_cycle',
      question: 'What is "New Tank Syndrome"?',
      options: [
        'When fish get stressed in a new environment',
        'Fish dying due to ammonia buildup from lack of beneficial bacteria',
        'A disease that spreads in new tanks',
        'When a tank leaks water',
      ],
      correctIndex: 1,
      explanation: 'New Tank Syndrome occurs when ammonia accumulates because beneficial bacteria haven\'t colonized the filter yet. This is the #1 killer of aquarium fish.',
      difficulty: QuestionDifficulty.beginner,
    ),

    // Question 2: Intermediate level
    const PlacementQuestion(
      id: 'nc_q2',
      pathId: 'nitrogen_cycle',
      question: 'During fishless cycling, what indicates the cycle is complete?',
      options: [
        'The water turns crystal clear',
        'Ammonia and nitrite both read 0 ppm after dosing',
        'Plants start growing rapidly',
        'The tank has been running for exactly 4 weeks',
      ],
      correctIndex: 1,
      explanation: 'A cycled tank can process ammonia to nitrite and then to nitrate within 24 hours, resulting in 0 ppm ammonia and nitrite readings.',
      difficulty: QuestionDifficulty.intermediate,
    ),

    // Question 3: Intermediate level
    const PlacementQuestion(
      id: 'nc_q3',
      pathId: 'nitrogen_cycle',
      question: 'Which bacteria converts nitrite (NO₂⁻) into nitrate (NO₃⁻)?',
      options: [
        'Nitrosomonas bacteria',
        'Nitrospira bacteria',
        'Heterotrophic bacteria',
        'Anaerobic bacteria',
      ],
      correctIndex: 1,
      explanation: 'Nitrospira bacteria convert toxic nitrite into less harmful nitrate. Nitrosomonas handle the first step (ammonia to nitrite).',
      difficulty: QuestionDifficulty.intermediate,
    ),

    // Question 4: Advanced level
    const PlacementQuestion(
      id: 'nc_q4',
      pathId: 'nitrogen_cycle',
      question: 'At what pH level does ammonia become significantly more toxic?',
      options: [
        'pH below 6.0',
        'pH 7.0 (neutral)',
        'pH above 7.5',
        'pH doesn\'t affect ammonia toxicity',
      ],
      correctIndex: 2,
      explanation: 'At higher pH levels (>7.5), more ammonia exists in its toxic NH₃ form rather than the less toxic NH₄⁺ form. This makes ammonia particularly dangerous in alkaline water.',
      difficulty: QuestionDifficulty.advanced,
    ),

    // ===========================================
    // WATER PARAMETERS PATH (4 questions)
    // ===========================================

    // Question 5: Beginner level
    const PlacementQuestion(
      id: 'wp_q1',
      pathId: 'water_parameters',
      question: 'What does pH measure in aquarium water?',
      options: [
        'The amount of oxygen in the water',
        'How acidic or alkaline the water is',
        'The water temperature',
        'The concentration of minerals',
      ],
      correctIndex: 1,
      explanation: 'pH measures acidity/alkalinity on a scale of 0-14, with 7 being neutral. Most freshwater fish prefer 6.5-7.5.',
      difficulty: QuestionDifficulty.beginner,
    ),

    // Question 6: Intermediate level
    const PlacementQuestion(
      id: 'wp_q2',
      pathId: 'water_parameters',
      question: 'What\'s the ideal nitrate (NO₃⁻) level for a freshwater aquarium?',
      options: [
        '0 ppm (absolutely zero)',
        'Under 20 ppm',
        'Between 40-60 ppm',
        'Over 80 ppm',
      ],
      correctIndex: 1,
      explanation: 'While nitrate is less toxic than ammonia or nitrite, keeping it under 20 ppm prevents algae blooms and stress. Regular water changes control nitrate levels.',
      difficulty: QuestionDifficulty.intermediate,
    ),

    // Question 7: Intermediate level
    const PlacementQuestion(
      id: 'wp_q3',
      pathId: 'water_parameters',
      question: 'What is GH (General Hardness) and why does it matter?',
      options: [
        'It measures dissolved minerals; fish have specific hardness preferences',
        'It\'s the same as pH',
        'It measures how hard the tank glass is',
        'It only matters for saltwater tanks',
      ],
      correctIndex: 0,
      explanation: 'GH measures calcium and magnesium ions. Soft water fish (like tetras) need low GH, while hard water fish (like African cichlids) need high GH.',
      difficulty: QuestionDifficulty.intermediate,
    ),

    // Question 8: Advanced level
    const PlacementQuestion(
      id: 'wp_q4',
      pathId: 'water_parameters',
      question: 'How do you safely lower pH in an aquarium?',
      options: [
        'Add pH Down chemicals daily',
        'Use driftwood, almond leaves, or peat to gradually lower pH',
        'Add vinegar or lemon juice',
        'pH can\'t be safely changed',
      ],
      correctIndex: 1,
      explanation: 'Natural methods like tannin-releasing wood or leaves gradually lower pH while buffering it against sudden swings. Chemical adjusters can cause dangerous pH crashes.',
      difficulty: QuestionDifficulty.advanced,
    ),

    // ===========================================
    // FIRST FISH PATH (4 questions)
    // ===========================================

    // Question 9: Beginner level
    const PlacementQuestion(
      id: 'ff_q1',
      pathId: 'first_fish',
      question: 'What is the "one inch per gallon" rule, and is it accurate?',
      options: [
        'It\'s perfectly accurate for all fish',
        'It\'s a rough guideline but doesn\'t account for fish behavior or bioload',
        'It only applies to goldfish',
        'It means one fish per gallon of water',
      ],
      correctIndex: 1,
      explanation: 'The "one inch per gallon" rule is overly simplistic. A 6-inch Oscar produces far more waste than six 1-inch tetras. Consider adult size, activity level, and waste production.',
      difficulty: QuestionDifficulty.beginner,
    ),

    // Question 10: Intermediate level
    const PlacementQuestion(
      id: 'ff_q2',
      pathId: 'first_fish',
      question: 'How should you acclimate new fish to your tank?',
      options: [
        'Dump them straight in - they\'ll adapt quickly',
        'Float the bag for 15 mins, then drip acclimate for 30-60 mins',
        'Keep them in the bag for 24 hours',
        'Add ice to the bag to slow their metabolism',
      ],
      correctIndex: 1,
      explanation: 'Temperature equalization (floating) + slow drip acclimation helps fish adjust to differences in pH, GH, and temperature without shock.',
      difficulty: QuestionDifficulty.intermediate,
    ),

    // Question 11: Intermediate level
    const PlacementQuestion(
      id: 'ff_q3',
      pathId: 'first_fish',
      question: 'Why shouldn\'t goldfish and tropical fish live together?',
      options: [
        'Goldfish are aggressive and will attack tropical fish',
        'They have different temperature requirements',
        'Tropical fish are poisonous to goldfish',
        'It\'s fine - they can live together',
      ],
      correctIndex: 1,
      explanation: 'Goldfish thrive in cooler water (65-72°F) while most tropical fish need 75-80°F. Mixing them stresses both species.',
      difficulty: QuestionDifficulty.intermediate,
    ),

    // Question 12: Advanced level
    const PlacementQuestion(
      id: 'ff_q4',
      pathId: 'first_fish',
      question: 'What causes "velvet" disease and how do you treat it?',
      options: [
        'It\'s a bacterial infection; treat with antibiotics',
        'It\'s a parasitic infection (Oodinium); treat with copper or raised temperature',
        'It\'s a fungal infection; treat with antifungal medication',
        'It\'s caused by poor water quality; just do water changes',
      ],
      correctIndex: 1,
      explanation: 'Velvet (Oodinium) is a dinoflagellate parasite that gives fish a gold/rust dusting. Treatment includes copper-based medications or raising temperature to 82-86°F for 10-14 days.',
      difficulty: QuestionDifficulty.advanced,
    ),

    // ===========================================
    // MAINTENANCE PATH (4 questions)
    // ===========================================

    // Question 13: Beginner level
    const PlacementQuestion(
      id: 'mt_q1',
      pathId: 'maintenance',
      question: 'How often should you do water changes in a typical aquarium?',
      options: [
        'Once a month or when the water looks dirty',
        'Weekly, changing 20-30% of the water',
        'Daily, changing 100% of the water',
        'Never - the filter handles everything',
      ],
      correctIndex: 1,
      explanation: 'Weekly 20-30% water changes remove nitrates, replenish minerals, and keep parameters stable. This is the most important maintenance task.',
      difficulty: QuestionDifficulty.beginner,
    ),

    // Question 14: Intermediate level
    const PlacementQuestion(
      id: 'mt_q2',
      pathId: 'maintenance',
      question: 'When should you clean or replace filter media?',
      options: [
        'Every week to keep it sparkling clean',
        'Rinse mechanical media in old tank water monthly; replace chemical media as needed',
        'Never clean it - the bacteria need the gunk',
        'Replace all media every month with new stuff',
      ],
      correctIndex: 1,
      explanation: 'Mechanical media (sponges) should be rinsed in old tank water to preserve bacteria. Chemical media (carbon) loses effectiveness after 4-6 weeks. Never replace all media at once.',
      difficulty: QuestionDifficulty.intermediate,
    ),

    // Question 15: Intermediate level
    const PlacementQuestion(
      id: 'mt_q3',
      pathId: 'maintenance',
      question: 'What\'s the best way to clean algae off aquarium glass?',
      options: [
        'Use window cleaner spray and paper towels',
        'Use an algae scraper or magnetic cleaner with tank water',
        'Add more chemicals to kill the algae',
        'Drain the entire tank and scrub it',
      ],
      correctIndex: 1,
      explanation: 'Algae scrapers or magnetic cleaners safely remove algae without scratching glass or introducing chemicals. Clean during water changes so debris can be vacuumed out.',
      difficulty: QuestionDifficulty.intermediate,
    ),

    // Question 16: Advanced level
    const PlacementQuestion(
      id: 'mt_q4',
      pathId: 'maintenance',
      question: 'How do you properly deep clean a filter without crashing the cycle?',
      options: [
        'Replace all media with brand new media for maximum cleanliness',
        'Clean only mechanical media in old tank water; leave biological media undisturbed',
        'Run hot tap water through everything to sterilize it',
        'Use bleach diluted in water to kill all bacteria',
      ],
      correctIndex: 1,
      explanation: 'Your biological media houses the beneficial bacteria. Only clean mechanical pre-filters in old tank water to remove debris while preserving the bacteria colony.',
      difficulty: QuestionDifficulty.advanced,
    ),

    // ===========================================
    // PLANTED TANK PATH (4 questions)
    // ===========================================

    // Question 17: Beginner level
    const PlacementQuestion(
      id: 'pt_q1',
      pathId: 'planted_tank',
      question: 'What do aquatic plants need to grow (besides water)?',
      options: [
        'Just light - plants don\'t need anything else',
        'Light, nutrients (fertilizer), and CO₂',
        'Darkness and soil',
        'Cold water and gravel',
      ],
      correctIndex: 1,
      explanation: 'Like terrestrial plants, aquatic plants need light for photosynthesis, nutrients (NPK + trace elements), and CO₂. Low-tech tanks rely on natural CO₂; high-tech tanks inject it.',
      difficulty: QuestionDifficulty.beginner,
    ),

    // Question 18: Intermediate level
    const PlacementQuestion(
      id: 'pt_q2',
      pathId: 'planted_tank',
      question: 'What causes plants to show yellow leaves with green veins?',
      options: [
        'Too much light',
        'Iron deficiency',
        'Nitrogen deficiency',
        'Overwatering (in an aquarium!)',
      ],
      correctIndex: 1,
      explanation: 'Yellowing leaves with green veins (interveinal chlorosis) indicates iron deficiency. Dose a complete fertilizer with chelated iron to fix this.',
      difficulty: QuestionDifficulty.intermediate,
    ),

    // Question 19: Intermediate level
    const PlacementQuestion(
      id: 'pt_q3',
      pathId: 'planted_tank',
      question: 'What is the "Walstad method" for planted tanks?',
      options: [
        'A high-tech method requiring CO₂ injection and strong lights',
        'A low-tech method using soil substrate capped with gravel, minimal filtration',
        'A method for growing plants without water',
        'A Japanese aquascaping style',
      ],
      correctIndex: 1,
      explanation: 'The Walstad (or "dirted tank") method uses organic soil as a substrate to provide nutrients, with minimal technology. It mimics natural ecosystems.',
      difficulty: QuestionDifficulty.intermediate,
    ),

    // Question 20: Advanced level
    const PlacementQuestion(
      id: 'pt_q4',
      pathId: 'planted_tank',
      question: 'What is the Redfield Ratio and why does it matter for planted tanks?',
      options: [
        'It\'s the ideal light-to-plant ratio',
        'It\'s the optimal N:P ratio (16:1) that prevents algae while feeding plants',
        'It\'s the filter flow rate formula',
        'It\'s the CO₂ injection rate',
      ],
      correctIndex: 1,
      explanation: 'The Redfield Ratio (16:1 nitrogen to phosphorus) helps balance nutrients so plants can grow without triggering algae blooms from excess nutrients.',
      difficulty: QuestionDifficulty.advanced,
    ),
  ];
}
