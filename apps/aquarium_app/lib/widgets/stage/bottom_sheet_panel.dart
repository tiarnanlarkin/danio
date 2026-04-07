import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../utils/navigation_throttle.dart';
import '../../screens/workshop_screen.dart';
import '../../screens/water_change_calculator_screen.dart';
import '../../screens/stocking_calculator_screen.dart';
import '../../screens/compatibility_checker_screen.dart';
import '../../screens/co2_calculator_screen.dart';
import 'stage_handle.dart';

/// A single DraggableScrollableSheet that replaces the three-stacked
/// BottomPlate system. Contains a horizontal TabBar with four tabs:
/// Progress | Tanks | Today | Tools.
///
/// Snap points: 0.12 (peek), 0.45 (half), 0.92 (full).
class BottomSheetPanel extends ConsumerStatefulWidget {
  /// Content for the Progress tab.
  final Widget progressContent;

  /// Content for the Tanks tab.
  final Widget tanksContent;

  /// Content for the Today tab.
  final Widget todayContent;

  const BottomSheetPanel({
    super.key,
    required this.progressContent,
    required this.tanksContent,
    required this.todayContent,
  });

  @override
  ConsumerState<BottomSheetPanel> createState() => _BottomSheetPanelState();
}

class _BottomSheetPanelState extends ConsumerState<BottomSheetPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  static const double _snapPeek = 0.16; // was 0.12 — increased for better tab visibility
  static const double _snapHalf = 0.45;
  static const double _snapFull = 0.92;

  int _currentTab = 0;

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
    final prefs = await SharedPreferences.getInstance();
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

  void _snapTo(double size) {
    if (!_sheetController.isAttached) return;
    _sheetController.animateTo(
      size,
      duration: AppDurations.medium4,
      curve: Curves.easeOutCubic,
    );
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.of(context).disableAnimations;

    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: _snapPeek,
      minChildSize: _snapPeek,
      maxChildSize: _snapFull,
      snapSizes: const [_snapPeek, _snapHalf, _snapFull],
      snap: true,
      shouldCloseOnMinExtent: false,
      builder: (context, scrollController) {
        return RepaintBoundary(
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: DecoratedBox(
              decoration: BoxDecoration(
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
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        color: AppColors.whiteAlpha25,
                      ),
                    ),
                  ),

                  // Sheet content — entire surface is scrollable so dragging
                  // the handle, tabs, or content all expand/collapse the sheet.
                  Column(
                    children: [
                      // First-use hint: bouncing chevron above the drag handle
                      if (_showSheetHint)
                        AnimatedOpacity(
                          opacity: _hintOpacity,
                          duration: const Duration(milliseconds: 600),
                          child: _BouncingChevronHint(),
                        ),

                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          physics: const ClampingScrollPhysics(),
                          // No bottom padding here. The TabNavigator parent already
                          // wraps this screen in `Padding(bottom: padding.bottom)`
                          // (tab_navigator.dart) so the sheet's parent stops at
                          // the navigation bar top. Adding padding.bottom inside
                          // the sheet content double-counts that inset and creates
                          // a visible gap above the bottom navigation bar.
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              // Drag handle + tabs header
                              _SheetHeader(
                                tabController: _tabController,
                                onSnapPeek: () => _snapTo(_snapPeek),
                                onSnapHalf: () => _snapTo(_snapHalf),
                                onSnapFull: () => _snapTo(_snapFull),
                              ),

                              // Tab content
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
        );
      },
    );
  }
}

/// The drag handle pill + TabBar header area.
class _SheetHeader extends StatelessWidget {
  final TabController tabController;
  final VoidCallback onSnapPeek;
  final VoidCallback onSnapHalf;
  final VoidCallback onSnapFull;

  const _SheetHeader({
    required this.tabController,
    required this.onSnapPeek,
    required this.onSnapHalf,
    required this.onSnapFull,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag handle — StageHandle replaces old pill Container
        const StageHandle(),

        // Horizontal tab bar
        TabBar(
          controller: tabController,
          indicatorColor: Colors.transparent,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.whiteAlpha50,
          labelStyle: AppTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: AppTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w400,
          ),
          indicator: _PillTabIndicator(),
          tabs: const [
            Tab(text: '🔥  Progress'),
            Tab(text: '🐠  Tanks'),
            Tab(text: '📋  Today'),
            Tab(text: '🔧  Tools'),
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

  const _AnimatedTabContent({
    required this.currentTab,
    required this.contents,
  });

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
    _bounce = Tween<double>(begin: 0.0, end: -8.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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

/// Inline workshop tools for the bottom sheet's Tools tab.
/// Shows the 4 most discoverable calculators + a "See All" button.
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
          // Section header
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm2),
            child: Text(
              'Quick Tools',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.whiteAlpha70,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // 2×2 grid of top tools
          Row(
            children: [
              Expanded(
                child: _SheetToolCard(
                  icon: Icons.water_drop,
                  label: 'Water Change',
                  color: DanioColors.tealWater,
                  onTap: () => NavigationThrottle.push(
                    context,
                    const WaterChangeCalculatorScreen(),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _SheetToolCard(
                  icon: Icons.pool,
                  label: 'Stocking',
                  color: DanioColors.wishlistAmber,
                  onTap: () => NavigationThrottle.push(
                    context,
                    const StockingCalculatorScreen(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _SheetToolCard(
                  icon: Icons.compare_arrows,
                  label: 'Compatibility',
                  color: DanioColors.wishlistAmber,
                  onTap: () => NavigationThrottle.push(
                    context,
                    const CompatibilityCheckerScreen(),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _SheetToolCard(
                  icon: Icons.science,
                  label: 'CO₂',
                  color: DanioColors.tealWater,
                  onTap: () => NavigationThrottle.push(
                    context,
                    const Co2CalculatorScreen(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // "See All Tools" button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => NavigationThrottle.push(
                context,
                const WorkshopScreen(),
              ),
              icon: const Icon(Icons.build_outlined, size: 16),
              label: const Text('See All Tools'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.whiteAlpha85,
                side: BorderSide(
                  color: AppColors.whiteAlpha30,
                ),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm2),
              ),
            ),
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
              border: Border.all(
                color: AppColors.whiteAlpha20,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: widget.color.withAlpha(51),
                    borderRadius: AppRadius.smallRadius,
                  ),
                  child: Icon(widget.icon, color: widget.color, size: AppIconSizes.sm),
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
