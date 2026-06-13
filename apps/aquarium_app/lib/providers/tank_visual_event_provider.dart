import 'package:flutter_riverpod/flutter_riverpod.dart';

final tankFeedingPulseProvider = StateProvider.family<int, String>(
  (ref, tankId) => 0,
);
