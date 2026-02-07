import 'package:flutter/material.dart';

/// Room visual themes - different aesthetic styles
/// Users can switch themes in settings

enum RoomThemeType {
  ocean,      // Current teal/coral design
  pastel,     // Whimsical pastel (new)
  sunset,     // Warm oranges/purples
  midnight,   // Dark mode deep blues
  forest,     // Earthy greens/browns
  dreamy,     // Ultra-soft abstract pastels
  watercolor, // Artistic watercolor washes
  cotton,     // Cotton candy gradient mesh
  aurora,     // Northern lights glow
  golden,     // Golden hour warmth
}

class RoomTheme {
  final String name;
  final String description;
  final Color primaryWave;
  final Color secondaryWave;
  final Color accentBlob;
  final Color accentBlob2;
  final Color background1;
  final Color background2;
  final Color background3;
  final Color waterTop;
  final Color waterMid;
  final Color waterBottom;
  final Color sand;
  final Color plantPrimary;
  final Color plantSecondary;
  final Color fish1;
  final Color fish2;
  final Color fish3;
  final Color glassCard;
  final Color glassBorder;
  final Color gaugeColor1;
  final Color gaugeColor2;
  final Color gaugeColor3;
  final Color buttonFeed;
  final Color buttonTest;
  final Color buttonWater;
  final Color buttonStats;
  final Color textPrimary;
  final Color textSecondary;
  final List<Color> accentCircles;

  const RoomTheme({
    required this.name,
    required this.description,
    required this.primaryWave,
    required this.secondaryWave,
    required this.accentBlob,
    required this.accentBlob2,
    required this.background1,
    required this.background2,
    required this.background3,
    required this.waterTop,
    required this.waterMid,
    required this.waterBottom,
    required this.sand,
    required this.plantPrimary,
    required this.plantSecondary,
    required this.fish1,
    required this.fish2,
    required this.fish3,
    required this.glassCard,
    required this.glassBorder,
    required this.gaugeColor1,
    required this.gaugeColor2,
    required this.gaugeColor3,
    required this.buttonFeed,
    required this.buttonTest,
    required this.buttonWater,
    required this.buttonStats,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentCircles,
  });

  static RoomTheme get ocean => const RoomTheme(
    name: 'Ocean',
    description: 'Teal & coral, modern feel',
    primaryWave: Color(0xFF6BABA0),
    secondaryWave: Color(0xFF3A6B5C),
    accentBlob: Color(0xFFE8A87C),
    accentBlob2: Color(0xFFD4956C),
    background1: Color(0xFF5B9A8B),
    background2: Color(0xFF4A8B7C),
    background3: Color(0xFF3D7A6C),
    waterTop: Color(0xFF8ED8D8),
    waterMid: Color(0xFF6BC4C4),
    waterBottom: Color(0xFF5AB5B5),
    sand: Color(0xFFD4B896),
    plantPrimary: Color(0xFF4CAF50),
    plantSecondary: Color(0xFF81C784),
    fish1: Color(0xFFFF8A65),
    fish2: Color(0xFFEF5350),
    fish3: Color(0xFF42A5F5),
    glassCard: Color(0x26FFFFFF),
    glassBorder: Color(0x40FFFFFF),
    gaugeColor1: Color(0xFF64B5F6),
    gaugeColor2: Color(0xFF81C784),
    gaugeColor3: Color(0xFFFFB74D),
    buttonFeed: Color(0xFFE8A87C),
    buttonTest: Color(0xFF81C784),
    buttonWater: Color(0xFF64B5F6),
    buttonStats: Color(0xFFBA68C8),
    textPrimary: Colors.white,
    textSecondary: Color(0xCCFFFFFF), // Improved from 0xB3 (70%) to 0xCC (80%) for WCAG AA contrast
    accentCircles: [Color(0xFF7FCDCD), Color(0xFFE8A87C), Colors.white],
  );

  static RoomTheme get pastel => const RoomTheme(
    name: 'Whimsical',
    description: 'Soft pastels, dreamy vibes',
    primaryWave: Color(0xFFB8D4E3),      // Soft sky blue
    secondaryWave: Color(0xFFE8D5E0),    // Lavender pink
    accentBlob: Color(0xFFFFD6E0),       // Soft pink
    accentBlob2: Color(0xFFD4F0F0),      // Mint
    background1: Color(0xFFE8EEF5),      // Very light blue-gray
    background2: Color(0xFFDDE5ED),      // Soft blue
    background3: Color(0xFFD0DCE8),      // Muted blue
    waterTop: Color(0xFFB5E8E8),         // Pastel aqua
    waterMid: Color(0xFF9DD8D8),         // Soft teal
    waterBottom: Color(0xFF8DCACA),      // Muted teal
    sand: Color(0xFFF5E6D3),             // Cream
    plantPrimary: Color(0xFF9DD6B0),     // Mint green
    plantSecondary: Color(0xFFB8E6C4),   // Light mint
    fish1: Color(0xFFFFB5BA),            // Soft coral
    fish2: Color(0xFFB5D8FF),            // Baby blue
    fish3: Color(0xFFE8D5FF),            // Lavender
    glassCard: Color(0x33FFFFFF),
    glassBorder: Color(0x4DFFFFFF),
    gaugeColor1: Color(0xFFB5D8FF),      // Baby blue
    gaugeColor2: Color(0xFFA8E6CF),      // Mint
    gaugeColor3: Color(0xFFFFDAB9),      // Peach
    buttonFeed: Color(0xFFFFB5BA),       // Soft coral
    buttonTest: Color(0xFFA8E6CF),       // Mint
    buttonWater: Color(0xFFB5D8FF),      // Baby blue
    buttonStats: Color(0xFFDDB8E8),      // Soft purple
    textPrimary: Color(0xFF5A6978),      // Soft dark gray
    textSecondary: Color(0xFF8896A6),    // Muted gray
    accentCircles: [Color(0xFFFFE4E8), Color(0xFFE4F0FF), Color(0xFFE8FFE8)],
  );

  static RoomTheme get sunset => const RoomTheme(
    name: 'Sunset',
    description: 'Warm oranges & purples',
    primaryWave: Color(0xFFE8B4A0),
    secondaryWave: Color(0xFF9B7BB8),
    accentBlob: Color(0xFFFFD194),
    accentBlob2: Color(0xFFD4A5C9),
    background1: Color(0xFFE8A088),
    background2: Color(0xFFD48B78),
    background3: Color(0xFFC07868),
    waterTop: Color(0xFFFFD4C4),
    waterMid: Color(0xFFE8B8A8),
    waterBottom: Color(0xFFD4A090),
    sand: Color(0xFFF5DCC8),
    plantPrimary: Color(0xFF8BB878),
    plantSecondary: Color(0xFFA8D090),
    fish1: Color(0xFFFFB878),
    fish2: Color(0xFFFF9088),
    fish3: Color(0xFFD4A8E8),
    glassCard: Color(0x26FFFFFF),
    glassBorder: Color(0x40FFFFFF),
    gaugeColor1: Color(0xFFFFB878),
    gaugeColor2: Color(0xFFE8A8B8),
    gaugeColor3: Color(0xFFD4A8E8),
    buttonFeed: Color(0xFFFFB878),
    buttonTest: Color(0xFFA8D090),
    buttonWater: Color(0xFFE8B8D0),
    buttonStats: Color(0xFFB8A8E8),
    textPrimary: Colors.white,
    textSecondary: Color(0xB3FFFFFF),
    accentCircles: [Color(0xFFFFE4D4), Color(0xFFE8D4FF), Color(0xFFFFF4E4)],
  );

  static RoomTheme get midnight => const RoomTheme(
    name: 'Midnight',
    description: 'Deep blues, night mode',
    primaryWave: Color(0xFF3D5A80),
    secondaryWave: Color(0xFF293D5C),
    accentBlob: Color(0xFF5C8AB8),
    accentBlob2: Color(0xFF4A6B8C),
    background1: Color(0xFF1A2634),
    background2: Color(0xFF152230),
    background3: Color(0xFF101C28),
    waterTop: Color(0xFF4A7090),
    waterMid: Color(0xFF3A5A78),
    waterBottom: Color(0xFF2A4A68),
    sand: Color(0xFF5A6878),
    plantPrimary: Color(0xFF4A8068),
    plantSecondary: Color(0xFF5A9078),
    fish1: Color(0xFFE8B888),
    fish2: Color(0xFF78B8E8),
    fish3: Color(0xFFB888D8),
    glassCard: Color(0x1AFFFFFF),
    glassBorder: Color(0x33FFFFFF),
    gaugeColor1: Color(0xFF78B8E8),
    gaugeColor2: Color(0xFF78D8A8),
    gaugeColor3: Color(0xFFE8B888),
    buttonFeed: Color(0xFFE8B888),
    buttonTest: Color(0xFF78D8A8),
    buttonWater: Color(0xFF78B8E8),
    buttonStats: Color(0xFFB888D8),
    textPrimary: Color(0xFFE8F0F8),
    textSecondary: Color(0xB3E8F0F8), // Improved from 0x99 (60%) to 0xB3 (70%) for WCAG AA contrast
    accentCircles: [Color(0xFF5A8AB8), Color(0xFF78B8E8), Color(0xFF4A6B8C)],
  );

  static RoomTheme get forest => const RoomTheme(
    name: 'Forest',
    description: 'Earthy greens & browns',
    primaryWave: Color(0xFF7BA07A),
    secondaryWave: Color(0xFF5A8058),
    accentBlob: Color(0xFFD4B896),
    accentBlob2: Color(0xFFA8C090),
    background1: Color(0xFF6B9068),
    background2: Color(0xFF5A8058),
    background3: Color(0xFF4A7048),
    waterTop: Color(0xFF90C8B0),
    waterMid: Color(0xFF78B898),
    waterBottom: Color(0xFF68A888),
    sand: Color(0xFFD4C4A8),
    plantPrimary: Color(0xFF5A9050),
    plantSecondary: Color(0xFF78B068),
    fish1: Color(0xFFE8A868),
    fish2: Color(0xFFD4786A),
    fish3: Color(0xFF78A8B8),
    glassCard: Color(0x26FFFFFF),
    glassBorder: Color(0x40FFFFFF),
    gaugeColor1: Color(0xFF90C878),
    gaugeColor2: Color(0xFFB8D890),
    gaugeColor3: Color(0xFFE8C878),
    buttonFeed: Color(0xFFE8A868),
    buttonTest: Color(0xFF90C878),
    buttonWater: Color(0xFF78B8C8),
    buttonStats: Color(0xFFA890B8),
    textPrimary: Colors.white,
    textSecondary: Color(0xB3FFFFFF),
    accentCircles: [Color(0xFFA8D890), Color(0xFFD4C4A8), Color(0xFF90C8B0)],
  );

  static RoomTheme get dreamy => const RoomTheme(
    name: 'Dreamy',
    description: 'Ultra-soft abstract pastels',
    primaryWave: Color(0xFFD8C8E8),      // Soft lavender wave
    secondaryWave: Color(0xFFC8E8D8),    // Mint cream wave
    accentBlob: Color(0xFFE8D0E0),       // Blush pink blob
    accentBlob2: Color(0xFFD0E0F0),      // Powder blue blob
    background1: Color(0xFFF0E8F4),      // Pale lavender base
    background2: Color(0xFFE8F4F0),      // Pale mint
    background3: Color(0xFFF4E8EC),      // Pale blush
    waterTop: Color(0xFFE0F0F8),         // Ethereal aqua
    waterMid: Color(0xFFD0E8F0),         // Soft sky
    waterBottom: Color(0xFFC8E0E8),      // Misty teal
    sand: Color(0xFFF8F4F0),             // Warm white
    plantPrimary: Color(0xFFA8D8B8),     // Soft sage
    plantSecondary: Color(0xFFB8E8C8),   // Pale mint
    fish1: Color(0xFFE8B8C8),            // Soft coral
    fish2: Color(0xFFB8D8E8),            // Baby blue
    fish3: Color(0xFFD8C8E8),            // Lavender
    glassCard: Color(0x40FFFFFF),        // Frosted white
    glassBorder: Color(0x60FFFFFF),      // Soft white border
    gaugeColor1: Color(0xFF98D8C8),      // Mint gauge
    gaugeColor2: Color(0xFFB8C8E8),      // Periwinkle
    gaugeColor3: Color(0xFFE8C8D0),      // Rose
    buttonFeed: Color(0xFFE8B8C8),       // Soft coral
    buttonTest: Color(0xFFA8D8B8),       // Sage
    buttonWater: Color(0xFFB8D8E8),      // Baby blue
    buttonStats: Color(0xFFD8B8E8),      // Soft lilac
    textPrimary: Color(0xFF5A5A6A),      // Soft charcoal
    textSecondary: Color(0xFF8A8A9A),    // Muted gray
    accentCircles: [Color(0xFFE8D0E0), Color(0xFFD0E8F0), Color(0xFFD8E8D0)],
  );

  static RoomTheme get watercolor => const RoomTheme(
    name: 'Watercolor',
    description: 'Artistic painted washes',
    primaryWave: Color(0xFFE8C8B8),      // Soft peach wash
    secondaryWave: Color(0xFFB8D0E8),    // Periwinkle wash
    accentBlob: Color(0xFFF0D8C8),       // Warm peach
    accentBlob2: Color(0xFFC8E8D8),      // Seafoam green
    background1: Color(0xFFFAF6F2),      // Warm paper white
    background2: Color(0xFFF4EFE8),      // Soft cream
    background3: Color(0xFFEDE6DE),      // Light tan
    waterTop: Color(0xFFD0E8E0),         // Seafoam
    waterMid: Color(0xFFC0D8D0),         // Soft teal
    waterBottom: Color(0xFFB0C8C0),      // Muted sage
    sand: Color(0xFFF5EDE0),             // Cream sand
    plantPrimary: Color(0xFF90C8A8),     // Watercolor green
    plantSecondary: Color(0xFFA8D8B8),   // Light green wash
    fish1: Color(0xFFE8B8A0),            // Peach fish
    fish2: Color(0xFFB8C8E8),            // Periwinkle fish
    fish3: Color(0xFFC8E0C8),            // Mint fish
    glassCard: Color(0x35FFFFFF),        // Soft frosted
    glassBorder: Color(0x50FFFFFF),      // Light border
    gaugeColor1: Color(0xFFB8D8D0),      // Seafoam gauge
    gaugeColor2: Color(0xFFD8C8B8),      // Warm tan
    gaugeColor3: Color(0xFFC8D0E8),      // Soft blue
    buttonFeed: Color(0xFFE8C0A8),       // Peach
    buttonTest: Color(0xFFA8D0B8),       // Mint
    buttonWater: Color(0xFFB8C8E0),      // Periwinkle
    buttonStats: Color(0xFFD0C0D8),      // Soft mauve
    textPrimary: Color(0xFF4A4A50),      // Warm charcoal
    textSecondary: Color(0xFF7A7A84),    // Soft gray
    accentCircles: [Color(0xFFF0D8C8), Color(0xFFC8E8D8), Color(0xFFD0D8E8)],
  );

  static RoomTheme get cotton => const RoomTheme(
    name: 'Cotton Candy',
    description: 'Smooth gradient mesh',
    primaryWave: Color(0xFFE8C0D0),      // Soft rose
    secondaryWave: Color(0xFFD0C0E8),    // Soft lilac
    accentBlob: Color(0xFFF0D0E0),       // Pink
    accentBlob2: Color(0xFFD0D8F0),      // Powder blue
    background1: Color(0xFFF8E0E8),      // Rose gradient start
    background2: Color(0xFFE8D8F0),      // Lilac middle
    background3: Color(0xFFE0E0F8),      // Blue gradient end
    waterTop: Color(0xFFE0D8F0),         // Soft lavender
    waterMid: Color(0xFFD8D0E8),         // Misty purple
    waterBottom: Color(0xFFD0C8E0),      // Dusky violet
    sand: Color(0xFFF8F0F4),             // Pale pink white
    plantPrimary: Color(0xFFB8D0C8),     // Muted sage
    plantSecondary: Color(0xFFC8E0D8),   // Soft mint
    fish1: Color(0xFFE8B0C0),            // Rose fish
    fish2: Color(0xFFC0B8E8),            // Lilac fish
    fish3: Color(0xFFB8D0E8),            // Sky fish
    glassCard: Color(0x30FFFFFF),        // Neumorphic white
    glassBorder: Color(0x45FFFFFF),      // Soft border
    gaugeColor1: Color(0xFFD8C0E0),      // Lilac gauge
    gaugeColor2: Color(0xFFE0C0D0),      // Rose gauge
    gaugeColor3: Color(0xFFC0D0E8),      // Blue gauge
    buttonFeed: Color(0xFFE8C0D0),       // Rose
    buttonTest: Color(0xFFB8D8C8),       // Soft mint
    buttonWater: Color(0xFFC0C8E8),      // Periwinkle
    buttonStats: Color(0xFFD8C0E0),      // Lilac
    textPrimary: Color(0xFF5A5060),      // Dusky purple-gray
    textSecondary: Color(0xFF8A8090),    // Muted mauve
    accentCircles: [Color(0xFFF0D0E0), Color(0xFFD0D8F0), Color(0xFFD8E0D8)],
  );

  static RoomTheme get aurora => const RoomTheme(
    name: 'Aurora',
    description: 'Northern lights glow',
    primaryWave: Color(0xFF40E0D0),      // Bright teal aurora
    secondaryWave: Color(0xFF20B890),    // Deep green aurora
    accentBlob: Color(0xFF60F0C0),       // Glowing green
    accentBlob2: Color(0xFF8080D0),      // Soft purple
    background1: Color(0xFF1A2040),      // Deep navy
    background2: Color(0xFF152038),      // Darker navy
    background3: Color(0xFF101830),      // Deepest blue
    waterTop: Color(0xFF304858),         // Dark teal
    waterMid: Color(0xFF283848),         // Deeper teal
    waterBottom: Color(0xFF202838),      // Deep blue-gray
    sand: Color(0xFF384048),             // Dark sand
    plantPrimary: Color(0xFF40C090),     // Aurora green
    plantSecondary: Color(0xFF60D0A0),   // Lighter aurora
    fish1: Color(0xFF60E0C0),            // Teal fish
    fish2: Color(0xFF80A0E0),            // Blue fish
    fish3: Color(0xFFA080D0),            // Purple fish
    glassCard: Color(0x20FFFFFF),        // Dark frosted
    glassBorder: Color(0x3040E0D0),      // Teal glow border
    gaugeColor1: Color(0xFF40E0D0),      // Teal gauge
    gaugeColor2: Color(0xFF60D0A0),      // Green gauge
    gaugeColor3: Color(0xFF8080D0),      // Purple gauge
    buttonFeed: Color(0xFF60E0C0),       // Teal
    buttonTest: Color(0xFF40C090),       // Green
    buttonWater: Color(0xFF6090D0),      // Blue
    buttonStats: Color(0xFF9070C0),      // Purple
    textPrimary: Color(0xFFE0F0F0),      // Light cyan
    textSecondary: Color(0xFFA0C0C0),    // Muted cyan
    accentCircles: [Color(0xFF40E0D0), Color(0xFF60D0A0), Color(0xFF8080D0)],
  );

  static RoomTheme get golden => const RoomTheme(
    name: 'Golden Hour',
    description: 'Warm sunset glow',
    primaryWave: Color(0xFFF0C080),      // Amber wave
    secondaryWave: Color(0xFFE8A868),    // Peach wave
    accentBlob: Color(0xFFFFD090),       // Golden blob
    accentBlob2: Color(0xFFF8E0C0),      // Cream blob
    background1: Color(0xFFF8D8A0),      // Warm amber
    background2: Color(0xFFF0C888),      // Golden peach
    background3: Color(0xFFE8B878),      // Deeper amber
    waterTop: Color(0xFFF8E8D0),         // Cream water
    waterMid: Color(0xFFF0D8C0),         // Warm beige
    waterBottom: Color(0xFFE8C8B0),      // Sandy tone
    sand: Color(0xFFFFF0E0),             // Warm white
    plantPrimary: Color(0xFF90B878),     // Warm sage
    plantSecondary: Color(0xFFA8C888),   // Light green
    fish1: Color(0xFFE89060),            // Coral fish
    fish2: Color(0xFFF0A870),            // Peach fish
    fish3: Color(0xFFD08050),            // Amber fish
    glassCard: Color(0x30FFFFFF),        // Warm frosted
    glassBorder: Color(0x50FFFFFF),      // Soft border
    gaugeColor1: Color(0xFFF0B060),      // Gold gauge
    gaugeColor2: Color(0xFFE89868),      // Coral gauge
    gaugeColor3: Color(0xFFD8A878),      // Tan gauge
    buttonFeed: Color(0xFFE89060),       // Coral
    buttonTest: Color(0xFF90B878),       // Sage
    buttonWater: Color(0xFFD0B8A0),      // Tan
    buttonStats: Color(0xFFC08868),      // Amber
    textPrimary: Color(0xFF5A4030),      // Warm brown
    textSecondary: Color(0xFF8A7060),    // Muted brown
    accentCircles: [Color(0xFFFFD090), Color(0xFFF0B060), Color(0xFFE8C0A0)],
  );

  static RoomTheme fromType(RoomThemeType type) {
    switch (type) {
      case RoomThemeType.ocean:
        return ocean;
      case RoomThemeType.pastel:
        return pastel;
      case RoomThemeType.sunset:
        return sunset;
      case RoomThemeType.midnight:
        return midnight;
      case RoomThemeType.forest:
        return forest;
      case RoomThemeType.dreamy:
        return dreamy;
      case RoomThemeType.watercolor:
        return watercolor;
      case RoomThemeType.cotton:
        return cotton;
      case RoomThemeType.aurora:
        return aurora;
      case RoomThemeType.golden:
        return golden;
    }
  }

  static List<RoomTheme> get allThemes => [
    ocean,
    pastel,
    sunset,
    midnight,
    forest,
    dreamy,
    watercolor,
    cotton,
    aurora,
    golden,
  ];
}
