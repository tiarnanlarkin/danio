import 'dart:io';

import 'package:danio/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

String _source(String path) => File(path).readAsStringSync();

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

  group('AppTheme local fonts', () {
    test('material text themes use bundled Fredoka and Nunito families', () {
      expect(AppTheme.light.textTheme.displayLarge?.fontFamily, 'Fredoka');
      expect(AppTheme.light.textTheme.headlineMedium?.fontFamily, 'Fredoka');
      expect(AppTheme.light.textTheme.titleLarge?.fontFamily, 'Fredoka');
      expect(AppTheme.light.textTheme.titleMedium?.fontFamily, 'Nunito');
      expect(AppTheme.light.textTheme.bodyMedium?.fontFamily, 'Nunito');
      expect(AppTheme.light.textTheme.labelSmall?.fontFamily, 'Nunito');

      expect(AppTheme.dark.textTheme.headlineSmall?.fontFamily, 'Fredoka');
      expect(AppTheme.dark.textTheme.bodySmall?.fontFamily, 'Nunito');
    });

    test('semantic typography aliases use bundled font families directly', () {
      expect(AppTypography.headlineLarge.fontFamily, 'Fredoka');
      expect(AppTypography.titleLarge.fontFamily, 'Fredoka');
      expect(AppTypography.titleMedium.fontFamily, 'Nunito');
      expect(AppTypography.bodyMedium.fontFamily, 'Nunito');
      expect(AppTypography.labelSmall.fontFamily, 'Nunito');
      expect(AppTypography.overline.fontFamily, 'Nunito');
      expect(AppTypography.lessonBody.fontFamily, 'Nunito');
      expect(AppTypography.lessonQuote.fontFamily, 'Nunito');
      expect(AppTypography.lessonQuote.fontStyle, FontStyle.italic);
    });

    test('theme font sources do not use the GoogleFonts runtime loader', () {
      for (final path in <String>[
        'lib/theme/app_typography.dart',
        'lib/theme/app_theme.dart',
        'lib/main.dart',
      ]) {
        final source = _source(path);
        expect(
          source,
          isNot(contains("package:google_fonts/google_fonts.dart")),
          reason: '$path still imports google_fonts',
        );
        expect(
          source,
          isNot(contains('GoogleFonts.')),
          reason: '$path still calls GoogleFonts',
        );
      }
    });
  });
}
