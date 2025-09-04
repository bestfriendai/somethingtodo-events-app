import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'dart:ui';
import '../../config/modern_theme.dart';

/// Modern button component with multiple variants
/// Supports primary, secondary, outlined, text, and glass styles
class ModernButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ModernButtonVariant variant;
  final ModernButtonSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool isFullWidth;
  final Color? customColor;
  final double? borderRadius;

  const ModernButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ModernButtonVariant.primary,
    this.size = ModernButtonSize.medium,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.customColor,
    this.borderRadius,
  });

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: ModernTheme.animationFast,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      _controller.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: ModernTheme.animationFast,
        curve: ModernTheme.curveEaseOut,
        child: SizedBox(
          width: widget.isFullWidth ? double.infinity : null,
          child: _buildButtonContent(theme, isDark),
        ),
      ),
    );
  }

  Widget _buildButtonContent(ThemeData theme, bool isDark) {
    switch (widget.variant) {
      case ModernButtonVariant.glass:
        return _buildGlassButton(theme, isDark);
      case ModernButtonVariant.primary:
        return _buildPrimaryButton(theme, isDark);
      case ModernButtonVariant.secondary:
        return _buildSecondaryButton(theme, isDark);
      case ModernButtonVariant.outlined:
        return _buildOutlinedButton(theme, isDark);
      case ModernButtonVariant.text:
        return _buildTextButton(theme, isDark);
    }
  }

  Widget _buildGlassButton(ThemeData theme, bool isDark) {
    final size = _getButtonSize();

    return ClipRRect(
      borderRadius: BorderRadius.circular(
        widget.borderRadius ?? ModernTheme.radiusLg,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: GlassmorphicContainer(
          width: widget.isFullWidth ? double.infinity : 200,
          height: size.height,
          borderRadius: (widget.borderRadius ?? ModernTheme.radiusLg)
              .toDouble(),
          blur: 20,
          alignment: Alignment.center,
          border: 2,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (widget.customColor ?? ModernTheme.primaryColor).withValues(
                alpha: 0.2,
              ),
              (widget.customColor ?? ModernTheme.primaryColor).withValues(
                alpha: 0.1,
              ),
            ],
          ),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (widget.customColor ?? ModernTheme.primaryColor).withValues(
                alpha: 0.5,
              ),
              (widget.customColor ?? ModernTheme.primaryColor).withValues(
                alpha: 0.2,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.isLoading ? null : widget.onPressed,
              borderRadius: BorderRadius.circular(
                widget.borderRadius ?? ModernTheme.radiusLg,
              ),
              child: Container(
                padding: size.padding,
                child: _buildButtonLabel(theme, Colors.white, size.fontSize),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(ThemeData theme, bool isDark) {
    final size = _getButtonSize();
    final color = widget.customColor ?? ModernTheme.primaryColor;

    return Container(
      height: size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(
          widget.borderRadius ?? ModernTheme.radiusLg,
        ),
        boxShadow: widget.onPressed == null || widget.isLoading
            ? null
            : ModernTheme.elevationMd(color),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(
          widget.borderRadius ?? ModernTheme.radiusLg,
        ),
        child: InkWell(
          onTap: widget.isLoading ? null : widget.onPressed,
          borderRadius: BorderRadius.circular(
            widget.borderRadius ?? ModernTheme.radiusLg,
          ),
          child: Container(
            padding: size.padding,
            child: _buildButtonLabel(theme, Colors.white, size.fontSize),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(ThemeData theme, bool isDark) {
    final size = _getButtonSize();
    final color = widget.customColor ?? ModernTheme.secondaryColor;

    return Container(
      height: size.height,
      decoration: BoxDecoration(
        color: isDark ? ModernTheme.darkSurface : ModernTheme.lightSurface,
        borderRadius: BorderRadius.circular(
          widget.borderRadius ?? ModernTheme.radiusLg,
        ),
        border: Border.all(
          color: isDark
              ? ModernTheme.darkSurfaceVariant
              : ModernTheme.lightSurfaceVariant,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(
          widget.borderRadius ?? ModernTheme.radiusLg,
        ),
        child: InkWell(
          onTap: widget.isLoading ? null : widget.onPressed,
          borderRadius: BorderRadius.circular(
            widget.borderRadius ?? ModernTheme.radiusLg,
          ),
          child: Container(
            padding: size.padding,
            child: _buildButtonLabel(theme, color, size.fontSize),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedButton(ThemeData theme, bool isDark) {
    final size = _getButtonSize();
    final color = widget.customColor ?? ModernTheme.primaryColor;

    return Container(
      height: size.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          widget.borderRadius ?? ModernTheme.radiusLg,
        ),
        border: Border.all(
          color: widget.onPressed == null || widget.isLoading
              ? (isDark
                    ? ModernTheme.darkOnSurfaceVariant
                    : ModernTheme.lightOnSurfaceVariant)
              : color,
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(
          widget.borderRadius ?? ModernTheme.radiusLg,
        ),
        child: InkWell(
          onTap: widget.isLoading ? null : widget.onPressed,
          borderRadius: BorderRadius.circular(
            widget.borderRadius ?? ModernTheme.radiusLg,
          ),
          child: Container(
            padding: size.padding,
            child: _buildButtonLabel(theme, color, size.fontSize),
          ),
        ),
      ),
    );
  }

  Widget _buildTextButton(ThemeData theme, bool isDark) {
    final size = _getButtonSize();
    final color = widget.customColor ?? ModernTheme.primaryColor;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(
        widget.borderRadius ?? ModernTheme.radiusLg,
      ),
      child: InkWell(
        onTap: widget.isLoading ? null : widget.onPressed,
        borderRadius: BorderRadius.circular(
          widget.borderRadius ?? ModernTheme.radiusLg,
        ),
        child: Container(
          padding: size.padding,
          child: _buildButtonLabel(theme, color, size.fontSize),
        ),
      ),
    );
  }

  Widget _buildButtonLabel(ThemeData theme, Color color, double fontSize) {
    if (widget.isLoading) {
      return SizedBox(
        height: fontSize,
        width: fontSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    final textStyle = theme.textTheme.labelLarge?.copyWith(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: widget.onPressed == null ? color.withValues(alpha: 0.5) : color,
    );

    final children = <Widget>[];

    if (widget.leadingIcon != null) {
      children.add(
        Icon(
          widget.leadingIcon,
          size: fontSize + 2,
          color: widget.onPressed == null
              ? color.withValues(alpha: 0.5)
              : color,
        ),
      );
      children.add(SizedBox(width: ModernTheme.spaceSm));
    }

    children.add(Text(widget.text, style: textStyle));

    if (widget.trailingIcon != null) {
      children.add(SizedBox(width: ModernTheme.spaceSm));
      children.add(
        Icon(
          widget.trailingIcon,
          size: fontSize + 2,
          color: widget.onPressed == null
              ? color.withValues(alpha: 0.5)
              : color,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  _ButtonSize _getButtonSize() {
    switch (widget.size) {
      case ModernButtonSize.small:
        return _ButtonSize(
          height: 36,
          padding: EdgeInsets.symmetric(
            horizontal: ModernTheme.spaceMd,
            vertical: ModernTheme.spaceSm,
          ),
          fontSize: 14,
        );
      case ModernButtonSize.medium:
        return _ButtonSize(
          height: 44,
          padding: EdgeInsets.symmetric(
            horizontal: ModernTheme.spaceLg,
            vertical: ModernTheme.spaceMd - 2,
          ),
          fontSize: 16,
        );
      case ModernButtonSize.large:
        return _ButtonSize(
          height: 52,
          padding: EdgeInsets.symmetric(
            horizontal: ModernTheme.spaceXl,
            vertical: ModernTheme.spaceMd,
          ),
          fontSize: 18,
        );
    }
  }
}

enum ModernButtonVariant { primary, secondary, outlined, text, glass }

enum ModernButtonSize { small, medium, large }

class _ButtonSize {
  final double height;
  final EdgeInsets padding;
  final double fontSize;

  _ButtonSize({
    required this.height,
    required this.padding,
    required this.fontSize,
  });
}
