import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/species_unlock_provider.dart';
import '../../providers/tank_provider.dart';
import 'animated_swimming_fish.dart';
import 'species_fish.dart';

/// The three depth layers fish are distributed across.
const _kDepthLayers = [0.2, 0.5, 0.8];

/// Maximum number of fish shown simultaneously.
const _kMaxFish = 8;

/// How long between display rotations (when >8 unlocked species).
const _kRotationInterval = Duration(seconds: 30);

/// Orchestration widget that populates the tank with species-specific fish.
///
/// Behaviour:
/// - Reads the user's unlocked species from [speciesUnlockProvider].
/// - Optionally cross-references a [tankId] to show only species the user
///   actually owns as livestock (future tank config).
/// - Selects up to [_kMaxFish] fish, distributes them across 3 depth layers,
///   and staggered start positions so they don't move in sync.
/// - When the user has more than [_kMaxFish] unlocked species, the display
///   rotates every 30 seconds with a gentle fade transition.
/// - Falls back to [AnimatedSwimmingFish] widgets when the user has no
///   unlocked species.
class TankFishManager extends ConsumerStatefulWidget {
  final double tankWidth;
  final double tankHeight;

  /// Optional tank ID — when provided, only species the user owns as livestock
  /// in that tank are shown (cross-referenced with [livestockProvider]).
  final String? tankId;

  const TankFishManager({
    super.key,
    required this.tankWidth,
    required this.tankHeight,
    this.tankId,
  });

  @override
  ConsumerState<TankFishManager> createState() => _TankFishManagerState();
}

class _TankFishManagerState extends ConsumerState<TankFishManager>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _opacity;

  List<String> _activeSpecies = [];
  List<_FishConfig> _configs = [];
  int _rotationOffset = 0;
  DateTime _lastRotation = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      value: 1.0,
    );
    _opacity = _fadeController;
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Guard: dimensions not yet measured — return empty to avoid downstream
    // invalid-matrix errors in SpeciesFish.
    if (widget.tankWidth <= 0 || widget.tankHeight <= 0) {
      return const SizedBox.shrink();
    }

    final unlocked = ref.watch(speciesUnlockProvider).toList()..sort();

    // Optionally filter to livestock the user actually owns in this tank
    List<String> available = unlocked;
    if (widget.tankId != null) {
      final livestockAsync = ref.watch(livestockProvider(widget.tankId!));
      final livestock = livestockAsync.valueOrNull;
      if (livestock != null && livestock.isNotEmpty) {
        // Map livestock commonName to a species ID by normalising the name
        final ownedIds = livestock
            .map((l) => _nameToSpeciesId(l.commonName))
            .whereType<String>()
            .toSet();
        final filtered = unlocked.where(ownedIds.contains).toList();
        // Fall back to all unlocked if we couldn't match any owned livestock
        if (filtered.isNotEmpty) available = filtered;
      }
    }

    if (available.isEmpty) {
      return _buildFallback();
    }

    // Rotation: cycle through species if more than _kMaxFish
    _maybeRotate(available);

    final selected = _selectSpecies(available);
    if (_activeSpecies != selected) {
      _activeSpecies = selected;
      _configs = _buildConfigs(selected);
    }

    return FadeTransition(
      opacity: _opacity,
      child: Stack(
        children: [
          for (final cfg in _configs)
            SpeciesFish(
              key: ValueKey('fish_${cfg.speciesId}_${cfg.index}'),
              speciesId: cfg.speciesId,
              tankWidth: widget.tankWidth,
              tankHeight: widget.tankHeight,
              depth: cfg.depth,
              baseSpeed: cfg.speed,
              bobAmplitude: cfg.bobAmplitude,
              bobPeriod: cfg.bobPeriod,
              baseTop: cfg.baseTop,
              phaseOffset: cfg.phaseOffset,
            ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Gentle fade-out → swap → fade-in when more species than the display cap.
  void _maybeRotate(List<String> available) {
    if (available.length <= _kMaxFish) return;
    final now = DateTime.now();
    if (now.difference(_lastRotation) < _kRotationInterval) return;

    _lastRotation = now;
    _rotationOffset = (_rotationOffset + _kMaxFish) % available.length;

    _fadeController.reverse().then((_) {
      if (!mounted) return;
      setState(() {
        _activeSpecies = [];
        _configs = [];
      });
      _fadeController.forward();
    });
  }

  /// Pick up to [_kMaxFish] species from [available], respecting rotation.
  List<String> _selectSpecies(List<String> available) {
    if (available.length <= _kMaxFish) return available;
    final start = _rotationOffset % available.length;
    final result = <String>[];
    for (int i = 0; i < _kMaxFish; i++) {
      result.add(available[(start + i) % available.length]);
    }
    return result;
  }

  /// Build per-fish animation configs with deterministic (but varied) values.
  List<_FishConfig> _buildConfigs(List<String> species) {
    final configs = <_FishConfig>[];
    final rng = math.Random(species.fold<int>(0, (h, s) => h ^ s.hashCode));

    for (int i = 0; i < species.length; i++) {
      final depth = _kDepthLayers[i % _kDepthLayers.length];
      configs.add(_FishConfig(
        index: i,
        speciesId: species[i],
        depth: depth,
        speed: 20.0 + rng.nextDouble() * 20.0, // 20–40 px/s
        bobAmplitude: 5.0 + rng.nextDouble() * 10.0, // 5–15 px
        bobPeriod: 3.0 + rng.nextDouble() * 3.0, // 3–6 s
        baseTop: 0.15 + rng.nextDouble() * 0.55, // 15%–70% of tank height
        phaseOffset: i / math.max(1, species.length - 1),
      ));
    }
    return configs;
  }

  /// Fallback: simple coloured animated fish for when nothing is unlocked.
  Widget _buildFallback() {
    return Stack(
      children: [
        AnimatedSwimmingFish(
          size: 28,
          color: const Color(0xFFE8503A),
          tankWidth: widget.tankWidth,
          tankHeight: widget.tankHeight,
          baseTop: 0.22,
          swimSpeed: 10.0,
          verticalBob: 12.0,
          startOffset: 0.0,
        ),
        AnimatedSwimmingFish(
          size: 24,
          color: const Color(0xFF3A78C9),
          tankWidth: widget.tankWidth,
          tankHeight: widget.tankHeight,
          baseTop: 0.40,
          swimSpeed: 8.0,
          verticalBob: 18.0,
          startOffset: 0.6,
        ),
        AnimatedSwimmingFish(
          size: 20,
          color: const Color(0xFFE8A030),
          tankWidth: widget.tankWidth,
          tankHeight: widget.tankHeight,
          baseTop: 0.55,
          swimSpeed: 12.0,
          verticalBob: 10.0,
          startOffset: 0.3,
        ),
      ],
    );
  }

  /// Convert a livestock common name (e.g. "Neon Tetra") to a species ID
  /// (e.g. "neon_tetra") for cross-referencing with unlock map.
  static String? _nameToSpeciesId(String commonName) {
    final id = commonName
        .toLowerCase()
        .replaceAll(RegExp(r"[^a-z0-9]+"), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    // Validate against known species IDs
    const known = {
      'betta', 'neon_tetra', 'harlequin_rasbora', 'cherry_barb',
      'zebra_danio', 'guppy', 'molly', 'platy', 'angelfish',
      'amano_shrimp', 'cherry_shrimp', 'nerite_snail', 'otocinclus',
      'bristlenose_pleco', 'bronze_corydoras',
    };
    return known.contains(id) ? id : null;
  }
}

// ── Data class ────────────────────────────────────────────────────────────

class _FishConfig {
  final int index;
  final String speciesId;
  final double depth;
  final double speed;
  final double bobAmplitude;
  final double bobPeriod;
  final double baseTop;
  final double phaseOffset;

  const _FishConfig({
    required this.index,
    required this.speciesId,
    required this.depth,
    required this.speed,
    required this.bobAmplitude,
    required this.bobPeriod,
    required this.baseTop,
    required this.phaseOffset,
  });
}
