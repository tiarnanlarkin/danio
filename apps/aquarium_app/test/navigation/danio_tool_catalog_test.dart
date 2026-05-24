import 'package:flutter_test/flutter_test.dart';

import 'package:danio/navigation/danio_tool_catalog.dart';

void main() {
  test('every major tool has one canonical ownership definition', () {
    final ids = danioToolDefinitions
        .map((definition) => definition.id)
        .toList();

    expect(ids.toSet(), hasLength(DanioToolId.values.length));
    for (final id in DanioToolId.values) {
      final matches = danioToolDefinitions.where(
        (definition) => definition.id == id,
      );
      expect(matches, hasLength(1), reason: id.name);
      expect(
        matches.single.entryKinds,
        contains(DanioToolEntryKind.canonical),
        reason: id.name,
      );
    }
  });

  test('Workshop owns calculators and planning tools', () {
    const workshopTools = {
      DanioToolId.waterChangeCalculator,
      DanioToolId.stockingCalculator,
      DanioToolId.co2Calculator,
      DanioToolId.dosingCalculator,
      DanioToolId.unitConverter,
      DanioToolId.tankVolumeCalculator,
      DanioToolId.lightingPlanner,
      DanioToolId.localCompatibilityChecker,
      DanioToolId.cyclingAssistant,
      DanioToolId.costTracker,
    };

    for (final id in workshopTools) {
      expect(danioToolDefinition(id).canonicalHome, DanioToolHome.workshop);
    }
  });

  test('Tank and Tank Detail own tank-specific care workflows', () {
    const tankTools = {
      DanioToolId.waterTestLog,
      DanioToolId.feedingLog,
      DanioToolId.waterChangeLog,
      DanioToolId.tankNote,
      DanioToolId.tankTasks,
      DanioToolId.tankReminders,
      DanioToolId.tankCharts,
      DanioToolId.tankGallery,
      DanioToolId.tankJournal,
      DanioToolId.livestock,
      DanioToolId.equipment,
      DanioToolId.tankSettings,
      DanioToolId.compareTanks,
      DanioToolId.estimateLivestockValue,
    };

    for (final id in tankTools) {
      expect(
        danioToolDefinition(id).canonicalHome,
        anyOf(DanioToolHome.tank, DanioToolHome.tankDetail),
      );
    }
  });

  test('Smart owns AI tools and More owns global hubs', () {
    const smartTools = {
      DanioToolId.fishPlantId,
      DanioToolId.symptomTriage,
      DanioToolId.weeklyCarePlan,
      DanioToolId.askDanio,
      DanioToolId.aiCompatibilityAdvice,
      DanioToolId.anomalyHistory,
    };

    for (final id in smartTools) {
      expect(danioToolDefinition(id).canonicalHome, DanioToolHome.smart);
    }

    const moreTools = {
      DanioToolId.shopStreet,
      DanioToolId.gemShop,
      DanioToolId.achievements,
      DanioToolId.workshop,
      DanioToolId.analytics,
      DanioToolId.backupRestore,
      DanioToolId.preferences,
      DanioToolId.about,
    };

    for (final id in moreTools) {
      expect(danioToolDefinition(id).canonicalHome, DanioToolHome.more);
    }
  });
}
