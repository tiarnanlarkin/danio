import 'package:flutter/material.dart';

/// Room visual themes - different aesthetic styles
/// Users can switch themes in settings

enum RoomThemeType {
  ocean,      // Current teal/coral design
  pastel,     // Whimsical pastel (new)
  sunset,     // Warm oranges/purples
  midnight,   // Dark mode deep blues
  forest,     // Earthy greens/browns
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
    textSecondary: Color(0xB3FFFFFF),
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
    textSecondary: Color(0x99E8F0F8),
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
    }
  }

  static List<RoomTheme> get allThemes => [
    ocean,
    pastel,
    sunset,
    midnight,
    forest,
  ];
}
