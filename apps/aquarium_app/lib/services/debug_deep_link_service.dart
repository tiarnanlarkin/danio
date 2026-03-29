/// Debug-only QA fast-entry service via ADB intents.
///
/// ALL logic is gated behind [kDebugMode] and has zero effect in release builds.
/// Wire this into [_AppRouterState.initState] using [addPostFrameCallback].
library;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/lesson_provider.dart';
import '../screens/tab_navigator.dart'; // currentTabProvider, tabNavigatorKeysProvider
import '../screens/achievements_screen.dart';
import '../screens/debug_menu_screen.dart';
import '../screens/species_browser_screen.dart';
import '../screens/plant_browser_screen.dart';
import '../screens/workshop_screen.dart';
import '../screens/glossary_screen.dart';
import '../screens/faq_screen.dart';
import '../screens/lesson/lesson_screen.dart';

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
    _kQaChannel.invokeMethod<String>('getInitialUri').then((uri) {
      if (uri != null && uri.isNotEmpty && context.mounted) {
        _handleUri(uri, context, ref);
      }
    }).catchError((Object e) {
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

    final segments = uri.pathSegments; // e.g. ['learn'] or ['lesson', 'first_fish']
    if (segments.isEmpty) return;

    final route = segments[0];

    // ── Tab routes ────────────────────────────────────────────────────────
    final tabIndex = const {
      'learn': 0,
      'practice': 1,
      'tank': 2,
      'smart': 3,
      'settings': 4,
    }[route];

    if (tabIndex != null) {
      ref.read(currentTabProvider.notifier).state = tabIndex;
      return;
    }

    // ── Screen routes ─────────────────────────────────────────────────────
    final nav = Navigator.of(context, rootNavigator: true);

    switch (route) {
      case 'debug':
        nav.push(MaterialPageRoute(builder: (_) => const DebugMenuScreen()));

      case 'achievements':
        nav.push(MaterialPageRoute(builder: (_) => const AchievementsScreen()));

      case 'species':
        nav.push(MaterialPageRoute(builder: (_) => const SpeciesBrowserScreen()));

      case 'plants':
        nav.push(MaterialPageRoute(builder: (_) => const PlantBrowserScreen()));

      case 'workshop':
        nav.push(MaterialPageRoute(builder: (_) => const WorkshopScreen()));

      case 'glossary':
        nav.push(MaterialPageRoute(builder: (_) => const GlossaryScreen()));

      case 'faq':
        nav.push(MaterialPageRoute(builder: (_) => const FaqScreen()));

      case 'lesson':
        final pathId = segments.length > 1 ? segments[1] : null;
        if (pathId != null) {
          _navigateToLesson(pathId, context, ref);
        }

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
