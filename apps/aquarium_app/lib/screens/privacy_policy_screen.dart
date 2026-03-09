import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: _openOnlineVersion,
            tooltip: 'View online',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(AppSpacing.lg2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppOverlays.primary10,
                    AppOverlays.secondary10,
                  ],
                ),
                borderRadius: AppRadius.mediumRadius,
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppSpacing.sm2),
                    decoration: BoxDecoration(
                      color: AppOverlays.primary20,
                      borderRadius: AppRadius.mediumRadius,
                    ),
                    child: const Icon(
                      Icons.shield,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Privacy First',
                          style: AppTypography.headlineSmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Your data stays on your device',
                          style: AppTypography.bodyMedium.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // TL;DR Summary
            _buildSummaryCard(),

            const SizedBox(height: AppSpacing.xl),

            // Last Updated
            Text(
              'Last Updated: February 6, 2025',
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Sections
            _buildSection(
              'Introduction',
              'Danio is committed to protecting your privacy. This Privacy Policy explains how we handle your information when you use our Android application.\n\nThe short version: We don\'t collect, transmit, or store any of your data on external servers. Everything stays on your device.',
            ),

            _buildSection(
              'Information Collection and Storage',
              'Danio stores the following information locally on your device only:',
            ),

            _buildBulletList([
              'Tank information (names, sizes, types, setup dates)',
              'Livestock data (fish species, quantities)',
              'Equipment records (filters, heaters, lighting)',
              'Water test logs (pH, ammonia, nitrite, nitrate)',
              'Maintenance logs (water changes, cleanings)',
              'Photos (stored in app\'s local directory)',
              'Reminders (notification schedules)',
              'App settings (preferences, themes)',
            ]),

            _buildHighlight(
              'How Is Data Stored?',
              'All data is stored in JSON files and local database on your device. No cloud storage. No remote servers. No external databases.',
              Icons.storage,
            ),

            _buildSection(
              'Data We Do NOT Collect',
              'We do not collect, transmit, or have access to:',
            ),

            _buildBulletList([
              'Personal identification information',
              'Email addresses or phone numbers',
              'Location data',
              'Usage analytics or statistics',
              'Device information',
              'Crash reports',
              'Advertising identifiers',
            ], isNegative: true),

            _buildSection(
              'Third-Party Services',
              'Danio v1.0 does not use any third-party services that collect data. No analytics (Google Analytics, Firebase, etc.), no advertising networks, no cloud sync, no social media integrations, no crash reporting.',
            ),

            _buildSection(
              'Android Permissions Used',
              'The app requests the following permissions for local functionality only:',
            ),

            _buildPermissionCard(
              'Notifications',
              'To send you reminders about water changes and maintenance tasks. Uses flutter_local_notifications (local only, no external communication).',
              Icons.notifications,
            ),

            _buildPermissionCard(
              'Storage/Photos',
              'To let you add photos to your tanks and create/restore backups. Uses image_picker and file_picker (local file access only).',
              Icons.photo_library,
            ),

            const SizedBox(height: AppSpacing.md),

            _buildHighlight(
              'Important',
              'None of these permissions are used to transmit data off your device.',
              Icons.security,
            ),

            _buildSection(
              'Your Data Rights',
              'Since all data is stored locally on your device, you have complete control:',
            ),

            _buildRightCard(
              'Access',
              'View all your data anytime within the app',
              Icons.visibility,
            ),
            _buildRightCard(
              'Export',
              'Use the Backup feature to export all data to a JSON file',
              Icons.file_download,
            ),
            _buildRightCard(
              'Delete',
              'Delete individual items, clear all data, or uninstall the app',
              Icons.delete,
            ),
            _buildRightCard(
              'Portability',
              'Backup files are in standard JSON format',
              Icons.sync_alt,
            ),

            _buildSection(
              'Data Security',
              'Your data security is inherent in our design:',
            ),

            _buildBulletList([
              'Local storage only - data never leaves your device',
              'No network transmission - app doesn\'t communicate with external servers',
              'Protected by your device\'s security (lock screen, encryption)',
              'No account system - no passwords to leak, no accounts to compromise',
            ]),

            _buildSection(
              'Backup Security',
              'When you create a backup, you choose where to save it (device storage, SD card, or cloud service via your file manager). If you share a backup file with someone, they can read your data. We recommend storing backups securely and not sharing them publicly.',
            ),

            _buildSection(
              'Children\'s Privacy',
              'Danio does not collect any personal information from anyone, including children under 13. The app can be safely used by hobbyists of all ages.',
            ),

            _buildSection(
              'Changes to This Policy',
              'If we add features that involve data collection in future versions, we will update this policy and notify you within the app. We will always prioritize your privacy.',
            ),

            _buildSection(
              'Contact Information',
              'If you have questions about this Privacy Policy or data practices:',
            ),

            _buildContactCard(),

            const SizedBox(height: AppSpacing.xl),

            // Footer
            Center(
              child: Column(
                children: [
                  Text(
                    'Danio v1.0',
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Built for the aquarium community',
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg2),
      decoration: BoxDecoration(
        color: AppOverlays.success10,
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: AppOverlays.success30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: AppIconSizes.md,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Summary (TL;DR)', style: AppTypography.labelLarge),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildSummaryItem('All data stored locally on your device'),
          _buildSummaryItem('No internet connection required'),
          _buildSummaryItem('No analytics, ads, or tracking'),
          _buildSummaryItem('You own and control your data'),
          _buildSummaryItem('Export backups anytime'),
          _buildSummaryItem('Delete data anytime'),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check, color: AppColors.success, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: AppTypography.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(content, style: AppTypography.bodyMedium.copyWith(height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildBulletList(List<String> items, {bool isNegative = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(
                    isNegative ? Icons.close : Icons.circle,
                    size: isNegative ? 16 : 8,
                    color: isNegative
                        ? AppColors.error
                        : context.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm2),
                Expanded(
                  child: Text(
                    item,
                    style: AppTypography.bodyMedium.copyWith(height: 1.5),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHighlight(String title, String content, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppOverlays.primary5,
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: AppOverlays.primary20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: AppIconSizes.md),
          const SizedBox(width: AppSpacing.sm2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.labelLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  content,
                  style: AppTypography.bodyMedium.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionCard(String title, String description, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppOverlays.primary10,
              borderRadius: AppRadius.smallRadius,
            ),
            child: Icon(icon, color: AppColors.primary, size: AppIconSizes.sm),
          ),
          const SizedBox(width: AppSpacing.sm2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.labelMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightCard(String title, String description, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppOverlays.success5,
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: AppOverlays.success20),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.success, size: AppIconSizes.md),
          const SizedBox(width: AppSpacing.sm2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.labelMedium),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.email, color: AppColors.primary, size: AppIconSizes.md),
              const SizedBox(width: AppSpacing.sm2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email', style: AppTypography.labelMedium),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'tiarnan.larkin@gmail.com',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                onPressed: () {
                  // Copy to clipboard (implement if needed)
                },
                tooltip: 'Copy email',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Response time: Within 7 business days',
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  void _openOnlineVersion() async {
    // GitHub Pages URL once repo is pushed
    final url = Uri.parse(
      'https://gist.github.com/tiarnanlarkin/ba344c0c023b4fd799227850963a35f3',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
