/// User-facing tool ownership contract for Danio.
///
/// This is intentionally small: it describes where each major tool lives and
/// which entry kinds are allowed, so duplicate entry points can be reviewed
/// against one source of truth.
library;

enum DanioToolId {
  waterChangeCalculator,
  stockingCalculator,
  co2Calculator,
  dosingCalculator,
  unitConverter,
  tankVolumeCalculator,
  lightingPlanner,
  localCompatibilityChecker,
  cyclingAssistant,
  costTracker,
  waterTestLog,
  feedingLog,
  waterChangeLog,
  tankNote,
  tankTasks,
  tankReminders,
  tankCharts,
  tankGallery,
  tankJournal,
  livestock,
  equipment,
  tankSettings,
  compareTanks,
  estimateLivestockValue,
  fishPlantId,
  symptomTriage,
  weeklyCarePlan,
  askDanio,
  aiCompatibilityAdvice,
  anomalyHistory,
  shopStreet,
  gemShop,
  achievements,
  workshop,
  analytics,
  backupRestore,
  preferences,
  about,
  notificationSettings,
  aiConfiguration,
  appearanceSettings,
  privacyControls,
  destructiveDataControls,
}

enum DanioToolHome {
  learn,
  practice,
  tank,
  tankDetail,
  smart,
  more,
  workshop,
  preferences,
}

enum DanioToolEntryKind { canonical, contextualShortcut, relatedStatus }

class DanioToolDefinition {
  final DanioToolId id;
  final String title;
  final DanioToolHome canonicalHome;
  final Set<DanioToolEntryKind> entryKinds;

  const DanioToolDefinition({
    required this.id,
    required this.title,
    required this.canonicalHome,
    this.entryKinds = const {DanioToolEntryKind.canonical},
  });

  bool allows(DanioToolEntryKind kind) => entryKinds.contains(kind);
}

const List<DanioToolDefinition> danioToolDefinitions = [
  DanioToolDefinition(
    id: DanioToolId.waterChangeCalculator,
    title: 'Water Change',
    canonicalHome: DanioToolHome.workshop,
  ),
  DanioToolDefinition(
    id: DanioToolId.stockingCalculator,
    title: 'Stocking',
    canonicalHome: DanioToolHome.workshop,
  ),
  DanioToolDefinition(
    id: DanioToolId.co2Calculator,
    title: 'CO2 Calculator',
    canonicalHome: DanioToolHome.workshop,
  ),
  DanioToolDefinition(
    id: DanioToolId.dosingCalculator,
    title: 'Dosing',
    canonicalHome: DanioToolHome.workshop,
  ),
  DanioToolDefinition(
    id: DanioToolId.unitConverter,
    title: 'Unit Converter',
    canonicalHome: DanioToolHome.workshop,
  ),
  DanioToolDefinition(
    id: DanioToolId.tankVolumeCalculator,
    title: 'Tank Volume',
    canonicalHome: DanioToolHome.workshop,
  ),
  DanioToolDefinition(
    id: DanioToolId.lightingPlanner,
    title: 'Lighting',
    canonicalHome: DanioToolHome.workshop,
  ),
  DanioToolDefinition(
    id: DanioToolId.localCompatibilityChecker,
    title: 'Workshop Compatibility Checker',
    canonicalHome: DanioToolHome.workshop,
  ),
  DanioToolDefinition(
    id: DanioToolId.cyclingAssistant,
    title: 'Cycling Assistant',
    canonicalHome: DanioToolHome.workshop,
    entryKinds: {
      DanioToolEntryKind.canonical,
      DanioToolEntryKind.contextualShortcut,
      DanioToolEntryKind.relatedStatus,
    },
  ),
  DanioToolDefinition(
    id: DanioToolId.costTracker,
    title: 'Cost Tracker',
    canonicalHome: DanioToolHome.workshop,
  ),
  DanioToolDefinition(
    id: DanioToolId.waterTestLog,
    title: 'Water Test',
    canonicalHome: DanioToolHome.tank,
    entryKinds: {
      DanioToolEntryKind.canonical,
      DanioToolEntryKind.contextualShortcut,
    },
  ),
  DanioToolDefinition(
    id: DanioToolId.feedingLog,
    title: 'Feed',
    canonicalHome: DanioToolHome.tank,
    entryKinds: {
      DanioToolEntryKind.canonical,
      DanioToolEntryKind.contextualShortcut,
    },
  ),
  DanioToolDefinition(
    id: DanioToolId.waterChangeLog,
    title: 'Water Change Log',
    canonicalHome: DanioToolHome.tank,
    entryKinds: {
      DanioToolEntryKind.canonical,
      DanioToolEntryKind.contextualShortcut,
    },
  ),
  DanioToolDefinition(
    id: DanioToolId.tankNote,
    title: 'Tank Note',
    canonicalHome: DanioToolHome.tank,
    entryKinds: {
      DanioToolEntryKind.canonical,
      DanioToolEntryKind.contextualShortcut,
    },
  ),
  DanioToolDefinition(
    id: DanioToolId.tankTasks,
    title: 'Tasks',
    canonicalHome: DanioToolHome.tankDetail,
  ),
  DanioToolDefinition(
    id: DanioToolId.tankReminders,
    title: 'Reminders',
    canonicalHome: DanioToolHome.tankDetail,
    entryKinds: {
      DanioToolEntryKind.canonical,
      DanioToolEntryKind.contextualShortcut,
    },
  ),
  DanioToolDefinition(
    id: DanioToolId.tankCharts,
    title: 'Charts',
    canonicalHome: DanioToolHome.tankDetail,
    entryKinds: {
      DanioToolEntryKind.canonical,
      DanioToolEntryKind.contextualShortcut,
    },
  ),
  DanioToolDefinition(
    id: DanioToolId.tankGallery,
    title: 'Gallery',
    canonicalHome: DanioToolHome.tankDetail,
  ),
  DanioToolDefinition(
    id: DanioToolId.tankJournal,
    title: 'Tank Journal',
    canonicalHome: DanioToolHome.tankDetail,
    entryKinds: {
      DanioToolEntryKind.canonical,
      DanioToolEntryKind.contextualShortcut,
    },
  ),
  DanioToolDefinition(
    id: DanioToolId.livestock,
    title: 'Livestock',
    canonicalHome: DanioToolHome.tankDetail,
  ),
  DanioToolDefinition(
    id: DanioToolId.equipment,
    title: 'Equipment',
    canonicalHome: DanioToolHome.tankDetail,
  ),
  DanioToolDefinition(
    id: DanioToolId.tankSettings,
    title: 'Tank Settings',
    canonicalHome: DanioToolHome.tankDetail,
  ),
  DanioToolDefinition(
    id: DanioToolId.compareTanks,
    title: 'Compare Tanks',
    canonicalHome: DanioToolHome.tankDetail,
  ),
  DanioToolDefinition(
    id: DanioToolId.estimateLivestockValue,
    title: 'Estimate Value',
    canonicalHome: DanioToolHome.tankDetail,
  ),
  DanioToolDefinition(
    id: DanioToolId.fishPlantId,
    title: 'Fish & Plant ID',
    canonicalHome: DanioToolHome.smart,
  ),
  DanioToolDefinition(
    id: DanioToolId.symptomTriage,
    title: 'Symptom Checker',
    canonicalHome: DanioToolHome.smart,
  ),
  DanioToolDefinition(
    id: DanioToolId.weeklyCarePlan,
    title: 'Weekly Care Plan',
    canonicalHome: DanioToolHome.smart,
  ),
  DanioToolDefinition(
    id: DanioToolId.askDanio,
    title: 'Ask Danio',
    canonicalHome: DanioToolHome.smart,
  ),
  DanioToolDefinition(
    id: DanioToolId.aiCompatibilityAdvice,
    title: 'AI Compatibility Advice',
    canonicalHome: DanioToolHome.smart,
  ),
  DanioToolDefinition(
    id: DanioToolId.anomalyHistory,
    title: 'Anomaly History',
    canonicalHome: DanioToolHome.smart,
  ),
  DanioToolDefinition(
    id: DanioToolId.shopStreet,
    title: 'Shop Street',
    canonicalHome: DanioToolHome.more,
  ),
  DanioToolDefinition(
    id: DanioToolId.gemShop,
    title: 'Gem Shop',
    canonicalHome: DanioToolHome.more,
  ),
  DanioToolDefinition(
    id: DanioToolId.achievements,
    title: 'Achievements',
    canonicalHome: DanioToolHome.more,
  ),
  DanioToolDefinition(
    id: DanioToolId.workshop,
    title: 'Workshop',
    canonicalHome: DanioToolHome.more,
  ),
  DanioToolDefinition(
    id: DanioToolId.analytics,
    title: 'Analytics',
    canonicalHome: DanioToolHome.more,
  ),
  DanioToolDefinition(
    id: DanioToolId.backupRestore,
    title: 'Backup & Restore',
    canonicalHome: DanioToolHome.more,
  ),
  DanioToolDefinition(
    id: DanioToolId.preferences,
    title: 'Preferences',
    canonicalHome: DanioToolHome.more,
  ),
  DanioToolDefinition(
    id: DanioToolId.about,
    title: 'About',
    canonicalHome: DanioToolHome.more,
  ),
  DanioToolDefinition(
    id: DanioToolId.notificationSettings,
    title: 'Phone Notifications',
    canonicalHome: DanioToolHome.preferences,
  ),
  DanioToolDefinition(
    id: DanioToolId.aiConfiguration,
    title: 'OpenAI API Key',
    canonicalHome: DanioToolHome.preferences,
  ),
  DanioToolDefinition(
    id: DanioToolId.appearanceSettings,
    title: 'Appearance & Accessibility',
    canonicalHome: DanioToolHome.preferences,
  ),
  DanioToolDefinition(
    id: DanioToolId.privacyControls,
    title: 'Privacy Controls',
    canonicalHome: DanioToolHome.preferences,
  ),
  DanioToolDefinition(
    id: DanioToolId.destructiveDataControls,
    title: 'Clear or Delete Data',
    canonicalHome: DanioToolHome.preferences,
  ),
];

DanioToolDefinition danioToolDefinition(DanioToolId id) {
  return danioToolDefinitions.firstWhere((definition) => definition.id == id);
}
