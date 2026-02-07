/// Daily tips for the learning system
/// Personalized based on user experience and tank type

import '../models/learning.dart';
import '../models/user_profile.dart';

class DailyTips {
  static const List<DailyTip> all = [
    // Beginner tips
    DailyTip(
      id: 'tip_patience',
      title: 'Patience Pays Off',
      content: 'The nitrogen cycle takes 2-6 weeks. Rushing it is the #1 cause of fish deaths. Your patience now means healthy fish later!',
      targetExperience: [ExperienceLevel.beginner],
    ),
    DailyTip(
      id: 'tip_test_regularly',
      title: 'Test Your Water',
      content: 'Can\'t see ammonia or nitrite - they\'re invisible killers. Test weekly, or more often in new tanks.',
      targetExperience: [ExperienceLevel.beginner],
      relatedLessonId: 'nc_stages',
    ),
    DailyTip(
      id: 'tip_less_food',
      title: 'Less is More',
      content: 'Fish stomachs are tiny - about the size of their eye. Feed small amounts they can finish in 2 minutes. Overfeeding pollutes water.',
      targetExperience: [ExperienceLevel.beginner],
    ),
    DailyTip(
      id: 'tip_observe',
      title: 'Watch Your Fish',
      content: 'Spend a few minutes daily just watching. You\'ll notice behavior changes early - often the first sign of problems.',
      targetExperience: [ExperienceLevel.beginner],
    ),
    DailyTip(
      id: 'tip_quarantine',
      title: 'Quarantine New Fish',
      content: 'New fish can carry diseases. A simple quarantine tank (even a bucket with a heater) for 2-4 weeks protects your main tank.',
      targetExperience: [ExperienceLevel.beginner, ExperienceLevel.intermediate],
    ),
    
    // Water quality tips
    DailyTip(
      id: 'tip_dechlorinator',
      title: 'Always Dechlorinate',
      content: 'Tap water chlorine kills beneficial bacteria AND fish. Always add dechlorinator before adding new water.',
      targetExperience: [ExperienceLevel.beginner],
      relatedLessonId: 'maint_water_changes',
    ),
    DailyTip(
      id: 'tip_temperature_match',
      title: 'Match Temperature',
      content: 'New water should feel the same temperature as tank water. Big temperature swings stress fish and can trigger disease.',
      targetExperience: [ExperienceLevel.beginner],
    ),
    DailyTip(
      id: 'tip_filter_media',
      title: 'Don\'t Over-Clean',
      content: 'Your filter media houses beneficial bacteria. Only rinse in old tank water, and only when flow is reduced.',
      targetExperience: [ExperienceLevel.beginner],
      relatedLessonId: 'maint_filter',
    ),
    
    // Planted tank tips
    DailyTip(
      id: 'tip_plant_timer',
      title: 'Use a Light Timer',
      content: 'Consistent 6-8 hours of light daily prevents algae. A timer removes the guesswork and human error.',
      targetTankTypes: [TankType.planted],
      relatedLessonId: 'planted_light',
    ),
    DailyTip(
      id: 'tip_plant_ferts',
      title: 'Start Low, Go Slow',
      content: 'With fertilizers, less is more at first. It\'s easier to add more than to fight algae from overdosing.',
      targetTankTypes: [TankType.planted],
    ),
    DailyTip(
      id: 'tip_trim_plants',
      title: 'Trim Dead Leaves',
      content: 'Remove yellowing or dying plant leaves promptly. They decay and add ammonia to your water.',
      targetTankTypes: [TankType.planted],
    ),
    
    // Intermediate tips
    DailyTip(
      id: 'tip_stability',
      title: 'Stability Over Perfection',
      content: 'Fish adapt to a range of parameters, but hate sudden changes. A stable pH of 7.8 is better than a fluctuating "perfect" 7.0.',
      targetExperience: [ExperienceLevel.intermediate],
    ),
    DailyTip(
      id: 'tip_research_first',
      title: 'Research Before Buying',
      content: 'That cute fish at the store might grow huge, need special water, or eat your other fish. Always research first!',
      targetExperience: [ExperienceLevel.beginner, ExperienceLevel.intermediate],
    ),
    DailyTip(
      id: 'tip_backup_heater',
      title: 'Backup Equipment',
      content: 'Heaters fail. Having a spare heater ready can save your tank in an emergency, especially in winter.',
      targetExperience: [ExperienceLevel.intermediate],
    ),
    
    // General tips
    DailyTip(
      id: 'tip_water_change_routine',
      title: 'Make It Routine',
      content: 'Pick a day for water changes and stick to it. Sunday morning water change? Make it a habit!',
    ),
    DailyTip(
      id: 'tip_gravel_vac',
      title: 'Vacuum That Gravel',
      content: 'Debris builds up in substrate. Use a gravel vacuum during water changes to remove trapped waste.',
    ),
    DailyTip(
      id: 'tip_slow_changes',
      title: 'Slow and Steady',
      content: 'Making changes to your tank? Do them gradually. Slow changes give fish time to adapt.',
    ),
    DailyTip(
      id: 'tip_community',
      title: 'Join the Community',
      content: 'Reddit\'s r/Aquariums and local fish clubs are great resources. Don\'t be afraid to ask questions!',
    ),
    DailyTip(
      id: 'tip_enjoy',
      title: 'Enjoy the Journey',
      content: 'Fishkeeping has a learning curve, but that\'s part of the fun. Every mistake teaches you something.',
    ),
  ];

  /// Get a random tip relevant to the user's profile
  static DailyTip? getRelevantTip(UserProfile profile, List<String> recentTipIds) {
    final relevant = all.where((tip) {
      // Skip recently shown tips
      if (recentTipIds.contains(tip.id)) return false;
      // Check if relevant to user
      return tip.isRelevantFor(profile);
    }).toList();

    if (relevant.isEmpty) {
      // All tips shown recently, reset and pick any relevant one
      final anyRelevant = all.where((tip) => tip.isRelevantFor(profile)).toList();
      if (anyRelevant.isEmpty) return null;
      anyRelevant.shuffle();
      return anyRelevant.first;
    }

    relevant.shuffle();
    return relevant.first;
  }
}
