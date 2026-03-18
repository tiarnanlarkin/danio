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
                  colors: [AppOverlays.primary10, AppOverlays.secondary10],
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
                          'Your Privacy Matters',
                          style: AppTypography.headlineSmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Transparency about how we handle your data',
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
              'Last Updated: 18 March 2026',
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Sections
            _buildSection(
              '1. Introduction',
              'Danio is an aquarium management and learning app built by Tiarnan Larkin. This Privacy Policy explains what data we collect, why, and how you can control it.\n\nThis policy is written in accordance with the UK General Data Protection Regulation (UK GDPR) and the Data Protection Act 2018.',
            ),

            _buildSection(
              '2. Data Controller',
              'The data controller responsible for your personal data is:\n\nTiarnan Larkin\nEmail: tiarnan.larkin@gmail.com\n\nFor any privacy-related inquiries, contact us at the email above. We aim to respond within 7 business days.',
            ),

            _buildSection(
              '3. Information We Collect',
              'We collect and process the following categories of data:',
            ),

            _buildHighlight(
              'Local App Data (stored on your device)',
              'Tank information, livestock records, water test logs, maintenance logs, photos, learning progress, app settings, and reminders. All stored locally using SharedPreferences and SQLite on your device.',
              Icons.storage,
            ),

            _buildHighlight(
              'Firebase Analytics (consent-based)',
              'When you consent, we collect anonymous usage data including 6 event types: page views, feature usage patterns, and screen navigation. This helps us improve the app. Data is shared with Google LLC (USA) for processing.',
              Icons.bar_chart,
            ),

            _buildHighlight(
              'Firebase Crashlytics (legitimate interest)',
              'Crash reports are collected automatically when the app encounters an error. These reports contain device OS version, app version, and error stack traces. No personal data is included in crash logs. Retained for 90 days.',
              Icons.bug_report,
            ),

            _buildHighlight(
              'OpenAI API — Fish ID (optional feature)',
              'When you use the Fish ID feature, the photo you capture is sent to OpenAI Inc. (USA) for species identification. Images are retained by OpenAI for a maximum of 30 days, then automatically deleted. OpenAI does not use your data to train their models.',
              Icons.photo_camera,
            ),

            _buildHighlight(
              'Supabase Auth — Cloud Sync (currently dormant)',
              'The app includes code for optional cloud sync via Supabase. This feature is not currently active. When activated in future, it will store your email and password in Supabase (EU region), encrypted in transit using TLS 1.3. We will update this policy and request explicit consent before activation.',
              Icons.cloud_off,
            ),

            _buildSection(
              '4. Legal Basis for Processing',
              'Under UK GDPR Art. 6(1), we process your data on the following legal bases:',
            ),

            _buildBulletList([
              'Analytics data: Art. 6(1)(a) — Your explicit consent, given on first launch and manageable in Settings',
              'Crash reports: Art. 6(1)(f) — Legitimate interest in maintaining app stability',
              'Fish ID images: Art. 6(1)(a) — Your consent each time you use the feature',
              'Local app data: Not subject to GDPR as it does not leave your device',
            ], context),

            _buildSection(
              '5. International Data Transfers',
              'Some of your data is transferred outside the UK to the following recipients:',
            ),

            _buildBulletList([
              'Google LLC (USA) — Firebase Analytics and Crashlytics data, covered by the EU-US Data Privacy Framework and Google\'s Data Processing Agreement',
              'OpenAI Inc. (USA) — Fish ID image data, covered by OpenAI\'s Data Processing Agreement and standard contractual clauses',
              'Appropriate safeguards are in place for all transfers in compliance with UK GDPR Chapter V',
            ], context),

            _buildSection(
              '6. Data Retention',
              'We retain your data only for as long as necessary:',
            ),

            _buildBulletList([
              'Analytics data: 26 months (Google\'s default retention period)',
              'Crash logs: 90 days, then automatically deleted',
              'Fish ID images: Max 30 days on OpenAI\'s servers, then deleted',
              'Local app data: Stored indefinitely on your device until you delete it',
            ], context),

            _buildSection(
              '7. Your Data Rights',
              'Under UK GDPR, you have the following rights regarding your personal data:',
            ),

            _buildRightCard(
              'Right of Access',
              'You can request a copy of all personal data we hold about you',
              Icons.visibility,
              context,
            ),
            _buildRightCard(
              'Right to Rectification',
              'You can request correction of inaccurate personal data',
              Icons.edit,
              context,
            ),
            _buildRightCard(
              'Right to Erasure',
              'You can request deletion of your personal data. In-app: Settings > Account > Delete Data. Or email tiarnan.larkin@gmail.com',
              Icons.delete,
              context,
            ),
            _buildRightCard(
              'Right to Data Portability',
              'Export your data via the app\'s Backup feature (JSON format)',
              Icons.sync_alt,
              context,
            ),
            _buildRightCard(
              'Right to Object',
              'You can withdraw analytics consent at any time in Settings',
              Icons.block,
              context,
            ),

            _buildSection(
              '8. Opting Out of Analytics',
              'You can opt out of Firebase Analytics at any time:\n\n1. Open Settings\n2. Navigate to Privacy\n3. Toggle "Analytics" off\n\nWhen disabled, no usage events are sent to Google. Crashlytics operates independently of this setting.',
            ),

            _buildSection(
              '9. Data Deletion',
              'You can delete all your data in the following ways:',
            ),

            _buildBulletList([
              'In-app: Settings > Account > Delete Data — permanently removes all local data',
              'Email request: Contact tiarnan.larkin@gmail.com and we will delete all data we hold within 30 days',
              'Uninstall: Removing the app deletes all local data from your device',
              'Analytics opt-out: Disabling analytics in Settings stops further data collection',
            ], context),

            _buildSection(
              '10. Data Security',
              'We implement appropriate technical and organisational measures to protect your data:',
            ),

            _buildBulletList([
              'All network transmissions use HTTPS/TLS encryption',
              'Supabase connections use TLS 1.3',
              'Local data is protected by your device\'s security (lock screen, encryption)',
              'No sensitive personal data ( passwords, financial info) is collected',
            ], context),

            _buildSection(
              '11. Children\'s Privacy',
              'Danio does not knowingly collect personal information from children under 13. Analytics consent is obtained before any data collection. Parents or guardians may contact us to request deletion of any child\'s data.',
            ),

            _buildSection(
              '12. Changes to This Policy',
              'We may update this Privacy Policy from time to time. Material changes will be notified within the app. We encourage you to review this policy periodically.',
            ),

            _buildSection(
              '13. Complaints',
              'If you are unsatisfied with our handling of your personal data, you have the right to lodge a complaint with the UK supervisory authority:\n\nInformation Commissioner\'s Office (ICO)\nWebsite: ico.org.uk\nPhone: 0303 123 1113',
            ),

            _buildSection(
              '14. Contact Information',
              'For any questions about this Privacy Policy or our data practices:',
            ),

            _buildContactCard(context),

            const SizedBox(height: AppSpacing.xl),

            // Footer
            Center(
              child: Column(
                children: [
                  Text(
                    'Danio',
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
      padding: const EdgeInsets.all(AppSpacing.lg2),
      decoration: BoxDecoration(
        color: AppOverlays.primary5,
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: AppOverlays.primary20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppColors.primary,
                size: AppIconSizes.md,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Summary', style: AppTypography.labelLarge),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildSummaryItem('Tank, livestock, and log data stored locally on your device'),
          _buildSummaryItem('Firebase Analytics collects anonymous usage data (opt-in)'),
          _buildSummaryCardBullet('Firebase Crashlytics collects crash reports (automatic)'),
          _buildSummaryItem('Fish ID sends photos to OpenAI for identification (opt-in per use)'),
          _buildSummaryItem('Cloud sync code exists but is not currently active'),
          _buildSummaryItem('You can delete all data in-app or by emailing us'),
          _buildSummaryItem('Analytics can be toggled off in Settings'),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.circle, color: AppColors.primary, size: 8),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: AppTypography.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildSummaryCardBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.circle, color: AppColors.primary, size: 8),
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

  Widget _buildBulletList(
    List<String> items,
    BuildContext context, {
    bool isNegative = false,
  }) {
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
                    color: isNegative ? AppColors.error : context.textSecondary,
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

  Widget _buildRightCard(
    String title,
    String description,
    IconData icon,
    BuildContext context,
  ) {
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

  Widget _buildContactCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.email,
                color: AppColors.primary,
                size: AppIconSizes.md,
              ),
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
    final url = Uri.parse(
      'https://gist.github.com/tiarnanlarkin/ba344c0c023b4fd799227850963a35f3',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
