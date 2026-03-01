// Models for the Smart Layer features.

/// Result of a fish/plant identification.
class IdentificationResult {
  final String commonName;
  final String scientificName;
  final int careLevel; // 1-5
  final double phMin;
  final double phMax;
  final double tempMin;
  final double tempMax;
  final String hardness;
  final double? maxSizeCm;
  final String? diet;
  final List<String> tankMates;
  final String compatibilityNotes;
  final List<String> careTips;
  final bool isPlant;
  final String confidence; // high, medium, low
  final DateTime createdAt;

  const IdentificationResult({
    required this.commonName,
    required this.scientificName,
    required this.careLevel,
    required this.phMin,
    required this.phMax,
    required this.tempMin,
    required this.tempMax,
    required this.hardness,
    this.maxSizeCm,
    this.diet,
    this.tankMates = const [],
    required this.compatibilityNotes,
    required this.careTips,
    this.isPlant = false,
    this.confidence = 'high',
    required this.createdAt,
  });

  factory IdentificationResult.fromJson(Map<String, dynamic> json) {
    return IdentificationResult(
      commonName: json['common_name'] as String? ?? 'Unknown',
      scientificName: json['scientific_name'] as String? ?? 'Unknown',
      careLevel: (json['care_level'] as num?)?.toInt() ?? 3,
      phMin: (json['ph_min'] as num?)?.toDouble() ?? 6.5,
      phMax: (json['ph_max'] as num?)?.toDouble() ?? 7.5,
      tempMin: (json['temp_min'] as num?)?.toDouble() ?? 24,
      tempMax: (json['temp_max'] as num?)?.toDouble() ?? 28,
      hardness: json['hardness'] as String? ?? 'Moderate',
      maxSizeCm: (json['max_size_cm'] as num?)?.toDouble(),
      diet: json['diet'] as String?,
      tankMates: (json['tank_mates'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      compatibilityNotes: json['compatibility_notes'] as String? ?? '',
      careTips: (json['care_tips'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isPlant: json['is_plant'] as bool? ?? false,
      confidence: json['confidence'] as String? ?? 'high',
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'common_name': commonName,
    'scientific_name': scientificName,
    'care_level': careLevel,
    'ph_min': phMin,
    'ph_max': phMax,
    'temp_min': tempMin,
    'temp_max': tempMax,
    'hardness': hardness,
    'max_size_cm': maxSizeCm,
    'diet': diet,
    'tank_mates': tankMates,
    'compatibility_notes': compatibilityNotes,
    'care_tips': careTips,
    'is_plant': isPlant,
    'confidence': confidence,
    'created_at': createdAt.toIso8601String(),
  };
}

/// Anomaly severity levels.
enum AnomalySeverity { warning, alert, critical }

/// A detected water parameter anomaly.
class Anomaly {
  final String id;
  final String tankId;
  final String parameter;
  final String description;
  final AnomalySeverity severity;
  final String? aiExplanation;
  final String? recommendation;
  final DateTime detectedAt;
  final bool dismissed;

  const Anomaly({
    required this.id,
    required this.tankId,
    required this.parameter,
    required this.description,
    required this.severity,
    this.aiExplanation,
    this.recommendation,
    required this.detectedAt,
    this.dismissed = false,
  });

  Anomaly copyWith({
    String? aiExplanation,
    String? recommendation,
    bool? dismissed,
  }) {
    return Anomaly(
      id: id,
      tankId: tankId,
      parameter: parameter,
      description: description,
      severity: severity,
      aiExplanation: aiExplanation ?? this.aiExplanation,
      recommendation: recommendation ?? this.recommendation,
      detectedAt: detectedAt,
      dismissed: dismissed ?? this.dismissed,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tank_id': tankId,
    'parameter': parameter,
    'description': description,
    'severity': severity.name,
    'ai_explanation': aiExplanation,
    'recommendation': recommendation,
    'detected_at': detectedAt.toIso8601String(),
    'dismissed': dismissed,
  };

  factory Anomaly.fromJson(Map<String, dynamic> json) {
    return Anomaly(
      id: json['id'] as String,
      tankId: json['tank_id'] as String,
      parameter: json['parameter'] as String,
      description: json['description'] as String,
      severity: AnomalySeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => AnomalySeverity.warning,
      ),
      aiExplanation: json['ai_explanation'] as String?,
      recommendation: json['recommendation'] as String?,
      detectedAt: DateTime.parse(json['detected_at'] as String),
      dismissed: json['dismissed'] as bool? ?? false,
    );
  }
}

/// A task in the weekly plan.
class PlanTask {
  final String task;
  final int durationMins;
  final String priority; // low, normal, high

  const PlanTask({
    required this.task,
    required this.durationMins,
    required this.priority,
  });

  factory PlanTask.fromJson(Map<String, dynamic> json) {
    return PlanTask(
      task: json['task'] as String? ?? '',
      durationMins: (json['duration_mins'] as num?)?.toInt() ?? 5,
      priority: json['priority'] as String? ?? 'normal',
    );
  }

  Map<String, dynamic> toJson() => {
    'task': task,
    'duration_mins': durationMins,
    'priority': priority,
  };
}

/// A day in the weekly maintenance plan.
class PlanDay {
  final String day; // Mon, Tue, ...
  final List<PlanTask> tasks;

  const PlanDay({required this.day, required this.tasks});

  factory PlanDay.fromJson(Map<String, dynamic> json) {
    final tasksList = (json['tasks'] as List<dynamic>?)
            ?.map((t) => PlanTask.fromJson(t as Map<String, dynamic>))
            .toList() ??
        [];
    return PlanDay(
      day: json['day'] as String? ?? '',
      tasks: tasksList,
    );
  }

  Map<String, dynamic> toJson() => {
    'day': day,
    'tasks': tasks.map((t) => t.toJson()).toList(),
  };
}

/// A weekly maintenance plan.
class WeeklyPlan {
  final List<PlanDay> days;
  final DateTime generatedAt;

  const WeeklyPlan({required this.days, required this.generatedAt});

  factory WeeklyPlan.fromJson(Map<String, dynamic> json) {
    final daysList = (json['days'] as List<dynamic>?)
            ?.map((d) => PlanDay.fromJson(d as Map<String, dynamic>))
            .toList() ??
        [];
    return WeeklyPlan(
      days: daysList,
      generatedAt: json['generated_at'] != null
          ? DateTime.parse(json['generated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'days': days.map((d) => d.toJson()).toList(),
    'generated_at': generatedAt.toIso8601String(),
  };
}

/// A record of an AI interaction (for history).
class AIInteraction {
  final String id;
  final String type; // fish_id, symptom_triage, anomaly, weekly_plan
  final String summary;
  final DateTime timestamp;

  const AIInteraction({
    required this.id,
    required this.type,
    required this.summary,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'summary': summary,
    'timestamp': timestamp.toIso8601String(),
  };

  factory AIInteraction.fromJson(Map<String, dynamic> json) {
    return AIInteraction(
      id: json['id'] as String,
      type: json['type'] as String,
      summary: json['summary'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
