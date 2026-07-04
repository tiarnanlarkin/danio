  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Semantics(
      button: true,
      enabled: _isEnabled,

      child: InkWell(
        onTap: _isEnabled ? _handleTap : null,
        onLongPress: _isEnabled ? _handleTapCancel : null,
        onTapDown: _isEnabled ? _handleTapDown : null,
        onTapUp: _isEnabled ? _handleTapUp : null,
        onHighlightChanged: _isEnabled ? _handleHighlightChange : null,
        splashColor: isDark ? AppColors.primaryAlpha10 : AppColors.whiteAlpha10,
        borderRadius: _getBorderRadius(theme),
        highlightColor: Colors.transparent,

        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            final scale = child == AnimationStatus.completed ? 1.0 : _scaleAnimation.value;
            
            return Transform.scale(
              scale: scale,
              child: Container(
                decoration: BoxDecoration(
                  color: widget.isLoading 
                          ? widget.variant == AppButtonVariant.destructive
                              ? Colors.transparent
                              : AppColors.whiteAlpha08
                          : Colors.transparent,
                  borderRadius: _getBorderRadius(theme),
                  boxShadow: _getBoxShadow(theme),
                ),
                padding: _getPadding(theme),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.leadingIcon != null) ...[
                      _buildIcon(theme, widget.leadingIcon!),
                      SizedBox(width: AppSpacing.sm),
                    ],
                    
                    if (widget.label.isNotEmpty) ...[
                      Flexible(
                        child: _buildLabel(theme, isDark),
                      ),
                      
                      if (widget.trailingIcon != null) ...[
                        SizedBox(width: AppSpacing.sm),
                        _buildIcon(theme, widget.trailingIcon!),
                      ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
