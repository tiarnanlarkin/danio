import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/decorative_elements.dart';
import '../../../widgets/core/app_button.dart';

class EmptyRoomScene extends StatelessWidget {
  final VoidCallback onCreateTank;
  final VoidCallback onLoadDemo;

  const EmptyRoomScene({
    super.key,
    required this.onCreateTank,
    required this.onLoadDemo,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Stack(
      children: [
        // Empty room background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [DanioColors.creamWarm, DanioColors.ivoryWhite],
            ),
          ),
        ),

        // Window — offset by status bar height to avoid overlap
        Positioned(
          top: topPadding + 16,
          right: 30,
          child: Container(
            width: 80,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE8D8C8), Color(0xFFF0E4D4)],
              ),
              border: Border.all(color: AppColors.woodBrown, width: 6),
              borderRadius: AppRadius.xsRadius,
            ),
          ),
        ),

        // Floor
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 120,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [DanioColors.studyGold, Color(0xFFC49664)],
              ),
            ),
          ),
        ),

        // Empty stand where tank should go
        Positioned(
          bottom: 100,
          left: 40,
          child: Container(
            width: 200,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [DanioColors.workshopBackground1, DanioColors.substrateSoil],
              ),
              borderRadius: AppRadius.xsRadius,
              boxShadow: [
                BoxShadow(
                  color: AppOverlays.black30,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
        ),

        // "Tank goes here" placeholder
        Positioned(
          bottom: 160,
          left: 50,
          child: Container(
            width: 180,
            height: 120,
            decoration: BoxDecoration(
              color: AppOverlays.surfaceVariant30,
              borderRadius: AppRadius.smallRadius,
              border: Border.all(
                color: AppOverlays.textHint50,
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.water_drop_outlined,
                  size: 40,
                  color: AppOverlays.textHint50,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Your aquarium adventure starts here',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textHint,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Floor plant (waiting)
        Positioned(
          bottom: 80,
          right: 20,
          child: Opacity(
            opacity: 0.5,
            child: SizedBox(
              width: 40,
              height: 80,
              child: Column(
                children: [
                  Container(
                    width: 30,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppOverlays.forestGreen50,
                      borderRadius: AppRadius.mediumRadius,
                    ),
                  ),
                  Container(
                    width: 25,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppOverlays.peru50,
                      borderRadius: AppRadius.xsRadius,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Call to action with warm first-session messaging
        Center(
          child: NotebookCard(
            rotation: 1.5,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Fish icon - warm welcome
                Icon(
                  Icons.set_meal_rounded,
                  size: AppIconSizes.xxl,
                  color: DanioColors.tealWater,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Your tank awaits 🐠',
                  style: AppTypography.headlineSmall.copyWith(
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Add your first tank to get personalised care tips and alerts',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg2),
                AppButton(
                  label: 'Add my tank',
                  onPressed: onCreateTank,
                  leadingIcon: Icons.add,
                  variant: AppButtonVariant.primary,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: 'Explore a demo tank first',
                  onPressed: onLoadDemo,
                  variant: AppButtonVariant.text,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
