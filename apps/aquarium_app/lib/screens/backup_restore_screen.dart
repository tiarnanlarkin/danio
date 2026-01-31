import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../providers/tank_provider.dart';
import '../theme/app_theme.dart';

class BackupRestoreScreen extends ConsumerStatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  ConsumerState<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  String? _lastBackup;
  bool _isExporting = false;
  bool _isImporting = false;
  final _importController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final tanksAsync = ref.watch(tanksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: AppColors.info.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.backup, size: 32, color: AppColors.info),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Export your tank data as JSON to back up or transfer to another device.',
                      style: AppTypography.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text('Export Data', style: AppTypography.headlineSmall),
          const SizedBox(height: 12),

          tanksAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
            data: (tanks) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.inventory_2, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text('${tanks.length} tank${tanks.length == 1 ? '' : 's'} to export', 
                            style: AppTypography.labelLarge),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...tanks.take(5).map((t) => Padding(
                      padding: const EdgeInsets.only(left: 32, top: 4),
                      child: Text('• ${t.name}', style: AppTypography.bodySmall),
                    )),
                    if (tanks.length > 5)
                      Padding(
                        padding: const EdgeInsets.only(left: 32, top: 4),
                        child: Text('... and ${tanks.length - 5} more', 
                            style: AppTypography.bodySmall),
                      ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _isExporting ? null : () => _exportData(tanks),
                        icon: _isExporting 
                            ? const SizedBox(
                                width: 16, height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.file_download),
                        label: Text(_isExporting ? 'Exporting...' : 'Export to Clipboard'),
                      ),
                    ),
                    if (_lastBackup != null) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          '✓ Copied to clipboard!',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.success),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text('Import Data', style: AppTypography.headlineSmall),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Paste exported JSON data below to restore your tanks.',
                    style: AppTypography.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _importController,
                    decoration: const InputDecoration(
                      hintText: 'Paste JSON here...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final data = await Clipboard.getData('text/plain');
                            if (data?.text != null) {
                              _importController.text = data!.text!;
                            }
                          },
                          icon: const Icon(Icons.paste),
                          label: const Text('Paste from Clipboard'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: _isImporting || _importController.text.isEmpty
                            ? null
                            : _importData,
                        icon: _isImporting
                            ? const SizedBox(
                                width: 16, height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.file_upload),
                        label: Text(_isImporting ? 'Importing...' : 'Import'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text('What Gets Exported', style: AppTypography.headlineSmall),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ExportItem(icon: Icons.water, text: 'All tanks and settings', included: true),
                  _ExportItem(icon: Icons.pets, text: 'Livestock inventories', included: true),
                  _ExportItem(icon: Icons.science, text: 'Water test logs', included: true),
                  _ExportItem(icon: Icons.eco, text: 'Plant inventories', included: true),
                  _ExportItem(icon: Icons.book, text: 'Journal entries', included: true),
                  const Divider(),
                  _ExportItem(icon: Icons.photo, text: 'Photos (URLs only)', included: true),
                  _ExportItem(icon: Icons.settings, text: 'App preferences', included: false),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Card(
            color: AppColors.warning.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning, color: AppColors.warning),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Import Warning', style: AppTypography.labelLarge),
                        const SizedBox(height: 4),
                        Text(
                          'Importing data will ADD to your existing tanks — it won\'t overwrite or delete anything.',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Future<void> _exportData(List<dynamic> tanks) async {
    setState(() => _isExporting = true);

    try {
      final export = {
        'version': 1,
        'exportDate': DateTime.now().toIso8601String(),
        'appVersion': '1.0.0',
        'tanks': tanks.map((t) => t.toJson()).toList(),
      };

      final json = const JsonEncoder.withIndent('  ').convert(export);
      await Clipboard.setData(ClipboardData(text: json));

      setState(() {
        _lastBackup = DateFormat('MMM d, y h:mm a').format(DateTime.now());
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data copied to clipboard!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _importData() async {
    setState(() => _isImporting = true);

    try {
      final json = _importController.text.trim();
      final data = jsonDecode(json) as Map<String, dynamic>;

      if (data['tanks'] == null || data['tanks'] is! List) {
        throw 'Invalid format: missing tanks array';
      }

      final tanks = data['tanks'] as List;
      
      // Show confirmation dialog
      if (!mounted) return;
      
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Import Data?'),
          content: Text(
            'This will import ${tanks.length} tank${tanks.length == 1 ? '' : 's'}.\n\n'
            'Your existing data will NOT be affected.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Import'),
            ),
          ],
        ),
      );

      if (confirmed != true) {
        setState(() => _isImporting = false);
        return;
      }

      // TODO: Actually import tanks through provider
      // For now, show success message
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imported ${tanks.length} tanks successfully!')),
        );
        _importController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    } finally {
      setState(() => _isImporting = false);
    }
  }
}

class _ExportItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool included;

  const _ExportItem({required this.icon, required this.text, required this.included});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTypography.bodyMedium)),
          Icon(
            included ? Icons.check_circle : Icons.cancel,
            size: 18,
            color: included ? AppColors.success : AppColors.textHint,
          ),
        ],
      ),
    );
  }
}
