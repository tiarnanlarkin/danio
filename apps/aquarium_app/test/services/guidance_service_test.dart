import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/services/guidance_service.dart';

Future<GuidanceService> _service(Map<String, Object> initialValues) async {
  SharedPreferences.setMockInitialValues(initialValues);
  final prefs = await SharedPreferences.getInstance();
  return GuidanceService(prefs);
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
