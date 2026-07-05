import 'package:flutter/services.dart';

Future<void>? _loadedFonts;

Future<void> loadDanioTestFonts() {
  return _loadedFonts ??= _loadDanioTestFonts();
}

Future<void> _loadDanioTestFonts() async {
  final nunito = FontLoader('Nunito')
    ..addFont(rootBundle.load('assets/fonts/Nunito-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Nunito-Italic.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Nunito-Medium.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Nunito-SemiBold.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Nunito-Bold.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Nunito-ExtraBold.ttf'));

  final fredoka = FontLoader('Fredoka')
    ..addFont(rootBundle.load('assets/fonts/Fredoka-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Fredoka-SemiBold.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Fredoka-Bold.ttf'));

  await Future.wait([nunito.load(), fredoka.load()]);
}
