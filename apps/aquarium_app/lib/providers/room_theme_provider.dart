import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_profile_provider.dart';
import '../theme/room_themes.dart';
import '../utils/logger.dart';

/// Provider for room visual theme selection
final roomThemeProvider =
    StateNotifierProvider<RoomThemeNotifier, RoomThemeType>((ref) {
      return RoomThemeNotifier(ref);
    });

/// Convenience provider to get the actual theme data
final currentRoomThemeProvider = Provider<RoomTheme>((ref) {
  final themeType = ref.watch(roomThemeProvider);
  return RoomTheme.fromType(themeType);
});

class RoomThemeNotifier extends StateNotifier<RoomThemeType> {
  final Ref ref;
  RoomThemeNotifier(this.ref) : super(RoomThemeType.golden) {
    _loadTheme();
  }

  static const _key = 'room_theme';

  Future<void> _loadTheme() async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final themeIndex = prefs.getInt(_key) ?? 0;
      if (themeIndex < RoomThemeType.values.length) {
        state = RoomThemeType.values[themeIndex];
      }
    } catch (e) {
      // If loading fails, keep default theme (ocean)
      // Don't crash the app for a cosmetic preference
      logError('Failed to load room theme preference: $e', tag: 'RoomThemeProvider');
    }
  }

  Future<void> setTheme(RoomThemeType theme) async {
    state = theme;
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await prefs.setInt(_key, theme.index);
    } catch (e) {
      // Theme is already set in state, just log the save failure
      // User will see the change but it won't persist
      logError('Failed to save room theme preference: $e', tag: 'RoomThemeProvider');
    }
  }

  void nextTheme() {
    final nextIndex = (state.index + 1) % RoomThemeType.values.length;
    setTheme(RoomThemeType.values[nextIndex]);
  }
}
