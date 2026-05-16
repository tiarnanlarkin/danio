import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';

/// Hard-block screen for users under 13 (COPPA compliance).
///
/// Once the user taps "I'm under 13" on the consent screen, the nav stack is
/// cleared and this screen is shown permanently.  There is no back button and
/// no way to proceed — the app is effectively locked for this install.
class AgeBlockedScreen extends StatelessWidget {
  const AgeBlockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Age Requirement',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Danio requires users to be 13 or older. Please ask a parent or guardian to help you set up an account.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton.icon(
                  onPressed: () => SystemNavigator.pop(),
                  icon: const Icon(Icons.close),
                  label: const Text('Close Danio'),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton.icon(
                  onPressed: () async {
                    await launchUrl(
                      Uri.parse(
                        'https://tiarnanlarkin.github.io/danio/privacy-policy.html',
                      ),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                  icon: const Icon(Icons.privacy_tip_outlined),
                  label: const Text('Privacy Policy'),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'If this was selected by mistake, ask a parent or guardian to reinstall and complete setup with you.',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: context.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
