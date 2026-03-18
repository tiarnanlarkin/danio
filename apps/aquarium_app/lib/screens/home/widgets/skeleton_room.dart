import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/fun_loading_messages.dart';

/// Skeleton loading state shown while tanks are loading.
class SkeletonRoom extends StatelessWidget {
  const SkeletonRoom({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Skeletonizer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.backgroundDark : null,
                gradient: isDark
                    ? null
                    : LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppOverlays.surfaceVariant50, context.surfaceVariant],
                      ),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 200,
              height: 150,
              decoration: BoxDecoration(
                color: AppOverlays.primary10,
                borderRadius: AppRadius.mediumRadius,
                border: Border.all(color: AppOverlays.primary30),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.water, size: AppIconSizes.xl, color: AppColors.primary),
                  SizedBox(height: AppSpacing.sm),
                  FunLoadingMessage(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
