/// Sample exercises demonstrating all exercise types
/// Use these as templates for creating new lessons
library;


import '../models/exercises.dart';

class SampleExercises {
  // ==========================================
  // NITROGEN CYCLE LESSON
  // ==========================================
  
  static final nitrogenCycleQuiz = EnhancedQuiz(
    id: 'nitrogen_cycle_quiz',
    lessonId: 'nitrogen_cycle_basics',
    passingScore: 70,
    bonusXp: 25,
    shuffleExercises: true,
    exercises: const [
      // Multiple Choice: Basic concept
      MultipleChoiceExercise(
        id: 'nc_mc1',
        question: 'What is the first toxic compound produced in the nitrogen cycle?',
        options: [
          'Nitrite',
          'Ammonia',
          'Nitrate',
          'Oxygen',
        ],
        correctIndex: 1,
        explanation: 'Ammonia (NH₃) is produced first from fish waste and uneaten food. It\'s highly toxic to fish.',
        hint: 'Think about what comes from fish waste',
      ),
      
      // True/False: Common misconception
      TrueFalseExercise(
        id: 'nc_tf1',
        question: 'The nitrogen cycle only happens in new aquariums.',
        correctAnswer: false,
        explanation: 'The nitrogen cycle is an ongoing process in all aquariums. It never stops - beneficial bacteria continuously convert ammonia to less harmful compounds.',
      ),
      
      // Fill in the Blank: Key facts
      FillBlankExercise(
        id: 'nc_fb1',
        question: 'Complete this sentence about cycling time',
        sentenceTemplate: 'A new aquarium typically takes ___ to ___ weeks to complete the nitrogen cycle.',
        correctAnswers: ['4', '6'],
        alternatives: [
          ['four'],
          ['six'],
        ],
        explanation: 'The cycling process usually takes 4-6 weeks, though this can vary based on temperature, initial bacteria levels, and bioload.',
      ),
      
      // Ordering: Process sequence
      OrderingExercise(
        id: 'nc_o1',
        question: 'Put the nitrogen cycle stages in the correct order',
        items: [
          'Fish waste produces ammonia',
          'Nitrosomonas bacteria convert ammonia to nitrite',
          'Nitrobacter bacteria convert nitrite to nitrate',
          'Plants and water changes remove nitrate',
        ],
        explanation: 'This is the complete nitrogen cycle: Ammonia → Nitrite → Nitrate → Removal',
      ),
      
      // Matching: Bacteria and their roles
      MatchingExercise(
        id: 'nc_m1',
        question: 'Match each bacteria type to what it converts',
        leftItems: [
          'Nitrosomonas',
          'Nitrobacter',
        ],
        rightItems: [
          'Ammonia to Nitrite',
          'Nitrite to Nitrate',
        ],
        correctPairs: {0: 0, 1: 1},
        explanation: 'Two main bacteria families handle the nitrogen cycle: Nitrosomonas converts ammonia to nitrite, and Nitrobacter converts nitrite to nitrate.',
      ),
    ],
  );

  // ==========================================
  // WATER PARAMETERS LESSON
  // ==========================================
  
  static final waterParamsQuiz = EnhancedQuiz(
    id: 'water_params_quiz',
    lessonId: 'water_parameters_101',
    passingScore: 75,
    bonusXp: 30,
    exercises: const [
      // Multiple Choice with hint
      MultipleChoiceExercise(
        id: 'wp_mc1',
        question: 'What is the ideal pH range for most community freshwater fish?',
        options: [
          '5.0 - 6.0',
          '6.5 - 7.5',
          '8.0 - 9.0',
          '9.0 - 10.0',
        ],
        correctIndex: 1,
        explanation: 'Most common freshwater fish thrive at a pH between 6.5 and 7.5, which is slightly acidic to neutral.',
        hint: 'Think about neutral pH (7.0)',
      ),
      
      // True/False
      TrueFalseExercise(
        id: 'wp_tf1',
        question: 'It\'s safe to add tap water directly to your aquarium without treating it.',
        correctAnswer: false,
        explanation: 'Tap water contains chlorine and chloramine that are toxic to fish. Always use a water conditioner to neutralize these chemicals.',
      ),
      
      TrueFalseExercise(
        id: 'wp_tf2',
        question: 'Temperature fluctuations can stress fish more than the actual temperature.',
        correctAnswer: true,
        explanation: 'Rapid temperature changes stress fish significantly. Consistent temperature (even if not perfect) is better than constantly fluctuating water.',
      ),
      
      // Fill in the Blank with word bank
      FillBlankExercise(
        id: 'wp_fb1',
        question: 'Choose the correct values',
        sentenceTemplate: 'Ideal ammonia level: ___, ideal nitrite level: ___, safe nitrate level: ___.',
        correctAnswers: ['0 ppm', '0 ppm', 'below 20 ppm'],
        wordBank: ['0 ppm', '0 ppm', 'below 20 ppm', '5 ppm', '50 ppm'],
        explanation: 'Ammonia and nitrite should always be 0 ppm - any amount is toxic. Nitrate should stay below 20 ppm for optimal health.',
      ),
      
      // Matching: Parameters to effects
      MatchingExercise(
        id: 'wp_m1',
        question: 'Match water parameters to their effects when too high',
        leftItems: [
          'Ammonia',
          'Temperature',
          'pH swings',
        ],
        rightItems: [
          'Burns fish gills',
          'Increases metabolism and oxygen needs',
          'Causes stress and immune issues',
        ],
        correctPairs: {0: 0, 1: 1, 2: 2},
        explanation: 'Each parameter affects fish health differently. Maintaining stable, appropriate levels is crucial.',
      ),
    ],
  );

  // ==========================================
  // FISH ANATOMY LESSON
  // ==========================================
  
  static final fishAnatomyQuiz = EnhancedQuiz(
    id: 'fish_anatomy_quiz',
    lessonId: 'fish_anatomy_basics',
    passingScore: 70,
    bonusXp: 20,
    mode: QuizMode.practice,
    exercises: const [
      // Fill in the Blank: Basic anatomy
      FillBlankExercise(
        id: 'fa_fb1',
        question: 'Complete this sentence about fish breathing',
        sentenceTemplate: 'Fish extract ___ from water using their ___.',
        correctAnswers: ['oxygen', 'gills'],
        alternatives: [
          ['o2', 'O2'],
          [],
        ],
        explanation: 'Fish breathe by extracting dissolved oxygen from water through their gills.',
      ),
      
      // True/False: Fun facts
      TrueFalseExercise(
        id: 'fa_tf1',
        question: 'All fish have scales.',
        correctAnswer: false,
        explanation: 'Not all fish have scales! For example, catfish have smooth skin, and some species have bony plates instead.',
      ),
      
      // Matching: Fins and their functions
      MatchingExercise(
        id: 'fa_m1',
        question: 'Match each fin to its primary function',
        leftItems: [
          'Dorsal fin',
          'Caudal fin',
          'Pectoral fins',
          'Anal fin',
        ],
        rightItems: [
          'Stability and steering',
          'Propulsion and speed',
          'Steering and braking',
          'Stability',
        ],
        correctPairs: {0: 0, 1: 1, 2: 2, 3: 3},
        explanation: 'Each fin type serves a specific purpose in swimming and balance.',
      ),
      
      // Multiple Choice
      MultipleChoiceExercise(
        id: 'fa_mc1',
        question: 'What organ helps fish maintain buoyancy?',
        options: [
          'Liver',
          'Swim bladder',
          'Stomach',
          'Heart',
        ],
        correctIndex: 1,
        explanation: 'The swim bladder is a gas-filled organ that helps fish maintain their depth in water without constantly swimming.',
      ),
    ],
  );

  // ==========================================
  // BEGINNER SETUP LESSON
  // ==========================================
  
  static final beginnerSetupQuiz = EnhancedQuiz(
    id: 'beginner_setup_quiz',
    lessonId: 'first_aquarium_setup',
    passingScore: 60,
    bonusXp: 15,
    exercises: const [
      // Ordering: Setup steps
      OrderingExercise(
        id: 'bs_o1',
        question: 'Put these aquarium setup steps in the correct order',
        items: [
          'Clean tank and equipment',
          'Add substrate and decorations',
          'Fill tank with conditioned water',
          'Install and run filter for 24 hours',
          'Begin cycling process',
        ],
        explanation: 'Following the correct setup order prevents problems and helps your tank cycle properly.',
      ),
      
      // Multiple Choice: Equipment
      MultipleChoiceExercise(
        id: 'bs_mc1',
        question: 'What is the minimum recommended tank size for a beginner?',
        options: [
          '5 gallons',
          '10 gallons',
          '20 gallons',
          '55 gallons',
        ],
        correctIndex: 1,
        explanation: 'A 10-gallon tank is easier to maintain than smaller tanks because water parameters are more stable in larger volumes.',
        hint: 'Bigger is actually easier!',
      ),
      
      // True/False
      TrueFalseExercise(
        id: 'bs_tf1',
        question: 'You can add fish immediately after setting up your tank.',
        correctAnswer: false,
        explanation: 'New tanks need to complete the nitrogen cycle first, which takes 4-6 weeks. Adding fish too early can lead to "new tank syndrome" and fish death.',
      ),
      
      // Fill in the Blank with word bank
      FillBlankExercise(
        id: 'bs_fb1',
        question: 'Choose the essential equipment',
        sentenceTemplate: 'Every aquarium needs a ___, ___, and ___.',
        correctAnswers: ['filter', 'heater', 'light'],
        wordBank: ['filter', 'heater', 'light', 'air pump', 'CO2 system', 'UV sterilizer'],
        explanation: 'Filter, heater, and light are the three essential pieces of equipment for most tropical freshwater tanks.',
      ),
      
      // Matching: Equipment to purpose
      MatchingExercise(
        id: 'bs_m1',
        question: 'Match equipment to its purpose',
        leftItems: [
          'Filter',
          'Heater',
          'Air pump',
        ],
        rightItems: [
          'Removes waste and debris',
          'Maintains stable temperature',
          'Increases oxygen levels',
        ],
        correctPairs: {0: 0, 1: 1, 2: 2},
        explanation: 'Understanding what each piece of equipment does helps you maintain a healthy tank.',
      ),
    ],
  );

  // ==========================================
  // ADVANCED: PLANTED TANK LESSON
  // ==========================================
  
  static final plantedTankQuiz = EnhancedQuiz(
    id: 'planted_tank_quiz',
    lessonId: 'planted_tank_basics',
    passingScore: 80,
    bonusXp: 40,
    mode: QuizMode.adaptive,
    exercises: const [
      // Fill in the Blank: Chemistry
      FillBlankExercise(
        id: 'pt_fb1',
        question: 'Complete the photosynthesis equation',
        sentenceTemplate: 'Plants use ___ and water with light to produce ___ and oxygen.',
        correctAnswers: ['CO2', 'glucose'],
        alternatives: [
          ['carbon dioxide', 'co2'],
          ['sugar', 'sugars', 'carbohydrates'],
        ],
        explanation: 'Plants use CO₂ and water, with light energy, to produce glucose (sugar) and oxygen through photosynthesis.',
      ),
      
      // Matching: Lighting levels
      MatchingExercise(
        id: 'pt_m1',
        question: 'Match plants to their lighting requirements',
        leftItems: [
          'Anubias',
          'Dwarf Hairgrass',
          'Amazon Sword',
          'Rotala',
        ],
        rightItems: [
          'Low light',
          'High light',
          'Medium light',
          'High light',
        ],
        correctPairs: {0: 0, 1: 1, 2: 2, 3: 3},
        explanation: 'Different plant species have different light requirements. Match plants to your lighting setup.',
      ),
      
      // Multiple Choice: Nutrients
      MultipleChoiceExercise(
        id: 'pt_mc1',
        question: 'What is the role of nitrogen in planted tanks?',
        options: [
          'It\'s only harmful and should be removed',
          'It\'s essential for plant growth',
          'It only helps algae grow',
          'It has no effect on plants',
        ],
        correctIndex: 1,
        explanation: 'While high nitrogen can be harmful to fish, plants actually need it as a macronutrient for growth. Planted tanks create a balance.',
      ),
      
      // Ordering: Nutrient deficiency diagnosis
      OrderingExercise(
        id: 'pt_o1',
        question: 'Order these steps for diagnosing plant problems',
        items: [
          'Observe plant symptoms',
          'Check water parameters',
          'Research deficiency symptoms',
          'Adjust fertilizer dosing',
          'Monitor improvements over 2 weeks',
        ],
        explanation: 'Systematic diagnosis prevents over-correction and helps you learn your tank\'s needs.',
      ),
      
      // True/False
      TrueFalseExercise(
        id: 'pt_tf1',
        question: 'CO2 injection is necessary for all planted tanks.',
        correctAnswer: false,
        explanation: 'Many plants thrive without CO2 injection. Low-light, slow-growing plants can do well with just water column nutrients and light.',
      ),
    ],
  );

  /// Get all sample quizzes
  static List<EnhancedQuiz> get allQuizzes => [
        nitrogenCycleQuiz,
        waterParamsQuiz,
        fishAnatomyQuiz,
        beginnerSetupQuiz,
        plantedTankQuiz,
      ];

  /// Get quiz by ID
  static EnhancedQuiz? getById(String id) {
    try {
      return allQuizzes.firstWhere((q) => q.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get quizzes by difficulty (based on passing score and mode)
  static List<EnhancedQuiz> getByDifficulty(ExerciseDifficulty difficulty) {
    return allQuizzes.where((quiz) {
      switch (difficulty) {
        case ExerciseDifficulty.easy:
          return quiz.passingScore < 70;
        case ExerciseDifficulty.medium:
          return quiz.passingScore >= 70 && quiz.passingScore < 80;
        case ExerciseDifficulty.hard:
          return quiz.passingScore >= 80;
      }
    }).toList();
  }
}
