import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../models/models.dart';
import '../../../services/api_rate_limiter.dart';
import '../../../services/openai_service.dart';
import '../models/smart_models.dart';
import '../smart_providers.dart';
import 'package:danio/utils/logger.dart';

const _uuid = Uuid();

/// Analyses water parameter logs for a tank and detects anomalies.
///
/// First pass is rules-based (fast, no API call). If anomalies are found
/// and the AI service is available, a GPT call explains the cause and
/// recommends actions.
class AnomalyDetectorService {
  final OpenAIService _openai;
  final ApiRateLimiter _rateLimiter;

  AnomalyDetectorService(this._openai, this._rateLimiter);

  /// Run anomaly detection on a list of water-test log entries for a tank.
  ///
  /// [logs] should contain the last 30 days of logs, newest first.
  Future<List<Anomaly>> analyse({
    required String tankId,
    required List<LogEntry> logs,
  }) async {
    final waterTests =
        logs
            .where((l) => l.type == LogType.waterTest && l.waterTest != null)
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // newest first

    if (waterTests.isEmpty) return [];

    final anomalies = <Anomaly>[];

    // --- Rules-based first pass ---

    // Check pairs of consecutive readings for drift/spikes.
    for (int i = 0; i < waterTests.length - 1; i++) {
      final recent = waterTests[i];
      final older = waterTests[i + 1];
      final hoursBetween = recent.timestamp
          .difference(older.timestamp)
          .inHours
          .abs();

      if (hoursBetween > 24 || hoursBetween == 0) continue;

      final rw = recent.waterTest!;
      final ow = older.waterTest!;

      // pH drift > 0.5 in 24h
      if (rw.ph != null && ow.ph != null) {
        final drift = (rw.ph! - ow.ph!).abs();
        if (drift > 0.5) {
          anomalies.add(
            Anomaly(
              id: _uuid.v4(),
              tankId: tankId,
              parameter: 'pH',
              description:
                  'pH drifted ${drift.toStringAsFixed(1)} in ${hoursBetween}h '
                  '(${ow.ph} → ${rw.ph})',
              severity: AnomalySeverity.warning,
              detectedAt: DateTime.now(),
            ),
          );
        }
      }

      // Temperature spike > 3°C in 24h
      if (rw.temperature != null && ow.temperature != null) {
        final spike = (rw.temperature! - ow.temperature!).abs();
        if (spike > 3) {
          anomalies.add(
            Anomaly(
              id: _uuid.v4(),
              tankId: tankId,
              parameter: 'Temperature',
              description:
                  'Temperature changed ${spike.toStringAsFixed(1)}°C in '
                  '${hoursBetween}h (${ow.temperature} → ${rw.temperature}°C)',
              severity: AnomalySeverity.alert,
              detectedAt: DateTime.now(),
            ),
          );
        }
      }
    }

    // Check most recent reading for absolute thresholds.
    if (waterTests.isNotEmpty) {
      final latest = waterTests.first.waterTest!;

      // Ammonia - any non-zero reading is critical
      if (latest.ammonia != null && latest.ammonia! > 0) {
        anomalies.add(
          Anomaly(
            id: _uuid.v4(),
            tankId: tankId,
            parameter: 'Ammonia',
            description: 'Ammonia detected: ${latest.ammonia} ppm',
            severity: AnomalySeverity.critical,
            detectedAt: DateTime.now(),
          ),
        );
      }

      // Nitrite - any non-zero reading is critical
      if (latest.nitrite != null && latest.nitrite! > 0) {
        anomalies.add(
          Anomaly(
            id: _uuid.v4(),
            tankId: tankId,
            parameter: 'Nitrite',
            description: 'Nitrite detected: ${latest.nitrite} ppm',
            severity: AnomalySeverity.critical,
            detectedAt: DateTime.now(),
          ),
        );
      }

      // Nitrate > 40 ppm
      if (latest.nitrate != null && latest.nitrate! > 40) {
        anomalies.add(
          Anomaly(
            id: _uuid.v4(),
            tankId: tankId,
            parameter: 'Nitrate',
            description: 'Nitrate high: ${latest.nitrate} ppm',
            severity: AnomalySeverity.warning,
            detectedAt: DateTime.now(),
          ),
        );
      }
    }

    // --- AI explanation pass (if anomalies found, API available, and under rate limit) ---
    if (anomalies.isNotEmpty &&
        _openai.isConfigured &&
        _rateLimiter.canRequest(AIFeature.anomalyDetector)) {
      try {
        final descriptions = anomalies.map((a) => a.description).join('; ');
        final result = await _openai.chatCompletion(
          messages: [
            const ChatMessage(
              role: 'system',
              content:
                  'You are Danio AI, an expert in aquarium water chemistry and '
                  'the nitrogen cycle. You understand how pH, ammonia, nitrite, '
                  'nitrate, temperature, and hardness interact. When explaining '
                  'anomalies, consider: tank cycling status, bioload, overfeeding, '
                  'filter issues, and substrate disturbance. Be concise - '
                  'hobbyists need clear, actionable advice, not lectures.',
            ),
            ChatMessage(
              role: 'user',
              content:
                  'These anomalies were detected in a freshwater aquarium: '
                  '$descriptions. '
                  'For each anomaly, provide:\n'
                  '1. Most likely cause (one sentence)\n'
                  '2. Immediate action to take\n'
                  '3. How to prevent recurrence',
            ),
          ],
          maxTokens: 300,
        );

        _rateLimiter.recordRequest(AIFeature.anomalyDetector);

        // Apply AI explanation to the first anomaly (or all via a single
        // combined explanation).
        for (int i = 0; i < anomalies.length; i++) {
          anomalies[i] = anomalies[i].copyWith(aiExplanation: result.text);
        }
      } on TimeoutException {
        appLog('Anomaly AI explanation timed out', tag: 'AnomalyDetectorService');
        // Continue without AI explanation - rules-based results are still valid.
      } catch (e) {
        logError('Anomaly AI explanation failed: $e', tag: 'AnomalyDetectorService');
        // Continue without AI explanation - rules-based results are still valid.
      }
    }

    return anomalies;
  }
}

/// Riverpod provider for the anomaly detector.
final anomalyDetectorProvider = Provider<AnomalyDetectorService>((ref) {
  final openai = ref.watch(openAIServiceProvider);
  final rateLimiter = ref.watch(apiRateLimiterProvider);
  return AnomalyDetectorService(openai, rateLimiter);
});

/// Run anomaly detection for a tank and store results.
///
/// Call this after logging new water parameters.
Future<List<Anomaly>> runAnomalyDetection({
  required WidgetRef ref,
  required String tankId,
  required List<LogEntry> logs,
}) async {
  final detector = ref.read(anomalyDetectorProvider);
  final anomalies = await detector.analyse(tankId: tankId, logs: logs);

  if (anomalies.isNotEmpty) {
    ref.read(anomalyHistoryProvider.notifier).addAll(anomalies);

    // Record in AI history if AI was used.
    if (anomalies.any((a) => a.aiExplanation != null)) {
      ref
          .read(aiHistoryProvider.notifier)
          .add(
            type: 'anomaly',
            summary: 'Detected ${anomalies.length} anomaly(ies)',
          );
    }
  }

  return anomalies;
}
