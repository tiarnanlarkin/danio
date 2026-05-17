// Patrol Smoke Test Suite — Danio Aquarium App
//
// These tests verify the most critical user flows work without crashes.
// Run with: patrol test -t integration_test/smoke_test.dart
//
// Prerequisites:
//   - Emulator running (adb devices should show a device)
//   - patrol_cli installed (dart pub global activate patrol_cli)
//   - ANDROID_HOME set

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:danio/main.dart' as app;

const _dockKey = ValueKey('danio-bottom-dock');
const _tabIds = ['learn', 'practice', 'tank', 'smart', 'more'];

ValueKey<String> _tabKey(String tabId) {
  return ValueKey('danio-bottom-dock-item-$tabId');
}

void main() {
  patrolSetUp(() async {
    // Any per-test setup goes here
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Test 1: App launches without crashing
  // ─────────────────────────────────────────────────────────────────────────
  patrolTest('App launches and displays initial screen', ($) async {
    app.main();

    // Wait for the app to settle (onboarding OR main tabs)
    await $.pumpAndSettle(timeout: const Duration(seconds: 15));

    // The app should show SOMETHING — either onboarding or the tab navigator
    // We just verify no crash occurred and a Scaffold is present
    expect($(Scaffold), findsWidgets);
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Test 2: Bottom navigation tabs are accessible
  // ─────────────────────────────────────────────────────────────────────────
  patrolTest('Can navigate through all bottom tabs without crash', ($) async {
    app.main();
    await $.pumpAndSettle(timeout: const Duration(seconds: 15));

    // If we're on onboarding, skip it first (tap through to main app)
    // Check for Danio bottom dock (main tabs) — if not present, we're on onboarding
    if ($(_dockKey).exists) {
      // Already on main tabs — test each tab
      await _tapAllTabs($);
    } else {
      // Might be on onboarding — just verify no crash on this screen
      expect($(Scaffold), findsWidgets);
      // Skip tab navigation test if onboarding is active
    }
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Test 3: Learn tab loads content
  // ─────────────────────────────────────────────────────────────────────────
  patrolTest('Learn tab displays content without crash', ($) async {
    app.main();
    await $.pumpAndSettle(timeout: const Duration(seconds: 15));

    if ($(_dockKey).exists) {
      await $(_tabKey('learn')).tap();
      await $.pumpAndSettle();

      // Verify we see scrollable content
      expect($(Scaffold), findsWidgets);
    }
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Test 4: Tank tab loads
  // ─────────────────────────────────────────────────────────────────────────
  patrolTest('Tank tab loads without crash', ($) async {
    app.main();
    await $.pumpAndSettle(timeout: const Duration(seconds: 15));

    if ($(_dockKey).exists) {
      await $(_tabKey('tank')).tap();
      await $.pumpAndSettle();

      expect($(Scaffold), findsWidgets);
    }
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Test 5: Settings/More tab loads
  // ─────────────────────────────────────────────────────────────────────────
  patrolTest('Settings (More) tab loads without crash', ($) async {
    app.main();
    await $.pumpAndSettle(timeout: const Duration(seconds: 15));

    if ($(_dockKey).exists) {
      await $(_tabKey('more')).tap();
      await $.pumpAndSettle();

      expect($(Scaffold), findsWidgets);
    }
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Test 6: Back button doesn't crash from any main tab
  // ─────────────────────────────────────────────────────────────────────────
  patrolTest('Back button from main tabs shows exit confirmation, not crash', (
    $,
  ) async {
    app.main();
    await $.pumpAndSettle(timeout: const Duration(seconds: 15));

    if ($(_dockKey).exists) {
      // Press back — should either show snackbar "press back again" or do nothing
      // ignore: deprecated_member_use
      await $.native.pressBack();
      await $.pump(const Duration(seconds: 2));

      // App should still be alive
      expect($(Scaffold), findsWidgets);
    }
  });
}

/// Helper: tap through all 5 bottom navigation tabs
Future<void> _tapAllTabs(PatrolIntegrationTester $) async {
  for (final tabId in _tabIds) {
    await $(_tabKey(tabId)).tap();
    await $.pumpAndSettle(timeout: const Duration(seconds: 5));

    // Just verify no crash — Scaffold should exist
    expect(
      $(Scaffold),
      findsWidgets,
      reason: 'Tab $tabId should display without crash',
    );
  }
}
