import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Panels that can appear on the stage
enum StagePanel { temp, waterQuality, progress, tanks }

/// Immutable state for the stage system
class StageState {
  final Set<StagePanel> openPanels;
  final double scrimIntensity;
  final bool tipVisible;

  const StageState({
    this.openPanels = const {},
    this.scrimIntensity = 0.0,
    this.tipVisible = false,
  });

  StageState copyWith({
    Set<StagePanel>? openPanels,
    double? scrimIntensity,
    bool? tipVisible,
  }) {
    return StageState(
      openPanels: openPanels ?? this.openPanels,
      scrimIntensity: scrimIntensity ?? this.scrimIntensity,
      tipVisible: tipVisible ?? this.tipVisible,
    );
  }
}

/// Notifier that manages panel open/close state and scrim intensity
class StageNotifier extends StateNotifier<StageState> {
  StageNotifier() : super(const StageState());

  /// Toggle a panel open/closed
  void toggle(StagePanel panel) {
    final panels = Set<StagePanel>.from(state.openPanels);
    if (panels.contains(panel)) {
      panels.remove(panel);
    } else {
      panels.add(panel);
    }
    state = state.copyWith(
      openPanels: panels,
      scrimIntensity: _computeScrim(panels),
    );
  }

  /// Open a specific panel
  void open(StagePanel panel) {
    if (state.openPanels.contains(panel)) return;
    final panels = Set<StagePanel>.from(state.openPanels)..add(panel);
    state = state.copyWith(
      openPanels: panels,
      scrimIntensity: _computeScrim(panels),
    );
  }

  /// Close a specific panel
  void close(StagePanel panel) {
    if (!state.openPanels.contains(panel)) return;
    final panels = Set<StagePanel>.from(state.openPanels)..remove(panel);
    state = state.copyWith(
      openPanels: panels,
      scrimIntensity: _computeScrim(panels),
    );
  }

  /// Close all panels
  void closeAll() {
    state = const StageState();
  }

  /// Show / hide the ambient tip
  void setTipVisible(bool visible) {
    state = state.copyWith(tipVisible: visible);
  }

  /// +0.1 per open panel, capped at 0.3
  double _computeScrim(Set<StagePanel> panels) {
    return (panels.length * 0.1).clamp(0.0, 0.3);
  }
}

final stageProvider = StateNotifierProvider<StageNotifier, StageState>(
  (ref) => StageNotifier(),
);

// ── Bottom Plate Controller ──────────────────────────────────────────────
/// Identifies which bottom plate is interacting with the controller.
enum BottomPlateId { today, tanks, progress }

/// Tracks which bottom plate is currently open.
/// When one plate opens, the previous one auto-collapses.
class BottomPlateController extends StateNotifier<BottomPlateId?> {
  BottomPlateController() : super(null);

  void registerOpen(BottomPlateId id) {
    if (state != id) {
      state = id;
    }
  }

  void registerClose(BottomPlateId id) {
    if (state == id) {
      state = null;
    }
  }
}

final bottomPlateControllerProvider =
    StateNotifierProvider<BottomPlateController, BottomPlateId?>(
  (ref) => BottomPlateController(),
);
