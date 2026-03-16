import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/app_theme.dart';

/// Key used in SharedPreferences to persist the user's GDPR analytics consent.
const String kGdprAnalyticsConsentKey = 'gdpr_analytics_consent';

/// Applies the user's analytics consent choice to Firebase services.
///
/// Call this after reading the persisted consent value or after the user
/// makes a choice on the consent screen.
Future<void> applyAnalyticsConsent(bool accepted) async {
  try {
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(accepted);
  } catch (_) {
    // Firebase may not be initialised — safe to ignore.
  }
  try {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      accepted,
    );
  } catch (_) {
    // Firebase may not be initialised — safe to ignore.
  }
}

/// A clean Material Design screen that explains what data Danio collects and
/// lets the user accept or decline analytics/crashlytics.
class ConsentScreen extends StatelessWidget {
  const ConsentScreen({super.key, required this.onConsentGiven});

  /// Called after the user taps either button and the preference is persisted.
  final VoidCallback onConsentGiven;

  Future<void> _respond(BuildContext context, bool accepted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kGdprAnalyticsConsentKey, accepted);
    await applyAnalyticsConsent(accepted);
    onConsentGiven();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          child: Column(
            children: [
              const Spacer(),
              Icon(
                Icons.privacy_tip_outlined,
                size: 64,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Your Privacy Matters',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'We use Firebase Analytics to understand how people use '
                'Danio, and Crashlytics to fix bugs. Data is sent to '
                'Google. You can change this anytime in Settings.',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 2),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _respond(context, true),
                  child: const Text('Accept Analytics'),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _respond(context, false),
                  child: const Text('No Thanks'),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
