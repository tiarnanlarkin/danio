import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import '../theme/app_theme.dart';

/// Extension for checking accessibility preferences
extension AccessibilityContext on BuildContext {
  /// Whether the user prefers reduced motion
  bool get prefersReducedMotion {
    return MediaQuery.of(this).disableAnimations;
  }

  /// Whether the user is using a screen reader
  bool get isUsingScreenReader {
    return MediaQuery.of(this).accessibleNavigation;
  }

  /// Whether high contrast mode is enabled
  bool get prefersHighContrast {
    return MediaQuery.of(this).highContrast;
  }

  /// Whether bold text is enabled
  bool get prefersBoldText {
    return MediaQuery.of(this).boldText;
  }

  /// Text scale factor
  double get textScaleFactor {
    return MediaQuery.of(this).textScaleFactor;
  }

  /// Get accessible animation duration (respects reduced motion)
  Duration accessibleDuration(Duration normal, {Duration? reduced}) {
    if (prefersReducedMotion) {
      return reduced ?? Duration.zero;
    }
    return normal;
  }

  /// Get accessible curve (returns linear for reduced motion)
  Curve accessibleCurve(Curve normal) {
    if (prefersReducedMotion) {
      return Curves.linear;
    }
    return normal;
  }
}

/// Mixin for stateful widgets that need reduced motion support
mixin ReducedMotionMixin<T extends StatefulWidget> on State<T> {
  /// Whether to reduce motion
  bool get reduceMotion => MediaQuery.of(context).disableAnimations;

  /// Get duration that respects reduced motion preference
  Duration getAnimationDuration(Duration normal) {
    return reduceMotion ? Duration.zero : normal;
  }

  /// Get curve that respects reduced motion preference
  Curve getAnimationCurve(Curve normal) {
    return reduceMotion ? Curves.linear : normal;
  }
}

/// A widget that respects reduced motion preferences
class MotionAware extends StatelessWidget {
  /// Child to display when animations are enabled
  final Widget child;

  /// Optional alternative child for reduced motion
  final Widget? reducedMotionChild;

  /// Whether this animation is essential (should play even with reduced motion)
  final bool isEssential;

  const MotionAware({
    super.key,
    required this.child,
    this.reducedMotionChild,
    this.isEssential = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isEssential && context.prefersReducedMotion) {
      return reducedMotionChild ?? child;
    }
    return child;
  }
}

/// AnimatedContainer that respects reduced motion
class AccessibleAnimatedContainer extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration? reducedDuration;
  final Curve curve;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Decoration? decoration;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry? margin;
  final Matrix4? transform;
  final double? width;
  final double? height;

  const AccessibleAnimatedContainer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 200),
    this.reducedDuration,
    this.curve = Curves.easeInOut,
    this.alignment,
    this.padding,
    this.color,
    this.decoration,
    this.constraints,
    this.margin,
    this.transform,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveDuration = context.prefersReducedMotion
        ? (reducedDuration ?? Duration.zero)
        : duration;

    return AnimatedContainer(
      duration: effectiveDuration,
      curve: context.prefersReducedMotion ? Curves.linear : curve,
      alignment: alignment,
      padding: padding,
      color: color,
      decoration: decoration,
      constraints: constraints,
      margin: margin,
      transform: transform,
      width: width,
      height: height,
      child: child,
    );
  }
}

/// Focus traversal group with semantic ordering
class AccessibleFocusGroup extends StatelessWidget {
  final Widget child;
  final FocusTraversalPolicy? policy;
  final bool descendantsAreFocusable;
  final bool descendantsAreTraversable;

  const AccessibleFocusGroup({
    super.key,
    required this.child,
    this.policy,
    this.descendantsAreFocusable = true,
    this.descendantsAreTraversable = true,
  });

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: policy ?? OrderedTraversalPolicy(),
      descendantsAreFocusable: descendantsAreFocusable,
      descendantsAreTraversable: descendantsAreTraversable,
      child: child,
    );
  }
}

/// Semantics wrapper with common patterns
class AppSemantics extends StatelessWidget {
  final Widget child;
  final String? label;
  final String? value;
  final String? hint;
  final bool? button;
  final bool? link;
  final bool? header;
  final bool? image;
  final bool? enabled;
  final bool? selected;
  final bool? checked;
  final bool? focusable;
  final bool? focused;
  final bool? hidden;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool excludeSemantics;

  const AppSemantics({
    super.key,
    required this.child,
    this.label,
    this.value,
    this.hint,
    this.button,
    this.link,
    this.header,
    this.image,
    this.enabled,
    this.selected,
    this.checked,
    this.focusable,
    this.focused,
    this.hidden,
    this.onTap,
    this.onLongPress,
    this.excludeSemantics = false,
  });

  /// Create semantics for a button
  factory AppSemantics.button({
    Key? key,
    required Widget child,
    required String label,
    String? hint,
    bool enabled = true,
    VoidCallback? onTap,
  }) {
    return AppSemantics(
      key: key,
      label: label,
      hint: hint,
      button: true,
      enabled: enabled,
      onTap: onTap,
      child: child,
    );
  }

  /// Create semantics for a link
  factory AppSemantics.link({
    Key? key,
    required Widget child,
    required String label,
    VoidCallback? onTap,
  }) {
    return AppSemantics(
      key: key,
      label: label,
      link: true,
      onTap: onTap,
      child: child,
    );
  }

  /// Create semantics for a header
  factory AppSemantics.header({
    Key? key,
    required Widget child,
    required String label,
  }) {
    return AppSemantics(
      key: key,
      label: label,
      header: true,
      child: child,
    );
  }

  /// Create semantics for a selectable item
  factory AppSemantics.selectable({
    Key? key,
    required Widget child,
    required String label,
    required bool selected,
    VoidCallback? onTap,
  }) {
    return AppSemantics(
      key: key,
      label: label,
      selected: selected,
      button: true,
      onTap: onTap,
      child: child,
    );
  }

  /// Create semantics for a toggleable item (checkbox, switch)
  factory AppSemantics.toggle({
    Key? key,
    required Widget child,
    required String label,
    required bool checked,
    VoidCallback? onTap,
  }) {
    return AppSemantics(
      key: key,
      label: label,
      checked: checked,
      button: true,
      onTap: onTap,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (excludeSemantics) {
      return ExcludeSemantics(child: child);
    }

    return Semantics(
      label: label,
      value: value,
      hint: hint,
      button: button,
      link: link,
      header: header,
      image: image,
      enabled: enabled,
      selected: selected,
      checked: checked,
      focusable: focusable,
      focused: focused,
      hidden: hidden,
      onTap: onTap,
      onLongPress: onLongPress,
      child: child,
    );
  }
}

/// Ensures minimum touch target size for accessibility
class MinimumTouchTarget extends StatelessWidget {
  final Widget child;
  final double minSize;
  final HitTestBehavior behavior;

  const MinimumTouchTarget({
    super.key,
    required this.child,
    this.minSize = 48.0, // WCAG minimum
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minSize,
        minHeight: minSize,
      ),
      child: Center(child: child),
    );
  }
}

/// A wrapper that announces changes to screen readers
class LiveRegion extends StatefulWidget {
  final Widget child;
  final String? announcement;
  final bool assertive;

  const LiveRegion({
    super.key,
    required this.child,
    this.announcement,
    this.assertive = false,
  });

  @override
  State<LiveRegion> createState() => _LiveRegionState();
}

class _LiveRegionState extends State<LiveRegion> {
  @override
  void didUpdateWidget(LiveRegion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.announcement != null &&
        widget.announcement != oldWidget.announcement) {
      // Announce to screen readers
      SemanticsService.announce(
        widget.announcement!,
        TextDirection.ltr,
        assertiveness: widget.assertive
            ? Assertiveness.assertive
            : Assertiveness.polite,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Common accessibility labels
class A11yLabels {
  A11yLabels._();

  // Navigation
  static const back = 'Go back';
  static const close = 'Close';
  static const menu = 'Menu';
  static const search = 'Search';
  static const settings = 'Settings';
  static const home = 'Home';
  
  // Actions
  static const add = 'Add';
  static const edit = 'Edit';
  static const delete = 'Delete';
  static const save = 'Save';
  static const cancel = 'Cancel';
  static const confirm = 'Confirm';
  static const share = 'Share';
  static const refresh = 'Refresh';
  
  // Status
  static const loading = 'Loading';
  static const error = 'Error';
  static const success = 'Success';
  static const warning = 'Warning';
  
  // App-specific
  static const addTank = 'Add new tank';
  static const viewTank = 'View tank details';
  static const logParameters = 'Log water parameters';
  static const startLesson = 'Start lesson';
  static const completeTask = 'Mark task as complete';
  
  // Formatting helpers
  static String itemCount(int count, String singular, String plural) {
    return count == 1 ? '1 $singular' : '$count $plural';
  }
  
  static String progress(int current, int total, String context) {
    return '$context: $current of $total';
  }
  
  static String status(String name, String value) {
    return '$name: $value';
  }
}
