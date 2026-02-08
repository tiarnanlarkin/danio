import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/local_json_storage_service.dart';
import '../services/storage_service.dart';

/// Global storage service provider
final storageServiceProvider = Provider<StorageService>((ref) {
  // MVP persistence: local JSON file storage.
  return LocalJsonStorageService();
});
