import 'package:flutter/material.dart';

import '../models/models.dart';

class LogEntryDisplay {
  const LogEntryDisplay._();

  static IconData iconFor(LogType type) {
    switch (type) {
      case LogType.waterTest:
        return Icons.science;
      case LogType.waterChange:
        return Icons.water_drop;
      case LogType.feeding:
        return Icons.restaurant;
      case LogType.medication:
        return Icons.medication;
      case LogType.observation:
        return Icons.visibility;
      case LogType.livestockAdded:
        return Icons.add_circle;
      case LogType.livestockRemoved:
        return Icons.remove_circle;
      case LogType.equipmentMaintenance:
        return Icons.build;
      case LogType.taskCompleted:
        return Icons.task_alt;
      case LogType.other:
        return Icons.note;
    }
  }

  static String titleFor(LogEntry entry) {
    final title = entry.title?.trim();
    switch (entry.type) {
      case LogType.waterTest:
        return title != null && title.isNotEmpty ? title : 'Water Test';
      case LogType.waterChange:
        final suffix = entry.waterChangePercent != null
            ? ' (${entry.waterChangePercent}%)'
            : '';
        return title != null && title.isNotEmpty
            ? title
            : 'Water Change$suffix';
      case LogType.taskCompleted:
        return title != null && title.isNotEmpty
            ? 'Completed: $title'
            : 'Task completed';
      case LogType.observation:
        return title != null && title.isNotEmpty ? title : 'Journal entry';
      case LogType.feeding:
      case LogType.medication:
      case LogType.livestockAdded:
      case LogType.livestockRemoved:
      case LogType.equipmentMaintenance:
      case LogType.other:
        return title != null && title.isNotEmpty ? title : entry.typeName;
    }
  }

  static String summaryFor(LogEntry entry) {
    switch (entry.type) {
      case LogType.waterTest:
        final test = entry.waterTest;
        if (test == null || !test.hasValues) return '';
        return _waterTestSummary(test);
      case LogType.waterChange:
        final percent = entry.waterChangePercent;
        return percent == null ? '' : 'Changed $percent% of the water.';
      case LogType.feeding:
        return 'Feeding logged.';
      case LogType.medication:
        return 'Medication logged.';
      case LogType.livestockAdded:
        return 'Livestock added to the tank.';
      case LogType.livestockRemoved:
        return 'Livestock removed from the tank.';
      case LogType.equipmentMaintenance:
        return 'Equipment maintenance logged.';
      case LogType.taskCompleted:
      case LogType.observation:
      case LogType.other:
        return '';
    }
  }

  static String fallbackFor(LogEntry entry) {
    return 'Logged ${entry.typeName.toLowerCase()} event.';
  }

  static String _waterTestSummary(WaterTestResults test) {
    final parts = <String>[];

    void addReading(String label, double? value, {String? suffix}) {
      if (value == null) return;
      final unit = suffix == null ? '' : ' $suffix';
      parts.add('$label: ${value.toStringAsFixed(2)}$unit');
    }

    addReading('pH', test.ph);
    addReading('NH3', test.ammonia);
    addReading('NO2', test.nitrite);
    addReading('NO3', test.nitrate);
    addReading('Temp', test.temperature, suffix: 'C');
    addReading('GH', test.gh);
    addReading('KH', test.kh);
    addReading('PO4', test.phosphate);
    addReading('CO2', test.co2);

    return parts.join(' | ');
  }
}
