import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            
            // App icon placeholder
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(Icons.water_drop, size: 50, color: Colors.white),
            ),
            
            const SizedBox(height: 24),
            
            Text('Aquarium Hobby App', style: AppTypography.headlineMedium),
            const SizedBox(height: 4),
            Text('Version 1.0.0', style: AppTypography.bodyMedium),
            
            const SizedBox(height: 32),
            
            Text(
              'Track your tanks, livestock, equipment, and maintenance in one calm, organized place.',
              style: AppTypography.bodyLarge,
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            const Divider(),
            
            const SizedBox(height: 16),
            
            _FeatureItem(
              icon: Icons.water,
              title: 'Multi-Tank Management',
              description: 'Track unlimited aquariums with individual settings',
            ),
            _FeatureItem(
              icon: Icons.science,
              title: 'Water Testing',
              description: 'Log parameters and visualize trends over time',
            ),
            _FeatureItem(
              icon: Icons.task_alt,
              title: 'Smart Reminders',
              description: 'Never miss a water change or filter maintenance',
            ),
            _FeatureItem(
              icon: Icons.pets,
              title: 'Species Database',
              description: '45+ freshwater species with care requirements',
            ),
            _FeatureItem(
              icon: Icons.shield,
              title: 'Local-First',
              description: 'Your data stays on your device',
            ),
            
            const SizedBox(height: 32),
            
            const Divider(),
            
            const SizedBox(height: 16),
            
            Text('Made with ❤️ for the fishkeeping community', 
              style: AppTypography.bodySmall),
            
            const SizedBox(height: 24),
            
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.privacy_tip_outlined, size: 18),
                  label: const Text('Privacy'),
                  onPressed: () => _showPrivacyInfo(context),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.gavel, size: 18),
                  label: const Text('Terms'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TermsOfServiceScreen(),
                    ),
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.code, size: 18),
                  label: const Text('Licenses'),
                  onPressed: () => showLicensePage(
                    context: context,
                    applicationName: 'Aquarium Hobby App',
                    applicationVersion: '1.0.0',
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  void _showPrivacyInfo(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
    );
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
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
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
