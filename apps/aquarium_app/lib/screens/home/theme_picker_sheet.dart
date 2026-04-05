import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/reduced_motion_provider.dart';
import '../../providers/room_theme_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/room_themes.dart';
import '../../utils/haptic_feedback.dart';
import '../../widgets/room/mini_tank_painter.dart';
import '../../widgets/room/room_background.dart';

/// Stacked-card theme picker content for use inside a bottom sheet.
///
/// Shows a swipeable stack of theme preview cards. Each card displays the
/// room's background image with a painted mini-aquarium overlay. Swipe to
/// browse, tap to select.
class ThemePickerSheet extends ConsumerStatefulWidget {
  const ThemePickerSheet({super.key});

  @override
  ConsumerState<ThemePickerSheet> createState() => _ThemePickerSheetState();
}

class _ThemePickerSheetState extends ConsumerState<ThemePickerSheet>
    with TickerProviderStateMixin {
  static const _themes = RoomThemeType.values;
  static const _maxVisibleCards = 3;
  static const _cardRotationDeg = 2.5;
  static const _cardOffsetY = 10.0;
  static const _cardOffsetX = 6.0;

  late int _currentIndex;
  late AnimationController _swipeController;
  late AnimationController _entranceController;

  // Swipe tracking
  double _dragX = 0;
  double _dragY = 0;

  @override
  void initState() {
    super.initState();
    // Start on the currently selected theme
    final current = ref.read(roomThemeProvider);
    _currentIndex = _themes.indexOf(current);
    if (_currentIndex < 0) _currentIndex = 0;

    _swipeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _removeActiveListener();
    _swipeController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  bool get _reduceMotion =>
      ref.read(reducedMotionProvider).isEnabled;

  bool get _hapticEnabled =>
      ref.read(settingsProvider).hapticFeedbackEnabled;

  void _advanceCard(int direction) {
    setState(() {
      _currentIndex = (_currentIndex + direction) % _themes.length;
      if (_currentIndex < 0) _currentIndex += _themes.length;
    });
    AppHaptics.selection(enabled: _hapticEnabled);
  }

  void _onPanStart(DragStartDetails _) {
    _dragX = 0;
    _dragY = 0;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragX += details.delta.dx;
      _dragY += details.delta.dy;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final velocityX = details.velocity.pixelsPerSecond.dx;
    final threshold = MediaQuery.of(context).size.width * 0.25;

    if (_dragX.abs() > threshold || velocityX.abs() > 600) {
      // Swipe off — left swipe advances forward, right swipe goes back
      final swipeDirection = _dragX > 0 ? -1 : 1;
      if (_reduceMotion) {
        // Instant transition
        setState(() {
          _dragX = 0;
          _dragY = 0;
        });
        _advanceCard(swipeDirection);
      } else {
        _animateSwipeOff(swipeDirection);
      }
    } else {
      // Snap back
      if (_reduceMotion) {
        setState(() {
          _dragX = 0;
          _dragY = 0;
        });
      } else {
        _animateSnapBack();
      }
    }
  }

  // Active listener tracked to prevent leaks on rapid swipes (Critical #2).
  VoidCallback? _activeSwipeListener;

  void _removeActiveListener() {
    if (_activeSwipeListener != null) {
      _swipeController.removeListener(_activeSwipeListener!);
      _activeSwipeListener = null;
    }
  }

  void _animateSwipeOff(int direction) {
    final startX = _dragX;
    final startY = _dragY;
    // Fly off in the direction the card was dragged
    final flyDirection = startX >= 0 ? 1 : -1;
    final endX = flyDirection * MediaQuery.of(context).size.width * 1.2;

    _removeActiveListener();
    _swipeController.reset();
    _swipeController.forward().then((_) {
      if (!mounted) return;
      _removeActiveListener();
      setState(() {
        _dragX = 0;
        _dragY = 0;
      });
      _advanceCard(direction);
    });

    _activeSwipeListener = () {
      if (!mounted) return;
      final t = Curves.easeOut.transform(_swipeController.value);
      setState(() {
        _dragX = lerpDouble(startX, endX, t)!;
        _dragY = lerpDouble(startY, 0, t)!;
      });
    };
    _swipeController.addListener(_activeSwipeListener!);
  }

  void _animateSnapBack() {
    final startX = _dragX;
    final startY = _dragY;

    _removeActiveListener();
    _swipeController.reset();
    _swipeController.forward().then((_) {
      if (!mounted) return;
      _removeActiveListener();
      setState(() {
        _dragX = 0;
        _dragY = 0;
      });
    });

    _activeSwipeListener = () {
      if (!mounted) return;
      final t = Curves.easeOut.transform(_swipeController.value);
      setState(() {
        _dragX = lerpDouble(startX, 0, t)!;
        _dragY = lerpDouble(startY, 0, t)!;
      });
    };
    _swipeController.addListener(_activeSwipeListener!);
  }

  void _selectTheme() {
    final type = _themes[_currentIndex];
    ref.read(roomThemeProvider.notifier).setTheme(type);
    AppHaptics.success(enabled: _hapticEnabled);
    Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    final currentType = _themes[_currentIndex];
    final currentTheme = RoomTheme.fromType(currentType);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Row(
          children: [
            const Icon(Icons.palette, size: AppIconSizes.md),
            const SizedBox(width: AppSpacing.sm2),
            Expanded(
              child: Semantics(
                header: true,
                child: Text('Room Theme', style: AppTypography.headlineSmall),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.maybePop(context),
              tooltip: 'Close',
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Card stack
        SizedBox(
          height: 320,
          child: _buildCardStack(),
        ),
        const SizedBox(height: AppSpacing.lg2),

        // Theme info + apply
        _ThemeInfoBar(
          theme: currentTheme,
          onApply: _selectTheme,
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }

  Widget _buildCardStack() {
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, _) {
        final t = _reduceMotion
            ? 1.0
            : Curves.easeOutBack.transform(
                _entranceController.value.clamp(0.0, 1.0),
              );
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Stack(
            alignment: Alignment.center,
            children: _buildCardWidgets(t),
          ),
        );
      },
    );
  }

  /// Builds the visible card stack bottom-to-top so the top card renders last.
  List<Widget> _buildCardWidgets(double entranceFactor) {
    final cards = <Widget>[];
    for (var i = _maxVisibleCards - 1; i >= 0; i--) {
      final themeIndex = (_currentIndex + i) % _themes.length;
      final type = _themes[themeIndex];
      final theme = RoomTheme.fromType(type);
      final isTop = i == 0;

      cards.add(
        _buildCard(
          type: type,
          theme: theme,
          stackIndex: i,
          isTop: isTop,
          entranceFactor: entranceFactor,
        ),
      );
    }
    return cards;
  }

  Widget _buildCard({
    required RoomThemeType type,
    required RoomTheme theme,
    required int stackIndex,
    required bool isTop,
    required double entranceFactor,
  }) {
    // Stack offset and rotation for cards behind the top one
    final baseRotation = stackIndex * _cardRotationDeg * (math.pi / 180);
    final baseOffsetY = stackIndex * _cardOffsetY;
    final baseOffsetX = stackIndex * _cardOffsetX;
    final scale = 1.0 - (stackIndex * 0.04);

    // Apply drag transform to the top card only
    double dx = baseOffsetX;
    double dy = baseOffsetY;
    double rotation = baseRotation;
    double opacity = 1.0 - (stackIndex * 0.15);

    if (isTop) {
      dx += _dragX;
      dy += _dragY * 0.3;
      rotation += _dragX * 0.001; // subtle rotation while dragging
      // Fade the card as it's swiped away
      final dragProgress = (_dragX.abs() / (MediaQuery.of(context).size.width * 0.5)).clamp(0.0, 1.0);
      opacity = 1.0 - (dragProgress * 0.3);
    }

    // Entrance: slide up from below
    dy += (1.0 - entranceFactor) * (60 + stackIndex * 20);

    Widget card = Transform(
      alignment: Alignment.center,
      transform: Matrix4.translationValues(dx, dy, 0)
        ..rotateZ(rotation)
        ..scaleByDouble(scale, scale, 1.0, 1.0),
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: _ThemeCard(type: type, theme: theme),
      ),
    );

    if (isTop) {
      card = GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        onTap: _selectTheme,
        child: Semantics(
          label: '${theme.name} theme, ${theme.description}. '
              'Swipe to browse, tap to select',
          button: true,
          child: card,
        ),
      );
    } else {
      // Background cards are decorative — hide from assistive tech
      card = ExcludeSemantics(child: card);
    }

    return card;
  }
}

/// Individual theme preview card with room background and painted mini-tank.
class _ThemeCard extends StatelessWidget {
  final RoomThemeType type;
  final RoomTheme theme;

  const _ThemeCard({required this.type, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: AppRadius.largeRadius,
        boxShadow: [
          BoxShadow(
            color: AppOverlays.black12,
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.largeRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Room background image
            _buildBackground(),

            // Mini tank overlay (top 70%)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 90, // leave room for info area
              child: CustomPaint(
                painter: MiniTankPainter(theme: theme),
              ),
            ),

            // Frosted info area at bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(AppRadius.lg),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.sm2, AppSpacing.md, AppSpacing.md,
                    ),
                    color: context.cardColor.withAlpha(180),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          theme.name,
                          style: AppTypography.labelLarge.copyWith(
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          theme.description,
                          style: AppTypography.bodySmall.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        // Colour palette dots
                        Row(
                          children: [
                            _ColorDot(color: theme.accentBlob),
                            _ColorDot(color: theme.waterMid),
                            _ColorDot(color: theme.plantPrimary),
                            _ColorDot(color: theme.fish1),
                            _ColorDot(color: theme.sand),
                          ],
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
    );
  }

  Widget _buildBackground() {
    final assetPath = backgroundAssetForTheme(type);
    if (assetPath != null) {
      return Image.asset(
        assetPath,
        fit: BoxFit.cover,
        cacheWidth: 520, // 2x card width for retina
        errorBuilder: (_, __, ___) => _gradientFallback(),
      );
    }
    return _gradientFallback();
  }

  Widget _gradientFallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [theme.background1, theme.background2, theme.background3],
        ),
      ),
    );
  }
}

/// Small colour dot for the palette strip.
class _ColorDot extends StatelessWidget {
  final Color color;
  const _ColorDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: AppOverlays.black12, width: 0.5),
        ),
      ),
    );
  }
}

/// Theme name, description, and apply button below the card stack.
class _ThemeInfoBar extends StatelessWidget {
  final RoomTheme theme;
  final VoidCallback onApply;

  const _ThemeInfoBar({required this.theme, required this.onApply});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  theme.name,
                  style: AppTypography.labelLarge.copyWith(
                    color: context.textPrimary,
                  ),
                ),
                Text(
                  theme.description,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: onApply,
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
