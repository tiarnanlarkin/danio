import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'core/app_button.dart';
import 'mascot/mascot_widgets.dart';

/// Empty state widgets with mascot support
/// Beautiful empty state widget for consistent UX
///
/// Usage:
/// ```dart
/// EmptyState(
///   icon: Icons.water_drop,
///   title: 'No tanks yet',
///   message: 'Create your first aquarium to get started!',
///   actionLabel: 'Create Tank',
///   onAction: () => _createTank(),
/// )
/// ```
///
/// With mascot:
/// ```dart
/// EmptyState.withMascot(
///   icon: Icons.water_drop,
///   title: 'No tanks yet',
///   message: 'Create your first aquarium to get started!',
///   mascotContext: MascotContext.noTanks,
///   actionLabel: 'Create Tank',
///   onAction: () => _createTank(),
/// )
/// ```
class EmptyState extends StatefulWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? illustration;
  final List<String>? tips;

  /// Optional mascot message to display
  final String? mascotMessage;

  /// Optional mascot mood (defaults to encouraging)
  final MascotMood? mascotMood;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.illustration,
    this.tips,
    this.mascotMessage,
    this.mascotMood,
  });

  /// Create an empty state with Finn the mascot
  factory EmptyState.withMascot({
    Key? key,
    required IconData icon,
    required String title,
    required String message,
    required MascotContext mascotContext,
    String? actionLabel,
    VoidCallback? onAction,
    Widget? illustration,
    List<String>? tips,
  }) {
    return EmptyState(
      key: key,
      icon: icon,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      illustration: illustration,
      tips: tips,
      mascotMessage: MascotHelper.getMessage(mascotContext),
      mascotMood: MascotHelper.getMoodForContext(mascotContext),
    );
  }

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _floatController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Gentle float animation for the icon
    _floatController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _floatAnimation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    _floatController.repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.standardAccelerate),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.standardDecelerate),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon or custom illustration with gentle float
                if (widget.illustration != null)
                  widget.illustration!
                else
                  AnimatedBuilder(
                    animation: _floatAnimation,
                    builder: (context, child) {
                      final reduceMotion = MediaQuery.of(
                        context,
                      ).disableAnimations;
                      return Transform.translate(
                        offset: Offset(
                          0,
                          reduceMotion ? 0 : _floatAnimation.value,
                        ),
                        child: child,
                      );
                    },
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppOverlays.primary10, AppOverlays.primary5],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: AppOverlays.primary10,
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.icon,
                        size: 64,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                const SizedBox(height: AppSpacing.lg),

                // Title
                Text(
                  widget.title,
                  style: AppTypography.headlineMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.sm),

                // Message
                Text(
                  widget.message,
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                // Tips section
                if (widget.tips != null && widget.tips!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppOverlays.info5,
                      borderRadius: AppRadius.mediumRadius,
                      border: Border.all(color: AppOverlays.accent20, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              size: AppIconSizes.xs,
                              color: context.textSecondary,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Quick Tips',
                              style: AppTypography.labelMedium.copyWith(
                                color: context.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ...widget.tips!.map(
                          (tip) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '• ',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: context.textSecondary,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    tip,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: context.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Mascot bubble (if provided)
                if (widget.mascotMessage != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  MascotBubble(
                    message: widget.mascotMessage!,
                    mood: widget.mascotMood ?? MascotMood.encouraging,
                    size: MascotSize.medium,
                  ),
                ],

                // Action button
                if (widget.actionLabel != null && widget.onAction != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    onPressed: widget.onAction,
                    label: widget.actionLabel!,
                    leadingIcon: Icons.add,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact empty state for smaller sections
class CompactEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const CompactEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppIconSizes.xl, color: context.textHint),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: AppTypography.bodyMedium.copyWith(
              color: context.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: actionLabel!,
              onPressed: onAction,
              leadingIcon: Icons.add,
              variant: AppButtonVariant.text,
            ),
          ],
        ],
      ),
    );
  }
}
