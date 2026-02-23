import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// A standardised header widget used at the top of each room screen.
///
/// Provides a consistent layout: optional back button, room title,
/// optional subtitle, and optional trailing action(s).
///
/// Tokens used:
/// - [AppTypography.headline] for the title
/// - [AppTypography.body] for the subtitle
/// - [AppSpacing.s16] for horizontal padding
/// - [AppColors.primary] / dark-mode equivalents for text colour
///
/// Accessibility:
/// - Title is wrapped in [Semantics] with `header: true`
/// - Back button declares a semantic label "Back"
///
/// Example:
/// ```dart
/// RoomHeader(
///   title: 'Living Room',
///   subtitle: 'Tank: 60L Planted',
///   onBack: () => Navigator.pop(context),
///   trailing: [
///     IconButton(icon: Icon(Icons.settings), onPressed: openSettings),
///   ],
/// )
/// ```
class RoomHeader extends StatelessWidget implements PreferredSizeWidget {
  /// Room / screen title (required).
  final String title;

  /// Optional subtitle beneath the title (e.g. tank name or status).
  final String? subtitle;

  /// Callback for the back button. If null, the button is omitted.
  final VoidCallback? onBack;

  /// Optional widgets placed in the trailing (right) side of the header.
  ///
  /// Typically [IconButton] widgets for settings, add, share, etc.
  final List<Widget>? trailing;

  /// Background colour of the header bar. Defaults to the scaffold background.
  final Color? backgroundColor;

  /// Whether to draw a separator line beneath the header. Defaults to false.
  final bool showDivider;

  const RoomHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.trailing,
    this.backgroundColor,
    this.showDivider = false,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(subtitle != null ? 72.0 : 56.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titleColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final subtitleColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final bgColor = backgroundColor ??
        (isDark ? AppColors.backgroundDark : AppColors.background);

    return Semantics(
      container: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: subtitle != null ? 72.0 : 56.0,
            color: bgColor,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.s16),
            child: Row(
              children: [
                // ── Back button ────────────────────────────────────────────
                if (onBack != null)
                  Semantics(
                    label: 'Back',
                    button: true,
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: AppRadius.pillRadius,
                      child: InkWell(
                        onTap: onBack,
                        borderRadius: AppRadius.pillRadius,
                        child: Container(
                          width: AppTouchTargets.minimum,
                          height: AppTouchTargets.minimum,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            size: AppIconSizes.sm,
                            color: titleColor,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(width: AppSpacing.xs),

                // ── Title / Subtitle ───────────────────────────────────────
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTypography.headline.copyWith(
                            color: titleColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: AppTypography.body.copyWith(
                              color: subtitleColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // ── Trailing actions ───────────────────────────────────────
                if (trailing != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: trailing!,
                  ),
              ],
            ),
          ),

          // ── Optional divider ─────────────────────────────────────────────
          if (showDivider)
            Divider(
              height: 1,
              thickness: 1,
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
        ],
      ),
    );
  }
}
