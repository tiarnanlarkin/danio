import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../core/app_text_field.dart';

export '../core/app_text_field.dart' show AppTextField, AppSearchField;

/// Standardised text input component using design tokens.
///
/// Opinionated wrapper around [AppTextField] with the app's canonical
/// defaults for forms, search bars and settings inputs:
/// - Rounded container (AppRadius.sm = 8 dp)
/// - Filled surface background
/// - Focus highlight in [AppColors.primary]
/// - Error/success states with icon feedback
/// - Semantic label for screen reader support
///
/// Tokens used:
/// - [AppColors]: surface, border, primary, textHint, error, success
/// - [AppTypography.body] for input text
/// - [AppSpacing.s16] for horizontal content padding
/// - [AppRadius.smallRadius] for container shape
///
/// For password fields, set [obscureText] = true — a show/hide toggle
/// is automatically appended.
///
/// Example:
/// ```dart
/// StandardInput(
///   label: 'Tank name',
///   hint: 'e.g. Living Room 60L',
///   controller: _controller,
///   errorText: _validationError,
///   onChanged: (v) => _validateTankName(v),
/// )
/// ```
class StandardInput extends StatelessWidget {
  /// Label displayed above the field (also used as semantic label).
  final String? label;

  /// Placeholder text shown when the field is empty.
  final String? hint;

  /// Helper text below the field (shown when no error).
  final String? helperText;

  /// Error message. Activates the error visual state when non-null.
  final String? errorText;

  /// Text editing controller.
  final TextEditingController? controller;

  /// Initial value (alternative to [controller]).
  final String? initialValue;

  /// Focus node for programmatic focus management.
  final FocusNode? focusNode;

  /// Keyboard type (e.g. email, number, URL).
  final TextInputType? keyboardType;

  /// Input formatters (e.g. decimal-only, length limit).
  final List<TextInputFormatter>? inputFormatters;

  /// Action button on the soft keyboard.
  final TextInputAction? textInputAction;

  /// Maximum character count.
  final int? maxLength;

  /// Maximum visual lines. Defaults to 1.
  final int? maxLines;

  /// Whether the text is hidden (password mode).
  final bool obscureText;

  /// Whether the field is interactive. Defaults to true.
  final bool enabled;

  /// Whether the field is read-only (tappable but not editable).
  final bool readOnly;

  /// Leading icon.
  final IconData? prefixIcon;

  /// Trailing icon.
  final IconData? suffixIcon;

  /// Custom trailing widget (overrides [suffixIcon]).
  final Widget? suffix;

  /// Whether to show a success indicator.
  final bool isSuccess;

  /// Whether to show a loading spinner in the suffix.
  final bool isLoading;

  /// Called on every keystroke.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the field.
  final ValueChanged<String>? onSubmitted;

  /// Called when focus changes.
  final ValueChanged<bool>? onFocusChange;

  /// Called when the field is tapped.
  final VoidCallback? onTap;

  const StandardInput({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.keyboardType,
    this.inputFormatters,
    this.textInputAction,
    this.maxLength,
    this.maxLines = 1,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.suffix,
    this.isSuccess = false,
    this.isLoading = false,
    this.onChanged,
    this.onSubmitted,
    this.onFocusChange,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      hint: hint,
      helperText: helperText,
      errorText: errorText,
      controller: controller,
      initialValue: initialValue,
      focusNode: focusNode,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textInputAction: textInputAction,
      maxLength: maxLength,
      maxLines: maxLines,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      suffix: suffix,
      isSuccess: isSuccess,
      isLoading: isLoading,
      semanticsLabel: label,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onFocusChange: onFocusChange,
      onTap: onTap,
    );
  }
}
