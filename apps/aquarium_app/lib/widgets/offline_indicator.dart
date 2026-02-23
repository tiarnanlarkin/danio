import 'package:aquarium_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Provider that monitors network connectivity status
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// Provider that exposes a simple boolean for online/offline status
final isOnlineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.when(
    data: (results) =>
        results.any((result) => result != ConnectivityResult.none),
    loading: () => true, // Assume online while loading
    error: (_, __) => true, // Assume online on error
  );
});

/// A banner widget that shows when the device is offline
/// Automatically appears at the top of the screen when connection is lost
class OfflineIndicator extends ConsumerWidget {
  const OfflineIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    // Don't show anything when online
    if (isOnline) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.warningAlpha20,
        border: const Border(
          bottom: BorderSide(color: AppColors.warning, width: 1),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.wifi_off,
            color: AppColors.warning,
            size: AppIconSizes.sm,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              "You're offline — some features may not be available",
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A small indicator that can be embedded in app bar or other locations
class OfflineIndicatorCompact extends ConsumerWidget {
  const OfflineIndicatorCompact({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    if (isOnline) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.warningAlpha20,
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: AppColors.warningAlpha30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.wifi_off,
            color: AppColors.warning,
            size: 14,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Offline',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}
