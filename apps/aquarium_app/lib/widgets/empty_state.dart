import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'mascot/mascot_widgets.dart';

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

class _EmptyStateState extends State<EmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
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
                // Icon or custom illustration
                if (widget.illustration != null)
                  widget.illustration!
                else
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppOverlays.primary10,
                          AppOverlays.primary5,
                        ],
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
                      size: 60,
                      color: AppColors.primary,
                    ),
                  ),

                const SizedBox(height: AppSpacing.lg),

                // Title
                Text(
                  widget.title,
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.sm),

                // Message
                Text(
                  widget.message,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
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
                      border: Border.all(
                        color: AppOverlays.info20,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              size: 16,
                              color: AppColors.info,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Quick Tips',
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.info,
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
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    tip,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
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
                  ElevatedButton.icon(
                    onPressed: widget.onAction,
                    icon: const Icon(Icons.add),
                    label: Text(widget.actionLabel!),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                    ),
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
          Icon(icon, size: 48, color: AppColors.textHint),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.md),
            TextButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add, size: 18),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
