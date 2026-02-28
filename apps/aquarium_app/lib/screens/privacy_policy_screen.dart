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
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg2),
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
                    padding: const EdgeInsets.all(AppSpacing.sm2),
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
                          'Your privacy matters to us',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
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
              'Last Updated: February 28, 2026',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Sections
            _buildSection(
              'Introduction',
              'Aquarium Hobbyist is committed to protecting your privacy. This Privacy Policy explains how we handle your information when you use our Android application.\n\nThe short version: Your core aquarium data is stored locally on your device. Optional cloud sync and AI-powered features use third-party services (Supabase and OpenAI) as described below. You are always in control of what data is shared.',
            ),

            _buildSection(
              'Information Collection and Storage',
              'Aquarium Hobbyist stores the following information locally on your device only:',
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
              'Your aquarium data is stored locally in a database on your device. If you create an account, data can also be encrypted and synced to Supabase cloud servers (EU/US). Cloud sync is optional and user-initiated.',
              Icons.storage,
            ),

            _buildSection(
              'Cloud Sync (Optional)',
              'If you create an account, you may choose to sync your data to the cloud via Supabase (our backend provider). This includes:\n\n'
              '• Tank configurations, livestock, and equipment records\n'
              '• Water test logs and maintenance history\n'
              '• Encrypted backups of your app data\n\n'
              'Cloud sync is entirely optional. The app works fully offline without an account. You can delete your cloud account and all synced data at any time from the Account screen.',
            ),

            _buildSection(
              'AI-Powered Features',
              'Aquarium Hobbyist offers optional AI features powered by OpenAI:\n\n'
              '• Fish/Plant Identification: Photos you take are sent to OpenAI\'s GPT-4o Vision API for analysis.\n'
              '• Symptom Triage: Text descriptions are sent to OpenAI for care suggestions.\n'
              '• Weekly Care Plans: Your tank data summary is sent to generate personalised advice.\n\n'
              'When using AI features:\n'
              '• Photos and text are transmitted to OpenAI\'s servers for processing\n'
              '• OpenAI may temporarily process this data per their data usage policy\n'
              '• We do not store your photos or AI queries on our servers\n'
              '• AI features are optional — the app works without them',
            ),

            _buildSection(
              'Data We Do NOT Collect',
              'We do not collect, transmit, or have access to:',
            ),

            _buildBulletList([
              'Location data',
              'Usage analytics or tracking statistics',
              'Device fingerprinting information',
              'Advertising identifiers',
              'Data from other apps on your device',
            ], isNegative: true),

            _buildSection(
              'Third-Party Services',
              'Aquarium Hobbyist uses the following third-party services:',
            ),

            _buildPermissionCard(
              'Supabase (Cloud Sync & Auth)',
              'Provides optional account creation, authentication, and encrypted cloud backup/sync. Data is stored on Supabase-managed servers. Only used if you create an account.',
              Icons.cloud,
            ),

            _buildPermissionCard(
              'OpenAI (AI Features)',
              'Powers Fish ID, Symptom Triage, and AI care plans. Photos and text prompts are sent to OpenAI servers for processing. OpenAI\'s data usage policy applies. Only used when you actively use AI features.',
              Icons.auto_awesome,
            ),

            const SizedBox(height: AppSpacing.md),

            _buildSection(
              'Services We Do NOT Use',
              'No advertising networks, no Google Analytics or Firebase Analytics, no social media trackers, no crash reporting services.',
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
              'Permissions are only used for their stated purpose. Photos are only sent externally when you actively use AI identification features.',
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
              'Account Deletion',
              'Delete your cloud account and all synced data from the Account screen',
              Icons.person_remove,
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
              'Core data stored locally, protected by your device\'s security',
              'Cloud backups are encrypted before transmission',
              'API communications use HTTPS/TLS encryption',
              'Optional account system — the app works fully without one',
              'AI features process data transiently — we don\'t store queries server-side',
            ]),

            _buildSection(
              'Backup Security',
              'When you create a backup, you choose where to save it (device storage, SD card, or cloud service via your file manager). If you share a backup file with someone, they can read your data. We recommend storing backups securely and not sharing them publicly.',
            ),

            _buildSection(
              'Children\'s Privacy',
              'Aquarium Hobbyist does not collect any personal information from anyone, including children under 13. The app can be safely used by hobbyists of all ages.',
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
                    'Aquarium Hobbyist v2.0',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Built for the aquarium community',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
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
      padding: const EdgeInsets.all(AppSpacing.lg2),
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
          _buildSummaryItem('Core data stored locally on your device'),
          _buildSummaryItem('Optional cloud sync via Supabase (you choose)'),
          _buildSummaryItem('AI Fish ID sends photos to OpenAI for processing'),
          _buildSummaryItem('No ads or third-party tracking'),
          _buildSummaryItem('You own and control your data'),
          _buildSummaryItem('Export backups or delete your account anytime'),
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
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
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
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppOverlays.primary5,
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: AppOverlays.primary20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: AppIconSizes.md),
          const SizedBox(width: 12),
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
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppOverlays.primary10,
              borderRadius: AppRadius.smallRadius,
            ),
            child: Icon(icon, color: AppColors.primary, size: AppIconSizes.sm),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.labelMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
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
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppOverlays.success5,
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: AppOverlays.success20),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.success, size: AppIconSizes.md),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.labelMedium),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
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
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.email, color: AppColors.primary, size: AppIconSizes.md),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email', style: AppTypography.labelMedium),
                    const SizedBox(height: 2),
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
              color: AppColors.textSecondary,
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
      'https://tiarnanlarkin.github.io/Aquarium-App-Dev/docs/privacy-policy.html',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
