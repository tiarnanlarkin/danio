import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/app_theme.dart';
import '../../utils/logger.dart';
import '../../widgets/core/app_button.dart';

/// Key used in SharedPreferences to persist the user's GDPR analytics consent.
const String kGdprAnalyticsConsentKey = 'gdpr_analytics_consent';

/// Applies the user's analytics consent choice to Firebase services.
///
/// Call this after reading the persisted consent value or after the user
/// makes a choice on the consent screen.
Future<void> applyAnalyticsConsent(bool accepted) async {
  try {
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(accepted);
  } catch (e) {
    // Firebase may not be initialised — safe to ignore.
    appLog('ConsentScreen: Firebase Analytics not available: $e', tag: 'ConsentScreen');
  }
  try {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      accepted,
    );
  } catch (e) {
    // Firebase may not be initialised — safe to ignore.
    appLog('ConsentScreen: Firebase Crashlytics not available: $e', tag: 'ConsentScreen');
  }
}

/// A clean Material Design screen that explains what data Danio collects and
/// lets the user accept or decline analytics/crashlytics.
///
/// Also collects age confirmation (REQUIRED R3) and ToS acceptance (REQUIRED
/// R6) before allowing the user to proceed.
class ConsentScreen extends ConsumerStatefulWidget {
  const ConsentScreen({super.key, required this.onConsentGiven});

  /// Called after the user taps either button and the preference is persisted.
  final VoidCallback onConsentGiven;

  @override
  ConsumerState<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends ConsumerState<ConsentScreen> {
  bool _ageConfirmed = false;
  bool _tosAccepted = false;

  Future<void> _respond(bool accepted) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool(kGdprAnalyticsConsentKey, accepted);
    await prefs.setBool('tos_accepted', true);
    await applyAnalyticsConsent(accepted);
    widget.onConsentGiven();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool canProceed = _ageConfirmed && _tosAccepted;

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
              Semantics(
                label: 'Privacy icon',
                child: Icon(
                  Icons.privacy_tip_outlined,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Semantics(
                header: true,
                child: Text(
                  'Your Privacy Matters',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'We use Firebase Analytics to understand how people use '
                'Danio, and Crashlytics to fix bugs. Data is sent to '
                'Google. You can change this anytime in Settings.',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Age confirmation checkbox (REQUIRED R3) ──────────────
              Semantics(
                label: 'Age confirmation checkbox',
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  onTap: () => setState(() => _ageConfirmed = !_ageConfirmed),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: _ageConfirmed,
                          onChanged: (v) =>
                              setState(() => _ageConfirmed = v ?? false),
                          activeColor: AppColors.primary,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'I confirm I am 13 years of age or older',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xs),

              // ── "I'm under 13" link (COPPA blocking path) ───────────────
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      barrierDismissible: false,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Age Requirement'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Danio requires users to be 13 or older. '
                              'Ask a parent or guardian to set up your account.',
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextButton(
                              onPressed: () => _launchUrl(
                                'https://tiarnanlarkin.github.io/danio/privacy-policy.html',
                              ),
                              child: const Text('View Privacy Policy'),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(
                    "I'm under 13",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textHint,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xs),

              // ── ToS & Privacy Policy acceptance checkbox (REQUIRED R6) ──
              Semantics(
                label: 'Terms of Service and Privacy Policy acceptance checkbox',
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  onTap: () => setState(() => _tosAccepted = !_tosAccepted),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: _tosAccepted,
                          onChanged: (v) =>
                              setState(() => _tosAccepted = v ?? false),
                          activeColor: AppColors.primary,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: theme.textTheme.bodyMedium,
                              children: [
                                const TextSpan(
                                  text: 'I have read and agree to the ',
                                ),
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => _launchUrl(
                                          'https://tiarnanlarkin.github.io/danio/terms-of-service.html',
                                        ),
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => _launchUrl(
                                          'https://tiarnanlarkin.github.io/danio/privacy-policy.html',
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 2),

              AppButton(
                label: 'Accept Analytics',
                onPressed: canProceed ? () => _respond(true) : null,
                variant: AppButtonVariant.primary,
                isFullWidth: true,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: 'No Thanks',
                onPressed: canProceed ? () => _respond(false) : null,
                variant: AppButtonVariant.secondary,
                isFullWidth: true,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
