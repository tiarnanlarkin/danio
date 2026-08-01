import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../theme/room_themes.dart';
import '../widgets/stage/stage_provider.dart';
import '../widgets/stage/swiss_army_panel.dart';
import '../widgets/stage/temp_panel_content.dart';
import 'storage_service.dart';

/// Compile-time opt-in for the local Codex browser iteration surface.
///
/// The trial is deliberately unavailable on every non-web target and remains
/// off unless its explicit build define is supplied.
const bool browserPreviewDemoEnabled =
    kIsWeb &&
    bool.fromEnvironment('DANIO_BROWSER_PREVIEW_DEMO', defaultValue: false);

const String browserPreviewDemoTankId = 'browser-preview-demo-temperature';

bool isBrowserPreviewDemoEnabled({
  required bool runningOnWeb,
  required bool explicitlyRequested,
}) => runningOnWeb && explicitlyRequested;

/// Builds the complete, non-durable sample state for one browser preview.
///
/// Every invocation returns a new in-memory store. The displayed readings are
/// historical manual water-test logs; they do not represent live telemetry or
/// an equipment state.
Future<InMemoryStorageService> createBrowserPreviewDemoStorage() async {
  final storage = InMemoryStorageService.ephemeral();
  final now = DateTime.now().toUtc();
  final tank = Tank(
    id: browserPreviewDemoTankId,
    name: 'Preview-only Temperature Tank',
    type: TankType.freshwater,
    volumeLitres: 90,
    startDate: now.subtract(const Duration(days: 120)),
    targets: WaterTargets.freshwaterTropical(),
    notes:
        'Preview-only local sample data. Temperature readings are manual logs.',
    isDemoTank: true,
    createdAt: now.subtract(const Duration(days: 120)),
    updatedAt: now,
  );
  await storage.saveTank(tank);

  const temperatures = <double>[24.7, 24.9, 25.1, 24.8, 25.0, 25.2, 25.0];
  for (var index = 0; index < temperatures.length; index++) {
    final timestamp = now.subtract(
      Duration(days: temperatures.length - 1 - index),
    );
    await storage.saveLog(
      LogEntry(
        id: 'browser-preview-temperature-$index',
        tankId: tank.id,
        type: LogType.waterTest,
        timestamp: timestamp,
        createdAt: timestamp,
        waterTest: WaterTestResults(temperature: temperatures[index]),
      ),
    );
  }

  return storage;
}

/// An intentionally narrow web-preview surface that contains no account,
/// onboarding, or production persistence flow.
class BrowserPreviewDemoApp extends StatelessWidget {
  const BrowserPreviewDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Danio browser preview',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const _BrowserPreviewDemoHome(),
    );
  }
}

class _BrowserPreviewDemoHome extends ConsumerStatefulWidget {
  const _BrowserPreviewDemoHome();

  @override
  ConsumerState<_BrowserPreviewDemoHome> createState() =>
      _BrowserPreviewDemoHomeState();
}

class _BrowserPreviewDemoHomeState
    extends ConsumerState<_BrowserPreviewDemoHome> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(stageProvider.notifier).open(StagePanel.temp);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2428),
      body: Stack(
        children: [
          SwissArmyPanel.left(
            theme: RoomTheme.ocean,
            child: TempPanelContent(
              tankId: browserPreviewDemoTankId,
              theme: RoomTheme.ocean,
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: IgnorePointer(
                child: Semantics(
                  label: 'Browser preview only. Local demo data.',
                  child: Container(
                    key: const ValueKey('browser-preview-demo-banner'),
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10272B).withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'BROWSER PREVIEW — LOCAL DEMO DATA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
