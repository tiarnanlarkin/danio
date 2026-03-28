import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/room_theme_provider.dart';
import '../../theme/room_themes.dart';
import '../ambient/ambient_overlay.dart';
import '../effects/ripple_container.dart';
import '../stage/tank_glass_badge.dart';
import 'aquarium_stand_painter.dart';
import 'room_background.dart';
import 'themed_aquarium.dart';

/// Themeable room scene - supports multiple visual styles.
///
/// Includes day/night ambient lighting overlay based on real time.
class LivingRoomScene extends ConsumerWidget {
  final String tankId;
  final String tankName;
  final double tankVolume;
  final double? temperature;
  final double? ph;
  final double? ammonia;
  final double? nitrate;
  final RoomTheme theme;
  final VoidCallback? onTankTap;
  final VoidCallback? onTestKitTap;
  final VoidCallback? onFoodTap;
  final VoidCallback? onPlantTap;
  final VoidCallback? onStatsTap;
  final VoidCallback? onThemeTap;
  final VoidCallback? onJournalTap;
  final VoidCallback? onCalendarTap;
  final bool isNewUser;

  /// Whether to use animated Rive fish instead of static drawn fish
  final bool useRiveFish;

  const LivingRoomScene({
    super.key,
    required this.tankId,
    required this.tankName,
    required this.tankVolume,
    required this.theme,
    this.temperature,
    this.ph,
    this.ammonia,
    this.nitrate,
    this.onTankTap,
    this.onTestKitTap,
    this.onFoodTap,
    this.onPlantTap,
    this.onStatsTap,
    this.onThemeTap,
    this.onJournalTap,
    this.onCalendarTap,
    this.isNewUser = false,
    this.useRiveFish = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : w * 1.4;

        return SizedBox(
          width: w,
          height: h,
          child: Stack(
            // BUG-03: clip room scene children to prevent overflow into panel area
            clipBehavior: Clip.hardEdge,
            children: [
              // === LAYER 1: Background image with ambient lighting overlay ===
              Positioned.fill(
                child: AmbientLightingOverlay(
                  child: ExcludeSemantics(
                    child: buildRoomBackground(ref.watch(roomThemeProvider)),
                  ),
                ),
              ),

              // Stars/sparkles for whimsical themes
              if (theme.name == 'Whimsical' ||
                  theme.name == 'Midnight' ||
                  theme.name == 'Aurora') ...[
                Positioned(
                  top: h * 0.08,
                  left: w * 0.15,
                  child: Sparkle(size: 8, color: theme.accentCircles[0]),
                ),
                Positioned(
                  top: h * 0.12,
                  right: w * 0.25,
                  child: Sparkle(size: 6, color: theme.accentCircles[1]),
                ),
                Positioned(
                  top: h * 0.06,
                  left: w * 0.35,
                  child: Sparkle(size: 5, color: theme.accentCircles[2]),
                ),
                Positioned(
                  top: h * 0.15,
                  left: w * 0.08,
                  child: Sparkle(size: 4, color: theme.accentCircles[0]),
                ),
              ],

              // === LAYER 3: Furniture stand for aquarium ===
              Positioned(
                top: h * 0.66,
                left: w * 0.06,
                right: w * 0.06,
                child: AquariumStand(
                  width: w * 0.88,
                  height: h * 0.08,
                  theme: theme,
                ),
              ),

              // === LAYER 4: 3D Aquarium illustration ===
              Positioned(
                top: h * 0.24,
                left: w * 0.06,
                right: w * 0.06,
                child: Hero(
                  tag: 'tank-card-$tankId',
                  child: RippleContainer(
                    onTap: onTankTap,
                    child: ThemedAquarium(
                      width: w * 0.88,
                      height: h * 0.44,
                      theme: theme,
                      useRiveFish: useRiveFish,
                      reduceMotion: MediaQuery.of(context).disableAnimations,
                    ),
                  ),
                ),
              ),

              // === LAYER 5: Tank badge ===
              Positioned(
                bottom:
                    h -
                    (h * 0.68) +
                    6, // 6dp above tank bottom edge (inside glass border)
                right: w * 0.06 + 6, // 6dp inside tank right edge
                child: TankGlassBadge(
                  tankName: tankName,
                  tankVolume: tankVolume,
                  theme: theme,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
