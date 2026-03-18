import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../providers/tank_provider.dart';
import '../../providers/storage_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_page_routes.dart';
import '../../utils/navigation_throttle.dart';
import '../analytics_screen.dart';
import '../journal_screen.dart';
import '../reminders_screen.dart';
import '../search_screen.dart';

/// Tank toolbox bottom sheet with navigation to reminders, journal, analytics, search.
void showTankToolbox(BuildContext context, WidgetRef ref, String tankId) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Semantics(
            header: true,
            child: Text('Tank Toolbox 🔧', style: AppTypography.headlineSmall),
          ),
          const SizedBox(height: AppSpacing.sm2),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Reminders'),
            onTap: () {
              Navigator.pop(ctx);
              NavigationThrottle.push(
                context,
                const RemindersScreen(),
                route: RoomSlideRoute(page: const RemindersScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.book_outlined),
            title: const Text('Tank Journal'),
            onTap: () {
              Navigator.pop(ctx);
              NavigationThrottle.push(
                context,
                JournalScreen(tankId: tankId),
                route: RoomSlideRoute(page: JournalScreen(tankId: tankId)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics_outlined),
            title: const Text('Analytics'),
            onTap: () {
              Navigator.pop(ctx);
              NavigationThrottle.push(context, const AnalyticsScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Species Search'),
            onTap: () {
              Navigator.pop(ctx);
              NavigationThrottle.push(
                context,
                const SearchScreen(),
                route: RoomSlideRoute(page: const SearchScreen()),
              );
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    ),
  );
}

/// Quick water test log bottom sheet.
void showQuickLogSheet(BuildContext context, WidgetRef ref, Tank tank) {
  final phC = TextEditingController();
  final tempC = TextEditingController();
  final ammoniaC = TextEditingController();

  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
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
                  controller: phC,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'pH'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: tempC,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Temp (°C)'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: ammoniaC,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'NH3'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save & Earn 10 XP'),
              onPressed: () async {
                final ph = double.tryParse(phC.text);
                final temp = double.tryParse(tempC.text);
                final ammonia = double.tryParse(ammoniaC.text);
                if (ph == null && temp == null && ammonia == null) return;
                Navigator.pop(ctx);
                final now = DateTime.now();
                final log = LogEntry(
                  id: now.microsecondsSinceEpoch.toString(),
                  tankId: tank.id,
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
                ref.invalidate(logsProvider(tank.id));
                ref.invalidate(allLogsProvider(tank.id));
                await ref.read(userProfileProvider.notifier).addXp(10);
              },
            ),
          ),
        ],
      ),
    ),
  ).whenComplete(() {
    phC.dispose();
    tempC.dispose();
    ammoniaC.dispose();
  });
}
