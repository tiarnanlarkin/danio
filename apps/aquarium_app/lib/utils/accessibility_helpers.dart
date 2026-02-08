import 'package:flutter/material.dart';

/// Accessibility utility widgets and helpers for WCAG AA compliance

/// Wraps an interactive widget with proper semantics
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String label;
  final String? hint;
  final bool enabled;

  const AccessibleButton({
    super.key,
    required this.child,
    required this.onTap,
    required this.label,
    this.hint,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      button: true,
      enabled: enabled,
      child: child,
    );
  }
}

/// Wraps an image with proper semantic label
class AccessibleImage extends StatelessWidget {
  final Widget child;
  final String label;
  final bool isDecorative;

  const AccessibleImage({
    super.key,
    required this.child,
    required this.label,
    this.isDecorative = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isDecorative) {
      return ExcludeSemantics(child: child);
    }
    return Semantics(
      label: label,
      image: true,
      child: child,
    );
  }
}

/// Wraps a card/container with proper semantics
class AccessibleCard extends StatelessWidget {
  final Widget child;
  final String label;
  final String? value;
  final String? hint;
  final VoidCallback? onTap;

  const AccessibleCard({
    super.key,
    required this.child,
    required this.label,
    this.value,
    this.hint,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      value: value,
      hint: hint,
      button: onTap != null,
      child: child,
    );
  }
}

/// Provides semantic navigation context
class AccessibleNavigation extends StatelessWidget {
  final Widget child;
  final String currentRoute;
  final int? currentIndex;
  final int? totalItems;

  const AccessibleNavigation({
    super.key,
    required this.child,
    required this.currentRoute,
    this.currentIndex,
    this.totalItems,
  });

  @override
  Widget build(BuildContext context) {
    String label = 'Navigation to $currentRoute';
    if (currentIndex != null && totalItems != null) {
      label += ', item ${currentIndex! + 1} of $totalItems';
    }
    
    return Semantics(
      label: label,
      header: true,
      child: child,
    );
  }
}

/// Helper extension for quick semantic wrapping
extension AccessibleWidget on Widget {
  Widget withSemantics({
    required String label,
    String? value,
    String? hint,
    bool? button,
    bool? header,
    bool? image,
  }) {
    return Semantics(
      label: label,
      value: value,
      hint: hint,
      button: button,
      header: header,
      image: image,
      child: this,
    );
  }

  Widget excludeSemantics() {
    return ExcludeSemantics(child: this);
  }
}
