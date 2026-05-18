import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Home keeps Tank guidance quiet and unstacked', () {
    final source = File('lib/screens/home/home_screen.dart').readAsStringSync();

    expect(source, isNot(contains('DailyNudgeBanner')));
    expect(source, isNot(contains('AmbientTipOverlay')));
    expect(source, isNot(contains('StreakHeartsOverlay')));
    expect(source, isNot(contains('WelcomeBanner')));
    expect(source, isNot(contains('ComebackBanner')));
    expect(source, isNot(contains('has_seen_welcome_banner')));
    expect(RegExp(r'FirstVisitTooltip\(').allMatches(source), hasLength(1));
    expect(source, isNot(contains('tooltip_seen_tank')));
    expect(source, isNot(contains('tooltip_seen_hearts')));
    expect(source, isNot(contains('tooltip_seen_room_metaphor')));
  });
}
