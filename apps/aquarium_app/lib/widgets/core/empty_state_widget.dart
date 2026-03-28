import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'app_button.dart';

/// A reusable illustrated empty-state widget for use across all screens.
///
/// Accepts an [icon], [title], [description], and optional [ctaLabel]/[onCta].
/// Renders a centred, animated, friendly empty state using Material icons.
///
/// Usage:
/// ```dart
/// EmptyStateWidget(
///   icon: Icons.water,
///   title: 'Your tank is waiting!',
///   description: 'Add your first fish to get started.',
///   ctaLabel: 'Add Fish',
///   onCta: () => _addFish(),
/// )
/// ```
class EmptyStateWidget extends StatefulWidget {
  /// Material icon to display in the illustrated circle.
  final IconData icon;

  /// Short, friendly headline.
  final String title;

  /// Slightly longer description below the title.
  final String description;

  /// Optional label for the CTA button. Requires [onCta] to be set.
  final String? ctaLabel;

  /// Callback for the CTA button.
  final VoidCallback? onCta;

  /// Optional icon for the CTA button (defaults to [Icons.add]).
  final IconData? ctaIcon;

  /// Accent color for the icon circle. Defaults to [AppColors.primary].
  final Color? accentColor;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.ctaLabel,
    this.onCta,
    this.ctaIcon,
    this.accentColor,
  });

  @override
  State<EmptyStateWidget> createState() => _EmptyStateWidgetState();
}

class _EmptyStateWidgetState extends State<EmptyStateWidget>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _floatController;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _floatController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutBack),
    );
    _floatAnim = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _floatController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.accentColor ?? AppColors.primary;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Semantics(
      label: '${widget.title}. ${widget.description}',
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Illustrated icon circle with float animation
                  AnimatedBuilder(
                    animation: _floatAnim,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(0, reduceMotion ? 0 : _floatAnim.value),
                      child: child,
                    ),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            color.withAlpha(26), // 10%
                            color.withAlpha(13), // 5%
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withAlpha(26),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.icon,
                        size: 56,
                        color: color,
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Description
                  Text(
                    widget.description,
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // CTA button
                  if (widget.ctaLabel != null && widget.onCta != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: widget.ctaLabel!,
                      onPressed: widget.onCta,
                      leadingIcon: widget.ctaIcon ?? Icons.add,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
