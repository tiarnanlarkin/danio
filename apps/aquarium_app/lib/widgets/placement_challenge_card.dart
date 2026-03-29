/// Optional placement test challenge card for the Learn tab.
/// FB-H5: Hidden — no real placement test exists yet (DE-19).
/// Previously showed a CTA that routed to the standard SRS screen by mistake.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlacementChallengeCard extends ConsumerWidget {
  const PlacementChallengeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // FB-H5: Placement test is not yet implemented (DE-19).
    // Hide this CTA until a real placement flow exists.
    return const SizedBox.shrink();
  }
}
