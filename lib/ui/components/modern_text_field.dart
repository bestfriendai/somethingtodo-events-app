import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/modern_theme.dart';

/// Modern text field component with glassmorphic styling
class ModernTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool autofocus;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final IconData? prefixIcon;
  final Widget? prefix;
  final IconData? suffixIcon;
  final Widget? suffix;
  final VoidCallback? onSuffixTap;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final bool isGlass;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;

  const ModernTextField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.obscureText = false,
    this.autofocus = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.prefix,
    this.suffixIcon,
    this.suffix,
    this.onSuffixTap,
    this.inputFormatters,
    this.validator,
    this.isGlass = false,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<ModernTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _focusAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);

    _animationController = AnimationController(
      duration: ModernTheme.animationMedium,
      vsync: this,
    );

    _focusAnimation = CurvedAnimation(
      parent: _animationController,
      curve: ModernTheme.curveEaseOut,
    );
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_handleFocusChange);
    }
    _animationController.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    if (_isFocused) {
      _animationController.forward();
      HapticFeedback.selectionClick();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (widget.isGlass) {
      return _buildGlassTextField(theme, isDark);
    }

    return _buildStandardTextField(theme, isDark);
  }

  Widget _buildGlassTextField(ThemeData theme, bool isDark) {
    return AnimatedBuilder(
      animation: _focusAnimation,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.label != null) ...[
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  widget.label!,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: _isFocused
                        ? ModernTheme.primaryColor
                        : (isDark
                              ? ModernTheme.darkOnSurfaceVariant
                              : ModernTheme.lightOnSurfaceVariant),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            ClipRRect(
              borderRadius: BorderRadius.circular(ModernTheme.radiusLg),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: GlassmorphicContainer(
                  width: double.infinity,
                  height: widget.maxLines! > 1
                      ? 120
                      : 56 + (_focusAnimation.value * 2),
                  borderRadius: ModernTheme.radiusLg.toDouble(),
                  blur: 20,
                  alignment: Alignment.center,
                  border: 2,
                  linearGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                  ),
                  borderGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _isFocused
                        ? [
                            ModernTheme.primaryColor.withValues(alpha: 0.5),
                            ModernTheme.primaryLight.withValues(alpha: 0.3),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.2),
                            Colors.white.withValues(alpha: 0.1),
                          ],
                  ),
                  child: _buildTextFieldContent(theme, isDark),
                ),
              ),
            ),
            if (widget.errorText != null) ...[
              Padding(
                padding: const EdgeInsets.only(left: 4, top: 4),
                child:
                    Text(
                          widget.errorText!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: ModernTheme.errorColor,
                          ),
                        )
                        .animate()
                        .fadeIn(duration: ModernTheme.animationFast)
                        .slideY(
                          begin: -0.1,
                          duration: ModernTheme.animationFast,
                        ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildStandardTextField(ThemeData theme, bool isDark) {
    return AnimatedBuilder(
      animation: _focusAnimation,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.label != null) ...[
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  widget.label!,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: _isFocused
                        ? ModernTheme.primaryColor
                        : (isDark
                              ? ModernTheme.darkOnSurfaceVariant
                              : ModernTheme.lightOnSurfaceVariant),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? ModernTheme.darkSurface
                    : ModernTheme.lightSurface,
                borderRadius: BorderRadius.circular(ModernTheme.radiusLg),
                border: Border.all(
                  color: _isFocused
                      ? ModernTheme.primaryColor
                      : (widget.errorText != null
                            ? ModernTheme.errorColor
                            : (isDark
                                  ? ModernTheme.darkSurfaceVariant
                                  : ModernTheme.lightSurfaceVariant)),
                  width: _isFocused ? 2 : 1,
                ),
                boxShadow: _isFocused
                    ? ModernTheme.elevationSm(ModernTheme.primaryColor)
                    : null,
              ),
              child: _buildTextFieldContent(theme, isDark),
            ),
            if (widget.errorText != null) ...[
              Padding(
                padding: const EdgeInsets.only(left: 4, top: 4),
                child:
                    Text(
                          widget.errorText!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: ModernTheme.errorColor,
                          ),
                        )
                        .animate()
                        .fadeIn(duration: ModernTheme.animationFast)
                        .slideY(
                          begin: -0.1,
                          duration: ModernTheme.animationFast,
                        ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildTextFieldContent(ThemeData theme, bool isDark) {
    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      onSubmitted: widget.onSubmitted,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: widget.obscureText,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
      textCapitalization: widget.textCapitalization,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: widget.enabled
            ? (isDark ? ModernTheme.darkOnSurface : ModernTheme.lightOnSurface)
            : (isDark
                  ? ModernTheme.darkOnSurfaceVariant
                  : ModernTheme.lightOnSurfaceVariant),
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: theme.textTheme.bodyLarge?.copyWith(
          color: isDark
              ? ModernTheme.darkOnSurfaceVariant.withValues(alpha: 0.5)
              : ModernTheme.lightOnSurfaceVariant.withValues(alpha: 0.5),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: ModernTheme.spaceMd,
          vertical: widget.maxLines! > 1
              ? ModernTheme.spaceMd
              : ModernTheme.spaceMd - 2,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        prefixIcon: widget.prefixIcon != null
            ? Icon(
                widget.prefixIcon,
                color: _isFocused
                    ? ModernTheme.primaryColor
                    : (isDark
                          ? ModernTheme.darkOnSurfaceVariant
                          : ModernTheme.lightOnSurfaceVariant),
                size: 20,
              )
            : widget.prefix,
        suffixIcon: widget.suffixIcon != null
            ? GestureDetector(
                onTap: widget.onSuffixTap,
                child: Icon(
                  widget.suffixIcon,
                  color: _isFocused
                      ? ModernTheme.primaryColor
                      : (isDark
                            ? ModernTheme.darkOnSurfaceVariant
                            : ModernTheme.lightOnSurfaceVariant),
                  size: 20,
                ),
              )
            : widget.suffix,
        counterText: '', // Hide counter if maxLength is set
      ),
    );
  }
}

/// Modern search field with glassmorphic styling
class ModernSearchField extends StatelessWidget {
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool autofocus;
  final bool isGlass;

  const ModernSearchField({
    super.key,
    this.hint = 'Search...',
    this.controller,
    this.onChanged,
    this.onClear,
    this.autofocus = false,
    this.isGlass = true,
  });

  @override
  Widget build(BuildContext context) {
    return ModernTextField(
      controller: controller,
      onChanged: onChanged,
      hint: hint,
      autofocus: autofocus,
      isGlass: isGlass,
      prefixIcon: Icons.search_rounded,
      suffixIcon: controller?.text.isNotEmpty ?? false
          ? Icons.clear_rounded
          : null,
      onSuffixTap: () {
        controller?.clear();
        onClear?.call();
      },
      textInputAction: TextInputAction.search,
    );
  }
}

/// Modern PIN/OTP field for verification screens
class ModernPinField extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final bool obscureText;

  const ModernPinField({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.obscureText = false,
  });

  @override
  State<ModernPinField> createState() => _ModernPinFieldState();
}

class _ModernPinFieldState extends State<ModernPinField> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleInput(int index, String value) {
    if (value.isNotEmpty) {
      // Move to next field
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Completed
        final pin = _controllers.map((c) => c.text).join();
        widget.onCompleted?.call(pin);
        _focusNodes[index].unfocus();
      }
    }

    // Call onChanged
    final pin = _controllers.map((c) => c.text).join();
    widget.onChanged?.call(pin);
  }

  void _handleBackspace(int index, String value) {
    if (value.isEmpty && index > 0) {
      // Move to previous field
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.length,
        (index) => Container(
          width: 50,
          height: 60,
          margin: EdgeInsets.symmetric(horizontal: ModernTheme.spaceXs),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(ModernTheme.radiusMd),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: GlassmorphicContainer(
                width: 50,
                height: 60,
                borderRadius: ModernTheme.radiusMd,
                blur: 20,
                alignment: Alignment.center,
                border: 2,
                linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.white.withValues(alpha: 0.05),
                  ],
                ),
                borderGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _focusNodes[index].hasFocus
                      ? [
                          ModernTheme.primaryColor.withValues(alpha: 0.5),
                          ModernTheme.primaryLight.withValues(alpha: 0.3),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.2),
                          Colors.white.withValues(alpha: 0.1),
                        ],
                ),
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  keyboardType: TextInputType.number,
                  obscureText: widget.obscureText,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: isDark
                        ? ModernTheme.darkOnSurface
                        : ModernTheme.lightOnSurface,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    counterText: '',
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      _handleInput(index, value);
                    } else {
                      _handleBackspace(index, value);
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ).animate(interval: 50.ms).fadeIn().slideX(begin: -0.1),
    );
  }
}
