import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/storage_provider.dart';
import '../../providers/user_profile_provider.dart';
import 'package:uuid/uuid.dart';

import 'intelligence/aquarium_intelligence_service.dart';
import 'models/smart_models.dart';
import '../../utils/logger.dart';

const _uuid = Uuid();

// ── AI Interaction History ──────────────────────────────────────────────

/// Stores the last 10 AI interactions locally.
class AIHistoryNotifier extends StateNotifier<List<AIInteraction>> {
  final Ref ref;
  static const _key = 'ai_interaction_history';
  late final Future<void> _loadFuture;

  AIHistoryNotifier(this.ref) : super([]) {
    _loadFuture = _load();
  }

  Future<void> _load() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final raw = prefs.getStringList(_key) ?? [];
    state = raw
        .map((s) {
          try {
            return AIInteraction.fromJson(
              jsonDecode(s) as Map<String, dynamic>,
            );
          } catch (e) {
            logError(
              'Smart: failed to parse AI interaction: $e',
              tag: 'SmartProviders',
            );
            return null;
          }
        })
        .whereType<AIInteraction>()
        .toList();
  }

  Future<void> add({required String type, required String summary}) async {
    await _loadFuture;
    final interaction = AIInteraction(
      id: _uuid.v4(),
      type: type,
      summary: summary,
      timestamp: DateTime.now(),
    );
    final updated = [interaction, ...state].take(10).toList();
    await _save(updated);
    state = updated;
  }

  Future<void> _save(List<AIInteraction> interactions) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final saved = await prefs.setStringList(
      _key,
      interactions.map((i) => jsonEncode(i.toJson())).toList(),
    );
    if (!saved) {
      throw StateError('SharedPreferences returned false for $_key');
    }
  }
}

final aiHistoryProvider =
    StateNotifierProvider.autoDispose<AIHistoryNotifier, List<AIInteraction>>(
      (ref) => AIHistoryNotifier(ref),
    );

// ── Anomaly History ─────────────────────────────────────────────────────

/// Stores anomaly history locally.
class AnomalyHistoryNotifier extends StateNotifier<List<Anomaly>> {
  final Ref ref;
  static const _key = 'anomaly_history';
  late final Future<void> _loadFuture;

  AnomalyHistoryNotifier(this.ref) : super([]) {
    _loadFuture = _load();
  }

  Future<void> _load() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final raw = prefs.getStringList(_key) ?? [];
    state = raw
        .map((s) {
          try {
            return Anomaly.fromJson(jsonDecode(s) as Map<String, dynamic>);
          } catch (e) {
            logError(
              'Smart: failed to parse anomaly: $e',
              tag: 'SmartProviders',
            );
            return null;
          }
        })
        .whereType<Anomaly>()
        .toList();
  }

  Future<void> addAll(List<Anomaly> anomalies) async {
    await _loadFuture;
    final updated = [...anomalies, ...state].take(50).toList();
    await _save(updated);
    state = updated;
  }

  Future<void> dismiss(String id) async {
    await _loadFuture;
    final updated = state.map((a) {
      if (a.id == id) return a.copyWith(dismissed: true);
      return a;
    }).toList();
    await _save(updated);
    state = updated;
  }

  List<Anomaly> forTank(String tankId) =>
      state.where((a) => a.tankId == tankId && !a.dismissed).toList();

  Future<void> _save(List<Anomaly> anomalies) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final saved = await prefs.setStringList(
      _key,
      anomalies.map((a) => jsonEncode(a.toJson())).toList(),
    );
    if (!saved) {
      throw StateError('SharedPreferences returned false for $_key');
    }
  }
}

final anomalyHistoryProvider =
    StateNotifierProvider.autoDispose<AnomalyHistoryNotifier, List<Anomaly>>(
      (ref) => AnomalyHistoryNotifier(ref),
    );

// ── Weekly Plan Cache ───────────────────────────────────────────────────

final aquariumIntelligenceProvider =
    FutureProvider.autoDispose<AquariumIntelligenceReport>((ref) async {
      final storage = ref.watch(storageServiceProvider);
      final tanks = await storage.getAllTanks();
      final anomalies = ref.watch(anomalyHistoryProvider);
      final inputs = <AquariumIntelligenceTankInput>[];

      for (final tank in tanks) {
        inputs.add(
          AquariumIntelligenceTankInput(
            tank: tank,
            logs: await storage.getLogsForTank(tank.id, limit: 50),
            tasks: await storage.getTasksForTank(tank.id),
            livestock: await storage.getLivestockForTank(tank.id),
            equipment: await storage.getEquipmentForTank(tank.id),
            anomalies: anomalies
                .where(
                  (anomaly) => anomaly.tankId == tank.id && !anomaly.dismissed,
                )
                .toList(),
          ),
        );
      }

      return AquariumIntelligenceService.evaluate(tanks: inputs);
    });

/// Cached weekly plan - stored in shared prefs.
class WeeklyPlanNotifier extends StateNotifier<WeeklyPlan?> {
  final Ref ref;
  static const _key = 'weekly_plan_cache';
  late final Future<void> _loadFuture;

  WeeklyPlanNotifier(this.ref) : super(null) {
    _loadFuture = _load();
  }

  Future<void> _load() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final raw = prefs.getString(_key);
    if (raw != null) {
      try {
        state = WeeklyPlan.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (e) {
        logError(
          'Smart: failed to parse weekly plan: $e',
          tag: 'SmartProviders',
        );
        // Corrupted - ignore
      }
    }
  }

  Future<void> save(WeeklyPlan plan) async {
    await _loadFuture;
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final saved = await prefs.setString(_key, jsonEncode(plan.toJson()));
    if (!saved) {
      throw StateError('SharedPreferences returned false for $_key');
    }
    state = plan;
  }

  Future<void> clear() async {
    await _loadFuture;
    final prefs = await ref.read(sharedPreferencesProvider.future);
    if (prefs.containsKey(_key)) {
      final removed = await prefs.remove(_key);
      if (!removed) {
        throw StateError('SharedPreferences returned false for $_key');
      }
    }
    state = null;
  }
}

final weeklyPlanProvider =
    StateNotifierProvider.autoDispose<WeeklyPlanNotifier, WeeklyPlan?>(
      (ref) => WeeklyPlanNotifier(ref),
    );
