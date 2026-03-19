import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'mascot_helper.dart';

/// A speech bubble widget featuring Finn the mascot fish.
///
/// Displays a message with an animated speech bubble and the mascot character.
/// The mascot's appearance changes based on mood.
///
/// Example:
/// ```dart
/// MascotBubble(
///   message: "Let's set up your first tank!",
///   mood: MascotMood.encouraging,
///   onTap: () => print('Mascot tapped!'),
/// )
/// ```
class MascotBubble extends StatefulWidget {
  /// The message to display in the speech bubble
  final String message;

  /// The mood of the mascot, affects appearance
  final MascotMood mood;

  /// Optional callback when the bubble is tapped
  final VoidCallback? onTap;

  /// Optional callback when the dismiss button is pressed
  final VoidCallback? onDismiss;

  /// Whether to show a dismiss button
  final bool showDismiss;

  /// Whether to animate the entrance
  final bool animateEntrance;

  /// Size of the mascot (small, medium, large)
  final MascotSize size;

  /// Position of the mascot relative to the bubble
  final MascotPosition position;

  const MascotBubble({
    super.key,
    required this.message,
    this.mood = MascotMood.happy,
    this.onTap,
    this.onDismiss,
    this.showDismiss = false,
    this.animateEntrance = true,
    this.size = MascotSize.medium,
    this.position = MascotPosition.left,
  });

  /// Create a mascot bubble from a context
  factory MascotBubble.fromContext({
    Key? key,
    required MascotContext context,
    VoidCallback? onTap,
    VoidCallback? onDismiss,
    bool showDismiss = false,
    bool animateEntrance = true,
    MascotSize size = MascotSize.medium,
    MascotPosition position = MascotPosition.left,
  }) {
    return MascotBubble(
      key: key,
      message: MascotHelper.getMessage(context),
      mood: MascotHelper.getMoodForContext(context),
      onTap: onTap,
      onDismiss: onDismiss,
      showDismiss: showDismiss,
      animateEntrance: animateEntrance,
      size: size,
      position: position,
    );
  }

  @override
  State<MascotBubble> createState() => _MascotBubbleState();
}

class _MascotBubbleState extends State<MascotBubble>
    with TickerProviderStateMixin {
  late AnimationController _bubbleController;
  late AnimationController _fishController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fishBobAnimation;

  @override
  void initState() {
    super.initState();

    // Bubble entrance animation
    _bubbleController = AnimationController(
      duration: AppDurations.long2,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bubbleController, curve: AppCurves.elastic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _bubbleController,
        curve: const Interval(0.0, 0.5, curve: AppCurves.standardDecelerate),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _bubbleController,
            curve: AppCurves.emphasized,
          ),
        );

    // Fish bobbing animation (continuous)
    _fishController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fishBobAnimation = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(parent: _fishController, curve: AppCurves.standard),
    );

    // Start animations
    if (widget.animateEntrance) {
      _bubbleController.forward();
    } else {
      _bubbleController.value = 1.0;
    }
    _fishController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _bubbleController.dispose();
    _fishController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dimensions = widget.size.dimensions;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Semantics(
          button: widget.onTap != null,
          label: widget.message,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (widget.position == MascotPosition.left) ...[
                  _buildMascot(dimensions),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Flexible(
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    alignment: widget.position == MascotPosition.left
                        ? Alignment.bottomLeft
                        : Alignment.bottomRight,
                    child: _buildBubble(),
                  ),
                ),
                if (widget.position == MascotPosition.right) ...[
                  const SizedBox(width: AppSpacing.sm),
                  _buildMascot(dimensions),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMascot(_MascotDimensions dimensions) {
    return AnimatedBuilder(
      animation: _fishBobAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _fishBobAnimation.value),
          child: Container(
            width: dimensions.mascotSize,
            height: dimensions.mascotSize,
            decoration: BoxDecoration(
              gradient: _getMascotGradient(),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryAlpha30,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '🐠',
                style: TextStyle(fontSize: dimensions.emojiSize),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBubble() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 4,
          ),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(AppRadius.lg),
              topRight: const Radius.circular(AppRadius.lg),
              bottomLeft: widget.position == MascotPosition.left
                  ? const Radius.circular(4)
                  : const Radius.circular(AppRadius.lg),
              bottomRight: widget.position == MascotPosition.right
                  ? const Radius.circular(4)
                  : const Radius.circular(AppRadius.lg),
            ),
            boxShadow: [
              BoxShadow(
                color: AppOverlays.black10,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: AppColors.primaryAlpha20, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  widget.message,
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.textPrimary,
                  ),
                ),
              ),
              if (widget.showDismiss) ...[
                const SizedBox(width: AppSpacing.sm),
                Semantics(
                  label: 'Dismiss mascot message',
                  button: true,
                  child: GestureDetector(
                    onTap: widget.onDismiss,
                    child: Icon(
                      Icons.close,
                      size: AppIconSizes.xs,
                      color: context.textHint,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        // Mood indicator
        if (widget.mood != MascotMood.happy)
          Positioned(
            top: -8,
            right: 12,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                shape: BoxShape.circle,
                boxShadow: AppShadows.subtle,
              ),
              child: Text(
                widget.mood.emoji,
                style: Theme.of(context).textTheme.bodySmall!,
              ),
            ),
          ),
      ],
    );
  }

  LinearGradient _getMascotGradient() {
    switch (widget.mood) {
      case MascotMood.happy:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryLight, AppColors.primary],
        );
      case MascotMood.thinking:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [DanioColors.tealWater, Color(0xFF4A8A92)],
        );
      case MascotMood.celebrating:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
        );
      case MascotMood.encouraging:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9F6847), Color(0xFFE8A87C)],
        );
      case MascotMood.curious:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFC5A3FF), Color(0xFF9F7AEA)],
        );
      case MascotMood.waving:
        return AppColors.primaryGradient;
    }
  }
}

/// Size options for the mascot
enum MascotSize { small, medium, large }

extension on MascotSize {
  _MascotDimensions get dimensions {
    switch (this) {
      case MascotSize.small:
        return const _MascotDimensions(mascotSize: 40, emojiSize: 20);
      case MascotSize.medium:
        return const _MascotDimensions(mascotSize: 56, emojiSize: 28);
      case MascotSize.large:
        return const _MascotDimensions(mascotSize: 80, emojiSize: 40);
    }
  }
}

class _MascotDimensions {
  final double mascotSize;
  final double emojiSize;

  const _MascotDimensions({required this.mascotSize, required this.emojiSize});
}

/// Position of the mascot relative to the bubble
enum MascotPosition { left, right }

/// A compact mascot widget without the speech bubble
/// Useful for inline display or decoration
class MascotAvatar extends StatefulWidget {
  final MascotMood mood;
  final MascotSize size;
  final VoidCallback? onTap;
  final bool animate;

  const MascotAvatar({
    super.key,
    this.mood = MascotMood.happy,
    this.size = MascotSize.medium,
    this.onTap,
    this.animate = true,
  });

  @override
  State<MascotAvatar> createState() => _MascotAvatarState();
}

class _MascotAvatarState extends State<MascotAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bobAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _bobAnimation = Tween<double>(
      begin: -3,
      end: 3,
    ).animate(CurvedAnimation(parent: _controller, curve: AppCurves.standard));

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dimensions = widget.size.dimensions;

    Widget avatar = AnimatedBuilder(
      animation: _bobAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, widget.animate ? _bobAnimation.value : 0),
          child: Container(
            width: dimensions.mascotSize,
            height: dimensions.mascotSize,
            decoration: BoxDecoration(
              gradient: _getGradient(),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryAlpha30,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '🐠',
                style: TextStyle(fontSize: dimensions.emojiSize),
              ),
            ),
          ),
        );
      },
    );

    if (widget.onTap != null) {
      return Semantics(
        button: true,
        label: 'Mascot avatar',
        child: GestureDetector(onTap: widget.onTap, child: avatar),
      );
    }

    return avatar;
  }

  LinearGradient _getGradient() {
    switch (widget.mood) {
      case MascotMood.happy:
        return const LinearGradient(
          colors: [AppColors.primaryLight, AppColors.primary],
        );
      case MascotMood.thinking:
        return const LinearGradient(
          colors: [DanioColors.tealWater, Color(0xFF4A8A92)],
        );
      case MascotMood.celebrating:
        return const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
        );
      case MascotMood.encouraging:
        return const LinearGradient(
          colors: [Color(0xFF9F6847), Color(0xFFE8A87C)],
        );
      case MascotMood.curious:
        return const LinearGradient(
          colors: [Color(0xFFC5A3FF), Color(0xFF9F7AEA)],
        );
      case MascotMood.waving:
        return AppColors.primaryGradient;
    }
  }
}

/// A full-width mascot banner for use at the top of screens
class MascotBanner extends StatelessWidget {
  final String message;
  final MascotMood mood;
  final VoidCallback? onDismiss;
  final Widget? action;

  const MascotBanner({
    super.key,
    required this.message,
    this.mood = MascotMood.happy,
    this.onDismiss,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryAlpha10,
            AppColors.primaryLight.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: AppRadius.largeRadius,
        border: Border.all(color: AppColors.primaryAlpha20, width: 1),
      ),
      child: Row(
        children: [
          MascotAvatar(mood: mood, size: MascotSize.small),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.textPrimary,
                  ),
                ),
                if (action != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  action!,
                ],
              ],
            ),
          ),
          if (onDismiss != null)
            IconButton(
              tooltip: 'Close',
              icon: const Icon(Icons.close, size: 18),
              onPressed: onDismiss,
              visualDensity: VisualDensity.compact,
              color: context.textHint,
            ),
        ],
      ),
    );
  }
}
