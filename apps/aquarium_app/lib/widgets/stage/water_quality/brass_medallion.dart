import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import 'water_param_card.dart';

/// Floating brass medallion used in the Water Quality "Lab View" panel.
///
/// Visual spec (concept lock 2026-04-07):
/// - Cream/ivory circular fill
/// - Brass accent ring (color modulated by [status])
/// - Drop shadow 0,2,8 black @ 25 alpha
/// - Label (top), value (big, center), unit (small, below)
class BrassMedallion extends StatelessWidget {
  static const _brass = Color(0xFFC89B3C);
  static const _cream = Color(0xFFFFF8E7);
  static const _ink = Color(0xFF2D3436);

  final String label;
  final String? value;
  final String unit;
  final WqParamStatus status;

  const BrassMedallion({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.status,
  });

  Color _ringColor() {
    switch (status) {
      case WqParamStatus.perfect:
        return _brass;
      case WqParamStatus.watch:
        return const Color(0xFFC99524);
      case WqParamStatus.danger:
        return const Color(0xFFC0392B);
      case WqParamStatus.unknown:
        return _brass.withValues(alpha: 0.4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ring = _ringColor();
    final display = value ?? '--';

    return Semantics(
      label: '$label ${wqStatusLabel(status)}',
      child: AspectRatio(
        aspectRatio: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _cream,
            shape: BoxShape.circle,
            border: Border.all(color: ring, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: _ink.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  display,
                  style: AppTypography.headlineSmall.copyWith(
                    color: _ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    letterSpacing: -0.5,
                  ),
                ),
                if (unit.isNotEmpty)
                  Text(
                    unit,
                    style: AppTypography.labelSmall.copyWith(
                      color: _ink.withValues(alpha: 0.45),
                      fontSize: 9,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
