import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/services/guidance_service.dart';

Future<GuidanceService> _service(Map<String, Object> initialValues) async {
  SharedPreferences.setMockInitialValues(initialValues);
  final prefs = await SharedPreferences.getInstance();
  return GuidanceService(prefs);
}

class _FalseGuidancePrefs implements SharedPreferences {
  _FalseGuidancePrefs(this._delegate, this._shouldFail);

  final SharedPreferences _delegate;
  final bool Function(String key) _shouldFail;

  @override
  bool? getBool(String key) => _delegate.getBool(key);

  @override
  String? getString(String key) => _delegate.getString(key);

  @override
  Future<bool> setBool(String key, bool value) async {
    if (_shouldFail(key)) return false;
    return _delegate.setBool(key, value);
  }

  @override
  Future<bool> setString(String key, String value) async {
    if (_shouldFail(key)) return false;
    return _delegate.setString(key, value);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('GuidanceService', () {
    test(
      'migrates old Tank tooltip keys so existing users are not re-prompted',
      () async {
        final service = await _service({'tooltip_seen_tank': true});

        final decision = await service.shouldShow(
          GuidancePromptId.tankStageHandles,
          const GuidanceContext(surface: GuidanceSurface.tank),
        );

        expect(decision.shouldShow, isFalse);
        expect(
          service.prefs.getBool(
            GuidanceService.storageKey(GuidancePromptId.tankStageHandles),
          ),
          isTrue,
        );
      },
    );

    test(
      'does not show Practice guidance until practice has usable cards',
      () async {
        final service = await _service({});

        final decision = await service.shouldShow(
          GuidancePromptId.practiceFirstUsefulVisit,
          const GuidanceContext(
            surface: GuidanceSurface.practice,
            practiceCardCount: 0,
          ),
        );

        expect(decision.shouldShow, isFalse);
      },
    );

    test(
      'shows Practice guidance once cards exist and it has not been seen',
      () async {
        final service = await _service({});

        final decision = await service.shouldShow(
          GuidancePromptId.practiceFirstUsefulVisit,
          const GuidanceContext(
            surface: GuidanceSurface.practice,
            practiceCardCount: 3,
          ),
        );

        expect(decision.shouldShow, isTrue);
      },
    );

    test('markDismissed persists a prompt forever', () async {
      final service = await _service({});

      await service.markDismissed(GuidancePromptId.learnFirstVisit);

      final decision = await service.shouldShow(
        GuidancePromptId.learnFirstVisit,
        const GuidanceContext(surface: GuidanceSurface.learn),
      );

      expect(decision.shouldShow, isFalse);
    });

    test('markDismissed surfaces failed forever writes', () async {
      SharedPreferences.setMockInitialValues({});
      final delegate = await SharedPreferences.getInstance();
      final prefs = _FalseGuidancePrefs(
        delegate,
        (key) =>
            key ==
            GuidanceService.storageKey(
              GuidancePromptId.learnFirstVisit,
            ),
      );
      final service = GuidanceService(prefs);

      await expectLater(
        service.markDismissed(GuidancePromptId.learnFirstVisit),
        throwsA(isA<StateError>()),
      );

      expect(
        delegate.getBool(
          GuidanceService.storageKey(GuidancePromptId.learnFirstVisit),
        ),
        isNull,
      );
    });

    test('markDismissed surfaces failed day-scope writes', () async {
      SharedPreferences.setMockInitialValues({});
      final delegate = await SharedPreferences.getInstance();
      final prefs = _FalseGuidancePrefs(
        delegate,
        (key) =>
            key ==
            GuidanceService.dayStorageKey(
              GuidancePromptId.practiceFirstUsefulVisit,
            ),
      );
      final service = GuidanceService(prefs);

      await expectLater(
        service.markDismissed(
          GuidancePromptId.practiceFirstUsefulVisit,
          scope: GuidanceDismissalScope.day,
        ),
        throwsA(isA<StateError>()),
      );

      expect(
        delegate.getString(
          GuidanceService.dayStorageKey(
            GuidancePromptId.practiceFirstUsefulVisit,
          ),
        ),
        isNull,
      );
    });

    test(
      'firstEligiblePrompt returns only the first eligible prompt',
      () async {
        final service = await _service({});

        final prompt = await service.firstEligiblePrompt(const [
          GuidancePromptId.learnFirstVisit,
          GuidancePromptId.smartFirstVisit,
        ], const GuidanceContext(surface: GuidanceSurface.learn));

        expect(prompt, GuidancePromptId.learnFirstVisit);
      },
    );
  });
}
