import '../models/tank_decoration.dart';

class TankDecorationVisualState {
  final TankDecorationType? decoration;
  final String semanticsLabel;

  const TankDecorationVisualState({
    required this.decoration,
    required this.semanticsLabel,
  });

  bool get hasOverlay => decoration != null;

  static const clear = TankDecorationVisualState(
    decoration: null,
    semanticsLabel: 'Tank decoration cosmetic state: clear',
  );
}

class TankDecorationVisualService {
  const TankDecorationVisualService._();

  static TankDecorationVisualState fromEquipped(TankDecorationType? type) {
    if (type == null) return TankDecorationVisualState.clear;

    final definition = TankDecorationDefinition.fromType(type);
    return TankDecorationVisualState(
      decoration: type,
      semanticsLabel:
          'Tank decoration cosmetic state: ${definition.name} equipped',
    );
  }
}
