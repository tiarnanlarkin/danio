import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/onboarding_service.dart';

/// Reactive onboarding-completion state.
///
/// [_AppRouter] watches this provider so it rebuilds automatically when
/// onboarding completes mid-session.  Onboarding screens call
/// `ref.invalidate(onboardingCompletedProvider)` after writing the flag
/// to SharedPreferences, which triggers [_AppRouter] to re-evaluate and
/// transition to [TabNavigator] naturally — preventing the duplicate
/// TabNavigator bug that occurred when screens pushed their own instance.
final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  final service = await OnboardingService.getInstance();
  return service.isOnboardingCompleted;
});
