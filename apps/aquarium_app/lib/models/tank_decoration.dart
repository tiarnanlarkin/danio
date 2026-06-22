import 'package:flutter/foundation.dart';

enum TankDecorationType {
  riverStones,
  driftwoodArch,
  mossyHide,
  ceramicShelter,
}

@immutable
class TankDecorationDefinition {
  final TankDecorationType type;
  final String name;
  final String description;

  const TankDecorationDefinition({
    required this.type,
    required this.name,
    required this.description,
  });

  static const all = [
    TankDecorationDefinition(
      type: TankDecorationType.riverStones,
      name: 'River Stones',
      description: 'Smooth foreground stones for a calm natural tank base.',
    ),
    TankDecorationDefinition(
      type: TankDecorationType.driftwoodArch,
      name: 'Driftwood Arch',
      description: 'A soft branching hardscape cue earned from species growth.',
    ),
    TankDecorationDefinition(
      type: TankDecorationType.mossyHide,
      name: 'Mossy Hide',
      description: 'A planted shelter cue for steady learning progress.',
    ),
    TankDecorationDefinition(
      type: TankDecorationType.ceramicShelter,
      name: 'Ceramic Shelter',
      description: 'A simple safe shelter cue for deeper aquarium mastery.',
    ),
  ];

  static TankDecorationDefinition fromType(TankDecorationType type) {
    return all.firstWhere((definition) => definition.type == type);
  }
}
