import '../models/models.dart';

enum TankAquascapeVisualCondition {
  clear,
  planted,
  decorated,
  plantedDecorated,
}

class TankAquascapeVisualState {
  final TankAquascapeVisualCondition condition;
  final String semanticsLabel;

  const TankAquascapeVisualState({
    required this.condition,
    required this.semanticsLabel,
  });

  bool get hasOverlay => condition != TankAquascapeVisualCondition.clear;
}

class TankAquascapeVisualService {
  static const _plantTerms = {
    'plant',
    'planted',
    'aquascape',
    'moss',
    'fern',
    'stem',
    'carpet',
    'co2',
  };

  static const _decorTerms = {
    'decor',
    'decoration',
    'hardscape',
    'driftwood',
    'wood',
    'rock',
    'stone',
    'cave',
    'ornament',
    'root',
  };

  const TankAquascapeVisualService._();

  static TankAquascapeVisualState fromEquipment(List<Equipment> equipment) {
    var hasPlantCue = false;
    var hasDecorCue = false;

    for (final item in equipment) {
      final searchableText = _searchableText(item);

      hasPlantCue |= item.type == EquipmentType.co2System;
      hasPlantCue |=
          item.type == EquipmentType.other &&
          _containsAny(searchableText, _plantTerms);
      hasPlantCue |=
          item.type == EquipmentType.light &&
          _containsAny(searchableText, _plantTerms);
      hasDecorCue |= _containsAny(searchableText, _decorTerms);
    }

    if (hasPlantCue && hasDecorCue) {
      return const TankAquascapeVisualState(
        condition: TankAquascapeVisualCondition.plantedDecorated,
        semanticsLabel: 'Tank aquascape visual state: planted and decorated',
      );
    }
    if (hasPlantCue) {
      return const TankAquascapeVisualState(
        condition: TankAquascapeVisualCondition.planted,
        semanticsLabel: 'Tank aquascape visual state: planted',
      );
    }
    if (hasDecorCue) {
      return const TankAquascapeVisualState(
        condition: TankAquascapeVisualCondition.decorated,
        semanticsLabel: 'Tank aquascape visual state: decorated',
      );
    }

    return clear;
  }

  static const clear = TankAquascapeVisualState(
    condition: TankAquascapeVisualCondition.clear,
    semanticsLabel: 'Tank aquascape visual state: clear',
  );

  static String _searchableText(Equipment item) {
    final parts = [
      item.name,
      item.brand,
      item.model,
      item.notes,
      if (item.settings != null) ...item.settings!.values.map((v) => '$v'),
    ];

    return parts.whereType<String>().join(' ').toLowerCase();
  }

  static bool _containsAny(String text, Set<String> terms) {
    return terms.any((term) => text.contains(term));
  }
}
