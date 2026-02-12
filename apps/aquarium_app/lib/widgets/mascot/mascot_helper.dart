import 'dart:math';

/// Mascot mood states that affect appearance and animation
enum MascotMood {
  /// Default happy state - friendly and welcoming
  happy,
  
  /// Thinking/contemplative - for tips and suggestions
  thinking,
  
  /// Celebrating - for achievements and milestones
  celebrating,
  
  /// Encouraging - for empty states and motivation
  encouraging,
  
  /// Curious - for questions and exploration
  curious,
  
  /// Waving - for greetings and welcomes
  waving,
}

extension MascotMoodExtension on MascotMood {
  /// Get the emoji representation for each mood
  /// These are placeholders until Rive assets are ready
  String get emoji {
    switch (this) {
      case MascotMood.happy:
        return '🐠';
      case MascotMood.thinking:
        return '🤔';
      case MascotMood.celebrating:
        return '🎉';
      case MascotMood.encouraging:
        return '💪';
      case MascotMood.curious:
        return '🐟';
      case MascotMood.waving:
        return '👋';
    }
  }
  
  /// Get the fish emoji for the mascot
  String get fishEmoji => '🐠';
}

/// Context types for mascot messages
enum MascotContext {
  // Empty states
  noTanks,
  noLivestock,
  noLogs,
  noEquipment,
  noPlants,
  
  // Onboarding
  welcome,
  experienceQuestion,
  tankTypeQuestion,
  goalsQuestion,
  onboardingComplete,
  
  // Achievements
  achievementUnlocked,
  streakMilestone,
  levelUp,
  
  // General
  dailyGreeting,
  encouragement,
  tip,
  congratulations,
  comeback,
}

/// Static helper class for mascot messages and behavior
class MascotHelper {
  static final _random = Random();
  
  /// Get appropriate mood for a given context
  static MascotMood getMoodForContext(MascotContext context) {
    switch (context) {
      case MascotContext.noTanks:
      case MascotContext.noLivestock:
      case MascotContext.noLogs:
      case MascotContext.noEquipment:
      case MascotContext.noPlants:
        return MascotMood.encouraging;
      case MascotContext.welcome:
        return MascotMood.waving;
      case MascotContext.experienceQuestion:
      case MascotContext.tankTypeQuestion:
      case MascotContext.goalsQuestion:
        return MascotMood.curious;
      case MascotContext.onboardingComplete:
      case MascotContext.achievementUnlocked:
      case MascotContext.streakMilestone:
      case MascotContext.levelUp:
      case MascotContext.congratulations:
        return MascotMood.celebrating;
      case MascotContext.dailyGreeting:
        return MascotMood.happy;
      case MascotContext.encouragement:
        return MascotMood.encouraging;
      case MascotContext.tip:
        return MascotMood.thinking;
      case MascotContext.comeback:
        return MascotMood.waving;
    }
  }
  
  /// Get a message for a specific context
  /// Returns a random message from the available options
  static String getMessage(MascotContext context) {
    final messages = _messagesForContext[context] ?? ['Hello!'];
    return messages[_random.nextInt(messages.length)];
  }
  
  /// Get all messages for a context (useful for cycling)
  static List<String> getMessages(MascotContext context) {
    return _messagesForContext[context] ?? ['Hello!'];
  }
  
  /// Get a random tip for aquarium care
  static String getRandomTip() {
    return _aquariumTips[_random.nextInt(_aquariumTips.length)];
  }
  
  /// Get a random encouragement message
  static String getRandomEncouragement() {
    return _encouragementMessages[_random.nextInt(_encouragementMessages.length)];
  }
  
  /// Get a random congratulations message
  static String getRandomCongratulations() {
    return _congratulationsMessages[_random.nextInt(_congratulationsMessages.length)];
  }
  
  /// Get mascot name
  static String get name => 'Finn';
  
  // Message database
  static const Map<MascotContext, List<String>> _messagesForContext = {
    // Empty states
    MascotContext.noTanks: [
      "Let's set up your first tank! 🐠",
      "Ready to start your aquarium journey?",
      "Every great aquarist starts with one tank!",
      "Your underwater world awaits!",
    ],
    MascotContext.noLivestock: [
      "Your tank looks a bit lonely...",
      "Time to add some finned friends!",
      "Let's find some compatible fish!",
      "An empty tank is full of possibilities!",
    ],
    MascotContext.noLogs: [
      "Time to log your first observation!",
      "Keeping records helps your fish thrive!",
      "Let's start tracking your tank's journey!",
      "Good record keeping = happy fish!",
    ],
    MascotContext.noEquipment: [
      "Let's track your equipment!",
      "Good gear makes fishkeeping easier!",
      "Time to catalog your setup!",
    ],
    MascotContext.noPlants: [
      "Plants make tanks beautiful!",
      "Ready to add some greenery?",
      "Live plants help your fish thrive!",
    ],
    
    // Onboarding
    MascotContext.welcome: [
      "Hi there! I'm Finn, your aquarium buddy! 🐠",
      "Welcome to Aquarium! I'm Finn, and I'll help you along the way!",
      "Hello, future fish keeper! I'm Finn! 👋",
    ],
    MascotContext.experienceQuestion: [
      "Tell me about your fishkeeping experience!",
      "How long have you been keeping fish?",
      "Let's personalize your journey!",
    ],
    MascotContext.tankTypeQuestion: [
      "What kind of underwater world do you have?",
      "Freshwater, saltwater, or planted?",
      "Every tank type is an adventure!",
    ],
    MascotContext.goalsQuestion: [
      "What do you want to achieve?",
      "Let's set some goals together!",
      "What's your aquarium dream?",
    ],
    MascotContext.onboardingComplete: [
      "You're all set! Let's dive in! 🎉",
      "Welcome aboard! Your journey begins now!",
      "Awesome! I can't wait to help you succeed!",
    ],
    
    // Achievements
    MascotContext.achievementUnlocked: [
      "You did it! Amazing work! 🏆",
      "Achievement unlocked! You're a star!",
      "Incredible! Keep up the great work!",
    ],
    MascotContext.streakMilestone: [
      "What a streak! You're on fire! 🔥",
      "Consistency is key, and you've got it!",
      "Your dedication is inspiring!",
    ],
    MascotContext.levelUp: [
      "Level up! You're becoming an expert! ⭐",
      "New level reached! Look at you go!",
      "You're making waves! Level up!",
    ],
    
    // General
    MascotContext.dailyGreeting: [
      "Great to see you! How are your fish today?",
      "Welcome back! Ready to check on your tanks?",
      "Hello again! Your fish missed you!",
      "Hey there! Let's make today a great tank day!",
    ],
    MascotContext.encouragement: [
      "You're doing great! Keep it up!",
      "Every expert was once a beginner!",
      "Your fish are lucky to have you!",
      "Small steps lead to big results!",
    ],
    MascotContext.tip: [
      "Pro tip: Test your water weekly!",
      "Did you know? Consistency beats perfection!",
      "Quick tip: Changes should be gradual!",
    ],
    MascotContext.congratulations: [
      "Congratulations! You're amazing! 🎉",
      "Fantastic work! I'm so proud!",
      "You nailed it! Celebrate this win!",
    ],
    MascotContext.comeback: [
      "Welcome back! I missed you! 👋",
      "It's been a while! Good to see you!",
      "You're back! Let's catch up on your tanks!",
    ],
  };
  
  static const List<String> _aquariumTips = [
    "Test your water parameters at least once a week!",
    "Never change more than 25% of water at once.",
    "New fish should be quarantined for 2-4 weeks.",
    "Overfeeding is the #1 cause of tank problems!",
    "A cycled tank is a happy tank!",
    "Consistency is more important than perfection.",
    "Always dechlorinate your water before adding it!",
    "Research fish compatibility before buying!",
    "Live plants help absorb nitrates naturally.",
    "Good filtration is your tank's best friend!",
    "Patience is the most important skill in fishkeeping.",
    "Watch your fish daily - they'll tell you when something's wrong!",
    "A larger tank is often easier to maintain than a small one.",
    "Don't chase perfect parameters - stability matters more!",
    "Clean your filter media in old tank water, not tap water!",
  ];
  
  static const List<String> _encouragementMessages = [
    "You've got this! 💪",
    "Every fish keeper started somewhere!",
    "Your dedication shows in your tank!",
    "Keep learning, keep growing!",
    "Small progress is still progress!",
    "You're doing better than you think!",
    "Mistakes are just learning opportunities!",
    "Your fish appreciate all your effort!",
  ];
  
  static const List<String> _congratulationsMessages = [
    "Fantastic job! 🎉",
    "You're crushing it!",
    "What an achievement!",
    "I'm so proud of you!",
    "You're a natural!",
    "Keep shining, aquarist! ⭐",
    "That's the way to do it!",
    "Absolutely brilliant!",
  ];
}
