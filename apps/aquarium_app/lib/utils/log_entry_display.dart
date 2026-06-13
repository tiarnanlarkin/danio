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
        final toolTitle = toolResultTitleFor(entry);
        if (toolTitle != null) return toolTitle;
        if (isMilestone(entry)) {
          if (title != null && title.isNotEmpty) {
            return _stripMilestonePrefix(title);
          }
          final milestoneSummary = _milestoneSummaryFor(entry);
          return milestoneSummary.isEmpty ? 'Milestone' : milestoneSummary;
        }
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

  static String timelineKindFor(LogEntry entry) {
    if (toolResultTitleFor(entry) != null) return 'Tool Result';
    if (isMilestone(entry)) return 'Milestone';
    return entry.typeName;
  }

  static bool isMilestone(LogEntry entry) {
    if (entry.type != LogType.observation) return false;

    final title = entry.title?.trim().toLowerCase();
    final notes = entry.notes?.trim().toLowerCase();

    return (title != null && title.startsWith('milestone:')) ||
        (notes != null && notes.startsWith('milestone:'));
  }

  static String? toolResultTitleFor(LogEntry entry) {
    if (entry.type != LogType.observation) return null;

    final notes = entry.notes?.trim().toLowerCase();
    if (notes == null || notes.isEmpty) return null;

    if (notes.startsWith('dosing calculation:')) {
      return 'Dosing Calculator Result';
    }
    if (notes.startsWith('co2 estimate:')) {
      return 'CO2 Calculator Result';
    }
    if (notes.startsWith('lighting schedule')) {
      return 'Lighting Planner Result';
    }
    if (notes.startsWith('compatibility check')) {
      return 'Compatibility Check Result';
    }
    if (notes.startsWith('stocking estimate') ||
        notes.startsWith('stocking check')) {
      return 'Stocking Calculator Result';
    }

    return null;
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
        return '';
      case LogType.observation:
        if (isMilestone(entry)) return _milestoneSummaryFor(entry);
        return '';
      case LogType.other:
        return '';
    }
  }

  static String fallbackFor(LogEntry entry) {
    if (isMilestone(entry)) return 'Logged milestone event.';
    return 'Logged ${entry.typeName.toLowerCase()} event.';
  }

  static String _milestoneSummaryFor(LogEntry entry) {
    final notes = entry.notes?.trim();
    if (notes == null || notes.isEmpty) return '';
    return _stripMilestonePrefix(notes);
  }

  static String _stripMilestonePrefix(String value) {
    final trimmed = value.trim();
    final lower = trimmed.toLowerCase();
    if (!lower.startsWith('milestone:')) return trimmed;
    return trimmed.substring('milestone:'.length).trim();
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
