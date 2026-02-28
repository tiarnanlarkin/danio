import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

/// Standard app bar with consistent styling
class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Title text
  final String? title;
  
  /// Title widget (alternative to text title)
  final Widget? titleWidget;
  
  /// Leading widget (defaults to back button if canPop)
  final Widget? leading;
  
  /// Whether to show back button automatically
  final bool automaticallyImplyLeading;
  
  /// Action buttons
  final List<Widget>? actions;
  
  /// Whether to center the title
  final bool centerTitle;
  
  /// Background color
  final Color? backgroundColor;
  
  /// Elevation
  final double elevation;
  
  /// Whether this is a transparent/overlay app bar
  final bool transparent;
  
  /// Bottom widget (tabs, etc.)
  final PreferredSizeWidget? bottom;
  
  /// Custom height
  final double? toolbarHeight;

  const AppAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.actions,
    this.centerTitle = true,
    this.backgroundColor,
    this.elevation = 0,
    this.transparent = false,
    this.bottom,
    this.toolbarHeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return AppBar(
      title: titleWidget ?? (title != null ? Text(
        title!,
        style: AppTypography.titleMedium.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
      ) : null),
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: actions,
      centerTitle: centerTitle,
      backgroundColor: transparent 
          ? Colors.transparent 
          : (backgroundColor ?? (isDark ? AppColors.surfaceDark : AppColors.surface)),
      elevation: elevation,
      scrolledUnderElevation: transparent ? 0 : 1,
      surfaceTintColor: Colors.transparent,
      bottom: bottom,
      toolbarHeight: toolbarHeight,
      iconTheme: IconThemeData(
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    (toolbarHeight ?? kToolbarHeight) + (bottom?.preferredSize.height ?? 0),
  );
}

/// App bar action button with consistent sizing
class AppBarAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final String? semanticsLabel;
  final bool showBadge;
  final int? badgeCount;
  final Color? color;

  const AppBarAction({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.semanticsLabel,
    this.showBadge = false,
    this.badgeCount,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    Widget button = IconButton(
      icon: Icon(icon, size: AppIconSizes.md),
      onPressed: onPressed,
      tooltip: tooltip,
      color: color ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
    );

    if (showBadge) {
      button = Badge(
        isLabelVisible: badgeCount != null && badgeCount! > 0,
        label: badgeCount != null ? Text(
          badgeCount! > 99 ? '99+' : badgeCount.toString(),
          style: TextStyle(fontSize: 10),
        ) : null,
        child: button,
      );
    }

    return Semantics(
      label: semanticsLabel ?? tooltip,
      button: true,
      child: button,
    );
  }
}

/// Back button with consistent styling
class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;
  final String? semanticsLabel;

  const AppBackButton({
    super.key,
    this.onPressed,
    this.color,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Semantics(
      label: semanticsLabel ?? 'Go back',
      button: true,
      child: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, size: AppIconSizes.sm),
        tooltip: 'Go back',
        onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
        color: color ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      ),
    );
  }
}

/// Close button with consistent styling
class AppCloseButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;
  final String? semanticsLabel;

  const AppCloseButton({
    super.key,
    this.onPressed,
    this.color,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Semantics(
      label: semanticsLabel ?? 'Close',
      button: true,
      child: IconButton(
        icon: Icon(Icons.close, size: AppIconSizes.md),
        tooltip: 'Close',
        onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
        color: color ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      ),
    );
  }
}

/// Tab bar with consistent styling
class AppTabBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Tab> tabs;
  final TabController? controller;
  final bool isScrollable;
  final void Function(int)? onTap;
  final EdgeInsets? padding;

  const AppTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.isScrollable = false,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return TabBar(
      controller: controller,
      tabs: tabs,
      isScrollable: isScrollable,
      onTap: onTap,
      padding: padding,
      labelColor: AppColors.primary,
      unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
      labelStyle: AppTypography.labelLarge,
      unselectedLabelStyle: AppTypography.labelMedium,
      indicatorColor: AppColors.primary,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.transparent,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48);
}

/// Bottom navigation bar with consistent styling
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppBottomNavItem> items;
  final Color? backgroundColor;
  final bool showLabels;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? (isDark ? AppColors.surfaceDark : AppColors.surface),
        boxShadow: [
          BoxShadow(
            color: AppOverlays.black10,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == currentIndex;
              
              return _NavBarItem(
                item: item,
                isSelected: isSelected,
                showLabel: showLabels,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTap(index);
                },
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final AppBottomNavItem item;
  final bool isSelected;
  final bool showLabel;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.item,
    required this.isSelected,
    required this.showLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = isSelected 
        ? AppColors.primary 
        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary);

    return Semantics(
      label: item.label,
      selected: isSelected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smallRadius,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: AppDurations.short,
                padding: EdgeInsets.all(isSelected ? AppSpacing.sm : 0),
                decoration: BoxDecoration(
                  color: isSelected ? AppOverlays.primary10 : null,
                  borderRadius: AppRadius.smallRadius,
                ),
                child: Badge(
                  isLabelVisible: item.badgeCount != null && item.badgeCount! > 0,
                  label: item.badgeCount != null 
                      ? Text(item.badgeCount.toString(), style: TextStyle(fontSize: 10))
                      : null,
                  child: Icon(
                    isSelected ? item.activeIcon ?? item.icon : item.icon,
                    size: AppIconSizes.md,
                    color: color,
                  ),
                ),
              ),
              if (showLabel) ...[
                SizedBox(height: AppSpacing.xs),
                Text(
                  item.label,
                  style: AppTypography.labelSmall.copyWith(
                    color: color,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom navigation item data
class AppBottomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final int? badgeCount;

  const AppBottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.badgeCount,
  });
}

/// Section header for settings/list screens
class AppSectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final EdgeInsets? padding;

  const AppSectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: padding ?? EdgeInsets.fromLTRB(
        AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTypography.labelSmall.copyWith(
              color: isDark ? AppColors.textHintDark : AppColors.textHint,
              letterSpacing: 0.5,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Scaffold with consistent styling and safe area handling
class AppScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Color? backgroundColor;
  final bool extendBodyBehindAppBar;
  final bool extendBody;
  final bool resizeToAvoidBottomInset;

  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.drawer,
    this.backgroundColor,
    this.extendBodyBehindAppBar = false,
    this.extendBody = false,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      backgroundColor: backgroundColor ?? (isDark ? AppColors.backgroundDark : AppColors.background),
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      extendBody: extendBody,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}
