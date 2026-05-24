import 'package:flutter_test/flutter_test.dart';
import 'package:danio/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppTheme chip contrast', () {
    test('light chip labels use the readable primary text color', () {
      expect(AppTheme.light.chipTheme.labelStyle?.color, AppColors.textPrimary);
    });

    test('dark chip labels use the readable dark primary text color', () {
      expect(
        AppTheme.dark.chipTheme.labelStyle?.color,
        AppColors.textPrimaryDark,
      );
    });
  });
}
