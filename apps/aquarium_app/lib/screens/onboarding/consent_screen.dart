import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/user_profile_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/logger.dart';
import '../../widgets/core/app_button.dart';
import '../../widgets/danio_snack_bar.dart';
import 'age_blocked_screen.dart';

/// Key used in SharedPreferences to persist the user's diagnostics consent.
/// The stored key name is kept for backward compatibility with existing installs.
const String kGdprAnalyticsConsentKey = 'gdpr_analytics_consent';

/// Applies the user's diagnostics consent choice to Firebase services.
///
/// Call this after reading the persisted consent value or after the user
/// makes a choice on the consent screen.
Future<void> applyAnalyticsConsent(bool accepted) async {
  // firebase_analytics removed; Crashlytics reporting is toggled below.
  appLog('ConsentScreen: diagnostics consent=$accepted', tag: 'ConsentScreen');
  try {
    if (accepted && Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
    if (Firebase.apps.isEmpty) return;
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      accepted,
    );
  } catch (e) {
    // Firebase may not be initialised; safe to ignore.
    appLog(
      'ConsentScreen: Firebase Crashlytics not available: $e',
      tag: 'ConsentScreen',
    );
  }
}

/// Explains diagnostics data and collects age/TOS consent before onboarding.
class ConsentScreen extends ConsumerStatefulWidget {
  const ConsentScreen({super.key, required this.onConsentGiven});

  /// Called after the user taps either button and the preference is persisted.
  final VoidCallback onConsentGiven;

  @override
  ConsumerState<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends ConsumerState<ConsentScreen> {
  static const double _maxContentWidth = 720;
  static const String _saveFailureMessage =
      "Couldn't save your choice. Please try again.";

  bool _ageConfirmed = false;
  bool _tosAccepted = false;

  bool get _canProceed => _ageConfirmed && _tosAccepted;

  void _toggleAgeConfirmed() {
    setState(() => _ageConfirmed = !_ageConfirmed);
  }

  void _toggleTosAccepted() {
    setState(() => _tosAccepted = !_tosAccepted);
  }

  Future<void> _respond(bool accepted) async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final consentSaved = await prefs.setBool(
        kGdprAnalyticsConsentKey,
        accepted,
      );
      if (!consentSaved) {
        throw StateError('Consent preference write returned false.');
      }

      final tosSaved = await prefs.setBool('tos_accepted', true);
      if (!tosSaved) {
        throw StateError('TOS preference write returned false.');
      }
    } catch (e) {
      appLog(
        'ConsentScreen: failed to persist consent: $e',
        tag: 'ConsentScreen',
      );
      if (mounted) DanioSnackBar.error(context, _saveFailureMessage);
      return;
    }

    if (!mounted) return;
    unawaited(applyAnalyticsConsent(accepted));
    widget.onConsentGiven();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _blockUnder13() async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final saved = await prefs.setBool('under_13_blocked', true);
      if (!saved) {
        throw StateError('Under-13 block preference write returned false.');
      }
    } catch (e) {
      appLog(
        'ConsentScreen: failed to persist under-13 block: $e',
        tag: 'ConsentScreen',
      );
      if (mounted) DanioSnackBar.error(context, _saveFailureMessage);
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const AgeBlockedScreen()),
      (_) => false,
    );
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
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
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
                    'Crash reports help us fix bugs and keep Danio stable. '
                    'They do not include your tank records, photos, or learning '
                    'progress. You can change your mind anytime in Settings.',
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _ConsentCheckboxRow(
                    semanticsLabel: 'Age confirmation checkbox',
                    checked: _ageConfirmed,
                    onTap: _toggleAgeConfirmed,
                    checkbox: Checkbox(
                      value: _ageConfirmed,
                      onChanged: (value) =>
                          setState(() => _ageConfirmed = value ?? false),
                      activeColor: AppColors.primary,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'I confirm I am 13 years of age or older',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                        ),
                        minimumSize: const Size(48, 48),
                        tapTargetSize: MaterialTapTargetSize.padded,
                      ),
                      onPressed: _blockUnder13,
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
                  _ConsentCheckboxRow(
                    semanticsLabel:
                        'Terms of Service and Privacy Policy acceptance checkbox',
                    checked: _tosAccepted,
                    onTap: _toggleTosAccepted,
                    checkbox: Checkbox(
                      value: _tosAccepted,
                      onChanged: (value) =>
                          setState(() => _tosAccepted = value ?? false),
                      activeColor: AppColors.primary,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
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
                  const Spacer(flex: 2),
                  AppButton(
                    label: 'Share Crash Reports',
                    onPressed: _canProceed ? () => _respond(true) : null,
                    variant: AppButtonVariant.primary,
                    isFullWidth: true,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    label: 'No Thanks',
                    onPressed: _canProceed ? () => _respond(false) : null,
                    variant: AppButtonVariant.secondary,
                    isFullWidth: true,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConsentCheckboxRow extends StatelessWidget {
  const _ConsentCheckboxRow({
    required this.semanticsLabel,
    required this.checked,
    required this.onTap,
    required this.checkbox,
    required this.child,
  });

  final String semanticsLabel;
  final bool checked;
  final VoidCallback onTap;
  final Widget checkbox;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      checked: checked,
      button: true,
      onTap: onTap,
      child: ExcludeSemantics(
        child: InkWell(
          borderRadius: AppRadius.smallRadius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                checkbox,
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
