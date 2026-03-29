import 'package:flutter/material.dart';

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

  const StageHandle({super.key, this.accentColor});

  @override
  Widget build(BuildContext context) {
    final tint = accentColor?.withValues(alpha: 0.15) ??
        Colors.white.withValues(alpha: 0.18);

    return Semantics(
      label: 'Drag to resize panel',
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: tint,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.20),
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
                color: Colors.white.withValues(alpha: 0.70),
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
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
                      color: Colors.white.withValues(alpha: 0.45),
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
