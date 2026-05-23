import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../danio_bottom_dock.dart';

/// Redesigned drag handle for the bottom sheet stage panel.
///
/// Replaces the old 3px accent-coloured line with a full-width glass handle
/// that clearly signals "drag me" via:
///  - A 48dp touch target (meets Material a11y minimum)
///  - A frosted-glass background with a subtle tint from [accentColor]
///  - A centred white pill (48×5dp) with a drop shadow
///  - Three small grip notches stacked below the pill for extra affordance
class StageHandle extends StatelessWidget {
  /// Optional accent colour blended into the glass background.
  /// Defaults to fully transparent (plain frosted glass).
  final Color? accentColor;
  final DanioDockGlassStyle? glassStyle;

  const StageHandle({super.key, this.accentColor, this.glassStyle});

  @override
  Widget build(BuildContext context) {
    final tint =
        accentColor?.withValues(alpha: 0.15) ??
        AppColors.whiteAlpha18;

    return Semantics(
      label: 'Drag to resize panel',
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: glassStyle == null ? tint : null,
          gradient: glassStyle == null
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: glassStyle!.gradient,
                ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(
            top: BorderSide(
              color: glassStyle?.border ?? AppColors.whiteAlpha20,
              width: 0.5,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Main drag pill ──────────────────────────────────────────
            Container(
              width: 56,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.whiteAlpha70,
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blackAlpha25,
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                  BoxShadow(
                    color: AppColors.blackAlpha10,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),

            // ── Grip notches ────────────────────────────────────────────
            // Three short horizontal lines stacked 2dp apart, centered
            // below the pill to reinforce the "drag me" affordance.
            const SizedBox(height: 5),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return Padding(
                  padding: EdgeInsets.only(top: i == 0 ? 0 : 2),
                  child: Container(
                    width: 18,
                    height: 1.5,
                    decoration: BoxDecoration(
                      color: AppColors.whiteAlpha45,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class StageSheetNib extends StatelessWidget {
  final double width;
  final double height;
  final DanioDockGlassStyle glassStyle;

  const StageSheetNib({
    super.key,
    required this.width,
    required this.height,
    required this.glassStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Drag to resize panel',
      child: SizedBox(
        key: const ValueKey('danio-stage-sheet-nib-hit-target'),
        height: DanioBottomDock.stageSheetNibTouchHeight,
        width: double.infinity,
        child: Align(
          alignment: Alignment.topCenter,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(18),
              bottom: Radius.circular(9),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: DecoratedBox(
                key: const ValueKey('danio-stage-sheet-nib'),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: glassStyle.gradient,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                    bottom: Radius.circular(9),
                  ),
                  border: Border.all(color: glassStyle.border, width: 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: glassStyle.shadow,
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: width,
                  height: height,
                  child: Center(
                    child: Container(
                      key: const ValueKey('danio-stage-sheet-nib-grip'),
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.whiteAlpha90,
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.blackAlpha24,
                            blurRadius: 8,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
