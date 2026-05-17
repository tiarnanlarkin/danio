import 'package:shared_preferences/shared_preferences.dart';

enum GuidancePromptId {
  learnFirstVisit,
  practiceFirstUsefulVisit,
  tankStageHandles,
  smartFirstVisit,
  moreFirstVisit,
}

enum GuidanceSurface { learn, practice, tank, smart, more }

enum GuidanceDismissalScope { forever, day }

class GuidanceContext {
  final GuidanceSurface surface;
  final int practiceCardCount;
  final bool interruptionsBlocked;
  final bool hasOpenPanels;

  const GuidanceContext({
    required this.surface,
    this.practiceCardCount = 0,
    this.interruptionsBlocked = false,
    this.hasOpenPanels = false,
  });
}

class GuidanceDecision {
  final GuidancePromptId promptId;
  final bool shouldShow;
  final String reason;

  const GuidanceDecision({
    required this.promptId,
    required this.shouldShow,
    required this.reason,
  });
}

class GuidanceService {
  final SharedPreferences prefs;

  GuidanceService(this.prefs);

  static String storageKey(GuidancePromptId promptId) =>
      'guidance_seen_${promptId.name}';

  static String dayStorageKey(GuidancePromptId promptId) =>
      'guidance_seen_today_${promptId.name}';

  static final Map<GuidancePromptId, GuidanceSurface> _surfaces = {
    GuidancePromptId.learnFirstVisit: GuidanceSurface.learn,
    GuidancePromptId.practiceFirstUsefulVisit: GuidanceSurface.practice,
    GuidancePromptId.tankStageHandles: GuidanceSurface.tank,
    GuidancePromptId.smartFirstVisit: GuidanceSurface.smart,
    GuidancePromptId.moreFirstVisit: GuidanceSurface.more,
  };

  static final Map<GuidancePromptId, List<String>> _legacyKeys = {
    GuidancePromptId.learnFirstVisit: ['tooltip_seen_learn'],
    GuidancePromptId.practiceFirstUsefulVisit: ['tooltip_seen_practice'],
    GuidancePromptId.tankStageHandles: [
      'tooltip_seen_tank',
      'tooltip_seen_hearts',
      'tooltip_seen_stage_handles',
      'tooltip_seen_room_metaphor',
    ],
    GuidancePromptId.smartFirstVisit: ['tooltip_seen_smart'],
    GuidancePromptId.moreFirstVisit: ['tooltip_seen_more'],
  };

  Future<GuidanceDecision> shouldShow(
    GuidancePromptId promptId,
    GuidanceContext context,
  ) async {
    final expectedSurface = _surfaces[promptId];
    if (expectedSurface != context.surface) {
      return GuidanceDecision(
        promptId: promptId,
        shouldShow: false,
        reason: 'wrong_surface',
      );
    }

    if (context.interruptionsBlocked) {
      return GuidanceDecision(
        promptId: promptId,
        shouldShow: false,
        reason: 'interruptions_blocked',
      );
    }

    if (promptId == GuidancePromptId.practiceFirstUsefulVisit &&
        context.practiceCardCount <= 0) {
      return GuidanceDecision(
        promptId: promptId,
        shouldShow: false,
        reason: 'no_practice_cards',
      );
    }

    if (promptId == GuidancePromptId.tankStageHandles &&
        context.hasOpenPanels) {
      return GuidanceDecision(
        promptId: promptId,
        shouldShow: false,
        reason: 'tank_panel_open',
      );
    }

    if (await _isDismissed(promptId)) {
      return GuidanceDecision(
        promptId: promptId,
        shouldShow: false,
        reason: 'dismissed',
      );
    }

    return GuidanceDecision(
      promptId: promptId,
      shouldShow: true,
      reason: 'eligible',
    );
  }

  Future<GuidancePromptId?> firstEligiblePrompt(
    List<GuidancePromptId> promptIds,
    GuidanceContext context,
  ) async {
    for (final promptId in promptIds) {
      final decision = await shouldShow(promptId, context);
      if (decision.shouldShow) return promptId;
    }
    return null;
  }

  Future<void> markDismissed(
    GuidancePromptId promptId, {
    GuidanceDismissalScope scope = GuidanceDismissalScope.forever,
  }) async {
    if (scope == GuidanceDismissalScope.day) {
      await prefs.setString(dayStorageKey(promptId), _todayKey());
      return;
    }
    await prefs.setBool(storageKey(promptId), true);
  }

  Future<bool> _isDismissed(GuidancePromptId promptId) async {
    if (prefs.getBool(storageKey(promptId)) ?? false) return true;

    final dismissedToday = prefs.getString(dayStorageKey(promptId));
    if (dismissedToday == _todayKey()) return true;

    for (final oldKey in _legacyKeys[promptId] ?? const <String>[]) {
      if (prefs.getBool(oldKey) ?? false) {
        await markDismissed(promptId);
        return true;
      }
    }

    return false;
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }
}
