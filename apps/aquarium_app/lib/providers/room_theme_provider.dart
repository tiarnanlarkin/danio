import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/room_themes.dart';

/// Provider for room visual theme selection
final roomThemeProvider =
    StateNotifierProvider<RoomThemeNotifier, RoomThemeType>((ref) {
      return RoomThemeNotifier();
    });

/// Convenience provider to get the actual theme data
final currentRoomThemeProvider = Provider<RoomTheme>((ref) {
  final themeType = ref.watch(roomThemeProvider);
  return RoomTheme.fromType(themeType);
});

class RoomThemeNotifier extends StateNotifier<RoomThemeType> {
  RoomThemeNotifier() : super(RoomThemeType.golden) {
    _loadTheme();
  }

  static const _key = 'room_theme';

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_key) ?? 0;
      if (themeIndex < RoomThemeType.values.length) {
        state = RoomThemeType.values[themeIndex];
      }
    } catch (e) {
      // If loading fails, keep default theme (ocean)
      // Don't crash the app for a cosmetic preference
      debugPrint('Failed to load room theme preference: $e');
    }
  }

  Future<void> setTheme(RoomThemeType theme) async {
    state = theme;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_key, theme.index);
    } catch (e) {
      // Theme is already set in state, just log the save failure
      // User will see the change but it won't persist
      debugPrint('Failed to save room theme preference: $e');
    }
  }

  void nextTheme() {
    final nextIndex = (state.index + 1) % RoomThemeType.values.length;
    setTheme(RoomThemeType.values[nextIndex]);
  }
}
