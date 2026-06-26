import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/navigation_throttle.dart';
import '../../screens/workshop_screen.dart';
import '../danio_bottom_dock.dart';
import 'stage_handle.dart';
import 'stage_sheet_controller.dart';

/// A single DraggableScrollableSheet that replaces the three-stacked
/// BottomPlate system. Contains a horizontal TabBar with four tabs:
/// Progress | Tanks | Today | Tools.
///
/// Snap points: closed handle, peek, half, and full.
class BottomSheetPanel extends ConsumerStatefulWidget {
  /// Closed state leaves the intentional handle visible without showing tabs.
  @visibleForTesting
  static const double kSnapClosed = 0.055;

  /// Peek state shows the handle and tab row.
  @visibleForTesting
  static const double kSnapPeek = 0.16;

  @visibleForTesting
  static const double kSnapHalf = 0.45;

  @visibleForTesting
  static const double kSnapFull = 0.92;

  @visibleForTesting
  static const List<double> kSnapSizes = [
    kSnapClosed,
    kSnapPeek,
    kSnapHalf,
    kSnapFull,
  ];

  /// Content for the Progress tab.
  final Widget progressContent;

  /// Content for the Tanks tab.
  final Widget tanksContent;

  /// Content for the Today tab.
  final Widget todayContent;
  final double? sheetWidth;
  final double? closedNibWidth;
  final double closedNibHeight;
  final DanioDockGlassStyle? dockGlassStyle;

  const BottomSheetPanel({
    super.key,
    required this.progressContent,
    required this.tanksContent,
    required this.todayContent,
    this.sheetWidth,
    this.closedNibWidth,
    this.closedNibHeight = DanioBottomDock.stageSheetNibHeight,
    this.dockGlassStyle,
  });

  @override
  ConsumerState<BottomSheetPanel> createState() => _BottomSheetPanelState();
}

class _BottomSheetPanelState extends ConsumerState<BottomSheetPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  int _currentTab = 0;
  double _sheetExtent = BottomSheetPanel.kSnapClosed;

  // First-use hint state
  bool _showSheetHint = false;
  double _hintOpacity = 1.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _currentTab = _tabController.index);
      }
    });
    _checkSheetHint();
  }

  Future<void> _checkSheetHint() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final hasSeen = prefs.getBool('hasSeenSheetHint') ?? false;
    if (!hasSeen && mounted) {
      setState(() => _showSheetHint = true);
      // After 3 seconds, fade out and mark as seen
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        setState(() => _hintOpacity = 0.0);
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) setState(() => _showSheetHint = false);
      }
      await prefs.setBool('hasSeenSheetHint', true);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  void _snapTo(double size, {bool haptic = true}) {
    if (!_sheetController.isAttached) return;
    _sheetController.animateTo(
      size,
      duration: AppDurations.medium4,
      curve: Curves.easeOutCubic,
    );
    if (haptic) HapticFeedback.selectionClick();
  }

  void _handleSheetRequest(StageSheetRequest request) {
    final size = switch (request.snap) {
      StageSheetSnap.closed => BottomSheetPanel.kSnapClosed,
      StageSheetSnap.peek => BottomSheetPanel.kSnapPeek,
      StageSheetSnap.half => BottomSheetPanel.kSnapHalf,
      StageSheetSnap.full => BottomSheetPanel.kSnapFull,
    };
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _snapTo(size, haptic: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<StageSheetRequest>(stageSheetControllerProvider, (_, next) {
      _handleSheetRequest(next);
    });
    final reducedMotion = MediaQuery.of(context).disableAnimations;
    final isClosed = _sheetExtent <= BottomSheetPanel.kSnapClosed + 0.003;
    final dockGlassStyle =
        widget.dockGlassStyle ??
        DanioBottomDock.glassStyleFor(context, attached: true);
    final fallbackWidth = MediaQuery.sizeOf(context).width;
    final sheetWidth = widget.sheetWidth ?? fallbackWidth;
    final closedNibWidth =
        widget.closedNibWidth ??
        DanioBottomDock.stageSheetNibWidthFor(fallbackWidth);

    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        if ((notification.extent - _sheetExtent).abs() > 0.001) {
          setState(() => _sheetExtent = notification.extent);
        }
        return false;
      },
      child: DraggableScrollableSheet(
        controller: _sheetController,
        initialChildSize: BottomSheetPanel.kSnapClosed,
        minChildSize: BottomSheetPanel.kSnapClosed,
        maxChildSize: BottomSheetPanel.kSnapFull,
        snapSizes: BottomSheetPanel.kSnapSizes,
        snap: true,
        shouldCloseOnMinExtent: false,
        builder: (context, scrollController) {
          return RepaintBoundary(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                key: const ValueKey('danio-stage-sheet-shell'),
                width: sheetWidth,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: DecoratedBox(
                    decoration: isClosed
                        ? const BoxDecoration()
                        : BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: AppColors.whiteAlpha20,
                                width: 1,
                              ),
                            ),
                          ),
                    child: Stack(
                      children: [
                        // Glassmorphism backdrop — opacity 0.28 so the panel is
                        // visible against the room background at the peek snap point.
                        if (!isClosed)
                          Positioned.fill(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                              child: Container(color: AppColors.blackAlpha20),
                            ),
                          ),

                        // Sheet content — entire surface is scrollable so dragging
                        // the handle, tabs, or content all expand/collapse the sheet.
                        Column(
                          children: [
                            // First-use hint: bouncing chevron above the drag handle
                            if (_showSheetHint && !isClosed)
                              AnimatedOpacity(
                                opacity: _hintOpacity,
                                duration: const Duration(milliseconds: 600),
                                child: _BouncingChevronHint(),
                              ),

                            Expanded(
                              child: SingleChildScrollView(
                                controller: scrollController,
                                physics: const ClampingScrollPhysics(),
                                // No bottom padding here. HomeScreen constrains the
                                // sheet container above the floating dock; adding
                                // internal padding would create a visible gap.
                                padding: EdgeInsets.zero,
                                child: Column(
                                  children: [
                                    // Drag handle + tabs header
                                    _SheetHeader(
                                      isClosed: isClosed,
                                      closedNibWidth: closedNibWidth,
                                      closedNibHeight: widget.closedNibHeight,
                                      dockGlassStyle: dockGlassStyle,
                                      tabController: _tabController,
                                      onSnapPeek: () =>
                                          _snapTo(BottomSheetPanel.kSnapPeek),
                                      onSnapHalf: () =>
                                          _snapTo(BottomSheetPanel.kSnapHalf),
                                      onSnapFull: () =>
                                          _snapTo(BottomSheetPanel.kSnapFull),
                                    ),

                                    // Tab content
                                    if (!isClosed)
                                      () {
                                        final contents = [
                                          widget.progressContent,
                                          widget.tanksContent,
                                          widget.todayContent,
                                          const _WorkshopToolsContent(),
                                        ];
                                        return reducedMotion
                                            ? KeyedSubtree(
                                                key: ValueKey(_currentTab),
                                                child: contents[_currentTab],
                                              )
                                            : _AnimatedTabContent(
                                                currentTab: _currentTab,
                                                contents: contents,
                                              );
                                      }(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The drag handle pill + TabBar header area.
class _SheetHeader extends StatelessWidget {
  final bool isClosed;
  final double closedNibWidth;
  final double closedNibHeight;
  final DanioDockGlassStyle dockGlassStyle;
  final TabController tabController;
  final VoidCallback onSnapPeek;
  final VoidCallback onSnapHalf;
  final VoidCallback onSnapFull;

  const _SheetHeader({
    required this.isClosed,
    required this.closedNibWidth,
    required this.closedNibHeight,
    required this.dockGlassStyle,
    required this.tabController,
    required this.onSnapPeek,
    required this.onSnapHalf,
    required this.onSnapFull,
  });

  @override
  Widget build(BuildContext context) {
    if (isClosed) {
      return StageSheetNib(
        width: closedNibWidth,
        height: closedNibHeight,
        glassStyle: dockGlassStyle,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag handle — StageHandle replaces old pill Container
        StageHandle(glassStyle: dockGlassStyle),

        // Horizontal tab bar
        TabBar(
          key: const ValueKey('danio-stage-sheet-tab-row'),
          controller: tabController,
          indicatorColor: Colors.transparent,
          dividerColor: Colors.transparent,
          labelColor: AppColors.whiteAlpha95,
          unselectedLabelColor: AppColors.whiteAlpha70,
          labelStyle: AppTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: AppTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w400,
          ),
          indicator: _PillTabIndicator(),
          tabs: const [
            Tab(
              child: FittedBox(fit: BoxFit.scaleDown, child: Text('Progress')),
            ),
            Tab(
              child: FittedBox(fit: BoxFit.scaleDown, child: Text('Tanks')),
            ),
            Tab(
              child: FittedBox(fit: BoxFit.scaleDown, child: Text('Today')),
            ),
            Tab(
              child: FittedBox(fit: BoxFit.scaleDown, child: Text('Tools')),
            ),
          ],
        ),
      ],
    );
  }
}

/// A subtle animated pill indicator under the active tab.
class _PillTabIndicator extends Decoration {
  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _PillPainter(onChanged);
  }
}

class _PillPainter extends BoxPainter {
  _PillPainter(super.onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size ?? Size.zero;
    const pillWidth = 28.0;
    const pillHeight = 3.0;
    final left = offset.dx + (size.width - pillWidth) / 2;
    final top = offset.dy + size.height - pillHeight - 4;

    final paint = Paint()
      ..color = AppColors.whiteAlpha95
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, pillWidth, pillHeight),
        const Radius.circular(2),
      ),
      paint,
    );
  }
}

// ── Animated Tab Content ──────────────────────────────────────────────────────

/// Replaces plain [TabBarView] with an [AnimatedSwitcher] that performs a
/// slide + fade transition when the active tab changes.
///
/// The slide direction matches the tab direction (left = slide left, etc.).
class _AnimatedTabContent extends StatefulWidget {
  final int currentTab;
  final List<Widget> contents;

  const _AnimatedTabContent({required this.currentTab, required this.contents});

  @override
  State<_AnimatedTabContent> createState() => _AnimatedTabContentState();
}

class _AnimatedTabContentState extends State<_AnimatedTabContent> {
  int _previousTab = 0;

  @override
  void didUpdateWidget(_AnimatedTabContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentTab != widget.currentTab) {
      _previousTab = oldWidget.currentTab;
    }
  }

  @override
  Widget build(BuildContext context) {
    final goingRight = widget.currentTab > _previousTab;

    return AnimatedSwitcher(
      duration: AppDurations.medium4,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        // Determine direction for this specific child
        final isIncoming = child.key == ValueKey(widget.currentTab);
        final slideBegin = isIncoming
            ? Offset(goingRight ? 0.15 : -0.15, 0.0)
            : Offset(goingRight ? -0.15 : 0.15, 0.0);

        return SlideTransition(
          position: Tween<Offset>(
            begin: slideBegin,
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: KeyedSubtree(
        key: ValueKey(widget.currentTab),
        child: widget.contents[widget.currentTab],
      ),
    );
  }
}

// ── First-Use Sheet Hint ──────────────────────────────────────────────────────

/// A bouncing upward chevron that appears above the sheet handle on first
/// launch to hint users they can swipe the sheet up.
class _BouncingChevronHint extends StatefulWidget {
  const _BouncingChevronHint();

  @override
  State<_BouncingChevronHint> createState() => _BouncingChevronHintState();
}

class _BouncingChevronHintState extends State<_BouncingChevronHint>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.extraLong,
    )..repeat(reverse: true);
    _bounce = Tween<double>(
      begin: 0.0,
      end: -8.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounce,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounce.value),
          child: child,
        );
      },
      child: Center(
        child: Icon(
          Icons.keyboard_arrow_up_rounded,
          color: AppColors.whiteAlpha70,
          size: 28,
        ),
      ),
    );
  }
}

// ── Workshop Tools Quick-Access ───────────────────────────────────────────────

/// Single Workshop entry for the bottom sheet's Tools tab.
class _WorkshopToolsContent extends StatelessWidget {
  const _WorkshopToolsContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm2),
            child: Text(
              'Workshop',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.whiteAlpha70,
                letterSpacing: 0.5,
              ),
            ),
          ),
          _SheetToolCard(
            icon: Icons.build_outlined,
            label: 'Open Workshop',
            color: DanioColors.tealWater,
            onTap: () =>
                NavigationThrottle.push(context, const WorkshopScreen()),
          ),
        ],
      ),
    );
  }
}

/// A compact tool card for the bottom sheet Tools tab.
/// Includes a subtle press-scale animation (0.95 → 1.0, 100ms easeOut).
class _SheetToolCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SheetToolCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_SheetToolCard> createState() => _SheetToolCardState();
}

class _SheetToolCardState extends State<_SheetToolCard> {
  bool _pressed = false;

  void _onTapDown(TapDownDetails _) => setState(() => _pressed = true);
  void _onTapUp(TapUpDetails _) => setState(() => _pressed = false);
  void _onTapCancel() => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedScale(
          scale: _pressed ? 0.95 : 1.0,
          duration: AppDurations.short,
          curve: Curves.easeOut,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.sm2),
            decoration: BoxDecoration(
              color: AppColors.whiteAlpha12,
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(color: AppColors.whiteAlpha20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: widget.color.withAlpha(51),
                    borderRadius: AppRadius.smallRadius,
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.color,
                    size: AppIconSizes.sm,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    widget.label,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.whiteAlpha95,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
