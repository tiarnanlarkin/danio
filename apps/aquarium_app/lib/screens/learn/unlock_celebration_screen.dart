import 'package:flutter/material.dart';

import '../../data/species_unlock_map.dart';
import '../../theme/app_theme.dart';
import '../../widgets/core/app_button.dart';
import '../../widgets/effects/sparkle_effect.dart';

/// Full-screen celebration shown when a user's lesson completion unlocks a
/// new fish species for their tank.
///
/// Shown AFTER the XP animation (triggered from [LessonScreen._completeLesson]).
///
/// CTAs:
/// - "Add to Tank" → navigates back to the home tab (tank view).
/// - "Keep Learning" → pops back to the learn screen.
class UnlockCelebrationScreen extends StatefulWidget {
  /// The species ID that was just unlocked, e.g. `neon_tetra`.
  final String speciesId;

  const UnlockCelebrationScreen({super.key, required this.speciesId});

  @override
  State<UnlockCelebrationScreen> createState() =>
      _UnlockCelebrationScreenState();
}

class _UnlockCelebrationScreenState extends State<UnlockCelebrationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnim = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.elasticOut,
    );

    _fadeAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  String get _displayName =>
      speciesDisplayNames[widget.speciesId] ??
      widget.speciesId
          .replaceAll('_', ' ')
          .split(' ')
          .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
          .join(' ');

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final spriteSize = size.width * 0.55;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A3A5C), // deep ocean blue
              Color(0xFF0D2137),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Top spacer ────────────────────────────────────────────
              const Spacer(flex: 2),

              // ── "You unlocked" header ─────────────────────────────────
              FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  children: [
                    Text(
                      'You unlocked',
                      style: AppTypography.headlineMedium.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _displayName,
                      style: AppTypography.headlineLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // ── Fish sprite with sparkles ──────────────────────────────
              ScaleTransition(
                scale: _scaleAnim,
                child: SparkleEffect(
                  isActive: true,
                  particleCount: 12,
                  sparkleColor: const Color(0xFFFFD700),
                  minSize: 5,
                  maxSize: 10,
                  child: Image.asset(
                    speciesAssetPath(widget.speciesId),
                    width: spriteSize,
                    height: spriteSize,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => _FallbackSprite(
                      size: spriteSize,
                      name: _displayName,
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // ── Sub-text ──────────────────────────────────────────────
              FadeTransition(
                opacity: _fadeAnim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: Text(
                    '$_displayName is now swimming in your tank!',
                    style: AppTypography.bodyLarge.copyWith(
                      color: Colors.white60,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // ── CTAs ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg2,
                  vertical: AppSpacing.lg,
                ),
                child: Column(
                  children: [
                    AppButton(
                      label: 'See My Tank 🐟',
                      onPressed: _goToTank,
                      isFullWidth: true,
                      size: AppButtonSize.large,
                      variant: AppButtonVariant.primary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: 'Keep Learning',
                      onPressed: _keepLearning,
                      isFullWidth: true,
                      size: AppButtonSize.large,
                      variant: AppButtonVariant.secondary,
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

  // ── Navigation ────────────────────────────────────────────────────────────

  /// Navigate back to the home tab (which shows the tank).
  /// Pops all screens until we reach the root navigator.
  void _goToTank() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// Pop back to the learn screen (or the path browser).
  void _keepLearning() {
    Navigator.of(context).pop();
  }
}

// ── Fallback ──────────────────────────────────────────────────────────────

class _FallbackSprite extends StatelessWidget {
  final double size;
  final String name;

  const _FallbackSprite({required this.size, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF4A9DB5).withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '🐟',
          style: TextStyle(fontSize: size * 0.4),
        ),
      ),
    );
  }
}
