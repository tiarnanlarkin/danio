import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Welcome banner shown on first app open.
/// Displays a personalised greeting with the user's name.
class WelcomeBanner extends StatelessWidget {
  final String? userName;
  final bool visible;
  final VoidCallback onDismiss;

  const WelcomeBanner({
    super.key,
    required this.userName,
    required this.visible,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + AppSpacing.md,
      left: AppSpacing.md,
      right: AppSpacing.md,
      child: Semantics(
        label: 'Dismiss welcome banner',
        button: true,
        child: GestureDetector(
        onTap: onDismiss,
        child: AnimatedOpacity(
          opacity: visible ? 1.0 : 0.0,
          duration: AppDurations.long2,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppRadius.mediumRadius,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(60),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text(
                    '\u{1F420}',
                    style: TextStyle(fontSize: 28),
                  ),
                  const SizedBox(width: AppSpacing.sm2),
                  Expanded(
                    child: Text(
                      userName != null
                          ? 'Welcome, $userName! Your aquarium journey starts now'
                          : 'Welcome! Your aquarium journey starts now',
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }
}
