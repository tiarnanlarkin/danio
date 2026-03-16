import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

/// Input states for text fields
enum AppTextFieldState {
  /// Default state
  normal,

  /// Field has focus
  focused,

  /// Field has error
  error,

  /// Field is valid/success
  success,

  /// Field is disabled
  disabled,

  /// Field is loading/validating
  loading,
}

/// A unified text field component with consistent styling and validation states.
///
/// Supports error/success states, loading indicators, and helper text.
///
/// Example:
/// ```dart
/// AppTextField(
///   label: 'Email',
///   hint: 'Enter your email',
///   errorText: emailError,
///   onChanged: (value) => validateEmail(value),
/// )
/// ```
class AppTextField extends StatefulWidget {
  /// Label text above the field
  final String? label;

  /// Hint text inside the field
  final String? hint;

  /// Helper text below the field
  final String? helperText;

  /// Error text (displays in error state)
  final String? errorText;

  /// Initial value
  final String? initialValue;

  /// Text controller (alternative to initialValue)
  final TextEditingController? controller;

  /// Focus node
  final FocusNode? focusNode;

  /// Keyboard type
  final TextInputType? keyboardType;

  /// Input formatters
  final List<TextInputFormatter>? inputFormatters;

  /// Text input action
  final TextInputAction? textInputAction;

  /// Max length
  final int? maxLength;

  /// Max lines (null for auto-expand)
  final int? maxLines;

  /// Min lines
  final int minLines;

  /// Whether field is obscured (password)
  final bool obscureText;

  /// Whether field is enabled
  final bool enabled;

  /// Whether field is read-only
  final bool readOnly;

  /// Auto-correct
  final bool autocorrect;

  /// Show loading indicator
  final bool isLoading;

  /// Show success state
  final bool isSuccess;

  /// Leading icon
  final IconData? prefixIcon;

  /// Trailing icon
  final IconData? suffixIcon;

  /// Custom suffix widget
  final Widget? suffix;

  /// Called when value changes
  final ValueChanged<String>? onChanged;

  /// Called when field is submitted
  final ValueChanged<String>? onSubmitted;

  /// Called when field gains/loses focus
  final ValueChanged<bool>? onFocusChange;

  /// Called when field is tapped
  final VoidCallback? onTap;

  /// Semantic label for accessibility
  final String? semanticsLabel;

  /// Auto-fill hints
  final Iterable<String>? autofillHints;

  /// Text capitalization
  final TextCapitalization textCapitalization;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.initialValue,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.inputFormatters,
    this.textInputAction,
    this.maxLength,
    this.maxLines = 1,
    this.minLines = 1,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autocorrect = true,
    this.isLoading = false,
    this.isSuccess = false,
    this.prefixIcon,
    this.suffixIcon,
    this.suffix,
    this.onChanged,
    this.onSubmitted,
    this.onFocusChange,
    this.onTap,
    this.semanticsLabel,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late FocusNode _focusNode;
  late TextEditingController _controller;
  bool _hasFocus = false;
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
    _obscureText = widget.obscureText;
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (widget.focusNode == null) _focusNode.dispose();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() => _hasFocus = _focusNode.hasFocus);
    widget.onFocusChange?.call(_focusNode.hasFocus);
  }

  AppTextFieldState get _state {
    if (!widget.enabled) return AppTextFieldState.disabled;
    if (widget.isLoading) return AppTextFieldState.loading;
    if (widget.errorText != null) return AppTextFieldState.error;
    if (widget.isSuccess) return AppTextFieldState.success;
    if (_hasFocus) return AppTextFieldState.focused;
    return AppTextFieldState.normal;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      label: widget.semanticsLabel ?? widget.label,
      textField: true,
      enabled: widget.enabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.label != null) ...[
            Text(
              widget.label!,
              style: AppTypography.labelMedium.copyWith(
                color: _getLabelColor(isDark),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          AnimatedContainer(
            duration: AppDurations.short,
            decoration: BoxDecoration(
              color: _getBackgroundColor(isDark),
              borderRadius: AppRadius.smallRadius,
              border: Border.all(
                color: _getBorderColor(isDark),
                width: _hasFocus || _state == AppTextFieldState.error ? 2 : 1,
              ),
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: widget.enabled,
              readOnly: widget.readOnly,
              obscureText: _obscureText,
              autocorrect: widget.autocorrect,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              inputFormatters: widget.inputFormatters,
              maxLength: widget.maxLength,
              maxLines: widget.obscureText ? 1 : widget.maxLines,
              minLines: widget.minLines,
              autofillHints: widget.autofillHints,
              textCapitalization: widget.textCapitalization,
              style: AppTypography.bodyLarge.copyWith(
                color: widget.enabled
                    ? (context.textPrimary)
                    : (context.textHint),
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: AppTypography.bodyLarge.copyWith(
                  color: context.textHint,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                prefixIcon: widget.prefixIcon != null
                    ? Icon(
                        widget.prefixIcon,
                        color: _getIconColor(isDark),
                        size: AppIconSizes.md,
                      )
                    : null,
                suffixIcon: _buildSuffix(isDark),
                counterText: '',
              ),
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              onTap: widget.onTap,
            ),
          ),
          if (widget.errorText != null || widget.helperText != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              widget.errorText ?? widget.helperText ?? '',
              style: AppTypography.bodySmall.copyWith(
                color: widget.errorText != null
                    ? AppColors.error
                    : (context.textHint),
              ),
            ),
          ],
          if (widget.maxLength != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${_controller.text.length}/${widget.maxLength}',
                style: AppTypography.labelSmall.copyWith(
                  color: context.textHint,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget? _buildSuffix(bool isDark) {
    if (widget.isLoading) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: SizedBox(
          width: AppIconSizes.sm,
          height: AppIconSizes.sm,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(context.textHint),
          ),
        ),
      );
    }

    if (widget.isSuccess) {
      return Icon(
        Icons.check_circle,
        color: AppColors.success,
        size: AppIconSizes.md,
      );
    }

    if (widget.errorText != null) {
      return Icon(Icons.error, color: AppColors.error, size: AppIconSizes.md);
    }

    if (widget.obscureText) {
      return Semantics(
        label: _obscureText ? 'Show password' : 'Hide password',
        button: true,
        child: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: _getIconColor(isDark),
            size: AppIconSizes.md,
          ),
          onPressed: () => setState(() => _obscureText = !_obscureText),
          tooltip: _obscureText ? 'Show password' : 'Hide password',
        ),
      );
    }

    if (widget.suffix != null) {
      return widget.suffix;
    }

    if (widget.suffixIcon != null) {
      return Icon(
        widget.suffixIcon,
        color: _getIconColor(isDark),
        size: AppIconSizes.md,
      );
    }

    return null;
  }

  Color _getLabelColor(bool isDark) {
    switch (_state) {
      case AppTextFieldState.error:
        return AppColors.error;
      case AppTextFieldState.focused:
        return AppColors.primary;
      case AppTextFieldState.disabled:
        return context.textHint;
      default:
        return context.textSecondary;
    }
  }

  Color _getBackgroundColor(bool isDark) {
    if (_state == AppTextFieldState.disabled) {
      return isDark ? AppOverlays.white5 : AppOverlays.black5;
    }
    return context.surfaceColor;
  }

  Color _getBorderColor(bool isDark) {
    switch (_state) {
      case AppTextFieldState.error:
        return AppColors.error;
      case AppTextFieldState.success:
        return AppColors.success;
      case AppTextFieldState.focused:
        return AppColors.primary;
      case AppTextFieldState.disabled:
        return isDark ? AppOverlays.white10 : AppOverlays.black10;
      default:
        return context.borderColor;
    }
  }

  Color _getIconColor(bool isDark) {
    if (_state == AppTextFieldState.disabled) {
      return context.textHint;
    }
    if (_state == AppTextFieldState.focused) {
      return AppColors.primary;
    }
    return context.textSecondary;
  }
}

/// A search-specific text field with clear button and search icon.
class AppSearchField extends StatefulWidget {
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;

  const AppSearchField({
    super.key,
    this.hint,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
  });

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_updateHasText);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateHasText);
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _updateHasText() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: _controller,
      hint: widget.hint ?? 'Search...',
      prefixIcon: Icons.search,
      textInputAction: TextInputAction.search,
      autofillHints: null,
      semanticsLabel: 'Search field',
      suffix: _hasText
          ? Semantics(
              label: 'Clear search',
              button: true,
              child: IconButton(
                icon: Icon(Icons.clear, size: AppIconSizes.sm),
                onPressed: _clear,
                tooltip: 'Clear search',
              ),
            )
          : null,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
    );
  }
}
