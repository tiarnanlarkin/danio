/// Provider for lazy-loading lesson content
/// Eliminates 347KB startup bottleneck by loading lessons on-demand
library;

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/learning.dart';

// Deferred imports for lazy loading - only loaded when requested
import '../data/lessons/nitrogen_cycle.dart' deferred as nitrogen_cycle;
import '../data/lessons/water_parameters.dart' deferred as water_parameters;
import '../data/lessons/first_fish.dart' deferred as first_fish;
import '../data/lessons/maintenance.dart' deferred as maintenance;
import '../data/lessons/planted_tank.dart' deferred as planted_tank;
import '../data/lessons/equipment.dart' deferred as equipment;
import '../data/lessons/fish_health.dart' deferred as fish_health;
import '../data/lessons/species_care.dart' deferred as species_care;
import '../data/lessons/advanced_topics.dart' deferred as advanced_topics;
import '../data/lessons/equipment_expanded.dart' deferred as equipment_expanded;
import '../data/lessons/species_care_expanded.dart' deferred as species_care_expanded;
import '../data/lessons/aquascaping.dart' deferred as aquascaping;
import '../data/lessons/breeding.dart' deferred as breeding;
import '../data/lessons/troubleshooting.dart' deferred as troubleshooting;
import '../utils/logger.dart';

/// Lesson loading state
enum LessonLoadState { notLoaded, loading, loaded, error }

/// Metadata for a learning path (loaded immediately)
class PathMetadata {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final int orderIndex;
  final List<String> lessonIds; // Just IDs, not full lessons

  /// Cross-path prerequisite path IDs — mirrors [LearningPath.prerequisitePathIds].
  /// A path with entries here is locked until all lessons in each listed path
  /// are completed.
  final List<String> prerequisitePathIds;

  const PathMetadata({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.orderIndex,
    required this.lessonIds,
    this.prerequisitePathIds = const [],
  });

  /// Build the id→lessonIds map from a list of [PathMetadata] for easy lookup.
  static Map<String, List<String>> buildLessonIdMap(
    List<PathMetadata> allMeta,
  ) {
    return {for (final m in allMeta) m.id: m.lessonIds};
  }

  /// Check whether this path is unlocked given the set of completed lesson IDs.
  bool isUnlocked(List<String> completedLessons, List<PathMetadata> allMeta) {
    if (prerequisitePathIds.isEmpty) return true;
    final idMap = buildLessonIdMap(allMeta);
    return prerequisitePathIds.every((prereqId) {
      final ids = idMap[prereqId];
      if (ids == null || ids.isEmpty) return true;
      return ids.every((id) => completedLessons.contains(id));
    });
  }
}

/// State for lesson loading
class LessonState {
  final Map<String, LearningPath> loadedPaths;
  final Map<String, LessonLoadState> pathLoadStates;
  final String? errorMessage;

  const LessonState({
    this.loadedPaths = const {},
    this.pathLoadStates = const {},
    this.errorMessage,
  });

  LessonState copyWith({
    Map<String, LearningPath>? loadedPaths,
    Map<String, LessonLoadState>? pathLoadStates,
    String? errorMessage,
  }) {
    return LessonState(
      loadedPaths: loadedPaths ?? this.loadedPaths,
      pathLoadStates: pathLoadStates ?? this.pathLoadStates,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool isPathLoaded(String pathId) =>
      pathLoadStates[pathId] == LessonLoadState.loaded;

  bool isPathLoading(String pathId) =>
      pathLoadStates[pathId] == LessonLoadState.loading;

  LearningPath? getPath(String pathId) => loadedPaths[pathId];

  Lesson? getLesson(String lessonId) {
    for (final path in loadedPaths.values) {
      final lesson = path.lessons.firstWhereOrNull((l) => l.id == lessonId);
      if (lesson != null) return lesson;
    }
    return null;
  }
}

/// Provider for lazy-loaded lessons
class LessonProvider extends StateNotifier<LessonState> {
  LessonProvider() : super(const LessonState());

  /// Path metadata loaded at startup (lightweight)
  static const List<PathMetadata> allPathMetadata = [
    PathMetadata(
      id: 'nitrogen_cycle',
      title: 'The Nitrogen Cycle',
      description:
          'The #1 thing every fishkeeper must understand. Master this and your fish will thrive.',
      emoji: '🔄',
      orderIndex: 0,
      lessonIds: [
        'nc_intro',
        'nc_stages',
        'nc_how_to',
        'nc_testing',
        'nc_spikes',
        'nc_minicycle',
      ],
    ),
    PathMetadata(
      id: 'water_parameters',
      title: 'Water Parameters 101',
      description: 'Understanding pH, temperature, and water hardness',
      emoji: '💧',
      orderIndex: 1,
      lessonIds: [
        'wp_ph',
        'wp_temp',
        'wp_hardness',
        'wp_chlorine',
        'wp_tds',
        'wp_seasonal',
      ],
    ),
    PathMetadata(
      id: 'first_fish',
      title: 'Your First Fish',
      description: 'Choosing and introducing fish to your tank',
      emoji: '🐠',
      orderIndex: 2,
      lessonIds: [
        'ff_choosing',
        'ff_acclimation',
        'ff_feeding',
        'ff_behavior',
        'ff_quarantine',
        'ff_mistakes',
      ],
    ),
    PathMetadata(
      id: 'maintenance',
      title: 'Tank Maintenance',
      description: 'Water changes, cleaning, and ongoing care',
      emoji: '🧹',
      orderIndex: 3,
      lessonIds: [
        'maint_water_changes',
        'maint_filter',
        'maint_gravel_vac',
        'maint_algae',
        'maint_cleaning',
        'maint_schedule',
      ],
    ),
    PathMetadata(
      id: 'planted',
      title: 'Planted Tanks',
      description: 'Growing healthy aquarium plants',
      emoji: '🌱',
      orderIndex: 4,
      lessonIds: [
        'planted_basics',
        'planted_light',
        'planted_substrate',
        'planted_co2',
        'planted_propagation',
      ],
    ),
    PathMetadata(
      id: 'equipment',
      title: 'Equipment Guide',
      description: 'Filters, heaters, lights, and essential gear — beginner to advanced',
      emoji: '⚙️',
      orderIndex: 5,
      lessonIds: [
        // Beginner path — essential gear
        'eq_filters',
        'eq_heaters',
        'eq_lighting',
        'eq_test_kits',
        // Setting up & ongoing care
        'eq_setup_guide',
        'eq_filter_maintenance',
        'eq_water_change_gear',
        // Advanced / specialist topics
        'eq_air_pumps',
        'eq_co2_systems',
        'eq_aquascape_tools',
        'eq_substrate',
      ],
    ),
    PathMetadata(
      id: 'fish_health',
      title: 'Fish Health',
      description: 'Recognizing and treating common diseases',
      emoji: '🏥',
      orderIndex: 6,
      lessonIds: [
        'fh_prevention',
        'fh_ich',
        'fh_fin_rot',
        'fh_fungal',
        'fh_parasites',
        'fh_hospital_tank',
      ],
      prerequisitePathIds: ['nitrogen_cycle'],
    ),
    PathMetadata(
      id: 'species_care',
      title: 'Species Spotlights',
      description: 'Deep dives into popular fish species',
      emoji: '🐟',
      orderIndex: 7,
      lessonIds: [
        'sc_betta',
        'sc_goldfish',
        'sc_tetras',
        'sc_cichlids',
        'sc_shrimp',
        'sc_snails',
        'sc_corydoras',
        'sc_livebearers',
        'sc_rasboras',
        'sc_angelfish',
        'sc_plecos',
        'sc_gouramis',
        'sc_loaches',
      ],
    ),
    PathMetadata(
      id: 'advanced_topics',
      title: 'Advanced Topics',
      description: 'Breeding, aquascaping, and specialised setups',
      emoji: '🎓',
      orderIndex: 8,
      lessonIds: [
        'at_breeding_livebearers',
        'at_breeding_egg_layers',
        'at_aquascaping',
        'at_biotope',
        'at_troubleshooting',
        'at_water_chem',
      ],
    ),
    PathMetadata(
      id: 'aquascaping',
      title: 'Aquascaping & Design',
      description:
          'Create stunning aquatic landscapes — from layout principles to plant placement and maintenance',
      emoji: '🌿',
      orderIndex: 9,
      lessonIds: [
        'aq_layout_styles',
        'aq_plant_zones',
        'aq_fertilisation',
        'aq_algae_management',
      ],
    ),
    PathMetadata(
      id: 'breeding_basics',
      title: 'Breeding Basics',
      description:
          'Successfully breed fish in a home aquarium — from egg layers to livebearers',
      emoji: '🥚',
      orderIndex: 10,
      lessonIds: [
        'br_breeding_tank',
        'br_raising_fry',
        'br_egg_layers',
        'br_livebearers',
        'br_fry_care',
        'br_rehoming',
      ],
    ),
    PathMetadata(
      id: 'troubleshooting',
      title: 'Troubleshooting & Emergencies',
      description: 'Diagnose problems fast and respond before fish die',
      emoji: '🚨',
      orderIndex: 11,
      lessonIds: [
        'tr_emergency',
        'tr_disease_diagnosis',
        'tr_cloudy_water',
        'tr_power_outage',
        'tr_temperature_crash',
        'tr_ph_crash',
      ],
    ),
  ];

  /// Load a specific learning path
  Future<void> loadPath(String pathId) async {
    // Already loaded or loading
    if (state.isPathLoaded(pathId) || state.isPathLoading(pathId)) {
      return;
    }

    // Mark as loading
    state = state.copyWith(
      pathLoadStates: {
        ...state.pathLoadStates,
        pathId: LessonLoadState.loading,
      },
    );

    try {
      // Simulate async loading (actual implementation will import chunk files)

      // Load the path content
      final path = await _loadPathContent(pathId);

      if (path != null) {
        state = state.copyWith(
          loadedPaths: {...state.loadedPaths, pathId: path},
          pathLoadStates: {
            ...state.pathLoadStates,
            pathId: LessonLoadState.loaded,
          },
        );
      } else {
        throw Exception('Path $pathId not found');
      }
    } catch (e, st) {
      logError('LessonProvider: failed to load path $pathId: $e', stackTrace: st, tag: 'LessonProvider');
      state = state.copyWith(
        pathLoadStates: {
          ...state.pathLoadStates,
          pathId: LessonLoadState.error,
        },
        errorMessage: 'Couldn\'t load lessons. Pull down to refresh.',
      );
    }
  }

  /// Load multiple paths in sequence
  Future<void> loadPaths(List<String> pathIds) async {
    for (final pathId in pathIds) {
      await loadPath(pathId);
    }
  }

  /// Preload the most important paths (nitrogen cycle, water parameters)
  Future<void> preloadEssentials() async {
    await loadPaths(['nitrogen_cycle', 'water_parameters']);
  }

  /// Internal method to load path content
  /// Lazy loads from chunk files only when requested
  Future<LearningPath?> _loadPathContent(String pathId) async {
    // Import statement is synchronous in Dart, but we use Future
    // to simulate async behavior and allow for future enhancements
    // (e.g., loading from network, IndexedDB, etc.)

    // The actual import happens on first call - Dart tree-shaking
    // ensures unused chunks aren't included in the bundle
    switch (pathId) {
      case 'nitrogen_cycle':
        final module = await _loadNitrogenCycle();
        return module;
      case 'water_parameters':
        final module = await _loadWaterParameters();
        return module;
      case 'first_fish':
        final module = await _loadFirstFish();
        return module;
      case 'maintenance':
        final module = await _loadMaintenance();
        return module;
      case 'planted':
        final module = await _loadPlantedTank();
        return module;
      case 'equipment':
        final module = await _loadEquipment();
        return module;
      case 'fish_health':
        final module = await _loadFishHealth();
        return module;
      case 'species_care':
        final module = await _loadSpeciesCare();
        return module;
      case 'advanced_topics':
        final module = await _loadAdvancedTopics();
        return module;
      case 'aquascaping':
        final module = await _loadAquascaping();
        return module;
      case 'breeding_basics':
        final module = await _loadBreedingBasics();
        return module;
      case 'troubleshooting':
        final module = await _loadTroubleshooting();
        return module;
      default:
        return null;
    }
  }

  // Lazy loaders - deferred imports only load when first accessed
  Future<LearningPath> _loadNitrogenCycle() async {
    await nitrogen_cycle.loadLibrary();
    return nitrogen_cycle.nitrogenCyclePath;
  }

  Future<LearningPath> _loadWaterParameters() async {
    await water_parameters.loadLibrary();
    return water_parameters.waterParametersPath;
  }

  Future<LearningPath> _loadFirstFish() async {
    await first_fish.loadLibrary();
    return first_fish.firstFishPath;
  }

  Future<LearningPath> _loadMaintenance() async {
    await maintenance.loadLibrary();
    return maintenance.maintenancePath;
  }

  Future<LearningPath> _loadPlantedTank() async {
    await planted_tank.loadLibrary();
    return planted_tank.plantedTankPath;
  }

  Future<LearningPath> _loadEquipment() async {
    await equipment.loadLibrary();
    await equipment_expanded.loadLibrary();
    final basePath = equipment.equipmentPath;
    return LearningPath(
      id: basePath.id,
      title: basePath.title,
      description: basePath.description,
      emoji: basePath.emoji,
      recommendedFor: basePath.recommendedFor,
      orderIndex: basePath.orderIndex,
      lessons: [
        ...basePath.lessons,
        ...equipment_expanded.equipmentExpandedLessons,
      ],
    );
  }

  Future<LearningPath> _loadFishHealth() async {
    await fish_health.loadLibrary();
    return fish_health.fishHealthPath;
  }

  Future<LearningPath> _loadSpeciesCare() async {
    await species_care.loadLibrary();
    await species_care_expanded.loadLibrary();
    final basePath = species_care.speciesCarePath;
    return LearningPath(
      id: basePath.id,
      title: basePath.title,
      description: basePath.description,
      emoji: basePath.emoji,
      recommendedFor: basePath.recommendedFor,
      orderIndex: basePath.orderIndex,
      lessons: [
        ...basePath.lessons,
        ...species_care_expanded.speciesCareExpandedLessons,
      ],
    );
  }

  Future<LearningPath> _loadAdvancedTopics() async {
    await advanced_topics.loadLibrary();
    return advanced_topics.advancedTopicsPath;
  }

  Future<LearningPath> _loadAquascaping() async {
    await aquascaping.loadLibrary();
    return aquascaping.aquascapingPath;
  }

  Future<LearningPath> _loadBreedingBasics() async {
    await breeding.loadLibrary();
    return breeding.breedingBasicsPath;
  }

  Future<LearningPath> _loadTroubleshooting() async {
    await troubleshooting.loadLibrary();
    return troubleshooting.troubleshootingPath;
  }

  /// Clear all loaded lessons (memory management)
  void clearAll() {
    state = const LessonState();
  }

  /// Clear a specific path
  void clearPath(String pathId) {
    final paths = Map<String, LearningPath>.from(state.loadedPaths);
    final states = Map<String, LessonLoadState>.from(state.pathLoadStates);
    paths.remove(pathId);
    states.remove(pathId);

    state = state.copyWith(loadedPaths: paths, pathLoadStates: states);
  }

  /// Public getters for external access
  bool isPathLoaded(String pathId) => state.isPathLoaded(pathId);
  bool isPathLoading(String pathId) => state.isPathLoading(pathId);
  LearningPath? getPath(String pathId) => state.getPath(pathId);
  Lesson? getLesson(String lessonId) => state.getLesson(lessonId);
  Map<String, LearningPath> get loadedPaths => state.loadedPaths;
  Map<String, LessonLoadState> get pathLoadStates => state.pathLoadStates;
}

/// Global provider instance
final lessonProvider = StateNotifierProvider<LessonProvider, LessonState>(
  (ref) => LessonProvider(),
);

/// Helper provider to get all path metadata
final pathMetadataProvider = Provider<List<PathMetadata>>((ref) {
  return LessonProvider.allPathMetadata;
});

/// Helper provider to check if a path is loaded
final isPathLoadedProvider = Provider.family<bool, String>((ref, pathId) {
  return ref.watch(lessonProvider).isPathLoaded(pathId);
});

/// Helper provider to get a specific path
final pathProvider = Provider.family<LearningPath?, String>((ref, pathId) {
  return ref.watch(lessonProvider).getPath(pathId);
});

/// Helper provider to get a specific lesson
final lessonByIdProvider = Provider.family<Lesson?, String>((ref, lessonId) {
  return ref.watch(lessonProvider).getLesson(lessonId);
});
