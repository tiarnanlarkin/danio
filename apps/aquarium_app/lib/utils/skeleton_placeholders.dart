import '../models/equipment.dart';
import '../models/livestock.dart';
import '../models/log_entry.dart';

/// Placeholder data for skeleton loading states.
/// Used with Skeletonizer to show realistic shimmer shapes.
class SkeletonPlaceholders {
  SkeletonPlaceholders._();

  static final DateTime _now = DateTime.now();

  /// Placeholder livestock for skeleton display
  static Livestock get livestock => Livestock(
    id: 'skeleton-livestock',
    tankId: 'skeleton-tank',
    commonName: 'Neon Tetra Fish',
    scientificName: 'Paracheirodon innesi',
    count: 10,
    dateAdded: _now,
    createdAt: _now,
    updatedAt: _now,
  );

  /// List of placeholder livestock items
  static List<Livestock> get livestockList =>
      List.generate(5, (i) => livestock);

  /// Placeholder equipment for skeleton display
  static Equipment get equipment => Equipment(
    id: 'skeleton-equipment',
    tankId: 'skeleton-tank',
    type: EquipmentType.filter,
    name: 'Fluval 307 Canister',
    brand: 'Fluval',
    maintenanceIntervalDays: 30,
    lastServiced: _now.subtract(const Duration(days: 15)),
    installedDate: _now.subtract(const Duration(days: 90)),
    createdAt: _now,
    updatedAt: _now,
  );

  /// List of placeholder equipment items
  static List<Equipment> get equipmentList =>
      List.generate(5, (i) => equipment);

  /// Placeholder log entry for skeleton display
  static LogEntry get logEntry => LogEntry(
    id: 'skeleton-log',
    tankId: 'skeleton-tank',
    type: LogType.waterTest,
    timestamp: _now,
    title: 'Water parameters looking good',
    notes: 'Everything is stable today',
    createdAt: _now,
  );

  /// List of placeholder log entries
  static List<LogEntry> get logsList => List.generate(5, (i) => logEntry);

  /// Placeholder strings for text content
  static const String shortText = 'Loading text...';
  static const String mediumText = 'This is placeholder text for loading';
  static const String longText =
      'This is a longer placeholder text that simulates a paragraph of content';
}
