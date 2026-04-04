import 'package:flutter/material.dart';
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
                TextButton(
                  onPressed: () => launchUrl(
                    Uri.parse(
                      'https://tiarnanlarkin.github.io/danio-legal/privacy/',
                    ),
                  ),
                  child: const Text('Privacy Policy'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
