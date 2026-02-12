import 'package:aquarium_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import '../services/local_json_storage_service.dart';

/// Handles storage corruption errors by showing a dialog with recovery options
class StorageErrorHandler {
  /// Show error dialog when storage corruption is detected
  static Future<void> showStorageCorruptionDialog(
    BuildContext context,
    StorageCorruptionException error,
  ) async {
    if (!context.mounted) return;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text('Data Corrupted'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  error.message,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'What happened?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'The app storage file could not be read. This usually happens due to:\n'
                  '• App crash during save\n'
                  '• File system errors\n'
                  '• Incomplete write operation',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                if (error.corruptedFilePath != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: AppRadius.smallRadius,
                      border: Border.all(color: Colors.orange[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 18,
                              color: Colors.orange,
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Text(
                              'Backup Created',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Your corrupted data has been backed up to:\n${error.corruptedFilePath}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'What would you like to do?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: [
            // Contact Support option
            TextButton.icon(
              icon: const Icon(Icons.support_agent),
              label: const Text('Contact Support'),
              onPressed: () {
                Navigator.of(context).pop();
                _showContactSupport(context, error);
              },
            ),
            // Start Fresh option
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Start Fresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await _confirmStartFresh(context);
              },
            ),
          ],
        );
      },
    );
  }

  /// Show contact support information
  static Future<void> _showContactSupport(
    BuildContext context,
    StorageCorruptionException error,
  ) async {
    if (!context.mounted) return;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Contact Support'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('To help recover your data, please provide:'),
                const SizedBox(height: 12),
                _InfoItem(
                  icon: Icons.bug_report,
                  text:
                      'Error: ${error.originalError?.toString() ?? "Unknown"}',
                ),
                if (error.corruptedFilePath != null)
                  _InfoItem(
                    icon: Icons.folder,
                    text: 'Backup: ${error.corruptedFilePath}',
                  ),
                _InfoItem(
                  icon: Icons.access_time,
                  text: 'Time: ${DateTime.now().toIso8601String()}',
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Email this information to:\nsupport@aquariumapp.com',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'We\'ll help you recover your data from the backup file.',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.copy),
              label: const Text('Copy Info'),
              onPressed: () {
                // TODO: Copy error info to clipboard
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Error info copied to clipboard'),
                  ),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Confirm start fresh action
  static Future<void> _confirmStartFresh(BuildContext context) async {
    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('⚠️ Confirm Start Fresh'),
          content: const Text(
            'This will clear all your current data and let you start with a clean slate.\n\n'
            'Your corrupted data backup will still be saved.\n\n'
            'Are you sure you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Start Fresh'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      await _performStartFresh(context);
    }
  }

  /// Perform the start fresh operation
  static Future<void> _performStartFresh(BuildContext context) async {
    try {
      // Show loading indicator
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Clear all data
      final storage = LocalJsonStorageService();
      await storage.clearAllData();

      // Close loading indicator
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Storage cleared. You can start fresh!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }

      // Optionally restart the app or navigate to home
      // You might want to add navigation logic here
    } catch (e) {
      // Close loading indicator
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to clear storage: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Wrapper to safely execute storage operations with automatic error handling
  static Future<T?> safeStorageOperation<T>(
    BuildContext context,
    Future<T> Function() operation,
  ) async {
    try {
      return await operation();
    } on StorageCorruptionException catch (e) {
      if (context.mounted) {
        await showStorageCorruptionDialog(context, e);
      }
      return null;
    } catch (e) {
      // Handle other errors
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
      return null;
    }
  }
}

/// Helper widget for info items in dialogs
class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
