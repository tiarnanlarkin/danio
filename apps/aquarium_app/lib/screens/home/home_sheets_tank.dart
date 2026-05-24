import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/core/app_button.dart';
import '../../widgets/danio_bottom_dock.dart';
import '../../providers/tank_provider.dart';
import '../../providers/storage_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_feedback.dart';
import '../../utils/logger.dart';
import '../../utils/app_page_routes.dart';
import '../../utils/navigation_throttle.dart';
import '../journal_screen.dart';
import '../reminders_screen.dart';

/// Tank toolbox bottom sheet with navigation to tank-contextual tools.
void showTankToolbox(BuildContext context, WidgetRef ref, String tankId) {
  showAppBottomSheet(
    context: context,
    padding: const EdgeInsets.all(AppSpacing.md),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.md),
        Semantics(
          header: true,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.build_rounded, size: AppIconSizes.md),
              const SizedBox(width: AppSpacing.xs),
              Text('Tank Toolbox', style: AppTypography.headlineSmall),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm2),
        ListTile(
          leading: const Icon(Icons.notifications_outlined),
          title: const Text('Reminders'),
          onTap: () {
            Navigator.maybePop(context);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              NavigationThrottle.push(
                context,
                const RemindersScreen(),
                route: RoomSlideRoute(page: const RemindersScreen()),
              );
            });
          },
        ),
        ListTile(
          leading: const Icon(Icons.book_outlined),
          title: const Text('Tank Journal'),
          onTap: () {
            Navigator.maybePop(context);
            NavigationThrottle.push(
              context,
              JournalScreen(tankId: tankId),
              route: RoomSlideRoute(page: JournalScreen(tankId: tankId)),
            );
          },
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
      ],
    ),
  );
}

/// Quick water test log bottom sheet.
void showQuickLogSheet(BuildContext context, WidgetRef _, Tank tank) {
  final messenger = ScaffoldMessenger.of(context);
  showAppDragSheet(
    context: context,
    builder: (ctx) => _QuickWaterTestSheet(tank: tank, messenger: messenger),
  );
}

class _QuickWaterTestSheet extends ConsumerStatefulWidget {
  final Tank tank;
  final ScaffoldMessengerState messenger;

  const _QuickWaterTestSheet({required this.tank, required this.messenger});

  @override
  ConsumerState<_QuickWaterTestSheet> createState() =>
      _QuickWaterTestSheetState();
}

class _QuickWaterTestSheetState extends ConsumerState<_QuickWaterTestSheet> {
  final TextEditingController _phC = TextEditingController();
  final TextEditingController _tempC = TextEditingController();
  final TextEditingController _ammoniaC = TextEditingController();

  @override
  void dispose() {
    _phC.dispose();
    _tempC.dispose();
    _ammoniaC.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final ph = double.tryParse(_phC.text);
    final temp = double.tryParse(_tempC.text);
    final ammonia = double.tryParse(_ammoniaC.text);
    if (ph == null && temp == null && ammonia == null) {
      AppFeedback.showWarning(context, 'Enter at least one test value.');
      return;
    }

    try {
      final now = DateTime.now();
      final log = LogEntry(
        id: now.microsecondsSinceEpoch.toString(),
        tankId: widget.tank.id,
        type: LogType.waterTest,
        timestamp: now,
        createdAt: now,
        title: 'Quick test',
        waterTest: WaterTestResults(
          ph: ph,
          temperature: temp,
          ammonia: ammonia,
        ),
      );
      final storage = ref.read(storageServiceProvider);
      await storage.saveLog(log);
      ref.invalidate(logsProvider(widget.tank.id));
      ref.invalidate(allLogsProvider(widget.tank.id));
      await ref.read(userProfileProvider.notifier).addXp(10);
      if (!mounted) return;
      FocusManager.instance.primaryFocus?.unfocus();
      Navigator.maybePop(context);
      await Future<void>.delayed(AppDurations.medium4);
      AppFeedback.showSuccessViaMessenger(
        widget.messenger,
        'Water test logged! +10 XP',
      );
    } catch (e, st) {
      logError(
        'HomeScreen: quick water test save failed: $e',
        stackTrace: st,
        tag: 'HomeScreen',
      );
      if (mounted) {
        AppFeedback.showError(
          context,
          'Couldn\'t save that water test. Try again.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg2,
        right: AppSpacing.lg2,
        top: AppSpacing.md,
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).viewPadding.bottom +
            DanioBottomDock.contentClearance +
            AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            header: true,
            child: Text('Quick Water Test', style: AppTypography.headlineSmall),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _phC,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'pH'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: _tempC,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Temp (°C)'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: _ammoniaC,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'NH3'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Save & Earn 10 XP',
            leadingIcon: Icons.save,
            isFullWidth: true,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
