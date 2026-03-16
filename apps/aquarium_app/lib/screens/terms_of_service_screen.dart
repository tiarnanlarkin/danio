import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms of Service')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              icon: Icons.gavel,
              title: 'Terms of Service',
              content:
                  'These terms govern your use of the Danio app. '
                  'Please read them carefully.',
            ),

            const SizedBox(height: AppSpacing.lg),

            _buildSection(
              context,
              icon: Icons.school_outlined,
              title: 'Educational Use Only',
              content:
                  'This app provides educational information about fishkeeping. '
                  'It is NOT professional veterinary advice. Always consult qualified '
                  'professionals for specific advice about your aquatic life.',
              highlighted: true,
            ),

            const SizedBox(height: AppSpacing.lg),

            _buildSection(
              context,
              icon: Icons.shield_outlined,
              title: 'No Warranties',
              content:
                  'The app is provided "as is" without warranties. We are not '
                  'responsible for any harm to aquatic life or decisions made using the app.',
            ),

            const SizedBox(height: AppSpacing.lg),

            _buildSection(
              context,
              icon: Icons.storage_outlined,
              title: 'Your Data',
              content:
                  'You own all data you create in the app. All data is stored '
                  'locally on your device. You are responsible for creating backups.',
            ),

            const SizedBox(height: AppSpacing.lg),

            _buildSection(
              context,
              icon: Icons.lock_outline,
              title: 'License',
              content:
                  'We grant you a limited, personal, non-commercial license to use '
                  'the app. You may not modify, reverse engineer, or distribute the app.',
            ),

            const SizedBox(height: AppSpacing.lg),

            _buildSection(
              context,
              icon: Icons.update_outlined,
              title: 'Changes',
              content:
                  'We may update the app and these terms at any time. Continued '
                  'use after changes means you accept the new terms.',
            ),

            const SizedBox(height: AppSpacing.xl),

            const Divider(),

            const SizedBox(height: AppSpacing.md),

            Center(
              child: Text(
                'Last Updated: February 7, 2025',
                style: AppTypography.bodySmall.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            Center(
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _openFullTerms(),
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text('View Full Terms'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm2),
                  TextButton(
                    onPressed: () => _showContactInfo(context),
                    child: const Text('Contact Us'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.warningAlpha10,
                borderRadius: AppRadius.mediumRadius,
                border: Border.all(color: AppColors.warningAlpha30),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.warning,
                    size: AppIconSizes.md,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'By using Danio, you agree to these terms. '
                      'If you don\'t agree, please uninstall the app.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.warning,
                      ),
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

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    bool highlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.warningAlpha05 : context.surfaceColor,
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(
          color: highlighted ? AppColors.warningAlpha20 : context.borderColor,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: highlighted
                  ? AppColors.warningAlpha10
                  : AppOverlays.primary10,
              borderRadius: AppRadius.smallRadius,
            ),
            child: Icon(
              icon,
              color: highlighted ? AppColors.warning : AppColors.primary,
              size: AppIconSizes.sm,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelLarge.copyWith(
                    color: highlighted ? AppColors.warning : null,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  content,
                  style: AppTypography.bodySmall.copyWith(
                    color: highlighted
                        ? AppColors.warning
                        : context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openFullTerms() async {
    // GitHub Pages URL once repo is pushed
    final Uri url = Uri.parse(
      'https://gist.github.com/tiarnanlarkin/36afa94b6fd4845761c1af28121c11e4',
    );

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // If URL launching fails, user can still read the summary above
      debugPrint('Could not launch terms URL: $e');
    }
  }

  void _showContactInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Contact Us'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'For questions about these Terms of Service:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildContactRow(
              Icons.email,
              'support@aquariumhobbyist.app',
              context,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildContactRow(
              Icons.person,
              'Developer: Tiarnan Larkin',
              context,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text, BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: AppIconSizes.xs, color: context.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(text, style: TextStyle(color: context.textSecondary)),
        ),
      ],
    );
  }
}
