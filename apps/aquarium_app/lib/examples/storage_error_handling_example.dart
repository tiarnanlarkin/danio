import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/local_json_storage_service.dart';
import '../utils/storage_error_handler.dart';
import '../models/models.dart';

/// Example implementation showing how to properly handle storage errors
/// in your widgets and providers.

// ============================================================================
// EXAMPLE 1: Simple Widget with Error Handling
// ============================================================================

class TankListScreen extends ConsumerWidget {
  const TankListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Tanks')),
      body: FutureBuilder<List<Tank>?>(
        future: _loadTanks(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          final tanks = snapshot.data ?? [];
          if (tanks.isEmpty) {
            return const Center(child: Text('No tanks yet'));
          }
          
          return ListView.builder(
            itemCount: tanks.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(tanks[index].name),
              subtitle: Text('${tanks[index].volumeLitres}L'),
            ),
          );
        },
      ),
    );
  }

  Future<List<Tank>?> _loadTanks(BuildContext context) async {
    // Using the safe wrapper - automatically handles StorageCorruptionException
    return StorageErrorHandler.safeStorageOperation(
      context,
      () => LocalJsonStorageService().getAllTanks(),
    );
  }
}

// ============================================================================
// EXAMPLE 2: Manual Error Handling with Custom Recovery
// ============================================================================

class TankDetailScreen extends ConsumerStatefulWidget {
  final String tankId;
  const TankDetailScreen({required this.tankId, super.key});

  @override
  ConsumerState<TankDetailScreen> createState() => _TankDetailScreenState();
}

class _TankDetailScreenState extends ConsumerState<TankDetailScreen> {
  Tank? _tank;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTank();
  }

  Future<void> _loadTank() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final storage = LocalJsonStorageService();
      final tank = await storage.getTank(widget.tankId);

      setState(() {
        _tank = tank;
        _loading = false;
      });
    } on StorageCorruptionException catch (e) {
      // Show error dialog with recovery options
      if (mounted) {
        await StorageErrorHandler.showStorageCorruptionDialog(context, e);
      }

      setState(() {
        _error = 'Storage corrupted';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadTank,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_tank == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Not Found')),
        body: const Center(child: Text('Tank not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(_tank!.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Volume: ${_tank!.volumeLitres}L'),
            Text('Type: ${_tank!.type.name}'),
            // ... more details
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 3: Riverpod Provider with Error Handling
// ============================================================================

/// Provider that loads all tanks with proper error propagation
final allTanksProvider = FutureProvider<List<Tank>>((ref) async {
  final storage = LocalJsonStorageService();
  
  // If StorageCorruptionException occurs here, it will be caught
  // by the widget's error handler (see example below)
  return await storage.getAllTanks();
});

/// Widget that uses the provider and handles errors
class TankListWithProvider extends ConsumerWidget {
  const TankListWithProvider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tanksAsync = ref.watch(allTanksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Tanks')),
      body: tanksAsync.when(
        data: (tanks) {
          if (tanks.isEmpty) {
            return const Center(child: Text('No tanks yet'));
          }
          return ListView.builder(
            itemCount: tanks.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(tanks[index].name),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          // Handle StorageCorruptionException specifically
          if (error is StorageCorruptionException) {
            // Show error dialog after build completes
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                StorageErrorHandler.showStorageCorruptionDialog(
                  context,
                  error,
                );
              }
            });
            
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Storage Error'),
                  const SizedBox(height: 8),
                  Text(
                    error.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            );
          }

          // Generic error
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(allTanksProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 4: Safe Batch Operations
// ============================================================================

class TankBulkOperations {
  final BuildContext context;
  final LocalJsonStorageService storage;

  TankBulkOperations(this.context, this.storage);

  /// Delete multiple tanks safely with error handling
  Future<int> deleteTanksBatch(List<String> tankIds) async {
    int successCount = 0;

    for (final id in tankIds) {
      final ok = await StorageErrorHandler.safeStorageOperation<bool>(
        context,
        () async {
          await storage.deleteTank(id);
          return true;
        },
      );

      if (ok == true) {
        successCount++;
      }
    }

    return successCount;
  }

  /// Import tanks from backup with error recovery
  Future<bool> importTanks(List<Tank> tanks) async {
    try {
      // Try to save all tanks
      for (final tank in tanks) {
        await storage.saveTank(tank);
      }
      return true;
    } on StorageCorruptionException catch (e) {
      // Show error and let user decide
      if (context.mounted) {
        await StorageErrorHandler.showStorageCorruptionDialog(context, e);
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
      return false;
    }
  }
}

// ============================================================================
// EXAMPLE 5: Testing Storage Error Handling
// ============================================================================

/// Helper to simulate storage corruption for testing
class StorageTestHelpers {
  /// Manually trigger a storage corruption exception (for testing only!)
  static Future<void> simulateCorruption() async {
    throw StorageCorruptionException(
      'Simulated corruption for testing',
      corruptedFilePath: '/path/to/test.corrupted',
      originalError: Exception('Test error'),
    );
  }

  /// Test the error dialog UI
  static void testErrorDialog(BuildContext context) {
    StorageErrorHandler.showStorageCorruptionDialog(
      context,
      StorageCorruptionException(
        'Test error message',
        corruptedFilePath: '/test/path/data.json.corrupted',
        originalError: Exception('Simulated parse error'),
      ),
    );
  }
}
