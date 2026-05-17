import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/guidance_service.dart';
import 'user_profile_provider.dart';

final guidanceServiceProvider = FutureProvider<GuidanceService>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return GuidanceService(prefs);
});
