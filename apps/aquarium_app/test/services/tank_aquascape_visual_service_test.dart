import 'package:danio/models/models.dart';
import 'package:danio/services/tank_aquascape_visual_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('empty equipment returns clear', () {
    final state = TankAquascapeVisualService.fromEquipment(const []);

    expect(state.condition, TankAquascapeVisualCondition.clear);
    expect(state.hasOverlay, isFalse);
  });

  test('co2 system returns planted cue', () {
    final state = TankAquascapeVisualService.fromEquipment([
      _equipment(type: EquipmentType.co2System, name: 'CO2 Kit'),
    ]);

    expect(state.condition, TankAquascapeVisualCondition.planted);
    expect(state.semanticsLabel, 'Tank aquascape visual state: planted');
  });

  test('hardscape named equipment returns decorated cue', () {
    final state = TankAquascapeVisualService.fromEquipment([
      _equipment(type: EquipmentType.other, name: 'Spiderwood hardscape'),
    ]);

    expect(state.condition, TankAquascapeVisualCondition.decorated);
    expect(state.semanticsLabel, 'Tank aquascape visual state: decorated');
  });

  test('plant and hardscape equipment returns planted decorated cue', () {
    final state = TankAquascapeVisualService.fromEquipment([
      _equipment(type: EquipmentType.co2System, name: 'CO2 Kit'),
      _equipment(type: EquipmentType.other, name: 'Seiryu stone decor'),
    ]);

    expect(state.condition, TankAquascapeVisualCondition.plantedDecorated);
    expect(
      state.semanticsLabel,
      'Tank aquascape visual state: planted and decorated',
    );
  });
}

Equipment _equipment({required EquipmentType type, required String name}) {
  final now = DateTime(2026, 6, 13);
  return Equipment(
    id: name.toLowerCase().replaceAll(' ', '-'),
    tankId: 'tank-1',
    type: type,
    name: name,
    createdAt: now,
    updatedAt: now,
  );
}
