import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Comeback banner shown when a returning user's streak has been broken.
/// Displays a personalised message referencing the user's fish.
class ComebackBanner extends StatelessWidget {
  final String? userName;
  final String? fishSpeciesName;
  final VoidCallback onDismiss;

  const ComebackBanner({
    super.key,
    required this.userName,
    required this.fishSpeciesName,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + AppSpacing.md,
      left: AppSpacing.md,
      right: AppSpacing.md,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm2,
          ),
          decoration: BoxDecoration(
            color: AppColors.warning.withAlpha(38),
            border: Border.all(color: AppColors.warning.withAlpha(76)),
            borderRadius: AppRadius.mediumRadius,
            boxShadow: [
              BoxShadow(
                color: AppColors.blackAlpha08,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Text('🐠', style: TextStyle(fontSize: 20)),
              const SizedBox(width: AppSpacing.sm2),
              Expanded(
                child: Text(
                  fishSpeciesName != null
                      ? 'Welcome back, ${userName ?? ""}${userName != null ? "! " : ""}How\'s your $fishSpeciesName doing? 🌿'
                      : userName != null
                          ? 'Welcome back, $userName! Your fish missed you 🌿'
                          : 'Welcome back! Your fish missed you 🌿',
                  style: AppTypography.labelLarge.copyWith(
                    color: context.textPrimary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                color: context.textSecondary,
                tooltip: 'Dismiss welcome banner',
                onPressed: onDismiss,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
