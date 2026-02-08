/// Accessibility utilities for WCAG AA compliance
/// Provides semantic label helpers and focus management utilities
library;

import 'package:flutter/material.dart';

/// Semantic label builder for common UI patterns
class A11yLabels {
  // Button labels
  static String button(String action, [String? target]) {
    if (target != null) {
      return '$action $target button';
    }
    return '$action button';
  }

  // Icon button labels
  static String iconButton(String action, [String? context]) {
    if (context != null) {
      return '$action $context';
    }
    return action;
  }

  // Navigation labels
  static String navItem(String destination) => 'Navigate to $destination';
  static String backButton([String? destination]) =>
      destination != null ? 'Go back to $destination' : 'Go back';
  static String closeButton([String? context]) =>
      context != null ? 'Close $context' : 'Close';

  // Form labels
  static String textField(String label, {bool required = false}) {
    return required ? '$label, required' : label;
  }

  static String dropdown(String label, String? currentValue) {
    if (currentValue != null) {
      return '$label, currently $currentValue';
    }
    return '$label selector';
  }

  static String checkbox(String label, bool checked) {
    return '$label, ${checked ? 'checked' : 'unchecked'}';
  }

  static String switchWidget(String label, bool enabled) {
    return '$label, ${enabled ? 'enabled' : 'disabled'}';
  }

  static String slider(String label, double value, double min, double max) {
    return '$label, value $value out of $min to $max';
  }

  // List items
  static String listItem(String title, int index, int total) {
    return '$title, item $index of $total';
  }

  static String selectableItem(String title, bool selected) {
    return '$title, ${selected ? 'selected' : 'not selected'}';
  }

  // Cards and containers
  static String card(String title, [String? description]) {
    if (description != null) {
      return '$title card, $description';
    }
    return '$title card';
  }

  // Images and icons
  static String decorativeImage() => '';
  static String contentImage(String description) => description;
  static String icon(String meaning) => meaning;

  // Progress indicators
  static String progress(int current, int total, [String? context]) {
    final percentage = ((current / total) * 100).round();
    if (context != null) {
      return '$context progress: $current of $total, $percentage percent complete';
    }
    return 'Progress: $current of $total, $percentage percent complete';
  }

  // Quiz/exercise specific
  static String quizQuestion(int number, int total) =>
      'Question $number of $total';
  
  static String answer(String text, bool isCorrect, bool answered) {
    if (!answered) return text;
    return isCorrect ? '$text, correct answer' : '$text, incorrect answer';
  }

  static String submitAnswer() => 'Submit answer';
  static String nextQuestion() => 'Next question';
  static String completeQuiz() => 'Complete quiz';

  // Tank/aquarium specific
  static String tank(String name) => '$name tank';
  static String addLivestock(String? tankName) =>
      tankName != null ? 'Add livestock to $tankName' : 'Add livestock';
  static String parameterReading(String parameter, double value, String unit) =>
      '$parameter: $value $unit';
}

/// Focus management helpers
class A11yFocus {
  /// Creates a FocusTraversalGroup for logical keyboard navigation
  static FocusTraversalGroup createGroup({
    required Widget child,
    FocusTraversalPolicy? policy,
  }) {
    return FocusTraversalGroup(
      policy: policy ?? OrderedTraversalPolicy(),
      child: child,
    );
  }

  /// Creates a FocusTraversalOrder widget
  static FocusTraversalOrder createOrder({
    required double order,
    required Widget child,
  }) {
    return FocusTraversalOrder(
      order: NumericFocusOrder(order),
      child: child,
    );
  }
}

/// Semantic wrapper for common patterns
class A11ySemantics extends StatelessWidget {
  final Widget child;
  final String? label;
  final String? hint;
  final String? value;
  final bool button;
  final bool header;
  final bool link;
  final bool image;
  final bool textField;
  final bool selected;
  final bool enabled;
  final bool obscured;
  final bool readOnly;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const A11ySemantics({
    super.key,
    required this.child,
    this.label,
    this.hint,
    this.value,
    this.button = false,
    this.header = false,
    this.link = false,
    this.image = false,
    this.textField = false,
    this.selected = false,
    this.enabled = true,
    this.obscured = false,
    this.readOnly = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: button,
      header: header,
      link: link,
      image: image,
      textField: textField,
      selected: selected,
      enabled: enabled,
      obscured: obscured,
      readOnly: readOnly,
      onTap: onTap,
      onLongPress: onLongPress,
      excludeSemantics: label != null || hint != null, // Exclude child semantics if we provide our own
      child: child,
    );
  }
}

/// Merge semantics wrapper for combining labels
class A11yMerge extends StatelessWidget {
  final Widget child;

  const A11yMerge({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(child: child);
  }
}

/// Exclude from semantics tree (for decorative elements)
class A11yExclude extends StatelessWidget {
  final Widget child;
  final bool excluding;

  const A11yExclude({
    super.key,
    required this.child,
    this.excluding = true,
  });

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      excluding: excluding,
      child: child,
    );
  }
}
