import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

/// Visual variant for cards
enum AppCardVariant {
  /// Default elevated card with shadow
  elevated,
  
  /// Card with border outline
  outlined,
  
  /// Filled with surface color
  filled,
  
  /// Glassmorphism effect (translucent with blur)
  glass,
  
  /// Gradient background
  gradient,
}

/// Padding presets for cards
enum AppCardPadding {
  /// No padding
  none,
  
  /// Compact: 8dp
  compact,
  
  /// Standard: 16dp
  standard,
  
  /// Spacious: 24dp
  spacious,
}

/// A unified card component providing consistent styling across the app.
/// 
/// Consolidates 45+ card variants into a single, composable component.
/// Supports different visual variants, structured layouts, and interactions.
/// 
/// Example:
/// ```dart
/// AppCard(
///   variant: AppCardVariant.elevated,
///   onTap: () => showDetails(),
///   child: Column(
///     children: [
///       Text('Card Title'),
///       Text('Card content'),
///     ],
///   ),
/// )
/// ```
class AppCard extends StatefulWidget {
  /// Main content of the card
  final Widget child;
  
  /// Visual variant
  final AppCardVariant variant;
  
  /// Internal padding
  final AppCardPadding padding;
  
  /// Custom padding (overrides padding preset)
  final EdgeInsets? customPadding;
  
  /// Optional header widget (appears above child)
  final Widget? header;
  
  /// Optional footer widget (appears below child)
  final Widget? footer;
  
  /// Called when card is tapped
  final VoidCallback? onTap;
  
  /// Called when card is long-pressed
  final VoidCallback? onLongPress;
  
  /// Custom background color
  final Color? backgroundColor;
  
  /// Gradient for gradient variant
  final LinearGradient? gradient;
  
  /// Custom border radius
  final BorderRadius? borderRadius;
  
  /// Custom shadow
  final List<BoxShadow>? boxShadow;
  
  /// Custom border
  final Border? border;
  
  /// Width constraint
  final double? width;
  
  /// Height constraint
  final double? height;
  
  /// Margin around the card
  final EdgeInsets? margin;
  
  /// Semantic label for accessibility
  final String? semanticsLabel;
  
  /// Whether to clip child content
  final bool clipBehavior;

  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.elevated,
    this.padding = AppCardPadding.standard,
    this.customPadding,
    this.header,
    this.footer,
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.gradient,
    this.borderRadius,
    this.boxShadow,
    this.border,
    this.width,
    this.height,
    this.margin,
    this.semanticsLabel,
    this.clipBehavior = true,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: AppDurations.short,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _scaleController, curve: AppCurves.standard),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  bool get _isInteractive => widget.onTap != null || widget.onLongPress != null;

  void _handleTapDown(TapDownDetails details) {
    if (_isInteractive) {
      setState(() => _isPressed = true);
      _scaleController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _handleTap() {
    if (widget.onTap != null) {
      HapticFeedback.lightImpact();
      widget.onTap!();
    }
  }

  void _handleLongPress() {
    if (widget.onLongPress != null) {
      HapticFeedback.mediumImpact();
      widget.onLongPress!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    Widget card = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isInteractive ? _scaleAnimation.value : 1.0,
          child: child,
        );
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        margin: widget.margin,
        decoration: _buildDecoration(isDark),
        clipBehavior: widget.clipBehavior ? Clip.antiAlias : Clip.none,
        child: _buildContent(),
      ),
    );

    if (_isInteractive) {
      card = Semantics(
        label: widget.semanticsLabel ?? 'Interactive card',
        button: true,
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onTap: _handleTap,
          onLongPress: _handleLongPress,
          child: card,
        ),
      );
    } else if (widget.semanticsLabel != null) {
      card = Semantics(
        label: widget.semanticsLabel,
        child: card,
      );
    }

    return card;
  }

  BoxDecoration _buildDecoration(bool isDark) {
    final radius = widget.borderRadius ?? AppRadius.mediumRadius;
    
    switch (widget.variant) {
      case AppCardVariant.elevated:
        return BoxDecoration(
          color: widget.backgroundColor ?? (context.cardColor),
          borderRadius: radius,
          boxShadow: widget.boxShadow ?? (_isPressed ? AppShadows.soft : AppShadows.medium),
        );
        
      case AppCardVariant.outlined:
        return BoxDecoration(
          color: widget.backgroundColor ?? Colors.transparent,
          borderRadius: radius,
          border: widget.border ?? Border.all(
            color: context.borderColor,
            width: 1,
          ),
        );
        
      case AppCardVariant.filled:
        return BoxDecoration(
          color: widget.backgroundColor ?? (context.surfaceVariant),
          borderRadius: radius,
        );
        
      case AppCardVariant.glass:
        return BoxDecoration(
          color: isDark ? AppOverlays.white10 : AppOverlays.black10,
          borderRadius: radius,
          border: Border.all(
            color: isDark ? AppOverlays.white10 : AppOverlays.black10,
            width: 1,
          ),
        );
        
      case AppCardVariant.gradient:
        return BoxDecoration(
          gradient: widget.gradient ?? AppColors.primaryGradient,
          borderRadius: radius,
          boxShadow: widget.boxShadow ?? AppShadows.glow,
        );
    }
  }

  Widget _buildContent() {
    final effectivePadding = widget.customPadding ?? _getPaddingForPreset();
    
    Widget content = Padding(
      padding: effectivePadding,
      child: widget.child,
    );

    if (widget.header != null || widget.footer != null) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.header != null) widget.header!,
          Padding(
            padding: effectivePadding,
            child: widget.child,
          ),
          if (widget.footer != null) widget.footer!,
        ],
      );
    }

    return content;
  }

  EdgeInsets _getPaddingForPreset() {
    switch (widget.padding) {
      case AppCardPadding.none:
        return EdgeInsets.zero;
      case AppCardPadding.compact:
        return const EdgeInsets.all(AppSpacing.sm);
      case AppCardPadding.standard:
        return const EdgeInsets.all(AppSpacing.md);
      case AppCardPadding.spacious:
        return const EdgeInsets.all(AppSpacing.lg);
    }
  }
}

// ============================================================================
// Pre-composed Card Variants
// ============================================================================

/// A card with an icon, title, and optional subtitle/description.
/// Great for tips, info blocks, and feature callouts.
class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppCard(
      variant: AppCardVariant.filled,
      backgroundColor: backgroundColor,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primary).withAlpha(38),
              borderRadius: AppRadius.smallRadius,
            ),
            child: Icon(
              icon,
              color: iconColor ?? AppColors.primary,
              size: AppIconSizes.md,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    color: context.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle!,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.chevron_right,
              color: context.textHint,
            ),
        ],
      ),
    );
  }
}

/// A card displaying a statistic with label and optional trend indicator.
class StatisticCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;
  final double? trend; // Positive for up, negative for down
  final Color? color;
  final VoidCallback? onTap;

  const StatisticCard({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.trend,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = color ?? AppColors.primary;
    
    return AppCard(
      variant: AppCardVariant.elevated,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (icon != null)
                Icon(icon, size: AppIconSizes.md, color: primaryColor),
              if (trend != null)
                _TrendBadge(trend: trend!),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.headlineMedium.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendBadge extends StatelessWidget {
  final double trend;

  const _TrendBadge({required this.trend});

  @override
  Widget build(BuildContext context) {
    final isPositive = trend >= 0;
    final color = isPositive ? AppColors.success : AppColors.error;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withAlpha(38),
        borderRadius: AppRadius.smallRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            size: AppIconSizes.xs,
            color: color,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '${isPositive ? '+' : ''}${trend.toStringAsFixed(1)}%',
            style: AppTypography.labelSmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

/// A card with an action button (CTA).
class ActionCard extends StatelessWidget {
  final String title;
  final String? description;
  final String actionLabel;
  final VoidCallback onAction;
  final IconData? icon;
  final Color? accentColor;

  const ActionCard({
    super.key,
    required this.title,
    this.description,
    required this.actionLabel,
    required this.onAction,
    this.icon,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = accentColor ?? AppColors.primary;
    
    return AppCard(
      variant: AppCardVariant.outlined,
      border: Border.all(color: color.withAlpha(76), width: 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppIconSizes.lg, color: color),
            const SizedBox(height: AppSpacing.sm),
          ],
          Text(
            title,
            style: AppTypography.titleSmall.copyWith(
              color: context.textPrimary,
            ),
          ),
          if (description != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              description!,
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: color,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              ),
              child: Text(actionLabel),
            ),
          ),
        ],
      ),
    );
  }
}
