import 'package:danio/models/tank_decoration.dart';
import 'package:danio/services/tank_decoration_visual_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('no equipped decoration returns clear state', () {
    final state = TankDecorationVisualService.fromEquipped(null);

    expect(state.hasOverlay, isFalse);
    expect(state.decoration, isNull);
    expect(state.semanticsLabel, 'Tank decoration cosmetic state: clear');
  });

  test('equipped decoration returns a named visual state', () {
    final state = TankDecorationVisualService.fromEquipped(
      TankDecorationType.driftwoodArch,
    );

    expect(state.hasOverlay, isTrue);
    expect(state.decoration, TankDecorationType.driftwoodArch);
    expect(
      state.semanticsLabel,
      'Tank decoration cosmetic state: Driftwood Arch equipped',
    );
  });
}
