# Tool Entry Consolidation QA - 2026-05-24

## Baseline

- Branch: `polish/tool-entry-consolidation`
- Device target: `emulator-5556`
- Baseline `flutter analyze --no-pub`: pass
- Baseline `flutter test`: pass
- Baseline `flutter test integration_test/smoke_test_v2.dart -d emulator-5556`: pass
- Normal debug APK rebuilt and installed after integration smoke.
- Initial screenshot: `docs/qa/screenshots/tool-entry-consolidation-2026-05-24/before/launch.png`
- Initial UI XML: `docs/qa/screenshots/danio-baseline-ui.xml`
- Note: the emulator was at the fresh consent gate when baseline screenshots were captured.

## Entry-Point Matrix

| Tool | Canonical Home | Kept Contextual Shortcuts | Removed/Demoted Entries | Coverage |
| --- | --- | --- | --- | --- |
| Water Change Calculator | Workshop | None from Tank bottom sheet | Tank bottom-sheet direct calculator card | `tool_entry_points_contract_test.dart` |
| Stocking Calculator | Workshop | None from Tank bottom sheet | Tank bottom-sheet direct calculator card | `tool_entry_points_contract_test.dart` |
| CO2 Calculator | Workshop | None from Tank bottom sheet | Tank bottom-sheet direct calculator card | `tool_entry_points_contract_test.dart` |
| Local Compatibility Checker | Workshop | Smart offline card opens Workshop | Tank bottom-sheet direct calculator card | `smart_screen_test.dart`, `tool_entry_points_contract_test.dart` |
| Cycling Assistant | Workshop | Tank Detail cycling status card | None | `danio_tool_catalog_test.dart` |
| Cost Tracker | Workshop | None | Tank Detail overflow entry | `tool_entry_points_contract_test.dart` |
| Reminders | Tank Detail | Tank Toolbox | None | `tool_entry_points_contract_test.dart` |
| Tank Journal | Tank Detail | Tank Toolbox and Tank Detail header | None | `tool_entry_points_contract_test.dart` |
| Analytics | More | None from Tank Toolbox | Tank Toolbox entry | `tool_entry_points_contract_test.dart` |
| Species Search | User browsing/search surfaces | None from Tank Toolbox | Tank Toolbox entry | `tool_entry_points_contract_test.dart` |
| Backup & Restore | More | None from Preferences | Preferences duplicate tile | `settings_screen_test.dart`, `tool_entry_points_contract_test.dart` |
| AI Compatibility Advice | Smart | Smart configured AI section | None | `smart_screen_test.dart`, `tool_entry_points_contract_test.dart` |

## Phase Notes

- Added `DanioToolId`, `DanioToolHome`, `DanioToolEntryKind`, and `DanioToolDefinition` in the tool catalog.
- Added catalog tests proving each major tool has one canonical home.
- Added source-contract tests for Tank Detail, Tank Toolbox, Tank bottom sheet, Preferences, and Smart compatibility labels.
- Tightened Smart feature-card text to one line with ellipsis so the clearer local compatibility label stays clear of the bottom dock on phone-sized screens.

## Verification

- Focused tests:
  - `flutter test test/navigation/danio_tool_catalog_test.dart test/screens/tool_entry_points_contract_test.dart test/widget_tests/smart_screen_test.dart test/widget_tests/tank_detail_screen_test.dart test/widget/settings_screen_test.dart test/widget_tests/tab_navigator_test.dart test/widgets/stage/swiss_army_panel_test.dart`
  - Result: pass
- `flutter analyze --no-pub`: pass
- Full `flutter test`: pass
- `flutter test integration_test/smoke_test_v2.dart -d emulator-5556`: pass
  - Note: the first install attempt reported emulator storage pressure, then Flutter recovered by uninstalling/reinstalling the app and the smoke test completed.
- `flutter build apk --debug --target lib/main.dart`: pass
- Normal debug APK installed on `emulator-5556`: pass

## Manual Emulator Evidence

- Fresh launch after normal APK install: `docs/qa/screenshots/tool-entry-consolidation-2026-05-24/after/current-launch.png`
- Consent/onboarding checkpoint: `docs/qa/screenshots/tool-entry-consolidation-2026-05-24/after/after-consent.png`, `docs/qa/screenshots/tool-entry-consolidation-2026-05-24/after/after-onboarding.png`
- Smart: `docs/qa/screenshots/tool-entry-consolidation-2026-05-24/after/smart.png`
  - XML confirms `Workshop Compatibility Checker`.
- More: `docs/qa/screenshots/tool-entry-consolidation-2026-05-24/after/more.png`
  - XML confirms `Workshop`, `Analytics`, and `Preferences` remain in the global hub.
- Preferences: `docs/qa/screenshots/tool-entry-consolidation-2026-05-24/after/settings.png`
  - Current viewport confirms settings-focused content and no duplicate Backup & Restore tile visible.
- Workshop: `docs/qa/screenshots/tool-entry-consolidation-2026-05-24/after/workshop.png`
- Tank tab: `docs/qa/screenshots/tool-entry-consolidation-2026-05-24/after/tank-tab.png`
- Tank Toolbox: `docs/qa/screenshots/tool-entry-consolidation-2026-05-24/after/tank-toolbox.png`
  - XML confirms only `Reminders` and `Tank Journal`; no `Analytics` or `Species Search`.
- Logcat scan after manual pass:
  - No `FATAL EXCEPTION`, `FlutterError`, `Unhandled Exception`, or widget exception entries found.
  - `AndroidRuntime` matches were routine `monkey`/`uiautomator` command startup and shutdown lines, not app crashes.

## Open QA

- Phone review can repeat the same changed surfaces once a physical device is available.
