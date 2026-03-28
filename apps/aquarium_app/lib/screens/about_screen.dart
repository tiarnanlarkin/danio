import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';
import '../utils/navigation_throttle.dart';
import '../widgets/core/app_button.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.lg),

            // App icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: AppRadius.largeRadius,
                boxShadow: [
                  BoxShadow(
                    color: AppOverlays.primary30,
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ExcludeSemantics(
                child: ClipRRect(
                  borderRadius: AppRadius.largeRadius,
                  child: Image.asset(
                    'assets/icons/app_icon.png',
                    width: 100,
                    height: 100,
                    cacheWidth: 200,
                    cacheHeight: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                    ),
                    child: const Icon(
                      Icons.water_drop,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            Text('Danio', style: AppTypography.headlineMedium),
            const SizedBox(height: AppSpacing.xs),
            Text('Version 1.0.0', style: AppTypography.bodyMedium),

            const SizedBox(height: AppSpacing.xl),

            Text(
              'Duolingo for Fishkeeping. Learn, track, and master the aquarium hobby - one lesson at a time. 🐟',
              style: AppTypography.bodyLarge,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.xl),

            const Divider(),

            const SizedBox(height: AppSpacing.md),

            const _FeatureItem(
              icon: Icons.water,
              title: 'Multi-Tank Management',
              description: 'Track unlimited aquariums with individual settings',
            ),
            const _FeatureItem(
              icon: Icons.science,
              title: 'Water Testing',
              description: 'Log parameters and visualize trends over time',
            ),
            const _FeatureItem(
              icon: Icons.task_alt,
              title: 'Smart Reminders',
              description: 'Never miss a water change or filter maintenance',
            ),
            const _FeatureItem(
              icon: Icons.set_meal,
              title: 'Species Database',
              description: '120+ freshwater species with care requirements',
            ),
            const _FeatureItem(
              icon: Icons.shield,
              title: 'Local-First',
              description: 'Your data stays on your device',
            ),

            const SizedBox(height: AppSpacing.xl),

            const Divider(),

            const SizedBox(height: AppSpacing.md),

            Text(
              'Made with ❤️ for the fishkeeping community',
              style: AppTypography.bodySmall,
            ),

            const SizedBox(height: AppSpacing.lg),

            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                AppButton(
                  label: 'Privacy',
                  leadingIcon: Icons.privacy_tip_outlined,
                  onPressed: () => _showPrivacyInfo(context),
                  variant: AppButtonVariant.text,
                ),
                AppButton(
                  label: 'Terms',
                  leadingIcon: Icons.gavel,
                  onPressed: () => NavigationThrottle.push(
                    context,
                    const TermsOfServiceScreen(),
                  ),
                  variant: AppButtonVariant.text,
                ),
                AppButton(
                  label: 'Licenses',
                  leadingIcon: Icons.code,
                  onPressed: () => showLicensePage(
                    context: context,
                    applicationName: 'Danio',
                    applicationVersion: '1.0.0',
                  ),
                  variant: AppButtonVariant.text,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  void _showPrivacyInfo(BuildContext context) {
    NavigationThrottle.push(context, const PrivacyPolicyScreen());
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppOverlays.primary10,
              borderRadius: AppRadius.smallRadius,
            ),
            child: Icon(icon, color: AppColors.primary, size: AppIconSizes.sm),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.labelLarge),
                Text(description, style: AppTypography.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
