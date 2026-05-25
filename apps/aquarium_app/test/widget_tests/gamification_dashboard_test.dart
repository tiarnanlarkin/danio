import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/models/user_profile.dart';
import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/widgets/gamification_dashboard.dart';

UserProfile _profile() => UserProfile(
  id: 'u_test',
  name: 'Test User',
  totalXp: 35,
  dailyXpGoal: 50,
  currentStreak: 1,
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
);

Widget _wrap() {
  SharedPreferences.setMockInitialValues({
    'user_profile': jsonEncode(_profile().toJson()),
  });

  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) async {
        return SharedPreferences.getInstance();
      }),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SizedBox(width: 360, child: GamificationDashboard()),
      ),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('compact stat labels scale instead of ellipsizing', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    for (final label in ['gems', 'today']) {
      final text = tester.widget<Text>(find.text(label));
      expect(text.overflow, isNot(TextOverflow.ellipsis));
    }
  });
}
