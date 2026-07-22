import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

class DanioDockGlassStyle {
  final Color border;
  final List<Color> gradient;
  final Color shadow;

  const DanioDockGlassStyle({
    required this.border,
    required this.gradient,
    required this.shadow,
  });
}

class DanioBottomDock extends StatelessWidget {
  static const double height = 86;
  static const double sheetOverlap = 18;
  static const double contentClearance = height + 24;

  static const double _railHeight = 74;
  static const double _railHorizontalMargin = 12;
  static const double _railBottomMargin = 6;
  static const double railHeight = _railHeight;
  static const double railHorizontalMargin = _railHorizontalMargin;
  static const double stageSheetNibHeight = 22;
  static const double stageSheetNibTouchHeight = 44;
  static const double stageSheetNibPreferredWidth = 176;

  static double railWidthFor(double screenWidth) {
    return math.max(0, screenWidth - (railHorizontalMargin * 2));
  }

  static double straightSheetWidthFor(double screenWidth) {
    return math.max(0, railWidthFor(screenWidth) - railHeight);
  }

  static double stageSheetNibWidthFor(double screenWidth) {
    return math.min(
      straightSheetWidthFor(screenWidth),
      stageSheetNibPreferredWidth,
    );
  }

  static DanioDockGlassStyle glassStyleFor(
    BuildContext context, {
    bool attached = false,
  }) {
    final palette = _DockPalette.resolve(
      isDark: Theme.of(context).brightness == Brightness.dark,
      attached: attached,
    );
    return palette.glassStyle;
  }

  final int selectedIndex;
  final int dueCardsCount;
  final bool attachedToStageSheet;
  final ValueChanged<int> onDestinationSelected;

  const DanioBottomDock({
    super.key,
    required this.selectedIndex,
    required this.dueCardsCount,
    required this.attachedToStageSheet,
    required this.onDestinationSelected,
  });

  static const _destinations = <_DockDestination>[
    _DockDestination('learn', 'Learn', _DockGlyph.learn),
    _DockDestination('practice', 'Practice', _DockGlyph.practice),
    _DockDestination('tank', 'Tank', _DockGlyph.tank),
    _DockDestination('smart', 'Smart', _DockGlyph.smart),
    _DockDestination('more', 'More', _DockGlyph.more),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = _DockPalette.resolve(
      isDark: isDark,
      attached: attachedToStageSheet,
    );
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return KeyedSubtree(
      key: const ValueKey('danio-bottom-dock'),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        key: const ValueKey('danio-bottom-dock-system-ui'),
        value: SystemUiOverlayStyle(
          systemNavigationBarColor: context.backgroundColor,
          systemNavigationBarDividerColor: Colors.transparent,
          systemNavigationBarIconBrightness: isDark
              ? Brightness.light
              : Brightness.dark,
        ),
        child: SizedBox(
          height: height + bottomInset,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Positioned.fill(
                key: const ValueKey('danio-bottom-dock-content-shield'),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        context.backgroundColor.withValues(alpha: 0),
                        context.backgroundColor.withValues(alpha: 0.96),
                        context.backgroundColor,
                      ],
                      stops: const [0, 0.42, 1],
                    ),
                  ),
                ),
              ),
              if (attachedToStageSheet)
                const Positioned.fill(
                  child: KeyedSubtree(
                    key: ValueKey('danio-bottom-dock-attached'),
                    child: SizedBox.expand(),
                  ),
                ),
              Positioned(
                left: _railHorizontalMargin,
                right: _railHorizontalMargin,
                bottom: bottomInset + _railBottomMargin,
                height: _railHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    KeyedSubtree(
                      key: const ValueKey('danio-bottom-dock-floating-rail'),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(38),
                          boxShadow: [
                            BoxShadow(
                              color: palette.railShadow,
                              blurRadius: 26,
                              spreadRadius: 1,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(38),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: palette.railGradient,
                              ),
                              borderRadius: BorderRadius.circular(38),
                              border: Border.all(color: palette.railBorder),
                            ),
                            child: Row(
                              children: [
                                for (var i = 0; i < _destinations.length; i++)
                                  Expanded(
                                    child: _DockItem(
                                      destination: _destinations[i],
                                      index: i,
                                      isSelected: selectedIndex == i,
                                      dueCardsCount: i == 1 ? dueCardsCount : 0,
                                      palette: palette,
                                      onTap: () => onDestinationSelected(i),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  final _DockDestination destination;
  final int index;
  final bool isSelected;
  final int dueCardsCount;
  final _DockPalette palette;
  final VoidCallback onTap;

  const _DockItem({
    required this.destination,
    required this.index,
    required this.isSelected,
    required this.dueCardsCount,
    required this.palette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final glyphColor = isSelected ? palette.selectedGlyph : palette.glyph;
    final socketSize = isSelected ? 64.0 : 58.0;
    final badgeText = dueCardsCount > 99 ? '99+' : '$dueCardsCount';

    return Semantics(
      label: '${destination.label} Tab ${index + 1} of 5',
      selected: isSelected,
      button: true,
      child: Tooltip(
        message: '${destination.label} tab',
        child: GestureDetector(
          key: ValueKey('danio-bottom-dock-item-${destination.id}'),
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Center(
            child: KeyedSubtree(
              key: isSelected
                  ? ValueKey(
                      'danio-bottom-dock-item-${destination.id}-selected',
                    )
                  : ValueKey('danio-bottom-dock-item-${destination.id}-idle'),
              child: SizedBox.square(
                dimension: 72,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    if (isSelected)
                      KeyedSubtree(
                        key: ValueKey(
                          'danio-bottom-dock-item-${destination.id}-glow',
                        ),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                palette.selectedCoreGlow,
                                palette.selectedGlow.withValues(alpha: 0.22),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.48, 1.0],
                            ),
                          ),
                          child: const SizedBox.square(dimension: 70),
                        ),
                      ),
                    AnimatedContainer(
                      duration: AppDurations.medium2,
                      curve: AppCurves.standardDecelerate,
                      width: socketSize,
                      height: socketSize,
                      child: CustomPaint(
                        painter: _RecessedSocketPainter(
                          palette: palette,
                          isSelected: isSelected,
                        ),
                      ),
                    ),
                    ExcludeSemantics(
                      child: AnimatedScale(
                        scale: isSelected ? 1.04 : 0.96,
                        duration: AppDurations.medium2,
                        curve: AppCurves.standardDecelerate,
                        child: SizedBox.square(
                          dimension: destination.glyph == _DockGlyph.tank
                              ? 36
                              : 32,
                          child: CustomPaint(
                            painter: _DockGlyphPainter(
                              glyph: destination.glyph,
                              color: glyphColor,
                              cutoutColor: palette.socketCutout,
                              shadowColor: palette.iconShadow,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (dueCardsCount > 0)
                      Positioned(
                        key: ValueKey(
                          'danio-bottom-dock-badge-${destination.id}',
                        ),
                        top: 4,
                        right: 6,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: palette.badgeBackground,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: palette.badgeBorder),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            child: Text(
                              badgeText,
                              style: AppTypography.labelSmall.copyWith(
                                color: palette.badgeForeground,
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                              ),
                            ),
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

class _DockDestination {
  final String id;
  final String label;
  final _DockGlyph glyph;

  const _DockDestination(this.id, this.label, this.glyph);
}

enum _DockGlyph { learn, practice, tank, smart, more }

class _DockPalette {
  final Color railBorder;
  final List<Color> railGradient;
  final Color railShadow;
  final Color socketAmbient;
  final Color socketOuter;
  final Color socketCenter;
  final Color socketSelectedCenter;
  final Color socketInnerShadow;
  final Color socketHighlight;
  final Color socketDepth;
  final Color socketCutout;
  final Color selectedGlow;
  final Color selectedCoreGlow;
  final Color selectedRing;
  final Color glyph;
  final Color selectedGlyph;
  final Color iconShadow;
  final Color badgeBackground;
  final Color badgeForeground;
  final Color badgeBorder;

  const _DockPalette({
    required this.railBorder,
    required this.railGradient,
    required this.railShadow,
    required this.socketAmbient,
    required this.socketOuter,
    required this.socketCenter,
    required this.socketSelectedCenter,
    required this.socketInnerShadow,
    required this.socketHighlight,
    required this.socketDepth,
    required this.socketCutout,
    required this.selectedGlow,
    required this.selectedCoreGlow,
    required this.selectedRing,
    required this.glyph,
    required this.selectedGlyph,
    required this.iconShadow,
    required this.badgeBackground,
    required this.badgeForeground,
    required this.badgeBorder,
  });

  factory _DockPalette.resolve({required bool isDark, required bool attached}) {
    if (isDark) {
      return _DockPalette(
        railBorder: AppColors.whiteAlpha15,
        railGradient: const [Color(0xE6202B2E), Color(0xF2090F10)],
        railShadow: AppColors.blackAlpha60,
        socketAmbient: AppColors.blackAlpha80,
        socketOuter: const Color(0xFF1A2325),
        socketCenter: const Color(0xFF070B0C),
        socketSelectedCenter: const Color(0xFF0E3338),
        socketInnerShadow: AppColors.blackAlpha85,
        socketHighlight: AppColors.whiteAlpha15,
        socketDepth: AppColors.blackAlpha90,
        socketCutout: const Color(0xFF060A0B),
        selectedGlow: const Color(0x665B9EA6),
        selectedCoreGlow: const Color(0x805B9EA6),
        selectedRing: AppColors.whiteAlpha60,
        glyph: AppColors.whiteAlpha85,
        selectedGlyph: AppColors.textPrimaryDark,
        iconShadow: AppColors.blackAlpha70,
        badgeBackground: AppColors.textPrimaryDark,
        badgeForeground: AppColors.backgroundDark,
        badgeBorder: AppColors.whiteAlpha40,
      );
    }

    return _DockPalette(
      railBorder: AppColors.whiteAlpha90,
      railGradient: const [Color(0xF9FFFFFF), Color(0xF4FFF7EA)],
      railShadow: AppColors.blackAlpha12,
      socketAmbient: AppColors.blackAlpha15,
      socketOuter: const Color(0xFFE9F1ED),
      socketCenter: const Color(0xFFD8E5E1),
      socketSelectedCenter: const Color(0xFFCBEDE7),
      socketInnerShadow: AppColors.blackAlpha30,
      socketHighlight: AppColors.whiteAlpha95,
      socketDepth: AppColors.blackAlpha30,
      socketCutout: const Color(0xFFDCE8E4),
      selectedGlow: const Color(0x665B9EA6),
      selectedCoreGlow: const Color(0x995B9EA6),
      selectedRing: AppColors.whiteAlpha95,
      glyph: AppColors.textSecondary,
      selectedGlyph: AppColors.textPrimary,
      iconShadow: AppColors.blackAlpha20,
      badgeBackground: AppColors.textPrimary,
      badgeForeground: AppColors.surface,
      badgeBorder: AppColors.whiteAlpha95,
    );
  }

  DanioDockGlassStyle get glassStyle => DanioDockGlassStyle(
    border: railBorder,
    gradient: railGradient,
    shadow: railShadow,
  );
}

class _RecessedSocketPainter extends CustomPainter {
  final _DockPalette palette;
  final bool isSelected;

  const _RecessedSocketPainter({
    required this.palette,
    required this.isSelected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 3;
    final lipRadius = radius;
    final basinRadius = radius - 6;

    canvas.drawCircle(
      center,
      lipRadius + 4,
      Paint()
        ..color = palette.socketAmbient
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    if (isSelected) {
      canvas.drawCircle(
        center,
        lipRadius + 7,
        Paint()
          ..color = palette.selectedGlow
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
      );
    }

    canvas.drawCircle(
      center,
      lipRadius,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            palette.socketHighlight,
            palette.socketOuter,
            palette.socketDepth,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: lipRadius)),
    );

    canvas.drawCircle(
      center,
      basinRadius + 2,
      Paint()
        ..color = palette.socketInnerShadow
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    final basinRect = Rect.fromCircle(center: center, radius: basinRadius);
    canvas.drawCircle(
      center,
      basinRadius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.22, 0.28),
          radius: 0.98,
          colors: [
            isSelected ? palette.socketSelectedCenter : palette.socketCenter,
            isSelected
                ? Color.lerp(
                    palette.socketSelectedCenter,
                    palette.socketOuter,
                    0.42,
                  )!
                : Color.lerp(palette.socketCenter, palette.socketOuter, 0.34)!,
            Color.lerp(palette.socketOuter, palette.socketDepth, 0.18)!,
          ],
          stops: const [0.0, 0.66, 1.0],
        ).createShader(basinRect),
    );

    canvas.drawCircle(
      center,
      basinRadius + 1,
      Paint()
        ..color = palette.socketInnerShadow
        ..strokeWidth = 3.8
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.4),
    );

    canvas.drawCircle(
      center,
      basinRadius + 0.5,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            palette.socketHighlight.withValues(alpha: 0.52),
            Colors.transparent,
            palette.socketDepth.withValues(alpha: 0.72),
          ],
          stops: const [0.0, 0.46, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: basinRadius))
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke,
    );

    canvas.drawCircle(
      center,
      lipRadius - 0.8,
      Paint()
        ..color = palette.socketHighlight.withValues(alpha: 0.34)
        ..strokeWidth = 0.9
        ..style = PaintingStyle.stroke,
    );

    if (isSelected) {
      canvas.drawCircle(
        center,
        basinRadius + 2,
        Paint()
          ..color = palette.selectedRing
          ..strokeWidth = 1.4
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RecessedSocketPainter oldDelegate) {
    return oldDelegate.palette != palette ||
        oldDelegate.isSelected != isSelected;
  }
}

class _DockGlyphPainter extends CustomPainter {
  final _DockGlyph glyph;
  final Color color;
  final Color cutoutColor;
  final Color shadowColor;

  const _DockGlyphPainter({
    required this.glyph,
    required this.color,
    required this.cutoutColor,
    required this.shadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 48, size.height / 48);

    final ink = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeJoin = StrokeJoin.round;
    final cut = Paint()
      ..color = cutoutColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final shadow = Paint()
      ..color = shadowColor
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

    switch (glyph) {
      case _DockGlyph.learn:
        _drawLearn(canvas, ink, cut, shadow);
      case _DockGlyph.practice:
        _drawPractice(canvas, ink, cut, shadow);
      case _DockGlyph.tank:
        _drawTank(canvas, ink, cut, shadow);
      case _DockGlyph.smart:
        _drawSmart(canvas, ink, cut, shadow);
      case _DockGlyph.more:
        _drawMore(canvas, ink, cut, shadow);
    }

    canvas.restore();
  }

  void _drawLearn(Canvas canvas, Paint ink, Paint cut, Paint shadow) {
    final bulb = Path()
      ..addOval(const Rect.fromLTWH(13, 7, 22, 24))
      ..moveTo(17, 27)
      ..quadraticBezierTo(19, 34, 21, 36)
      ..lineTo(27, 36)
      ..quadraticBezierTo(29, 34, 31, 27)
      ..close();
    _fill(canvas, bulb, ink, shadow);
    _fill(
      canvas,
      _roundedRectPath(const Rect.fromLTWH(18, 36, 12, 4), 1),
      ink,
      shadow,
    );
    _fill(
      canvas,
      _roundedRectPath(const Rect.fromLTWH(20, 41, 8, 3), 1),
      ink,
      shadow,
    );

    cut.strokeWidth = 3;
    canvas.drawPath(
      Path()
        ..moveTo(19, 22)
        ..quadraticBezierTo(22, 18, 27, 18),
      cut,
    );
  }

  void _drawPractice(Canvas canvas, Paint ink, Paint cut, Paint shadow) {
    final body = Path()
      ..moveTo(11, 35)
      ..lineTo(31.5, 14.5)
      ..lineTo(39, 22)
      ..lineTo(18.5, 42.5)
      ..lineTo(10, 44)
      ..close();
    _fill(canvas, body, ink, shadow);
    _fill(
      canvas,
      Path()
        ..moveTo(34, 9)
        ..quadraticBezierTo(36.5, 6.5, 39, 9)
        ..lineTo(42, 12)
        ..quadraticBezierTo(44.5, 14.5, 42, 17)
        ..lineTo(39.5, 19.5)
        ..lineTo(31.5, 11.5)
        ..close(),
      ink,
      shadow,
    );
    cut.strokeWidth = 2.4;
    canvas.drawLine(const Offset(15, 35), const Offset(19, 39), cut);
    canvas.drawLine(const Offset(28, 17), const Offset(36, 25), cut);
  }

  void _drawTank(Canvas canvas, Paint ink, Paint cut, Paint shadow) {
    final fish = Path()
      ..moveTo(7, 27)
      ..cubicTo(11, 18, 19, 14, 29, 15)
      ..cubicTo(39, 16, 45, 22, 44, 29)
      ..cubicTo(43, 36, 35, 40, 25, 39)
      ..cubicTo(16, 38, 10, 34, 7, 27)
      ..close();
    final tail = Path()
      ..moveTo(7.5, 27)
      ..cubicTo(4, 20, 1, 17, -1, 18)
      ..lineTo(1.5, 27)
      ..lineTo(-1, 36)
      ..cubicTo(2, 37, 5, 34, 7.5, 27)
      ..close();
    final topFin = Path()
      ..moveTo(20, 17)
      ..cubicTo(22, 7, 31, 6, 35, 15)
      ..cubicTo(30, 15, 25, 16, 20, 17)
      ..close();
    final lowerFin = Path()
      ..moveTo(24, 38)
      ..cubicTo(20, 43, 21, 47, 27, 45)
      ..cubicTo(31, 43, 33, 40, 34, 37)
      ..close();
    final sideFin = Path()
      ..moveTo(20, 31)
      ..cubicTo(16, 33, 15, 37, 19, 38)
      ..cubicTo(24, 38, 28, 34, 30, 31)
      ..close();

    for (final path in [tail, topFin, lowerFin, sideFin, fish]) {
      _fill(canvas, path, ink, shadow);
    }

    cut.strokeWidth = 3.1;
    canvas.drawPath(
      Path()
        ..moveTo(12, 25)
        ..cubicTo(18, 29, 25, 31, 34, 31),
      cut,
    );
    canvas.drawPath(
      Path()
        ..moveTo(15, 19)
        ..cubicTo(21, 23, 28, 24, 36, 23),
      cut,
    );
    canvas.drawPath(
      Path()
        ..moveTo(17, 34)
        ..cubicTo(22, 36, 29, 37, 36, 35),
      cut,
    );
    cut.strokeWidth = 2.4;
    canvas.drawPath(
      Path()
        ..moveTo(36, 32)
        ..quadraticBezierTo(39, 35, 42, 31),
      cut,
    );

    final eyeCut = Paint()..color = cutoutColor;
    canvas.drawCircle(const Offset(37, 25), 4.2, eyeCut);
    canvas.drawCircle(const Offset(38.1, 24.2), 1.7, ink);
  }

  void _drawSmart(Canvas canvas, Paint ink, Paint cut, Paint shadow) {
    final head = _roundedRectPath(const Rect.fromLTWH(12, 16, 24, 22), 6);
    _fill(canvas, head, ink, shadow);
    _fill(
      canvas,
      _roundedRectPath(const Rect.fromLTWH(7, 24, 6, 9), 2),
      ink,
      shadow,
    );
    _fill(
      canvas,
      _roundedRectPath(const Rect.fromLTWH(35, 24, 6, 9), 2),
      ink,
      shadow,
    );
    _fill(
      canvas,
      _roundedRectPath(const Rect.fromLTWH(21, 9, 6, 7), 1),
      ink,
      shadow,
    );
    _fill(
      canvas,
      _roundedRectPath(const Rect.fromLTWH(22.5, 5, 3, 5), 1),
      ink,
      shadow,
    );

    final cutFill = Paint()..color = cutoutColor;
    canvas.drawCircle(const Offset(19, 26), 2.5, cutFill);
    canvas.drawCircle(const Offset(29, 26), 2.5, cutFill);
    cut.strokeWidth = 2.5;
    canvas.drawLine(const Offset(19, 33), const Offset(29, 33), cut);
  }

  void _drawMore(Canvas canvas, Paint ink, Paint cut, Paint shadow) {
    for (final y in [10.0, 21.0, 32.0]) {
      for (final x in [10.0, 21.0, 32.0]) {
        _fill(
          canvas,
          _roundedRectPath(Rect.fromLTWH(x, y, 7, 7), 1.5),
          ink,
          shadow,
        );
      }
    }
    final cutFill = Paint()..color = cutoutColor;
    for (final y in [12.2, 23.2, 34.2]) {
      for (final x in [12.2, 23.2, 34.2]) {
        canvas.drawRect(Rect.fromLTWH(x, y, 2.6, 1.7), cutFill);
      }
    }
  }

  void _fill(Canvas canvas, Path path, Paint ink, Paint shadow) {
    canvas.drawPath(path.shift(const Offset(0, 1.2)), shadow);
    canvas.drawPath(path, ink);
  }

  Path _roundedRectPath(Rect rect, double radius) {
    return Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
  }

  @override
  bool shouldRepaint(covariant _DockGlyphPainter oldDelegate) {
    return oldDelegate.glyph != glyph ||
        oldDelegate.color != color ||
        oldDelegate.cutoutColor != cutoutColor ||
        oldDelegate.shadowColor != shadowColor;
  }
}
