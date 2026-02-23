import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'models/smart_models.dart';

const _uuid = Uuid();

// ── AI Interaction History ──────────────────────────────────────────────

/// Stores the last 10 AI interactions locally.
class AIHistoryNotifier extends StateNotifier<List<AIInteraction>> {
  static const _key = 'ai_interaction_history';

  AIHistoryNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    state = raw
        .map((s) {
          try {
            return AIInteraction.fromJson(
              jsonDecode(s) as Map<String, dynamic>,
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<AIInteraction>()
        .toList();
  }

  Future<void> add({
    required String type,
    required String summary,
  }) async {
    final interaction = AIInteraction(
      id: _uuid.v4(),
      type: type,
      summary: summary,
      timestamp: DateTime.now(),
    );
    final updated = [interaction, ...state].take(10).toList();
    state = updated;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      updated.map((i) => jsonEncode(i.toJson())).toList(),
    );
  }
}

final aiHistoryProvider =
    StateNotifierProvider<AIHistoryNotifier, List<AIInteraction>>(
  (ref) => AIHistoryNotifier(),
);

// ── Anomaly History ─────────────────────────────────────────────────────

/// Stores anomaly history locally.
class AnomalyHistoryNotifier extends StateNotifier<List<Anomaly>> {
  static const _key = 'anomaly_history';

  AnomalyHistoryNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    state = raw
        .map((s) {
          try {
            return Anomaly.fromJson(jsonDecode(s) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<Anomaly>()
        .toList();
  }

  Future<void> addAll(List<Anomaly> anomalies) async {
    final updated = [...anomalies, ...state].take(50).toList();
    state = updated;
    await _save();
  }

  Future<void> dismiss(String id) async {
    state = state.map((a) {
      if (a.id == id) return a.copyWith(dismissed: true);
      return a;
    }).toList();
    await _save();
  }

  List<Anomaly> forTank(String tankId) =>
      state.where((a) => a.tankId == tankId && !a.dismissed).toList();

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      state.map((a) => jsonEncode(a.toJson())).toList(),
    );
  }
}

final anomalyHistoryProvider =
    StateNotifierProvider<AnomalyHistoryNotifier, List<Anomaly>>(
  (ref) => AnomalyHistoryNotifier(),
);

// ── Weekly Plan Cache ───────────────────────────────────────────────────

/// Cached weekly plan — stored in shared prefs.
class WeeklyPlanNotifier extends StateNotifier<WeeklyPlan?> {
  static const _key = 'weekly_plan_cache';

  WeeklyPlanNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      try {
        state = WeeklyPlan.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        // Corrupted — ignore
      }
    }
  }

  Future<void> save(WeeklyPlan plan) async {
    state = plan;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(plan.toJson()));
  }

  void clear() {
    state = null;
  }
}

final weeklyPlanProvider =
    StateNotifierProvider<WeeklyPlanNotifier, WeeklyPlan?>(
  (ref) => WeeklyPlanNotifier(),
);
