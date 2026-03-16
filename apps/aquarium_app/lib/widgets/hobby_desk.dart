import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'hobby_items.dart';
import 'decorative_elements.dart';

/// A busy hobbyist's desk/workspace showing all aquarium items
/// Tap items to reveal their stats
class HobbyDesk extends StatelessWidget {
  final double? temperature;
  final double? ph;
  final double? ammonia;
  final double? nitrite;
  final double? nitrate;
  final List<String>? filterMedia;
  final bool filterRunning;
  final bool heaterOn;
  final bool lightOn;
  final Function(String item)? onItemTap;

  const HobbyDesk({
    super.key,
    this.temperature,
    this.ph,
    this.ammonia,
    this.nitrite,
    this.nitrate,
    this.filterMedia,
    this.filterRunning = true,
    this.heaterOn = true,
    this.lightOn = true,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        // Wooden desk surface
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppOverlays.burlyWood30, AppOverlays.tan40],
        ),
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: AppOverlays.darkGold50, width: 2),
      ),
      child: Column(
        children: [
          // Top shelf - Equipment
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Filter
              _ItemWithTooltip(
                label: 'Filter',
                child: FilterItem(
                  mediaTypes: filterMedia,
                  isRunning: filterRunning,
                  height: 75,
                  onTap: () => onItemTap?.call('filter'),
                ),
              ),

              // Heater
              _ItemWithTooltip(
                label: 'Heater',
                child: HeaterItem(
                  isOn: heaterOn,
                  height: 85,
                  onTap: () => onItemTap?.call('heater'),
                ),
              ),

              // Thermometer
              _ItemWithTooltip(
                label: '${temperature?.toStringAsFixed(1) ?? "--"}°C',
                child: ThermometerItem(
                  temperature: temperature,
                  height: 70,
                  onTap: () => onItemTap?.call('temperature'),
                ),
              ),

              // Light
              _ItemWithTooltip(
                label: 'Light',
                child: LightItem(
                  isOn: lightOn,
                  width: 70,
                  onTap: () => onItemTap?.call('light'),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Divider (desk edge)
          Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFC4A574),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: AppOverlays.black10,
                  blurRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Bottom shelf - Testing & maintenance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Test tubes
              _ItemWithTooltip(
                label: 'Water Tests',
                child: TestTubeRack(
                  ph: ph,
                  ammonia: ammonia,
                  nitrite: nitrite,
                  nitrate: nitrate,
                  width: 85,
                  onTap: () => onItemTap?.call('tests'),
                ),
              ),

              // Food jar
              _ItemWithTooltip(
                label: 'Food',
                child: FoodJarItem(
                  foodType: 'flakes',
                  fillLevel: 0.6,
                  height: 60,
                  onTap: () => onItemTap?.call('food'),
                ),
              ),

              // Net
              _ItemWithTooltip(
                label: 'Net',
                child: NetItem(size: 40, onTap: () => onItemTap?.call('net')),
              ),

              // Bucket
              _ItemWithTooltip(
                label: 'Bucket',
                child: BucketItem(
                  fillLevel: 0.0,
                  height: 50,
                  onTap: () => onItemTap?.call('bucket'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ItemWithTooltip extends StatelessWidget {
  final String label;
  final Widget child;

  const _ItemWithTooltip({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: context.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Popup detail card when tapping an item
class ItemDetailPopup extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<ItemDetailRow> rows;
  final VoidCallback? onClose;
  final Color? accentColor;

  const ItemDetailPopup({
    super.key,
    required this.title,
    required this.icon,
    required this.rows,
    this.onClose,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.primary;

    return NotebookCard(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm2),
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: AppIconSizes.sm),
                const SizedBox(width: AppSpacing.sm),
                Text(title, style: AppTypography.labelLarge),
                const Spacer(),
                if (onClose != null)
                  GestureDetector(
                    onTap: onClose,
                    child: Icon(Icons.close, size: 18, color: context.textHint),
                  ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm2),
            child: Column(
              children: rows
                  .map(
                    (row) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Text(row.label, style: AppTypography.bodySmall),
                          const Spacer(),
                          Text(
                            row.value,
                            style: AppTypography.labelLarge.copyWith(
                              color: row.color ?? context.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Data model for a label-value row in item detail displays.
///
/// Simple struct holding label text, value text, and optional color styling
/// for display in item detail lists.
class ItemDetailRow {
  final String label;
  final String value;
  final Color? color;

  const ItemDetailRow({required this.label, required this.value, this.color});
}

/// Mini tank scene that sits on a shelf
class MiniTankScene extends StatelessWidget {
  final String name;
  final double volumeLitres;
  final double? temperature;
  final VoidCallback? onTap;
  final double width;

  const MiniTankScene({
    super.key,
    required this.name,
    required this.volumeLitres,
    this.temperature,
    this.onTap,
    this.width = 160,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tank
            Container(
              width: width,
              height: width * 0.6,
              decoration: BoxDecoration(
                // Glass effect
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.accentAlpha20,
                    AppOverlays.primary30,
                    AppColors.primaryDarkAlpha40,
                  ],
                ),
                borderRadius: AppRadius.xsRadius,
                border: Border.all(color: AppOverlays.white50, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppOverlays.primary20,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Substrate
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppOverlays.darkWood60,
                            AppOverlays.deepWood80,
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(2),
                        ),
                      ),
                    ),
                  ),

                  // Simple plant shapes
                  Positioned(
                    bottom: 10,
                    left: 12,
                    child: _SimplePlant(
                      height: 30,
                      color: const Color(0xFF48BB78),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 20,
                    child: _SimplePlant(
                      height: 24,
                      color: const Color(0xFF68D391),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: width * 0.4,
                    child: _SimplePlant(
                      height: 20,
                      color: const Color(0xFF9AE6B4),
                    ),
                  ),

                  // Fish silhouettes
                  Positioned(top: 20, left: 30, child: _SimpleFish(size: 12)),
                  Positioned(
                    top: 35,
                    right: 25,
                    child: _SimpleFish(size: 10, flip: true),
                  ),

                  // Water surface shimmer
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppOverlays.white30,
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(2),
                        ),
                      ),
                    ),
                  ),

                  // Thermometer on side
                  if (temperature != null)
                    Positioned(
                      top: 8,
                      right: 6,
                      child: ThermometerItem(
                        temperature: temperature,
                        height: 35,
                      ),
                    ),
                ],
              ),
            ),

            // Shelf
            Container(
              height: 8,
              margin: const EdgeInsets.only(top: AppSpacing.xxs),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFD4A574), Color(0xFFC49A6C)],
                ),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: AppOverlays.black15,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Label
            Text(
              name,
              style: AppTypography.labelMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${volumeLitres.toStringAsFixed(0)}L',
              style: AppTypography.bodySmall.copyWith(color: context.textHint),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimplePlant extends StatelessWidget {
  final double height;
  final Color color;

  const _SimplePlant({required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(height * 0.4, height),
      painter: _SimplePlantPainter(color: color),
    );
  }
}

class _SimplePlantPainter extends CustomPainter {
  final Color color;

  _SimplePlantPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw 3 leaves
    for (var i = 0; i < 3; i++) {
      final leafPath = Path();
      final startY = size.height;
      final endY = size.height * (0.2 + i * 0.15);
      final curveX = size.width * (0.3 + i * 0.2) * (i.isEven ? 1 : -1);

      leafPath.moveTo(size.width / 2, startY);
      leafPath.quadraticBezierTo(
        size.width / 2 + curveX,
        (startY + endY) / 2,
        size.width / 2 + curveX * 0.3,
        endY,
      );
      leafPath.quadraticBezierTo(
        size.width / 2 - curveX * 0.3,
        (startY + endY) / 2,
        size.width / 2,
        startY,
      );

      canvas.drawPath(leafPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SimpleFish extends StatelessWidget {
  final double size;
  final bool flip;

  const _SimpleFish({required this.size, this.flip = false});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: flip ? -1 : 1,
      child: CustomPaint(
        size: Size(size * 1.5, size),
        painter: _SimpleFishPainter(),
      ),
    );
  }
}

class _SimpleFishPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppOverlays.orange70
      ..style = PaintingStyle.fill;

    // Body
    final bodyPath = Path()
      ..moveTo(0, size.height / 2)
      ..quadraticBezierTo(
        size.width * 0.4,
        0,
        size.width * 0.7,
        size.height / 2,
      )
      ..quadraticBezierTo(size.width * 0.4, size.height, 0, size.height / 2);

    canvas.drawPath(bodyPath, paint);

    // Tail
    final tailPath = Path()
      ..moveTo(size.width * 0.65, size.height / 2)
      ..lineTo(size.width, size.height * 0.2)
      ..lineTo(size.width, size.height * 0.8)
      ..close();

    canvas.drawPath(tailPath, paint);

    // Eye
    canvas.drawCircle(
      Offset(size.width * 0.25, size.height * 0.4),
      size.width * 0.06,
      Paint()..color = Colors.black,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
