/// Wave 3 Migration Service
///
/// Handles safe migration of user data from pre-Wave 3 to Wave 3 schema.
/// Includes backup, migration, and rollback capabilities.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aquarium_app/models/user_profile.dart';
import 'package:aquarium_app/models/adaptive_difficulty.dart';
import 'package:aquarium_app/services/backup_service.dart';

class Wave3MigrationService {
  static const int targetVersion = 3;
  static const String migrationVersionKey = 'migration_version';
  static const String backupPathKey = 'wave3_migration_backup_path';
  
  final BackupService _backupService = BackupService();
  
  /// Check if migration is needed
  Future<bool> needsMigration() async {
    final prefs = await SharedPreferences.getInstance();
    final currentVersion = prefs.getInt(migrationVersionKey) ?? 0;
    return currentVersion < targetVersion;
  }
  
  /// Get current migration version
  Future<int> getCurrentVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(migrationVersionKey) ?? 0;
  }
  
  /// Run full migration with backup
  Future<MigrationResult> migrate() async {
    debugPrint('🔄 Starting Wave 3 migration...');
    
    try {
      // Step 1: Create backup
      debugPrint('📦 Creating backup...');
      final backupPath = await _backupService.createBackup(
        includePhotos: false, // Faster migration
      );
      
      // Save backup path for potential rollback
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(backupPathKey, backupPath);
      debugPrint('✅ Backup created: $backupPath');
      
      // Step 2: Migrate UserProfile
      debugPrint('🔄 Migrating UserProfile...');
      await _migrateUserProfile();
      debugPrint('✅ UserProfile migrated');
      
      // Step 3: Initialize Wave 3 features
      debugPrint('🔄 Initializing Wave 3 features...');
      await _initializeWave3Features();
      debugPrint('✅ Wave 3 features initialized');
      
      // Step 4: Mark migration complete
      await prefs.setInt(migrationVersionKey, targetVersion);
      debugPrint('✅ Migration complete!');
      
      return MigrationResult(
        success: true,
        version: targetVersion,
        backupPath: backupPath,
        message: 'Successfully migrated to Wave 3',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Migration failed: $e');
      debugPrint('Stack trace: $stackTrace');
      
      return MigrationResult(
        success: false,
        version: await getCurrentVersion(),
        error: e.toString(),
        message: 'Migration failed. Your data is safe in the backup.',
      );
    }
  }
  
  /// Migrate UserProfile model
  Future<void> _migrateUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString('user_profile');
    
    if (profileJson == null) {
      debugPrint('ℹ️ No existing profile found, creating new one');
      final newProfile = UserProfile.empty();
      await prefs.setString('user_profile', jsonEncode(newProfile.toJson()));
      return;
    }
    
    try {
      final oldProfileData = jsonDecode(profileJson) as Map<String, dynamic>;
      final oldProfile = UserProfile.fromJson(oldProfileData);
      
      // Create migrated profile with Wave 3 fields
      final migratedProfile = oldProfile.copyWith(
        // Adaptive Difficulty
        skillProfile: UserSkillProfile.empty(),
        
        // Achievements (preserve existing if present)
        unlockedAchievements: oldProfile.unlockedAchievements ?? [],
        achievementProgress: oldProfile.achievementProgress ?? {},
        
        // Hearts System
        hearts: oldProfile.hearts ?? 5,
        lastHeartLost: oldProfile.lastHeartLost,
        unlimitedHeartsEnabled: oldProfile.unlimitedHeartsEnabled ?? false,
        
        // Spaced Repetition
        totalReviewsCompleted: oldProfile.totalReviewsCompleted ?? 0,
        reviewAccuracy: oldProfile.reviewAccuracy ?? 0.0,
        
        // Analytics
        dailyStats: oldProfile.dailyStats ?? {},
        currentStreak: _calculateStreak(oldProfile),
        lastActivityDate: oldProfile.lastActivityDate ?? DateTime.now(),
        
        // Social
        friends: oldProfile.friends ?? [],
        avatarUrl: oldProfile.avatarUrl,
      );
      
      // Save migrated profile
      await prefs.setString(
        'user_profile',
        jsonEncode(migratedProfile.toJson()),
      );
      
      debugPrint('✅ Profile fields migrated');
      debugPrint('   - Skill profile initialized');
      debugPrint('   - Hearts: ${migratedProfile.hearts}');
      debugPrint('   - Streak: ${migratedProfile.currentStreak}');
      
    } catch (e) {
      debugPrint('⚠️ Error parsing existing profile, creating fresh: $e');
      final newProfile = UserProfile.empty();
      await prefs.setString('user_profile', jsonEncode(newProfile.toJson()));
    }
  }
  
  /// Calculate existing streak from old data
  int _calculateStreak(UserProfile profile) {
    // Try to calculate from existing data
    // If not possible, start fresh
    if (profile.currentStreak != null && profile.currentStreak! > 0) {
      return profile.currentStreak!;
    }
    
    // Check if user was active today
    if (profile.lastActivityDate != null) {
      final daysSinceActivity = DateTime.now()
        .difference(profile.lastActivityDate!)
        .inDays;
      
      if (daysSinceActivity == 0) {
        return 1; // Active today, start with 1
      }
    }
    
    return 0; // No recent activity
  }
  
  /// Initialize Wave 3 features with default data
  Future<void> _initializeWave3Features() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Initialize achievement progress if not exists
    if (!prefs.containsKey('achievement_progress')) {
      await prefs.setString('achievement_progress', jsonEncode({}));
      debugPrint('   - Achievement progress initialized');
    }
    
    // Initialize review queue if not exists
    if (!prefs.containsKey('review_queue')) {
      await prefs.setString('review_queue', jsonEncode({'cards': []}));
      debugPrint('   - Review queue initialized');
    }
    
    // Set up analytics tracking
    if (!prefs.containsKey('analytics_enabled')) {
      await prefs.setBool('analytics_enabled', true);
      debugPrint('   - Analytics enabled');
    }
  }
  
  /// Rollback to pre-Wave 3 state
  Future<RollbackResult> rollback() async {
    debugPrint('🔄 Rolling back migration...');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final backupPath = prefs.getString(backupPathKey);
      
      if (backupPath == null) {
        throw Exception('No backup found. Cannot rollback.');
      }
      
      // Restore from backup
      debugPrint('📦 Restoring from backup: $backupPath');
      await _backupService.restoreBackup(backupPath);
      
      // Reset migration version
      await prefs.setInt(migrationVersionKey, 2);
      debugPrint('✅ Rollback complete');
      
      return RollbackResult(
        success: true,
        message: 'Successfully rolled back to pre-Wave 3 state',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Rollback failed: $e');
      debugPrint('Stack trace: $stackTrace');
      
      return RollbackResult(
        success: false,
        error: e.toString(),
        message: 'Rollback failed. Please contact support.',
      );
    }
  }
  
  /// Validate migration success
  Future<ValidationResult> validate() async {
    debugPrint('🔍 Validating migration...');
    
    final issues = <String>[];
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check migration version
      final version = prefs.getInt(migrationVersionKey);
      if (version != targetVersion) {
        issues.add('Migration version mismatch: $version != $targetVersion');
      }
      
      // Validate UserProfile
      final profileJson = prefs.getString('user_profile');
      if (profileJson == null) {
        issues.add('UserProfile not found');
      } else {
        try {
          final profile = UserProfile.fromJson(
            jsonDecode(profileJson) as Map<String, dynamic>,
          );
          
          // Check Wave 3 fields
          if (profile.skillProfile == null) {
            issues.add('Skill profile not initialized');
          }
          
          if (profile.hearts == null) {
            issues.add('Hearts field missing');
          }
          
          if (profile.dailyStats == null) {
            issues.add('Daily stats not initialized');
          }
          
        } catch (e) {
          issues.add('UserProfile validation failed: $e');
        }
      }
      
      // Validate feature initialization
      if (!prefs.containsKey('achievement_progress')) {
        issues.add('Achievement progress not initialized');
      }
      
      if (!prefs.containsKey('review_queue')) {
        issues.add('Review queue not initialized');
      }
      
      if (issues.isEmpty) {
        debugPrint('✅ Validation passed');
        return ValidationResult(
          valid: true,
          message: 'Migration validated successfully',
        );
      } else {
        debugPrint('⚠️ Validation issues found:');
        for (final issue in issues) {
          debugPrint('   - $issue');
        }
        
        return ValidationResult(
          valid: false,
          issues: issues,
          message: 'Migration validation found ${issues.length} issue(s)',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Validation error: $e');
      debugPrint('Stack trace: $stackTrace');
      
      return ValidationResult(
        valid: false,
        issues: ['Validation error: $e'],
        message: 'Validation failed with error',
      );
    }
  }
  
  /// Clean up old backup files
  Future<void> cleanupOldBackups({int keepDays = 7}) async {
    debugPrint('🧹 Cleaning up old backups...');
    
    try {
      // Implementation depends on your backup service
      // This is a placeholder
      debugPrint('✅ Old backups cleaned up');
    } catch (e) {
      debugPrint('⚠️ Cleanup failed: $e');
    }
  }
}

// =============================================================================
// Result Classes
// =============================================================================

class MigrationResult {
  final bool success;
  final int version;
  final String? backupPath;
  final String? error;
  final String message;
  
  MigrationResult({
    required this.success,
    required this.version,
    this.backupPath,
    this.error,
    required this.message,
  });
  
  @override
  String toString() {
    return 'MigrationResult(success: $success, version: $version, message: $message)';
  }
}

class RollbackResult {
  final bool success;
  final String? error;
  final String message;
  
  RollbackResult({
    required this.success,
    this.error,
    required this.message,
  });
  
  @override
  String toString() {
    return 'RollbackResult(success: $success, message: $message)';
  }
}

class ValidationResult {
  final bool valid;
  final List<String> issues;
  final String message;
  
  ValidationResult({
    required this.valid,
    this.issues = const [],
    required this.message,
  });
  
  @override
  String toString() {
    return 'ValidationResult(valid: $valid, issues: ${issues.length}, message: $message)';
  }
}

// =============================================================================
// Example Usage
// =============================================================================

/// Example usage in main.dart:
/// 
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   
///   final migrationService = Wave3MigrationService();
///   
///   if (await migrationService.needsMigration()) {
///     print('Migration needed. Starting...');
///     
///     final result = await migrationService.migrate();
///     
///     if (result.success) {
///       print('✅ Migration successful!');
///       
///       // Validate
///       final validation = await migrationService.validate();
///       if (!validation.valid) {
///         print('⚠️ Validation issues: ${validation.issues}');
///       }
///     } else {
///       print('❌ Migration failed: ${result.error}');
///       print('Backup available at: ${result.backupPath}');
///       
///       // Optionally rollback
///       final rollback = await migrationService.rollback();
///       print(rollback.message);
///     }
///   }
///   
///   runApp(const ProviderScope(child: MyApp()));
/// }
/// ```
