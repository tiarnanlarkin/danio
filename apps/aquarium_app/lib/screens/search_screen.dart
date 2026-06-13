import 'dart:async';
import '../utils/app_constants.dart';
import '../widgets/core/app_states.dart';
import 'package:flutter/material.dart';
import '../widgets/core/bubble_loader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/species_database.dart';
import '../models/models.dart';
import '../navigation/danio_tool_catalog.dart';
import '../providers/lesson_provider.dart';
import '../providers/tank_provider.dart';
import '../theme/app_theme.dart';
import '../navigation/app_routes.dart';
import '../utils/log_entry_display.dart';
import 'emergency_guide_screen.dart';
import 'livestock_detail_screen.dart';
import '../utils/navigation_throttle.dart';
import '../widgets/app_bottom_sheet.dart';
import 'about_screen.dart';
import 'achievements_screen.dart';
import 'acclimation_guide_screen.dart';
import 'algae_guide_screen.dart';
import 'analytics_screen.dart';
import 'backup_restore_screen.dart';
import 'breeding_guide_screen.dart';
import 'co2_calculator_screen.dart';
import 'compatibility_checker_screen.dart';
import 'cost_tracker_screen.dart';
import 'cycling_assistant_screen.dart';
import 'disease_guide_screen.dart';
import 'dosing_calculator_screen.dart';
import 'equipment_guide_screen.dart';
import 'faq_screen.dart';
import 'feeding_guide_screen.dart';
import 'gem_shop_screen.dart';
import 'glossary_screen.dart';
import 'hardscape_guide_screen.dart';
import 'learn_screen.dart';
import 'lighting_schedule_screen.dart';
import 'nitrogen_cycle_guide_screen.dart';
import 'notification_settings_screen.dart';
import 'parameter_guide_screen.dart';
import 'plant_browser_screen.dart';
import 'privacy_policy_screen.dart';
import 'quick_start_guide_screen.dart';
import 'quarantine_guide_screen.dart';
import 'settings_hub_screen.dart';
import 'settings_screen.dart';
import 'shop_street_screen.dart';
import 'smart_screen.dart';
import 'species_browser_screen.dart';
import 'stocking_calculator_screen.dart';
import 'substrate_guide_screen.dart';
import 'tank_volume_calculator_screen.dart';
import 'unit_converter_screen.dart';
import 'vacation_guide_screen.dart';
import 'water_change_calculator_screen.dart';
import 'workshop_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tanksAsync = ref.watch(tanksProvider);

    return GestureDetector(
      excludeFromSemantics: true,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Search tanks, fish, equipment, guides...',
              border: InputBorder.none,
              filled: false,
            ),
            onChanged: (value) {
              _debounce?.cancel();
              _debounce = Timer(kDebounceDuration, () {
                setState(() => _query = value.toLowerCase());
              });
            },
          ),
          actions: [
            if (_query.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear),
                tooltip: 'Clear search',
                onPressed: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
              ),
          ],
        ),
        body: _query.isEmpty
            ? _EmptySearchState()
            : tanksAsync.when(
                loading: () => const Center(child: BubbleLoader()),
                error: (e, _) => AppErrorState(
                  message: "Couldn't search right now. Tap to try again.",
                  onRetry: () => ref.invalidate(tanksProvider),
                ),
                data: (tanks) =>
                    _SearchResults(query: _query, tanks: tanks, ref: ref),
              ),
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search, size: AppIconSizes.xxl, color: context.textHint),
          const SizedBox(height: AppSpacing.md),
          Text('Search your aquarium data', style: AppTypography.bodyMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Find tanks, fish, equipment, guides, or browse species',
            style: AppTypography.bodySmall,
          ),
        ],
      ),
    );
  }
}

final List<_SearchDestination> _searchDestinations = [
  _SearchDestination(
    type: _ResultType.app,
    titleOverride: 'More',
    subtitle: 'Rewards, tools, settings, backups, and app details',
    icon: Icons.dashboard_customize_outlined,
    color: AppColors.secondary,
    keywords: const ['settings hub', 'menu', 'account', 'profile'],
    screenBuilder: (_) => const SettingsHubScreen(),
  ),
  _SearchDestination(
    type: _ResultType.app,
    toolId: DanioToolId.backupRestore,
    subtitle: 'Export, import, and protect local aquarium backups',
    icon: Icons.backup,
    color: AppColors.info,
    keywords: const ['restore', 'import', 'export', 'zip', 'data safety'],
    screenBuilder: (_) => const BackupRestoreScreen(),
  ),
  _SearchDestination(
    type: _ResultType.app,
    toolId: DanioToolId.preferences,
    subtitle: 'Units, theme, accessibility, AI, privacy, and data controls',
    icon: Icons.settings,
    color: AppColors.secondary,
    keywords: const ['settings', 'units', 'theme', 'accessibility'],
    screenBuilder: (_) => const SettingsScreen(),
  ),
  _SearchDestination(
    type: _ResultType.app,
    toolId: DanioToolId.notificationSettings,
    subtitle: 'Manage care reminders and phone notification settings',
    icon: Icons.notifications_active_outlined,
    color: AppColors.info,
    keywords: const ['reminders', 'alerts', 'phone'],
    screenBuilder: (_) => const NotificationSettingsScreen(),
  ),
  _SearchDestination(
    type: _ResultType.app,
    toolId: DanioToolId.aiConfiguration,
    subtitle: 'Configure optional AI power and your OpenAI API key',
    icon: Icons.key,
    color: AppColors.secondary,
    keywords: const ['openai', 'api', 'key', 'danio ai', 'optional ai'],
    screenBuilder: (_) => const SettingsScreen(),
  ),
  _SearchDestination(
    type: _ResultType.app,
    toolId: DanioToolId.appearanceSettings,
    subtitle: 'Adjust theme, room style, motion, and accessibility options',
    icon: Icons.palette_outlined,
    color: AppColors.secondary,
    keywords: const ['theme', 'dark mode', 'motion', 'haptics'],
    screenBuilder: (_) => const SettingsScreen(),
  ),
  _SearchDestination(
    type: _ResultType.app,
    toolId: DanioToolId.privacyControls,
    subtitle: 'Review privacy information and local data controls',
    icon: Icons.privacy_tip_outlined,
    color: AppColors.secondary,
    keywords: const ['privacy policy', 'analytics consent', 'data'],
    screenBuilder: (_) => const PrivacyPolicyScreen(),
  ),
  _SearchDestination(
    type: _ResultType.app,
    toolId: DanioToolId.destructiveDataControls,
    subtitle: 'Find local data export, reset, and deletion controls',
    icon: Icons.delete_forever_outlined,
    color: AppColors.error,
    keywords: const ['delete data', 'clear data', 'reset app'],
    screenBuilder: (_) => const SettingsScreen(),
  ),
  _SearchDestination(
    type: _ResultType.app,
    toolId: DanioToolId.analytics,
    subtitle: 'Review progress, care consistency, and aquarium trends',
    icon: Icons.insights,
    color: AppColors.info,
    keywords: const ['stats', 'charts', 'progress'],
    screenBuilder: (_) => const AnalyticsScreen(),
  ),
  _SearchDestination(
    type: _ResultType.app,
    toolId: DanioToolId.achievements,
    subtitle: 'View earned badges, milestones, and aquarium progress',
    icon: Icons.emoji_events_outlined,
    color: AppColors.warning,
    keywords: const ['badges', 'rewards', 'milestones'],
    screenBuilder: (_) => const AchievementsScreen(),
  ),
  _SearchDestination(
    type: _ResultType.app,
    toolId: DanioToolId.gemShop,
    subtitle: 'Spend gems on collectible room and tank cosmetics',
    icon: Icons.diamond_outlined,
    color: AppColors.primary,
    keywords: const ['gems', 'cosmetics', 'decorations'],
    screenBuilder: (_) => const GemShopScreen(),
  ),
  _SearchDestination(
    type: _ResultType.app,
    toolId: DanioToolId.shopStreet,
    subtitle: 'Browse the local shop street and aquarium extras',
    icon: Icons.storefront,
    color: AppColors.primary,
    keywords: const ['shop', 'store', 'street'],
    screenBuilder: (_) => const ShopStreetScreen(),
  ),
  _SearchDestination(
    type: _ResultType.app,
    toolId: DanioToolId.about,
    subtitle: 'Version details, app information, and support context',
    icon: Icons.info_outline,
    color: AppColors.secondary,
    keywords: const ['version', 'support', 'danio'],
    screenBuilder: (_) => const AboutScreen(),
  ),
  _SearchDestination(
    type: _ResultType.app,
    titleOverride: 'Smart Hub',
    subtitle: 'Local aquarium intelligence plus optional AI tools',
    icon: Icons.auto_awesome,
    color: AppColors.info,
    keywords: const ['ask danio', 'ai', 'symptom', 'weekly plan', 'fish id'],
    screenBuilder: (_) => const SmartScreen(),
  ),
  _SearchDestination(
    type: _ResultType.tool,
    toolId: DanioToolId.workshop,
    subtitle: 'Calculators, planners, and practical aquarium tools',
    icon: Icons.build_circle_outlined,
    color: AppColors.primary,
    keywords: const ['tools', 'calculators', 'planner'],
    screenBuilder: (_) => const WorkshopScreen(),
  ),
  _SearchDestination(
    type: _ResultType.tool,
    toolId: DanioToolId.waterChangeCalculator,
    subtitle: 'Calculate safe water-change volumes for a tank',
    icon: Icons.water_drop,
    color: AppColors.info,
    keywords: const ['partial water change', 'water change calculator'],
    screenBuilder: (tanks) {
      final tank = _firstTank(tanks);
      return tank == null
          ? const WaterChangeCalculatorScreen()
          : WaterChangeCalculatorScreen(
              tankId: tank.id,
              initialTankVolumeLitres: tank.volumeLitres,
            );
    },
  ),
  _SearchDestination(
    type: _ResultType.tool,
    toolId: DanioToolId.stockingCalculator,
    subtitle: 'Estimate sensible stocking levels for a tank',
    icon: Icons.pool,
    color: AppColors.warning,
    keywords: const ['stocking calculator', 'capacity', 'fish capacity'],
    screenBuilder: (tanks) {
      final tank = _firstTank(tanks);
      return tank == null
          ? const StockingCalculatorScreen()
          : StockingCalculatorScreen(
              tankId: tank.id,
              initialTankVolumeLitres: tank.volumeLitres,
            );
    },
  ),
  _SearchDestination(
    type: _ResultType.tool,
    toolId: DanioToolId.co2Calculator,
    subtitle: 'Estimate CO2 from pH and KH for planted tanks',
    icon: Icons.science,
    color: AppColors.success,
    keywords: const ['carbon dioxide', 'planted tank', 'ph kh'],
    screenBuilder: (tanks) {
      final tank = _firstTank(tanks);
      return Co2CalculatorScreen(tankId: tank?.id);
    },
  ),
  _SearchDestination(
    type: _ResultType.tool,
    toolId: DanioToolId.dosingCalculator,
    subtitle: 'Calculate liquid fertilizer or treatment doses',
    icon: Icons.medication_liquid,
    color: AppColors.success,
    keywords: const ['dose', 'fertilizer', 'medicine', 'ml'],
    screenBuilder: (tanks) {
      final tank = _firstTank(tanks);
      return DosingCalculatorScreen(
        tankId: tank?.id,
        tankVolumeLitres: tank?.volumeLitres,
      );
    },
  ),
  _SearchDestination(
    type: _ResultType.tool,
    toolId: DanioToolId.unitConverter,
    subtitle: 'Convert litres, gallons, cm, inches, and temperature',
    icon: Icons.swap_horiz,
    color: AppColors.secondary,
    keywords: const ['conversion', 'units', 'celsius', 'fahrenheit'],
    screenBuilder: (_) => const UnitConverterScreen(),
  ),
  _SearchDestination(
    type: _ResultType.tool,
    toolId: DanioToolId.tankVolumeCalculator,
    subtitle: 'Calculate aquarium volume from tank dimensions',
    icon: Icons.calculate,
    color: AppColors.info,
    keywords: const ['volume', 'dimensions', 'litres', 'gallons'],
    screenBuilder: (tanks) {
      final tank = _firstTank(tanks);
      return TankVolumeCalculatorScreen(tankId: tank?.id);
    },
  ),
  _SearchDestination(
    type: _ResultType.tool,
    toolId: DanioToolId.lightingPlanner,
    subtitle: 'Plan aquarium lighting duration and routine',
    icon: Icons.lightbulb_outline,
    color: AppColors.warning,
    keywords: const ['light', 'schedule', 'photoperiod', 'algae'],
    screenBuilder: (tanks) {
      final tank = _firstTank(tanks);
      return LightingScheduleScreen(tankId: tank?.id);
    },
  ),
  _SearchDestination(
    type: _ResultType.tool,
    toolId: DanioToolId.localCompatibilityChecker,
    subtitle: 'Check whether fish species are sensible tankmates',
    icon: Icons.compare_arrows,
    color: AppColors.warning,
    keywords: const ['compatibility', 'tank mates', 'tankmates'],
    screenBuilder: (tanks) {
      final tank = _firstTank(tanks);
      return CompatibilityCheckerScreen(tankId: tank?.id);
    },
  ),
  _SearchDestination(
    type: _ResultType.tool,
    toolId: DanioToolId.cyclingAssistant,
    subtitle: 'Track ammonia, nitrite, nitrate, and cycling actions',
    icon: Icons.sync,
    color: AppColors.info,
    keywords: const ['cycle', 'ammonia', 'nitrite', 'nitrate'],
    screenBuilder: (tanks) {
      final tank = _firstTank(tanks);
      return tank == null
          ? const WorkshopScreen()
          : CyclingAssistantScreen(tankId: tank.id);
    },
  ),
  _SearchDestination(
    type: _ResultType.tool,
    toolId: DanioToolId.costTracker,
    subtitle: 'Track aquarium spending across livestock, plants, and equipment',
    icon: Icons.receipt_long,
    color: AppColors.primary,
    keywords: const ['costs', 'money', 'budget', 'spend'],
    screenBuilder: (_) => const CostTrackerScreen(),
  ),
  _SearchDestination(
    type: _ResultType.guide,
    titleOverride: 'Quick Start Guide',
    subtitle: 'Start a freshwater aquarium with safer first steps',
    icon: Icons.rocket_launch_outlined,
    color: AppColors.info,
    keywords: const ['beginner', 'new tank', 'setup'],
    screenBuilder: (_) => const QuickStartGuideScreen(),
  ),
  _SearchDestination(
    type: _ResultType.guide,
    titleOverride: 'Nitrogen Cycle Guide',
    subtitle: 'Understand ammonia, nitrite, nitrate, and cycling',
    icon: Icons.sync,
    color: AppColors.info,
    keywords: const ['cycle', 'ammonia', 'nitrite', 'nitrate'],
    screenBuilder: (_) => const NitrogenCycleGuideScreen(),
  ),
  _SearchDestination(
    type: _ResultType.guide,
    titleOverride: 'Water Parameters Guide',
    subtitle: 'Read pH, temperature, hardness, and other water values',
    icon: Icons.science_outlined,
    color: AppColors.info,
    keywords: const ['parameters', 'testing', 'ph', 'gh', 'kh'],
    screenBuilder: (_) => const ParameterGuideScreen(),
  ),
  _SearchDestination(
    type: _ResultType.guide,
    titleOverride: 'Algae Guide',
    subtitle: 'Identify common algae and choose realistic fixes',
    icon: Icons.grass,
    color: AppColors.success,
    keywords: const ['brown algae', 'diatoms', 'green water', 'black beard'],
    screenBuilder: (_) => const AlgaeGuideScreen(),
  ),
  _SearchDestination(
    type: _ResultType.guide,
    titleOverride: 'Disease Guide',
    subtitle: 'Recognise fish illnesses and learn safe next steps',
    icon: Icons.medical_services_outlined,
    color: AppColors.error,
    keywords: const ['ich', 'sick fish', 'illness', 'parasite'],
    screenBuilder: (_) => const DiseaseGuideScreen(),
  ),
  _SearchDestination(
    type: _ResultType.guide,
    titleOverride: 'Feeding Guide',
    subtitle: 'Plan practical feeding routines without overfeeding',
    icon: Icons.restaurant,
    color: AppColors.primary,
    keywords: const ['food', 'feed', 'overfeeding'],
    screenBuilder: (_) => const FeedingGuideScreen(),
  ),
  _SearchDestination(
    type: _ResultType.guide,
    titleOverride: 'Acclimation Guide',
    subtitle: 'Introduce new fish with safer temperature and water changes',
    icon: Icons.login,
    color: AppColors.info,
    keywords: const ['new fish', 'drip acclimation', 'float bag'],
    screenBuilder: (_) => const AcclimationGuideScreen(),
  ),
  _SearchDestination(
    type: _ResultType.guide,
    titleOverride: 'Quarantine Guide',
    subtitle: 'Reduce disease risk before fish join the main tank',
    icon: Icons.health_and_safety_outlined,
    color: AppColors.error,
    keywords: const ['hospital tank', 'new fish', 'isolation'],
    screenBuilder: (_) => const QuarantineGuideScreen(),
  ),
  _SearchDestination(
    type: _ResultType.guide,
    titleOverride: 'Breeding Guide',
    subtitle: 'Learn breeding basics, fry care, and preparation',
    icon: Icons.favorite_outline,
    color: AppColors.primary,
    keywords: const ['fry', 'eggs', 'spawning'],
    screenBuilder: (_) => const BreedingGuideScreen(),
  ),
  _SearchDestination(
    type: _ResultType.guide,
    titleOverride: 'Equipment Guide',
    subtitle: 'Understand filters, heaters, lights, and useful hardware',
    icon: Icons.build,
    color: AppColors.secondary,
    keywords: const ['filter', 'heater', 'equipment'],
    screenBuilder: (_) => const EquipmentGuideScreen(),
  ),
  _SearchDestination(
    type: _ResultType.guide,
    titleOverride: 'Hardscape Guide',
    subtitle: 'Choose and place rocks, wood, and hardscape safely',
    icon: Icons.landscape_outlined,
    color: AppColors.secondary,
    keywords: const ['rocks', 'wood', 'aquascape'],
    screenBuilder: (_) => const HardscapeGuideScreen(),
  ),
  _SearchDestination(
    type: _ResultType.guide,
    titleOverride: 'Substrate Guide',
    subtitle: 'Choose gravel, sand, or plant substrate for your tank',
    icon: Icons.layers_outlined,
    color: AppColors.secondary,
    keywords: const ['sand', 'gravel', 'soil'],
    screenBuilder: (_) => const SubstrateGuideScreen(),
  ),
  _SearchDestination(
    type: _ResultType.guide,
    titleOverride: 'Vacation Guide',
    subtitle: 'Prepare your aquarium before time away from home',
    icon: Icons.beach_access_outlined,
    color: AppColors.info,
    keywords: const ['holiday', 'away', 'auto feeder'],
    screenBuilder: (_) => const VacationGuideScreen(),
  ),
  _SearchDestination(
    type: _ResultType.guide,
    titleOverride: 'Glossary',
    subtitle: 'Look up aquarium terms in plain language',
    icon: Icons.menu_book_outlined,
    color: AppColors.secondary,
    keywords: const ['dictionary', 'terms', 'definitions'],
    screenBuilder: (_) => const GlossaryScreen(),
  ),
  _SearchDestination(
    type: _ResultType.guide,
    titleOverride: 'FAQ',
    subtitle: 'Common fishkeeping questions and practical answers',
    icon: Icons.quiz_outlined,
    color: AppColors.secondary,
    keywords: const ['questions', 'help', 'answers'],
    screenBuilder: (_) => const FaqScreen(),
  ),
  _SearchDestination(
    type: _ResultType.guide,
    titleOverride: 'Fish Database',
    subtitle: 'Browse freshwater species care profiles',
    icon: Icons.set_meal,
    color: AppColors.info,
    keywords: const ['species', 'fish', 'livestock'],
    screenBuilder: (_) => const SpeciesBrowserScreen(),
  ),
  _SearchDestination(
    type: _ResultType.guide,
    titleOverride: 'Plant Database',
    subtitle: 'Browse aquarium plants and care requirements',
    icon: Icons.local_florist,
    color: AppColors.success,
    keywords: const ['plants', 'planted tank', 'aquatic plants'],
    screenBuilder: (_) => const PlantBrowserScreen(),
  ),
];

Tank? _firstTank(List<Tank> tanks) => tanks.isEmpty ? null : tanks.first;

bool _matchesSearchText(String query, Iterable<String?> values) {
  if (query.isEmpty) return false;
  return values.any((value) => (value ?? '').toLowerCase().contains(query));
}

String _homeLabel(DanioToolHome home) {
  switch (home) {
    case DanioToolHome.learn:
      return 'learn';
    case DanioToolHome.practice:
      return 'practice';
    case DanioToolHome.tank:
      return 'tank';
    case DanioToolHome.tankDetail:
      return 'tank detail';
    case DanioToolHome.smart:
      return 'smart hub';
    case DanioToolHome.more:
      return 'more';
    case DanioToolHome.workshop:
      return 'workshop';
    case DanioToolHome.preferences:
      return 'preferences settings';
  }
}

class _SearchDestination {
  final _ResultType type;
  final DanioToolId? toolId;
  final String? titleOverride;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<String> keywords;
  final Widget Function(List<Tank> tanks) screenBuilder;

  const _SearchDestination({
    required this.type,
    this.toolId,
    this.titleOverride,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.keywords = const [],
    required this.screenBuilder,
  });

  String get title => titleOverride ?? danioToolDefinition(toolId!).title;

  bool matches(String query) {
    final definition = toolId == null ? null : danioToolDefinition(toolId!);
    return _matchesSearchText(query, [
      title,
      subtitle,
      if (definition != null) definition.id.name,
      if (definition != null) _homeLabel(definition.canonicalHome),
      ...keywords,
    ]);
  }

  void open(BuildContext context, List<Tank> tanks) {
    NavigationThrottle.push(context, screenBuilder(tanks), rootNavigator: true);
  }
}

class _SearchResults extends StatelessWidget {
  final String query;
  final List<Tank> tanks;
  final WidgetRef ref;

  const _SearchResults({
    required this.query,
    required this.tanks,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = query.trim().toLowerCase();
    final results = <_SearchResult>[];

    if (_matchesEmergencyQuery(normalizedQuery)) {
      results.add(
        _SearchResult(
          type: _ResultType.guide,
          title: 'Emergency Guide',
          subtitle:
              'Urgent steps for water spikes, gasping, illness, injury, and equipment failure',
          icon: Icons.emergency_outlined,
          color: AppColors.error,
          onTap: () => NavigationThrottle.push(
            context,
            const EmergencyGuideScreen(),
            rootNavigator: true,
          ),
        ),
      );
    }

    for (final destination in _matchingDestinations(normalizedQuery, tanks)) {
      results.add(
        _SearchResult(
          type: destination.type,
          title: destination.title,
          subtitle: destination.subtitle,
          icon: destination.icon,
          color: destination.color,
          onTap: () => destination.open(context, tanks),
        ),
      );
    }

    for (final metadata in _matchingLearningPaths(normalizedQuery)) {
      results.add(
        _SearchResult(
          type: _ResultType.learning,
          title: metadata.title,
          subtitle: metadata.description,
          icon: Icons.school,
          color: AppColors.secondary,
          onTap: () => NavigationThrottle.push(
            context,
            const LearnScreen(),
            rootNavigator: true,
          ),
        ),
      );
    }

    // Search tanks
    for (final tank in tanks) {
      if (tank.name.toLowerCase().contains(normalizedQuery)) {
        results.add(
          _SearchResult(
            type: _ResultType.tank,
            title: tank.name,
            subtitle:
                '${tank.volumeLitres.toStringAsFixed(0)}L ${tank.type.name}',
            icon: Icons.water,
            onTap: () => AppRoutes.toTankDetail(context, tank.id),
          ),
        );
      }
    }

    // Search livestock across all tanks
    for (final tank in tanks) {
      final livestockAsync = ref.watch(livestockProvider(tank.id));
      livestockAsync.whenData((livestock) {
        for (final l in livestock) {
          if (l.commonName.toLowerCase().contains(normalizedQuery) ||
              (l.scientificName?.toLowerCase().contains(normalizedQuery) ??
                  false)) {
            results.add(
              _SearchResult(
                type: _ResultType.livestock,
                title: l.commonName,
                subtitle: 'in ${tank.name} (x${l.count})',
                icon: Icons.set_meal,
                onTap: () => NavigationThrottle.push(
                  context,
                  LivestockDetailScreen(tankId: tank.id, livestock: l),
                ),
              ),
            );
          }
        }
      });

      // Search equipment
      final equipmentAsync = ref.watch(equipmentProvider(tank.id));
      equipmentAsync.whenData((equipment) {
        for (final e in equipment) {
          if (e.name.toLowerCase().contains(normalizedQuery) ||
              e.typeName.toLowerCase().contains(normalizedQuery) ||
              (e.brand?.toLowerCase().contains(normalizedQuery) ?? false)) {
            results.add(
              _SearchResult(
                type: _ResultType.equipment,
                title: e.name,
                subtitle: '${e.typeName} in ${tank.name}',
                icon: Icons.build,
                onTap: () => AppRoutes.toTankDetail(context, tank.id),
              ),
            );
          }
        }
      });

      final logsAsync = ref.watch(allLogsProvider(tank.id));
      logsAsync.whenData((logs) {
        final sortedLogs = [...logs]
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        for (final log in sortedLogs.take(8)) {
          if (!_matchesLog(normalizedQuery, tank, log)) continue;

          results.add(
            _SearchResult(
              type: _ResultType.log,
              title: LogEntryDisplay.titleFor(log),
              subtitle: '${tank.name} - ${_logSummary(log)}',
              icon: LogEntryDisplay.iconFor(log.type),
              color: AppColors.primary,
              onTap: () => AppRoutes.toTankDetail(context, tank.id),
            ),
          );
        }
      });
    }

    // Search species database
    final speciesResults = SpeciesDatabase.search(normalizedQuery);
    for (final species in speciesResults.take(10)) {
      results.add(
        _SearchResult(
          type: _ResultType.species,
          title: species.commonName,
          subtitle: '${species.scientificName} - ${species.careLevel}',
          icon: Icons.set_meal,
          onTap: () => _showSpeciesInfo(context, species),
        ),
      );
    }

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: AppIconSizes.xxl,
              color: context.textHint,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Hmm, nothing found for "$query" \u{1F50D}',
              style: AppTypography.bodyMedium,
            ),
          ],
        ),
      );
    }

    // Build flat list of items for ListView.builder
    final items = <_SearchListItem>[];

    void addSection(_ResultType type, String title, {bool addSpacer = true}) {
      final sectionResults = results.where((r) => r.type == type).toList();
      if (sectionResults.isEmpty) return;

      items.add(
        _SearchListItem.header(title: title, count: sectionResults.length),
      );
      items.addAll(sectionResults.map((r) => _SearchListItem.result(r)));
      if (addSpacer) items.add(_SearchListItem.spacer());
    }

    addSection(_ResultType.app, 'App');
    addSection(_ResultType.tool, 'Tools');
    addSection(_ResultType.learning, 'Learning');
    addSection(_ResultType.guide, 'Guides');
    addSection(_ResultType.tank, 'Tanks');
    addSection(_ResultType.log, 'Logs');
    addSection(_ResultType.livestock, 'Livestock');
    addSection(_ResultType.equipment, 'Equipment');
    addSection(_ResultType.species, 'Species Database', addSpacer: false);

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        if (item.isHeader) {
          return _SectionHeader(
            title: item.headerTitle!,
            count: item.headerCount!,
          );
        } else if (item.isSpacer) {
          return const SizedBox(height: AppSpacing.md);
        } else {
          return _ResultTile(result: item.result!);
        }
      },
    );
  }

  Iterable<_SearchDestination> _matchingDestinations(
    String query,
    List<Tank> tanks,
  ) {
    return _searchDestinations.where((destination) {
      if (!destination.matches(query)) return false;
      final id = destination.toolId;
      if (id == null) return true;

      final tankRequiredIds = {
        DanioToolId.tankTasks,
        DanioToolId.tankReminders,
        DanioToolId.tankCharts,
        DanioToolId.tankGallery,
        DanioToolId.tankJournal,
        DanioToolId.tankSettings,
        DanioToolId.estimateLivestockValue,
      };
      return !tankRequiredIds.contains(id) || tanks.isNotEmpty;
    });
  }

  Iterable<PathMetadata> _matchingLearningPaths(String query) {
    return LessonProvider.allPathMetadata.where((metadata) {
      return _matchesSearchText(query, [
        metadata.title,
        metadata.description,
        metadata.id.replaceAll('_', ' '),
        ...metadata.lessonIds,
      ]);
    });
  }

  bool _matchesLog(String query, Tank tank, LogEntry log) {
    return _matchesSearchText(query, [
      tank.name,
      log.typeName,
      LogEntryDisplay.titleFor(log),
      LogEntryDisplay.summaryFor(log),
      LogEntryDisplay.fallbackFor(log),
      log.title,
      log.notes,
    ]);
  }

  String _logSummary(LogEntry log) {
    final notes = log.notes?.trim();
    if (notes != null && notes.isNotEmpty) return notes;

    final summary = LogEntryDisplay.summaryFor(log).trim();
    if (summary.isNotEmpty) return summary;

    return LogEntryDisplay.fallbackFor(log);
  }

  bool _matchesEmergencyQuery(String query) {
    const terms = [
      'emergency',
      'urgent',
      'ammonia',
      'nitrite',
      'toxic',
      'spike',
      'gasping',
      'heater',
      'filter',
      'ich',
      'injury',
      'injured',
      'poison',
      'poisoning',
      'sick',
      'disease',
      'dying',
    ];

    return terms.any(query.contains);
  }

  void _showSpeciesInfo(BuildContext context, SpeciesInfo species) {
    showAppScrollableSheet(
      context: context,
      initialSize: 0.7,
      minSize: 0.5,
      maxSize: 0.95,
      builder: (_, scrollController) => SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(AppSpacing.lg2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.textHint,
                  borderRadius: AppRadius.xxsRadius,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg2),
            Text(species.commonName, style: AppTypography.headlineMedium),
            Text(
              species.scientificName,
              style: AppTypography.bodyMedium.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(label: species.careLevel),
                _InfoChip(label: species.temperament),
                _InfoChip(label: '${species.adultSizeCm.toStringAsFixed(0)}cm'),
                _InfoChip(label: species.family),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(species.description, style: AppTypography.bodyLarge),
            const SizedBox(height: AppSpacing.md),
            Text('Parameters', style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Temperature: ${species.minTempC}-${species.maxTempC} C\n'
              'pH: ${species.minPh}-${species.maxPh}\n'
              'Min tank: ${species.minTankLitres.toStringAsFixed(0)}L\n'
              'School size: ${species.minSchoolSize}+',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Diet', style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            Text(species.diet, style: AppTypography.bodyMedium),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;

  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm3,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.surfaceVariant,
        borderRadius: AppRadius.mediumRadius,
      ),
      child: Text(label, style: AppTypography.bodySmall),
    );
  }
}

enum _ResultType {
  app,
  tool,
  learning,
  guide,
  tank,
  log,
  livestock,
  equipment,
  species,
}

class _SearchResult {
  final _ResultType type;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SearchResult({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.color = AppColors.primary,
    required this.onTap,
  });
}

/// Helper class to represent items in the search results list (header, result, or spacer)
class _SearchListItem {
  final bool isHeader;
  final bool isSpacer;
  final String? headerTitle;
  final int? headerCount;
  final _SearchResult? result;

  _SearchListItem._({
    this.isHeader = false,
    this.isSpacer = false,
    this.headerTitle,
    this.headerCount,
    this.result,
  });

  factory _SearchListItem.header({required String title, required int count}) =>
      _SearchListItem._(isHeader: true, headerTitle: title, headerCount: count);

  factory _SearchListItem.result(_SearchResult result) =>
      _SearchListItem._(result: result);

  factory _SearchListItem.spacer() => _SearchListItem._(isSpacer: true);
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Text(title, style: AppTypography.labelLarge),
          const SizedBox(width: AppSpacing.sm),
          Text('($count)', style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final _SearchResult result;

  const _ResultTile({required this.result});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: result.color.withValues(alpha: 0.1),
          child: Icon(result.icon, color: result.color, size: AppIconSizes.sm),
        ),
        title: Text(result.title),
        subtitle: Text(result.subtitle, style: AppTypography.bodySmall),
        trailing: const Icon(Icons.chevron_right, size: AppIconSizes.sm),
        onTap: result.onTap,
      ),
    );
  }
}
