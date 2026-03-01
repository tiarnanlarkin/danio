import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';

/// Schema version for migrations
const int kStorageSchemaVersion = 1;

/// Hive-based persistent storage service
/// 
/// Replaces the in-memory storage with durable local persistence.
/// All data survives app restarts.
class HiveStorageService {
  static HiveStorageService? _instance;
  
  /// Singleton instance
  static HiveStorageService get instance {
    assert(_instance != null, 'Call HiveStorageService.initialize() first');
    return _instance!;
  }
  
  /// Whether Hive has been initialized
  static bool get isInitialized => _instance != null;
  
  // Box names
  static const String _tanksBox = 'tanks';
  static const String _livestockBox = 'livestock';
  static const String _equipmentBox = 'equipment';
  static const String _logsBox = 'logs';
  static const String _tasksBox = 'tasks';
  static const String _userProfileBox = 'user_profile';
  static const String _settingsBox = 'settings';
  static const String _learningProgressBox = 'learning_progress';
  static const String _economyBox = 'economy';
  static const String _metadataBox = 'metadata';
  
  // Boxes (lazy-opened)
  late Box<Map> _tanks;
  late Box<Map> _livestock;
  late Box<Map> _equipment;
  late Box<Map> _logs;
  late Box<Map> _tasks;
  late Box<Map> _userProfile;
  late Box<Map> _settings;
  late Box<Map> _learningProgress;
  late Box<Map> _economy;
  // ignore: unused_field
  late Box<dynamic> _metadata;
  
  HiveStorageService._();
  
  /// Initialize Hive and open all boxes
  /// 
  /// Call once from main() before runApp().
  /// Returns true on success, false on failure.
  static Future<bool> initialize() async {
    if (_instance != null) return true;
    
    try {
      // Initialize Hive
      await Hive.initFlutter();
      
      debugPrint('[HiveStorage] Initializing...');
      
      // Check schema version and run migrations if needed
      final metadataBox = await Hive.openBox<dynamic>(_metadataBox);
      final storedVersion = (metadataBox.get('schema_version') ?? 0) as int;
      
      if (storedVersion < kStorageSchemaVersion) {
        debugPrint('[HiveStorage] Migration needed: v$storedVersion → v$kStorageSchemaVersion');
        await _runMigrations(storedVersion, kStorageSchemaVersion);
        await metadataBox.put('schema_version', kStorageSchemaVersion);
      }
      
      // Open all boxes
      final instance = HiveStorageService._();
      
      instance._tanks = await Hive.openBox<Map>(_tanksBox);
      instance._livestock = await Hive.openBox<Map>(_livestockBox);
      instance._equipment = await Hive.openBox<Map>(_equipmentBox);
      instance._logs = await Hive.openBox<Map>(_logsBox);
      instance._tasks = await Hive.openBox<Map>(_tasksBox);
      instance._userProfile = await Hive.openBox<Map>(_userProfileBox);
      instance._settings = await Hive.openBox<Map>(_settingsBox);
      instance._learningProgress = await Hive.openBox<Map>(_learningProgressBox);
      instance._economy = await Hive.openBox<Map>(_economyBox);
      instance._metadata = metadataBox;
      
      _instance = instance;
      
      debugPrint('[HiveStorage] Initialized successfully (schema v$kStorageSchemaVersion)');
      debugPrint('[HiveStorage] Loaded: ${instance._tanks.length} tanks, '
          '${instance._livestock.length} livestock, '
          '${instance._logs.length} logs');
      
      return true;
    } catch (e, st) {
      debugPrint('[HiveStorage] Initialization failed: $e\n$st');
      return false;
    }
  }
  
  /// Run migrations from oldVersion to newVersion
  static Future<void> _runMigrations(int fromVersion, int toVersion) async {
    debugPrint('[HiveStorage] Running migrations: v$fromVersion → v$toVersion');
    
    // Add migration logic here as schema evolves
    // Example:
    // if (fromVersion < 1) {
    //   await _migrateToV1();
    // }
    // if (fromVersion < 2) {
    //   await _migrateToV2();
    // }
    
    // For now, v0 → v1 is a fresh start (no existing data to migrate)
    if (fromVersion == 0) {
      debugPrint('[HiveStorage] Fresh install, no migration needed');
    }
  }
  
  // -------------------------------------------------------------------------
  // Tanks
  // -------------------------------------------------------------------------
  
  Future<List<Tank>> getAllTanks() async {
    return _tanks.values
        .map((json) => Tank.fromJson(Map<String, dynamic>.from(json)))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }
  
  Future<Tank?> getTank(String id) async {
    final json = _tanks.get(id);
    if (json == null) return null;
    return Tank.fromJson(Map<String, dynamic>.from(json));
  }
  
  Future<void> saveTank(Tank tank) async {
    await _tanks.put(tank.id, tank.toJson());
  }
  
  Future<void> deleteTank(String id) async {
    await _tanks.delete(id);
  }
  
  // -------------------------------------------------------------------------
  // Livestock
  // -------------------------------------------------------------------------
  
  Future<List<Livestock>> getLivestockForTank(String tankId) async {
    return _livestock.values
        .map((json) => Livestock.fromJson(Map<String, dynamic>.from(json)))
        .where((fish) => fish.tankId == tankId)
        .toList()
      ..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
  }
  
  Future<void> saveLivestock(Livestock livestock) async {
    await _livestock.put(livestock.id, livestock.toJson());
  }
  
  Future<void> deleteLivestock(String id) async {
    await _livestock.delete(id);
  }
  
  // -------------------------------------------------------------------------
  // Equipment
  // -------------------------------------------------------------------------
  
  Future<List<Equipment>> getEquipmentForTank(String tankId) async {
    return _equipment.values
        .map((json) => Equipment.fromJson(Map<String, dynamic>.from(json)))
        .where((eq) => eq.tankId == tankId)
        .toList();
  }
  
  Future<void> saveEquipment(Equipment equipment) async {
    await _equipment.put(equipment.id, equipment.toJson());
  }
  
  Future<void> deleteEquipment(String id) async {
    await _equipment.delete(id);
  }
  
  // -------------------------------------------------------------------------
  // Logs
  // -------------------------------------------------------------------------
  
  Future<List<LogEntry>> getLogsForTank(String tankId, {int? limit}) async {
    var logs = _logs.values
        .map((json) => LogEntry.fromJson(Map<String, dynamic>.from(json)))
        .where((log) => log.tankId == tankId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    if (limit != null && logs.length > limit) {
      logs = logs.sublist(0, limit);
    }
    
    return logs;
  }
  
  Future<void> saveLog(LogEntry log) async {
    await _logs.put(log.id, log.toJson());
  }
  
  Future<void> deleteLog(String id) async {
    await _logs.delete(id);
  }
  
  // -------------------------------------------------------------------------
  // Tasks
  // -------------------------------------------------------------------------
  
  Future<List<Task>> getTasksForTank(String? tankId) async {
    var tasks = _tasks.values
        .map((json) => Task.fromJson(Map<String, dynamic>.from(json)))
        .toList();
    
    if (tankId != null) {
      tasks = tasks.where((task) => task.tankId == tankId).toList();
    }
    
    return tasks..sort((a, b) {
      final aDate = a.dueDate ?? DateTime(9999);
      final bDate = b.dueDate ?? DateTime(9999);
      return aDate.compareTo(bDate);
    });
  }
  
  Future<void> saveTask(Task task) async {
    await _tasks.put(task.id, task.toJson());
  }
  
  Future<void> deleteTask(String id) async {
    await _tasks.delete(id);
  }
  
  // -------------------------------------------------------------------------
  // User Profile
  // -------------------------------------------------------------------------
  
  Future<Map<String, dynamic>?> getUserProfile() async {
    final json = _userProfile.get('profile');
    if (json == null) return null;
    return Map<String, dynamic>.from(json);
  }
  
  Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    await _userProfile.put('profile', profile);
  }
  
  // -------------------------------------------------------------------------
  // Settings
  // -------------------------------------------------------------------------
  
  Future<Map<String, dynamic>?> getSettings() async {
    final json = _settings.get('settings');
    if (json == null) return null;
    return Map<String, dynamic>.from(json);
  }
  
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _settings.put('settings', settings);
  }
  
  // -------------------------------------------------------------------------
  // Learning Progress
  // -------------------------------------------------------------------------
  
  Future<Map<String, dynamic>?> getLearningProgress() async {
    final json = _learningProgress.get('progress');
    if (json == null) return null;
    return Map<String, dynamic>.from(json);
  }
  
  Future<void> saveLearningProgress(Map<String, dynamic> progress) async {
    await _learningProgress.put('progress', progress);
  }
  
  // -------------------------------------------------------------------------
  // Economy (Hearts, XP, Achievements)
  // -------------------------------------------------------------------------
  
  Future<Map<String, dynamic>?> getEconomy() async {
    final json = _economy.get('economy');
    if (json == null) return null;
    return Map<String, dynamic>.from(json);
  }
  
  Future<void> saveEconomy(Map<String, dynamic> economy) async {
    await _economy.put('economy', economy);
  }
  
  // -------------------------------------------------------------------------
  // Utility
  // -------------------------------------------------------------------------
  
  /// Clear all data (for testing or reset)
  Future<void> clearAll() async {
    await _tanks.clear();
    await _livestock.clear();
    await _equipment.clear();
    await _logs.clear();
    await _tasks.clear();
    await _userProfile.clear();
    await _settings.clear();
    await _learningProgress.clear();
    await _economy.clear();
    debugPrint('[HiveStorage] All data cleared');
  }
  
  /// Get statistics about stored data
  Map<String, int> getStats() {
    return {
      'tanks': _tanks.length,
      'livestock': _livestock.length,
      'equipment': _equipment.length,
      'logs': _logs.length,
      'tasks': _tasks.length,
      'schema_version': kStorageSchemaVersion,
    };
  }
}
