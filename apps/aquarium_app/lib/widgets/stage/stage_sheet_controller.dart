import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum StageSheetSnap { closed, peek, half, full }

@immutable
class StageSheetRequest {
  final StageSheetSnap snap;
  final int sequence;

  const StageSheetRequest({required this.snap, required this.sequence});
}

class StageSheetController extends StateNotifier<StageSheetRequest> {
  StageSheetController()
    : super(const StageSheetRequest(snap: StageSheetSnap.closed, sequence: 0));

  void request(StageSheetSnap snap) {
    state = StageSheetRequest(snap: snap, sequence: state.sequence + 1);
  }

  void requestClosed() => request(StageSheetSnap.closed);
}

final stageSheetControllerProvider =
    StateNotifierProvider<StageSheetController, StageSheetRequest>(
      (ref) => StageSheetController(),
    );
