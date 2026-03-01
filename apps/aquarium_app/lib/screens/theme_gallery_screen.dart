import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/room_theme_provider.dart';
import '../theme/app_theme.dart';
import '../theme/room_themes.dart';
import '../utils/app_feedback.dart';

/// Theme Gallery Screen - Browse and select room visual themes
/// Supports free and premium (locked) themes for future monetization
class ThemeGalleryScreen extends ConsumerWidget {
  const ThemeGalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(roomThemeProvider);
    final themes = RoomTheme.allThemes;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Collapsing header with current theme preview
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _CurrentThemePreview(
                theme: RoomTheme.fromType(currentTheme),
              ),
              title: Text(
                'Theme Gallery',
                style: TextStyle(
                  color: Colors.white,
                  shadows: [
                    Shadow(color: AppOverlays.black50, blurRadius: 8),
                  ],
                ),
              ),
              titlePadding: const EdgeInsets.only(left: AppSpacing.md, bottom: AppSpacing.md),
            ),
            backgroundColor: RoomTheme.fromType(currentTheme).background1,
          ),

          // Section: Free Themes
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg2, AppSpacing.lg, AppSpacing.lg2, AppSpacing.sm2),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.successAlpha15,
                      borderRadius: AppRadius.smallRadius,
                    ),
                    child: Text(
                      'FREE',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('Included Themes', style: AppTypography.headlineSmall),
                ],
              ),
            ),
          ),

          // Free theme grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final theme = themes[index];
                final themeType = RoomThemeType.values[index];
                final isSelected = currentTheme == themeType;

                return _ThemeCard(
                  theme: theme,
                  isSelected: isSelected,
                  isPremium: false,
                  isLocked: false,
                  onTap: () {
                    ref.read(roomThemeProvider.notifier).setTheme(themeType);
                    AppFeedback.showSuccess(
                      context,
                      'Switched to ${theme.name} theme',
                    );
                  },
                );
              }, childCount: themes.length),
            ),
          ),

          // Section: Premium Themes (Coming Soon)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg2, AppSpacing.xl, AppSpacing.lg2, AppSpacing.sm2),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      ),
                      borderRadius: AppRadius.smallRadius,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 12, color: Colors.white),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'PREMIUM',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('Coming Soon', style: AppTypography.headlineSmall),
                ],
              ),
            ),
          ),

          // Premium theme placeholder grid
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xl),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final premiumThemes = _getPremiumThemePreviews();
                  return _ThemeCard(
                    theme: premiumThemes[index],
                    isSelected: false,
                    isPremium: true,
                    isLocked: true,
                    onTap: () => _showPremiumDialog(context),
                  );
                },
                childCount: 4, // Show 4 premium placeholders
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<RoomTheme> _getPremiumThemePreviews() {
    // Placeholder premium themes - these will be properly defined later
    return [
      const RoomTheme(
        name: 'Coral Reef',
        description: 'Vibrant underwater paradise',
        primaryWave: Color(0xFF00CED1),
        secondaryWave: Color(0xFF008B8B),
        accentBlob: Color(0xFFFF6B6B),
        accentBlob2: Color(0xFFFFE66D),
        background1: Color(0xFF006994),
        background2: Color(0xFF004F6F),
        background3: Color(0xFF003A52),
        waterTop: Color(0xFF00BFFF),
        waterMid: Color(0xFF0099CC),
        waterBottom: Color(0xFF007399),
        sand: Color(0xFFFAF0E6),
        plantPrimary: Color(0xFF32CD32),
        plantSecondary: Color(0xFF98FB98),
        fish1: Color(0xFFFF6B6B),
        fish2: Color(0xFFFFE66D),
        fish3: Color(0xFF00CED1),
        glassCard: Color(0x26FFFFFF),
        glassBorder: Color(0x40FFFFFF),
        gaugeColor1: Color(0xFF00CED1),
        gaugeColor2: Color(0xFF32CD32),
        gaugeColor3: Color(0xFFFFE66D),
        buttonFeed: Color(0xFFFF6B6B),
        buttonTest: Color(0xFF32CD32),
        buttonWater: Color(0xFF00BFFF),
        buttonStats: Color(0xFFDDA0DD),
        textPrimary: Colors.white,
        textSecondary: Color(0xB3FFFFFF),
        accentCircles: [Color(0xFF00CED1), Color(0xFFFF6B6B), Colors.white],
      ),
      const RoomTheme(
        name: 'Zen Garden',
        description: 'Peaceful minimalist calm',
        primaryWave: Color(0xFF98D8C8),
        secondaryWave: Color(0xFF7BC8B8),
        accentBlob: Color(0xFFD4A574),
        accentBlob2: Color(0xFFC49B6C),
        background1: Color(0xFFF5F0E6),
        background2: Color(0xFFE8E0D5),
        background3: Color(0xFFDAD2C7),
        waterTop: Color(0xFFB8E0D8),
        waterMid: Color(0xFFA0D0C8),
        waterBottom: Color(0xFF88C0B8),
        sand: Color(0xFFE8DCC8),
        plantPrimary: Color(0xFF6B8E6B),
        plantSecondary: Color(0xFF8BA88B),
        fish1: Color(0xFFD4A574),
        fish2: Color(0xFFE8B888),
        fish3: Color(0xFF6B8E6B),
        glassCard: Color(0x26000000),
        glassBorder: Color(0x20000000),
        gaugeColor1: Color(0xFF98D8C8),
        gaugeColor2: Color(0xFF6B8E6B),
        gaugeColor3: Color(0xFFD4A574),
        buttonFeed: Color(0xFFD4A574),
        buttonTest: Color(0xFF6B8E6B),
        buttonWater: Color(0xFF98D8C8),
        buttonStats: Color(0xFFB8A090),
        textPrimary: Color(0xFF4A4A4A),
        textSecondary: Color(0xFF7A7A7A),
        accentCircles: [
          Color(0xFF98D8C8),
          Color(0xFFD4A574),
          Color(0xFF6B8E6B),
        ],
      ),
      const RoomTheme(
        name: 'Neon Glow',
        description: 'Cyberpunk aquarium vibes',
        primaryWave: Color(0xFFFF00FF),
        secondaryWave: Color(0xFF00FFFF),
        accentBlob: Color(0xFFFF1493),
        accentBlob2: Color(0xFF00FF7F),
        background1: Color(0xFF1A0A2E),
        background2: Color(0xFF150824),
        background3: Color(0xFF10061A),
        waterTop: Color(0xFF4A0080),
        waterMid: Color(0xFF3A0066),
        waterBottom: Color(0xFF2A004D),
        sand: Color(0xFF2A2040),
        plantPrimary: Color(0xFF00FF7F),
        plantSecondary: Color(0xFF7FFF00),
        fish1: Color(0xFFFF00FF),
        fish2: Color(0xFF00FFFF),
        fish3: Color(0xFFFFFF00),
        glassCard: Color(0x26FFFFFF),
        glassBorder: Color(0x40FF00FF),
        gaugeColor1: Color(0xFF00FFFF),
        gaugeColor2: Color(0xFF00FF7F),
        gaugeColor3: Color(0xFFFF00FF),
        buttonFeed: Color(0xFFFF1493),
        buttonTest: Color(0xFF00FF7F),
        buttonWater: Color(0xFF00FFFF),
        buttonStats: Color(0xFFFF00FF),
        textPrimary: Colors.white,
        textSecondary: Color(0xB3FFFFFF),
        accentCircles: [
          Color(0xFFFF00FF),
          Color(0xFF00FFFF),
          Color(0xFF00FF7F),
        ],
      ),
      const RoomTheme(
        name: 'Autumn',
        description: 'Warm fall colors',
        primaryWave: Color(0xFFCD853F),
        secondaryWave: Color(0xFFB8732E),
        accentBlob: Color(0xFFDC143C),
        accentBlob2: Color(0xFFFF8C00),
        background1: Color(0xFFD2691E),
        background2: Color(0xFFC45A18),
        background3: Color(0xFFB64D12),
        waterTop: Color(0xFFDEB887),
        waterMid: Color(0xFFD2A679),
        waterBottom: Color(0xFFC6946B),
        sand: Color(0xFFE6D4A8),
        plantPrimary: Color(0xFFDC143C),
        plantSecondary: Color(0xFFFF6347),
        fish1: Color(0xFFFF8C00),
        fish2: Color(0xFFDC143C),
        fish3: Color(0xFFFFD700),
        glassCard: Color(0x26FFFFFF),
        glassBorder: Color(0x40FFFFFF),
        gaugeColor1: Color(0xFFFF8C00),
        gaugeColor2: Color(0xFFDC143C),
        gaugeColor3: Color(0xFFFFD700),
        buttonFeed: Color(0xFFFF8C00),
        buttonTest: Color(0xFF6B8E23),
        buttonWater: Color(0xFFDEB887),
        buttonStats: Color(0xFFDC143C),
        textPrimary: Colors.white,
        textSecondary: Color(0xB3FFFFFF),
        accentCircles: [
          Color(0xFFFF8C00),
          Color(0xFFDC143C),
          Color(0xFFFFD700),
        ],
      ),
    ];
  }

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.largeRadius),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
                borderRadius: AppRadius.mediumRadius,
              ),
              child: const Icon(Icons.star, color: Colors.white, size: AppIconSizes.sm),
            ),
            const SizedBox(width: 12),
            const Text('Premium Theme'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Premium themes are coming soon!',
              style: Theme.of(context).textTheme.titleMedium!,
            ),
            const SizedBox(height: 12),
            Text(
              'Support the app and unlock exclusive themes with unique animations and special effects.',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

/// Current theme preview at the top of the gallery
class _CurrentThemePreview extends StatelessWidget {
  final RoomTheme theme;

  const _CurrentThemePreview({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [theme.background1, theme.background2, theme.background3],
        ),
      ),
      child: Stack(
        children: [
          // Decorative waves
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: const Size(double.infinity, 60),
              painter: _WavePainter(
                color: theme.primaryWave.withAlpha(102),
                offset: 0,
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: const Size(double.infinity, 60),
              painter: _WavePainter(
                color: theme.secondaryWave.withAlpha(153),
                offset: 30,
              ),
            ),
          ),

          // Accent circles
          Positioned(
            top: 60,
            right: 30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.accentBlob.withAlpha(76),
              ),
            ),
          ),
          Positioned(
            top: 100,
            right: 80,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.accentBlob2.withAlpha(102),
              ),
            ),
          ),

          // Mini fish
          Positioned(
            bottom: 80,
            right: 60,
            child: _MiniFish(color: theme.fish1),
          ),
          Positioned(
            bottom: 100,
            right: 100,
            child: Transform.scale(
              scaleX: -1,
              child: _MiniFish(color: theme.fish2),
            ),
          ),

          // Mini plants
          Positioned(
            bottom: 20,
            left: 30,
            child: _MiniPlant(color: theme.plantPrimary),
          ),
          Positioned(
            bottom: 20,
            left: 70,
            child: _MiniPlant(color: theme.plantSecondary, height: 35),
          ),

          // Current label
          Positioned(
            bottom: 60,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm2, vertical: 6),
              decoration: BoxDecoration(
                color: AppOverlays.white20,
                borderRadius: AppRadius.largeRadius,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, size: AppIconSizes.xs, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    'Current: ${theme.name}',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Theme card with mini room preview
class _ThemeCard extends StatelessWidget {
  final RoomTheme theme;
  final bool isSelected;
  final bool isPremium;
  final bool isLocked;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.theme,
    required this.isSelected,
    required this.isPremium,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.medium2,
        decoration: BoxDecoration(
          borderRadius: AppRadius.largeRadius,
          border: Border.all(
            color: isSelected ? theme.accentBlob : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.accentBlob.withAlpha(76),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppColors.blackAlpha08,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: AppRadius.mediumRadius,
          child: Stack(
            children: [
              // Theme preview
              Positioned.fill(child: _MiniRoomPreview(theme: theme)),

              // Locked overlay
              if (isLocked)
                Positioned.fill(
                  child: Container(
                    color: AppOverlays.black40,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(AppSpacing.sm2),
                        decoration: BoxDecoration(
                          color: AppOverlays.black50,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),

              // Premium badge
              if (isPremium)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      ),
                      borderRadius: AppRadius.smallRadius,
                    ),
                    child: const Icon(
                      Icons.star,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),

              // Selected checkmark
              if (isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: theme.accentBlob,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: AppIconSizes.xs,
                      color: Colors.white,
                    ),
                  ),
                ),

              // Theme name bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppOverlays.black60,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        theme.name,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        theme.description,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: AppOverlays.white80,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mini room preview widget showing a simplified version of the room scene
class _MiniRoomPreview extends StatelessWidget {
  final RoomTheme theme;

  const _MiniRoomPreview({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [theme.background1, theme.background2, theme.background3],
        ),
      ),
      child: Stack(
        children: [
          // Window
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              width: 30,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.waterTop.withAlpha(128),
                    theme.waterMid.withAlpha(76),
                  ],
                ),
                border: Border.all(
                  color: theme.sand.withAlpha(204),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Tank stand
          Positioned(
            bottom: 50,
            left: 15,
            child: Container(
              width: 70,
              height: 10,
              decoration: BoxDecoration(
                color: theme.sand.withAlpha(204),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Mini aquarium tank
          Positioned(
            bottom: 60,
            left: 18,
            child: Container(
              width: 64,
              height: 45,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [theme.waterTop, theme.waterMid, theme.waterBottom],
                ),
                borderRadius: AppRadius.xsRadius,
                border: Border.all(color: theme.glassBorder, width: 1.5),
              ),
              child: Stack(
                children: [
                  // Sand substrate
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.sand,
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  // Mini plant
                  Positioned(
                    bottom: 6,
                    left: 8,
                    child: Container(
                      width: 6,
                      height: 16,
                      decoration: BoxDecoration(
                        color: theme.plantPrimary,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  // Mini fish
                  Positioned(
                    bottom: 18,
                    right: 12,
                    child: Container(
                      width: 10,
                      height: 6,
                      decoration: BoxDecoration(
                        color: theme.fish1,
                        borderRadius: AppRadius.xsRadius,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Color palette indicator
          Positioned(
            bottom: 30,
            right: 10,
            child: Column(
              children: [
                Row(
                  children: [
                    _ColorDot(color: theme.accentBlob),
                    _ColorDot(color: theme.waterMid),
                  ],
                ),
                Row(
                  children: [
                    _ColorDot(color: theme.plantPrimary),
                    _ColorDot(color: theme.fish1),
                  ],
                ),
              ],
            ),
          ),

          // Floor
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 30,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.sand.withAlpha(153),
                    theme.sand.withAlpha(204),
                  ],
                ),
              ),
            ),
          ),

          // Accent decorations
          Positioned(
            top: 20,
            left: 10,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.accentBlob.withAlpha(76),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;

  const _ColorDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.all(AppSpacing.hairline),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: AppOverlays.white30, width: 0.5),
      ),
    );
  }
}

class _MiniFish extends StatelessWidget {
  final Color color;

  const _MiniFish({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.horizontal(
          left: Radius.circular(AppRadius.md2),
          right: Radius.circular(6),
        ),
      ),
    );
  }
}

class _MiniPlant extends StatelessWidget {
  final Color color;
  final double height;

  const _MiniPlant({required this.color, this.height = 45});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final Color color;
  final double offset;

  _WavePainter({required this.color, required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()..moveTo(0, size.height * 0.5 + offset * 0.1);

    for (double x = 0; x <= size.width; x += 1) {
      final y =
          size.height * 0.5 +
          20 * (0.5 + 0.5 * (x / size.width + offset / 100).remainder(1));
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
