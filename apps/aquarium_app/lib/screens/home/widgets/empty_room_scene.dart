import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/room_theme_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/ambient/ambient_overlay.dart';
import '../../../widgets/core/app_button.dart';
import '../../../widgets/mascot/mascot_widgets.dart';
import '../../../widgets/room/aquarium_stand_painter.dart';
import '../../../widgets/room/room_background.dart';
import '../../create_tank_screen/setup_mode.dart';
import 'setup_path_selector.dart';

/// Empty-tank scene that reuses the active room theme's illustrated
/// background and the same [AquariumStand] used by [LivingRoomScene].
///
/// Visual consistency rule: this scene is the "before" snapshot of what the
/// user will see once they create a tank. Same WebP background, same
/// ambient-lighting overlay, same wood stand at the same position — only
/// difference is the tank itself is a ghost-glass outline (no water, no
/// fish, no label) and a content panel pinned to the bottom hosts the
/// welcome copy, the [SetupPathSelector] (guided vs expert), and a
/// demo-tank shortcut.
///
/// Concept locked in `docs/planning/2026-04-danio-fix-brief-concept-lock.md`.
class EmptyRoomScene extends ConsumerWidget {
  /// Fired when the user picks a setup path. The [SetupMode] determines
  /// whether [CreateTankScreen] shows its 3-page wizard or expert form.
  final ValueChanged<SetupMode> onCreateTank;

  /// Fired when the user taps "Load a demo tank".
  final VoidCallback onLoadDemo;

  const EmptyRoomScene({
    super.key,
    required this.onCreateTank,
    required this.onLoadDemo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeType = ref.watch(roomThemeProvider);
    final theme = ref.watch(currentRoomThemeProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Fall back to MediaQuery when the parent gives unbounded
        // constraints — the HomeScreen scaffold body passes loose bounds
        // in some configs and Positioned children would otherwise collapse.
        final media = MediaQuery.of(context);
        final w = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : media.size.width;
        final h = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : media.size.height;
        return SizedBox(
          width: w,
          height: h,
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.hardEdge,
            children: [
              // Layer 1: Themed background asset with ambient lighting.
              // Same code path as LivingRoomScene so the art style matches
              // exactly (no custom painters, no programmatic wall gradient).
              Positioned.fill(
                child: AmbientLightingOverlay(
                  child: ExcludeSemantics(
                    child: buildRoomBackground(themeType),
                  ),
                ),
              ),

              // Layer 2: Aquarium stand — same widget and same proportions
              // as LivingRoomScene, but shifted up so the content panel at
              // the bottom doesn't cover it.
              Positioned(
                top: h * 0.50,
                left: w * 0.06,
                right: w * 0.06,
                child: AquariumStand(
                  width: w * 0.88,
                  height: h * 0.06,
                  theme: theme,
                ),
              ),

              // Layer 3: Ghost-glass tank outline where the aquarium will
              // eventually live. Mirrors the LivingRoomScene tank rectangle
              // (scaled to sit above the stand) but shows no water/fish.
              Positioned(
                top: h * 0.16,
                left: w * 0.08,
                right: w * 0.08,
                child: SizedBox(
                  width: w * 0.84,
                  height: h * 0.34,
                  child: const _EmptyTankOutline(),
                ),
              ),

              // Layer 4: Mascot Finn, welcoming the user. Positioned near
              // the left edge of the stand as a "waiting helper".
              Positioned(
                left: w * 0.10,
                top: h * 0.44,
                child: const MascotAvatar(
                  mood: MascotMood.encouraging,
                  size: MascotSize.medium,
                ),
              ),

              // Layer 5: Content panel pinned to the bottom. Opaque ivory
              // surface with rounded top corners — the welcome copy,
              // guided/expert path selector, and demo-tank shortcut live
              // here.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _ContentPanel(
                  onCreateTank: onCreateTank,
                  onLoadDemo: onLoadDemo,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Ghost-glass tank outline
// ---------------------------------------------------------------------------

class _EmptyTankOutline extends StatelessWidget {
  const _EmptyTankOutline();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Faint white fill so the glass reads against any background.
        color: const Color(0x26FFFFFF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xB3FFFFFF),
          width: 3,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.water_drop_outlined,
              size: 52,
              color: Colors.white.withValues(alpha: 0.65),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'your tank',
              style: AppTypography.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Content panel — welcome copy, path selector, demo-tank shortcut
// ---------------------------------------------------------------------------

class _ContentPanel extends StatelessWidget {
  final ValueChanged<SetupMode> onCreateTank;
  final VoidCallback onLoadDemo;

  const _ContentPanel({
    required this.onCreateTank,
    required this.onLoadDemo,
  });

  @override
  Widget build(BuildContext context) {
    // DecoratedBox (not Material) avoids RenderPhysicalShape layout
    // strictness that fails inside a bottom-anchored Positioned with loose
    // height constraints.
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: DanioColors.ivoryWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 18,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your tank goes right here',
                textAlign: TextAlign.center,
                style: AppTypography.titleLarge.copyWith(
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Pick the path that suits you',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SetupPathSelector(onPathSelected: onCreateTank),
              const SizedBox(height: AppSpacing.xs),
              AppButton(
                label: 'Load a demo tank',
                onPressed: onLoadDemo,
                variant: AppButtonVariant.text,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
