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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Stack(
                children: [
                  // Glassmorphism backdrop
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        color: Colors.white.withOpacity(0.15),
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

                      // Tab content
                      Expanded(
                        child: TabBarView(
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
                        ),
                      ),

                      // Bottom safe area padding
                      SizedBox(height: MediaQuery.of(context).padding.bottom),
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
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
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
          unselectedLabelColor: Colors.white.withOpacity(0.5),
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
    return SingleChildScrollView(
      controller: scrollController,
      physics: const ClampingScrollPhysics(),
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
      ..color = Colors.white.withOpacity(0.9)
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
