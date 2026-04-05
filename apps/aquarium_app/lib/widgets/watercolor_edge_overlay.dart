import 'package:flutter/material.dart';

/// Paints a watercolour edge effect over a header image.
///
/// Works by layering a pre-made alpha mask (white with transparent centre)
/// on top of the content, tinted to the scaffold background colour.
/// The mask has organic paint-splatter edges so the underlying image
/// appears to bleed into watercolour washes at the boundary.
///
/// Because [ColorFiltered] with [BlendMode.srcIn] is used, a single
/// mask asset works for every theme — dark or light.
class WatercolorEdgeOverlay extends StatelessWidget {
  const WatercolorEdgeOverlay({super.key});

  static const String _maskAsset = 'assets/images/watercolor-edge-mask.png';

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return IgnorePointer(
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(bgColor, BlendMode.srcIn),
        child: Image.asset(
          _maskAsset,
          fit: BoxFit.fill,
          // Decode at a reasonable size — the mask is 800×480 source.
          cacheWidth: 800,
        ),
      ),
    );
  }
}
