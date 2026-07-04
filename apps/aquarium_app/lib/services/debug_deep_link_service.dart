/// Debug-only QA fast-entry service via ADB intents.
///
/// ALL logic is gated behind [kDebugMode] and has zero effect in release builds.
/// Wire this into [_AppRouterState.initState] using [addPostFrameCallback].
///
/// Architecture note: directly mutates [currentTabProvider] (line 86) for
/// tab switching. Acceptable for a debug-only service — no need to add
/// callback/stream indirection for QA tooling.
library;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/smart/fish_id/fish_id_screen.dart';
import '../features/smart/intelligence/aquarium_intelligence_screen.dart';
import '../features/smart/symptom_triage/symptom_triage_screen.dart';
import '../features/smart/weekly_plan/weekly_plan_screen.dart';
import '../models/wishlist.dart';
import '../providers/lesson_provider.dart';
import '../screens/about_screen.dart';
import '../screens/account_screen.dart';
import '../screens/acclimation_guide_screen.dart';
import '../screens/achievements_screen.dart';
import '../screens/algae_guide_screen.dart';
import '../screens/backup_restore_screen.dart';
import '../screens/breeding_guide_screen.dart';
import '../screens/co2_calculator_screen.dart';
import '../screens/compatibility_checker_screen.dart';
import '../screens/cost_tracker_screen.dart';
import '../screens/create_tank_screen.dart';
import '../screens/debug_menu_screen.dart';
import '../screens/debug_qa_seed_screen.dart';
import '../screens/disease_guide_screen.dart';
import '../screens/dosing_calculator_screen.dart';
import '../screens/emergency_guide_screen.dart';
import '../screens/equipment_guide_screen.dart';
import '../screens/faq_screen.dart';
import '../screens/feeding_guide_screen.dart';
import '../screens/gem_shop_screen.dart';
import '../screens/glossary_screen.dart';
import '../screens/hardscape_guide_screen.dart';
import '../screens/inventory_screen.dart';
import '../screens/lesson/lesson_screen.dart';
import '../screens/lighting_schedule_screen.dart';
import '../screens/nitrogen_cycle_guide_screen.dart';
import '../screens/notification_settings_screen.dart';
import '../screens/parameter_guide_screen.dart';
import '../screens/plant_browser_screen.dart';
import '../screens/privacy_policy_screen.dart';
import '../screens/quarantine_guide_screen.dart';
import '../screens/quick_start_guide_screen.dart';
import '../screens/search_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/shop_street_screen.dart';
import '../screens/species_browser_screen.dart';
import '../screens/stocking_calculator_screen.dart';
import '../screens/substrate_guide_screen.dart';
import '../screens/tab_navigator.dart'; // currentTabProvider, tabNavigatorKeysProvider
import '../screens/tank_comparison_screen.dart';
import '../screens/tank_volume_calculator_screen.dart';
import '../screens/terms_of_service_screen.dart';
import '../screens/troubleshooting_screen.dart';
import '../screens/unit_converter_screen.dart';
import '../screens/vacation_guide_screen.dart';
import '../screens/water_change_calculator_screen.dart';
import '../screens/wishlist_screen.dart';
import '../screens/workshop_screen.dart';

/// Method channel used by [MainActivity] (debug build only) to pass the
/// launch-intent URI back to Flutter.
const _kQaChannel = MethodChannel('danio/qa_links');

class DebugDeepLinkService {
  DebugDeepLinkService._();

  static DebugDeepLinkService? _instance;
  static DebugDeepLinkService get instance =>
      _instance ??= DebugDeepLinkService._();

  bool _initialized = false;

  /// Call once from [_AppRouterState] after the first frame, providing the
  /// [BuildContext] of the root navigator and a [WidgetRef] for Riverpod access.
  void init(BuildContext context, WidgetRef ref) {
    if (!kDebugMode) return;
    if (_initialized) return;
    _initialized = true;

    // 1. Check if the app was cold-started by an intent.
    _kQaChannel
        .invokeMethod<String>('getInitialUri')
        .then((uri) {
          if (uri != null && uri.isNotEmpty && context.mounted) {
            _handleUri(uri, context, ref);
          }
        })
        .catchError((Object e) {
          debugPrint('[QA] getInitialUri error: $e');
        });

    // 2. Listen for subsequent intents while the app is running.
    _kQaChannel.setMethodCallHandler((call) async {
      if (call.method == 'onNewIntent') {
        final uri = call.arguments as String?;
        if (uri != null && uri.isNotEmpty && context.mounted) {
          _handleUri(uri, context, ref);
        }
      }
    });
  }

  void _handleUri(String rawUri, BuildContext context, WidgetRef ref) {
    if (!kDebugMode) return;
    final uri = Uri.tryParse(rawUri);
    if (uri == null) return;
    if (uri.scheme != 'danio' || uri.host != 'qa') return;

    debugPrint('[QA] Deep link: $rawUri');

    final segments =
        uri.pathSegments; // e.g. ['learn'] or ['lesson', 'first_fish']
    if (segments.isEmpty) return;

    final route = segments[0];

    if (route == 'settings') {
      ref.read(currentTabProvider.notifier).state = 4;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        Navigator.of(
          context,
          rootNavigator: true,
        ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
      });
      return;
    }

    // ── Tab routes ────────────────────────────────────────────────────────
    final tabIndex = const {
      'learn': 0,
      'practice': 1,
      'tank': 2,
      'smart': 3,
      'more': 4,
    }[route];

    if (tabIndex != null) {
      ref.read(currentTabProvider.notifier).state = tabIndex;
      return;
    }

    // ── Screen routes ─────────────────────────────────────────────────────
    final nav = Navigator.of(context, rootNavigator: true);
    void push(Widget screen) {
      nav.push(MaterialPageRoute(builder: (_) => screen));
    }

    switch (route) {
      case 'debug':
        nav.push(MaterialPageRoute(builder: (_) => const DebugMenuScreen()));

      case 'new-tank':
      case 'create-tank':
        nav.push(
          MaterialPageRoute(
            builder: (_) => CreateTankScreen(
              initialName: uri.queryParameters['name'] ?? '',
            ),
          ),
        );

      case 'achievements':
        nav.push(MaterialPageRoute(builder: (_) => const AchievementsScreen()));

      case 'species':
        nav.push(
          MaterialPageRoute(builder: (_) => const SpeciesBrowserScreen()),
        );

      case 'plants':
        nav.push(MaterialPageRoute(builder: (_) => const PlantBrowserScreen()));

      case 'compare':
        nav.push(
          MaterialPageRoute(builder: (_) => const TankComparisonScreen()),
        );

      case 'workshop':
        nav.push(MaterialPageRoute(builder: (_) => const WorkshopScreen()));

      case 'glossary':
        nav.push(MaterialPageRoute(builder: (_) => const GlossaryScreen()));

      case 'faq':
        nav.push(MaterialPageRoute(builder: (_) => const FaqScreen()));

      case 'backup':
        push(const BackupRestoreScreen());

      case 'search':
        push(const SearchScreen());

      case 'notification-settings':
        push(const NotificationSettingsScreen());

      case 'account':
        push(const AccountScreen());

      case 'about':
        push(const AboutScreen());

      case 'privacy':
        push(const PrivacyPolicyScreen());

      case 'terms':
        push(const TermsOfServiceScreen());

      case 'shop':
        push(const ShopStreetScreen());

      case 'wishlist':
        push(const WishlistScreen(category: WishlistCategory.fish));

      case 'gem-shop':
        push(const GemShopScreen());

      case 'inventory':
        push(const InventoryScreen());

      case 'aquarium-intelligence':
        push(const AquariumIntelligenceScreen());

      case 'symptom-triage':
        push(const SymptomTriageScreen());

      case 'weekly-plan':
        push(const WeeklyPlanScreen());

      case 'fish-id':
        push(const FishIdScreen());

      case 'water-change':
        push(const WaterChangeCalculatorScreen());

      case 'tank-volume':
        push(const TankVolumeCalculatorScreen());

      case 'dosing':
        push(const DosingCalculatorScreen());

      case 'co2':
        push(const Co2CalculatorScreen());

      case 'lighting':
        push(const LightingScheduleScreen());

      case 'stocking':
        push(const StockingCalculatorScreen());

      case 'compatibility':
        push(const CompatibilityCheckerScreen());

      case 'unit-converter':
        push(const UnitConverterScreen());

      case 'cost-tracker':
        push(const CostTrackerScreen());

      case 'emergency-guide':
        push(const EmergencyGuideScreen());

      case 'quick-start-guide':
        push(const QuickStartGuideScreen());

      case 'nitrogen-cycle-guide':
        push(const NitrogenCycleGuideScreen());

      case 'parameter-guide':
        push(const ParameterGuideScreen());

      case 'algae-guide':
        push(const AlgaeGuideScreen());

      case 'disease-guide':
        push(const DiseaseGuideScreen());

      case 'feeding-guide':
        push(const FeedingGuideScreen());

      case 'acclimation-guide':
        push(const AcclimationGuideScreen());

      case 'quarantine-guide':
        push(const QuarantineGuideScreen());

      case 'breeding-guide':
        push(const BreedingGuideScreen());

      case 'equipment-guide':
        push(const EquipmentGuideScreen());

      case 'substrate-guide':
        push(const SubstrateGuideScreen());

      case 'hardscape-guide':
        push(const HardscapeGuideScreen());

      case 'vacation-guide':
        push(const VacationGuideScreen());

      case 'troubleshooting':
        push(const TroubleshootingScreen());

      case 'lesson':
        ref.read(currentTabProvider.notifier).state = 0;
        final pathId = segments.length > 1 ? segments[1] : null;
        if (pathId != null) {
          _navigateToLesson(pathId, context, ref);
        }

      case 'lesson-quiz':
        ref.read(currentTabProvider.notifier).state = 0;
        nav.push(
          MaterialPageRoute(
            builder: (_) => DebugQaLessonQuizScreen(
              state: uri.queryParameters['state'] ?? 'hint',
              pathId: uri.queryParameters['path'] ?? 'nitrogen_cycle',
            ),
          ),
        );

      case 'practice-session':
        ref.read(currentTabProvider.notifier).state = 1;
        nav.push(
          MaterialPageRoute(
            builder: (_) => DebugQaPracticeSessionScreen(
              pathId: uri.queryParameters['path'] ?? 'nitrogen_cycle',
            ),
          ),
        );

      default:
        debugPrint('[QA] Unknown route: $route');
    }
  }

  Future<void> _navigateToLesson(
    String pathId,
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      // Load the path content so we have lessons available.
      final notifier = ref.read(lessonProvider.notifier);
      await notifier.loadPath(pathId);
      final lessonState = ref.read(lessonProvider);
      final path = lessonState.getPath(pathId);
      if (path == null || path.lessons.isEmpty) {
        debugPrint('[QA] Path "$pathId" not found or has no lessons');
        return;
      }
      final lesson = path.lessons.first;
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (_) => LessonScreen(lesson: lesson, pathTitle: path.title),
        ),
      );
    } catch (e) {
      debugPrint('[QA] Failed to navigate to lesson for path "$pathId": $e');
    }
  }
}
