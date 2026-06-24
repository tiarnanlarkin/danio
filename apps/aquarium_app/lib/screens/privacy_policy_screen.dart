import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

const double _maxPrivacyPolicyContentWidth = 720;

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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: _maxPrivacyPolicyContentWidth,
            ),
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
                  'Last Updated: 28 March 2026',
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
                  'The data controller responsible for your personal data is:\n\nTiarnan Larkin\nEmail: larkintiarnanbizz@gmail.com\n\nFor any privacy-related inquiries, contact us at the email above. We aim to respond within 7 business days.',
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
                  'Firebase Crashlytics (consent-based)',
                  'When you consent, crash reports help us fix bugs and keep Danio stable. These reports contain device OS version, app version, and error stack traces. No tank records, photos, or learning progress are included. Retained for 90 days.',
                  Icons.bug_report,
                ),

                _buildHighlight(
                  'OpenAI API - Fish ID (optional feature)',
                  'When you use the Fish ID feature, the photo you capture is stripped of metadata before being sent to OpenAI Inc. (USA) for species identification. Images are retained by OpenAI for a maximum of 30 days, then automatically deleted. OpenAI does not use your data to train their models.',
                  Icons.photo_camera,
                ),

                _buildHighlight(
                  'Cloud Sync & Accounts',
                  'Cloud sync and account login are not active in this version of Danio. Danio does not upload tank records, photos, logs, or backups to a Danio server.',
                  Icons.cloud_off,
                ),

                _buildSection(
                  '4. Legal Basis for Processing',
                  'Under UK GDPR Art. 6(1), we process your data on the following legal bases:',
                ),

                _buildBulletList([
                  'Crash reports: Art. 6(1)(a) - Your explicit consent, given on first launch and manageable in Settings',
                  'Fish ID images: Art. 6(1)(a) - Your consent each time you use the feature',
                  'Local app data: Not subject to GDPR as it does not leave your device',
                ], context),

                _buildSection(
                  '5. International Data Transfers',
                  'Some of your data is transferred outside the UK to the following recipients:',
                ),

                _buildBulletList([
                  'Google LLC (USA) - Firebase Crashlytics data, covered by the EU-US Data Privacy Framework and Google\'s Data Processing Agreement',
                  'OpenAI Inc. (USA) - Fish ID image data, covered by OpenAI\'s Data Processing Agreement and standard contractual clauses',
                  'Appropriate safeguards are in place for all transfers in compliance with UK GDPR Chapter V',
                ], context),

                _buildSection(
                  '6. Data Retention',
                  'We retain your data only for as long as necessary:',
                ),

                _buildBulletList([
                  'Crash logs: 90 days, then automatically deleted',
                  'Fish ID images: metadata stripped before upload; max 30 days on OpenAI\'s servers, then deleted',
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
                  'You can delete local app data in Settings or email larkintiarnanbizz@gmail.com for privacy requests',
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
                  'You can withdraw crash reporting consent at any time in Settings',
                  Icons.block,
                  context,
                ),

                _buildSection(
                  '8. Opting Out of Crash Reports',
                  'You can opt out of crash reporting at any time:\n\n1. Open Settings\n2. Navigate to Privacy\n3. Toggle "Crash Reports" off\n\nWhen disabled, crash reports are not sent to Google.',
                ),

                _buildSection(
                  '9. Data Deletion',
                  'You can delete all your data in the following ways:',
                ),

                _buildBulletList([
                  'In-app: Settings > Clear All Data - permanently removes all local tank, log, task, and photo data',
                  'In-app: Settings > Delete My Data - removes local tanks, progress, achievements, and onboarding state',
                  'Email request: Contact larkintiarnanbizz@gmail.com and we will delete all data we hold within 30 days',
                  'Uninstall: Removing the app deletes all local data from your device',
                  'Crash report opt-out: Disabling Crash Reports in Settings stops further crash diagnostic collection',
                ], context),

                _buildSection(
                  '10. Data Security',
                  'We implement appropriate technical and organisational measures to protect your data:',
                ),

                _buildBulletList([
                  'Optional online services use HTTPS/TLS encryption',
                  'Local data is protected by your device\'s security (lock screen, encryption)',
                  'No sensitive personal data, such as passwords or financial information, is collected by this version of Danio',
                ], context),

                _buildSection(
                  '11. Children\'s Privacy (COPPA)',
                  'Danio is designed for general audiences, including users of all ages. We do not knowingly collect personal information from children under 13 years of age without verifiable parental consent.\n\nCrash reporting is opt-in and requires explicit consent on first launch. If you believe a child under 13 has provided us with personal data without parental consent, please contact us immediately at larkintiarnanbizz@gmail.com and we will delete it promptly.\n\nParents and guardians may contact us to review, delete, or restrict the collection of their child\'s data at any time. The app contains no advertising directed at children and does not share children\'s data with third parties for commercial purposes.',
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
          _buildSummaryItem(
            'Tank, livestock, and log data stored locally on your device',
          ),
          _buildSummaryCardBullet(
            'Firebase Crashlytics collects crash reports only when you opt in',
          ),
          _buildSummaryItem(
            'Fish ID sends metadata-stripped photos to OpenAI for identification',
          ),
          _buildSummaryItem(
            'Cloud sync and account login are not active in this version of Danio',
          ),
          _buildSummaryItem('You can delete all data in-app or by emailing us'),
          _buildSummaryItem('Crash reports can be toggled off in Settings'),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
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
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
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
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
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
      padding: const EdgeInsets.only(
        left: AppSpacing.md,
        bottom: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
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
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
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
      margin: const EdgeInsets.only(bottom: AppSpacing.sm2),
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
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
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
                      'larkintiarnanbizz@gmail.com',
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
      'https://tiarnanlarkin.github.io/danio/privacy-policy.html',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
