import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/room_themes.dart';

/// Provider for room visual theme selection
final roomThemeProvider = StateNotifierProvider<RoomThemeNotifier, RoomThemeType>((ref) {
  return RoomThemeNotifier();
});

/// Convenience provider to get the actual theme data
final currentRoomThemeProvider = Provider<RoomTheme>((ref) {
  final themeType = ref.watch(roomThemeProvider);
  return RoomTheme.fromType(themeType);
});

class RoomThemeNotifier extends StateNotifier<RoomThemeType> {
  RoomThemeNotifier() : super(RoomThemeType.ocean) {
    _loadTheme();
  }

  static const _key = 'room_theme';

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_key) ?? 0;
    if (themeIndex < RoomThemeType.values.length) {
      state = RoomThemeType.values[themeIndex];
    }
  }

  Future<void> setTheme(RoomThemeType theme) async {
    state = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, theme.index);
  }

  void nextTheme() {
    final nextIndex = (state.index + 1) % RoomThemeType.values.length;
    setTheme(RoomThemeType.values[nextIndex]);
  }
}
