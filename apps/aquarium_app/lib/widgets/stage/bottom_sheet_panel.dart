import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';

/// A single DraggableScrollableSheet that replaces the three-stacked
/// BottomPlate system. Contains a horizontal TabBar with three tabs:
/// Progress | Tanks | Today.
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

  static const double _snapPeek = 0.12;
  static const double _snapHalf = 0.45;
  static const double _snapFull = 0.92;

  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _currentTab = _tabController.index);
      }
    });
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
      duration: const Duration(milliseconds: 300),
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
                    color: Colors.white.withValues(alpha: 0.2),
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
                        color: Colors.white.withValues(alpha: 0.28),
                      ),
                    ),
                  ),

                  // Sheet content
                  Column(
                    children: [
                      // Drag handle + tabs header
                      _SheetHeader(
                        tabController: _tabController,
                        scrollController: scrollController,
                        reducedMotion: reducedMotion,
                        onSnapPeek: () => _snapTo(_snapPeek),
                        onSnapHalf: () => _snapTo(_snapHalf),
                        onSnapFull: () => _snapTo(_snapFull),
                      ),

                      // Tab content with fade-slide transition
                      Expanded(
                        child: reducedMotion
                            ? TabBarView(
                                controller: _tabController,
                                children: [
                                  _TabContent(
                                    scrollController: scrollController,
                                    child: widget.progressContent,
                                  ),
                                  _TabContent(
                                    scrollController: scrollController,
                                    child: widget.tanksContent,
                                  ),
                                  _TabContent(
                                    scrollController: scrollController,
                                    child: widget.todayContent,
                                  ),
                                ],
                              )
                            : _AnimatedTabContent(
                                tabController: _tabController,
                                scrollController: scrollController,
                                currentTab: _currentTab,
                                contents: [
                                  widget.progressContent,
                                  widget.tanksContent,
                                  widget.todayContent,
                                ],
                              ),
                      ),
                      // NOTE: Bottom safe area SizedBox was here but caused a
                      // Column overflow when padding.bottom (e.g. nav bar 67dp)
                      // was added AFTER the Expanded child — Expanded absorbs all
                      // remaining space first, leaving no room for the SizedBox.
                      // Removed: content is inside a scrollable so the bottom
                      // inset does not clip visible content.
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
  final ScrollController scrollController;
  final bool reducedMotion;
  final VoidCallback onSnapPeek;
  final VoidCallback onSnapHalf;
  final VoidCallback onSnapFull;

  const _SheetHeader({
    required this.tabController,
    required this.scrollController,
    required this.reducedMotion,
    required this.onSnapPeek,
    required this.onSnapHalf,
    required this.onSnapFull,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag handle pill
        const SizedBox(height: 10),
        Center(
          child: Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Horizontal tab bar
        TabBar(
          controller: tabController,
          indicatorColor: Colors.transparent,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.5),
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
          ],
        ),
      ],
    );
  }
}

/// Wraps tab content in a scroll view that plays nicely with the sheet.
class _TabContent extends StatelessWidget {
  final ScrollController scrollController;
  final Widget child;

  const _TabContent({
    required this.scrollController,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Add bottom padding equal to the system/nav bar inset so the last items
    // in the scrollable are not clipped behind the NavigationBar when
    // extendBody: true is used in TabNavigator.
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return SingleChildScrollView(
      controller: scrollController,
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: child,
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
      ..color = Colors.white.withValues(alpha: 0.9)
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
  final TabController tabController;
  final ScrollController scrollController;
  final int currentTab;
  final List<Widget> contents;

  const _AnimatedTabContent({
    required this.tabController,
    required this.scrollController,
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
      duration: const Duration(milliseconds: 300),
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
        child: _TabContent(
          scrollController: widget.scrollController,
          child: widget.contents[widget.currentTab],
        ),
      ),
    );
  }
}
