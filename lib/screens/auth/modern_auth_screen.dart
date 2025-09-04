import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../config/modern_theme.dart';
import '../../ui/components/index.dart';
import '../../services/logger_service.dart';
import '../../utils/navigation_helper.dart';

class ModernAuthScreen extends StatefulWidget {
  const ModernAuthScreen({super.key});

  @override
  State<ModernAuthScreen> createState() => _ModernAuthScreenState();
}

class _ModernAuthScreenState extends State<ModernAuthScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _formController;

  bool _isSignIn = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _nameError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _formController = AnimationController(
      duration: ModernTheme.animationMedium,
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _formController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      _isSignIn = !_isSignIn;
      _clearErrors();
    });
    _formController.reset();
    _formController.forward();
    HapticFeedback.lightImpact();
  }

  void _clearErrors() {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _nameError = null;
      _confirmPasswordError = null;
    });
  }

  bool _validateForm() {
    _clearErrors();
    bool isValid = true;

    // Email validation
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _emailError = 'Email is required');
      isValid = false;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() => _emailError = 'Enter a valid email address');
      isValid = false;
    }

    // Password validation
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      isValid = false;
    } else if (password.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
      isValid = false;
    }

    // Sign-up specific validations
    if (!_isSignIn) {
      // Name validation
      final name = _nameController.text.trim();
      if (name.isEmpty) {
        setState(() => _nameError = 'Name is required');
        isValid = false;
      } else if (name.length < 2) {
        setState(() => _nameError = 'Name must be at least 2 characters');
        isValid = false;
      }

      // Confirm password validation
      final confirmPassword = _confirmPasswordController.text;
      if (confirmPassword.isEmpty) {
        setState(() => _confirmPasswordError = 'Please confirm your password');
        isValid = false;
      } else if (confirmPassword != password) {
        setState(() => _confirmPasswordError = 'Passwords do not match');
        isValid = false;
      }

      // Terms acceptance
      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please accept the terms and conditions'),
            backgroundColor: ModernTheme.warningColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ModernTheme.radiusMd),
            ),
          ),
        );
        isValid = false;
      }
    }

    return isValid;
  }

  Future<void> _submitForm() async {
    if (!_validateForm()) {
      HapticFeedback.mediumImpact();
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    try {
      final authProvider = context.read<AuthProvider>();
      bool success = false;

      if (_isSignIn) {
        Logger.info('Attempting sign in');
        success = await authProvider.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        Logger.info('Attempting sign up');
        success = await authProvider.signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _nameController.text.trim(),
        );
      }

      if (mounted) {
        if (success && authProvider.isAuthenticated) {
          HapticFeedback.mediumImpact();
          Logger.info('Authentication successful, navigating to home');
          NavigationHelper.navigateToHome(context);
        } else {
          HapticFeedback.heavyImpact();
          _showErrorSnackBar(
            '${_isSignIn ? 'Sign in' : 'Sign up'} failed. Please try again.',
          );
        }
      }
    } catch (e) {
      Logger.error('Authentication error', e);
      if (mounted) {
        HapticFeedback.heavyImpact();
        _showErrorSnackBar(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.signInWithGoogle();

      if (mounted && authProvider.isAuthenticated) {
        HapticFeedback.mediumImpact();
        NavigationHelper.navigateToHome(context);
      }
    } catch (e) {
      if (mounted) {
        HapticFeedback.heavyImpact();
        _showErrorSnackBar('Google sign-in is not available');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInAsGuest() async {
    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.signInAsGuest();

      if (mounted && success) {
        HapticFeedback.mediumImpact();
        NavigationHelper.navigateToHome(context);
      }
    } catch (e) {
      if (mounted) {
        HapticFeedback.heavyImpact();
        _showErrorSnackBar('Failed to continue as guest');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ModernTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ModernTheme.radiusMd),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ModernTheme.darkBackground,
      body: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(),

          // Floating orbs
          ..._buildFloatingOrbs(),

          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(ModernTheme.spaceLg),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: _buildAuthForm(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(_backgroundController.value * 2 - 1, -1),
              end: Alignment(-_backgroundController.value * 2 + 1, 1),
              colors: [
                ModernTheme.darkBackground,
                ModernTheme.darkSurface,
                const Color(0xFF1A1A2E),
                ModernTheme.darkBackground,
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildFloatingOrbs() {
    return [
      Positioned(
        top: 100,
        left: -50,
        child: _buildOrb(150, ModernTheme.primaryColor.withValues(alpha: 0.1)),
      ),
      Positioned(
        bottom: 150,
        right: -30,
        child: _buildOrb(
          120,
          ModernTheme.secondaryColor.withValues(alpha: 0.1),
        ),
      ),
      Positioned(
        top: MediaQuery.of(context).size.height * 0.4,
        left: MediaQuery.of(context).size.width * 0.7,
        child: _buildOrb(80, ModernTheme.tertiaryColor.withValues(alpha: 0.1)),
      ),
    ];
  }

  Widget _buildOrb(double size, Color color) {
    return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color,
                color.withValues(alpha: 0.05),
                Colors.transparent,
              ],
            ),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .rotate(duration: const Duration(seconds: 30))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.2, 1.2),
          duration: const Duration(seconds: 3),
          curve: Curves.easeInOut,
        );
  }

  Widget _buildAuthForm() {
    return AnimatedBuilder(
      animation: _formController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.9 + (_formController.value * 0.1),
          child: Opacity(
            opacity: _formController.value,
            child: ModernCard(
              isGlass: true,
              padding: EdgeInsets.all(ModernTheme.spaceXl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  SizedBox(height: ModernTheme.spaceXl),
                  _buildFormFields(),
                  if (!_isSignIn) ...[
                    SizedBox(height: ModernTheme.spaceMd),
                    _buildTermsCheckbox(),
                  ],
                  SizedBox(height: ModernTheme.spaceXl),
                  _buildSubmitButton(),
                  SizedBox(height: ModernTheme.spaceLg),
                  _buildDivider(),
                  SizedBox(height: ModernTheme.spaceLg),
                  _buildSocialButtons(),
                  SizedBox(height: ModernTheme.spaceLg),
                  _buildToggleMode(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(
          Icons.celebration_rounded,
          size: 48,
          color: ModernTheme.primaryColor,
        ).animate().scale(duration: ModernTheme.animationSlow).fadeIn(),
        SizedBox(height: ModernTheme.spaceMd),
        Text(
          _isSignIn ? 'Welcome Back!' : 'Create Account',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: ModernTheme.spaceSm),
        Text(
          _isSignIn
              ? 'Sign in to discover amazing events'
              : 'Join us to explore exciting events',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: ModernTheme.darkOnSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        if (!_isSignIn) ...[
          ModernTextField(
            controller: _nameController,
            label: 'Full Name',
            hint: 'Enter your full name',
            prefixIcon: Icons.person_outline_rounded,
            errorText: _nameError,
            isGlass: true,
            textCapitalization: TextCapitalization.words,
          ),
          SizedBox(height: ModernTheme.spaceMd),
        ],
        ModernTextField(
          controller: _emailController,
          label: 'Email',
          hint: 'Enter your email address',
          prefixIcon: Icons.email_outlined,
          errorText: _emailError,
          isGlass: true,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: ModernTheme.spaceMd),
        ModernTextField(
          controller: _passwordController,
          label: 'Password',
          hint: 'Enter your password',
          prefixIcon: Icons.lock_outline_rounded,
          suffixIcon: _obscurePassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          onSuffixTap: () {
            setState(() => _obscurePassword = !_obscurePassword);
            HapticFeedback.selectionClick();
          },
          errorText: _passwordError,
          obscureText: _obscurePassword,
          isGlass: true,
        ),
        if (!_isSignIn) ...[
          SizedBox(height: ModernTheme.spaceMd),
          ModernTextField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            hint: 'Re-enter your password',
            prefixIcon: Icons.lock_outline_rounded,
            suffixIcon: _obscureConfirmPassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            onSuffixTap: () {
              setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword,
              );
              HapticFeedback.selectionClick();
            },
            errorText: _confirmPasswordError,
            obscureText: _obscureConfirmPassword,
            isGlass: true,
          ),
        ],
      ],
    ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1);
  }

  Widget _buildTermsCheckbox() {
    return GestureDetector(
      onTap: () {
        setState(() => _acceptTerms = !_acceptTerms);
        HapticFeedback.selectionClick();
      },
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ModernTheme.radiusXs),
              border: Border.all(
                color: _acceptTerms
                    ? ModernTheme.primaryColor
                    : ModernTheme.darkOnSurfaceVariant,
                width: 2,
              ),
              color: _acceptTerms
                  ? ModernTheme.primaryColor
                  : Colors.transparent,
            ),
            child: _acceptTerms
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
          SizedBox(width: ModernTheme.spaceSm),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: 'I accept the ',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ModernTheme.darkOnSurfaceVariant,
                ),
                children: [
                  TextSpan(
                    text: 'Terms & Conditions',
                    style: TextStyle(
                      color: ModernTheme.primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: ModernTheme.primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ModernButton(
      text: _isSignIn ? 'Sign In' : 'Create Account',
      onPressed: _isLoading ? null : _submitForm,
      isLoading: _isLoading,
      variant: ModernButtonVariant.primary,
      size: ModernButtonSize.large,
      isFullWidth: true,
      leadingIcon: _isSignIn ? Icons.login_rounded : Icons.person_add_rounded,
    ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.1);
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: ModernTheme.darkOnSurfaceVariant.withValues(alpha: 0.2),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ModernTheme.spaceMd),
          child: Text(
            'OR',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: ModernTheme.darkOnSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: ModernTheme.darkOnSurfaceVariant.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        ModernButton(
          text: 'Continue with Google',
          onPressed: _isLoading ? null : _signInWithGoogle,
          variant: ModernButtonVariant.outlined,
          size: ModernButtonSize.large,
          isFullWidth: true,
          leadingIcon: Icons.g_mobiledata_rounded,
        ),
        SizedBox(height: ModernTheme.spaceMd),
        ModernButton(
          text: 'Continue as Guest',
          onPressed: _isLoading ? null : _signInAsGuest,
          variant: ModernButtonVariant.text,
          size: ModernButtonSize.large,
          isFullWidth: true,
          leadingIcon: Icons.person_outline_rounded,
        ),
      ],
    ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.1);
  }

  Widget _buildToggleMode() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isSignIn ? "Don't have an account? " : 'Already have an account? ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: ModernTheme.darkOnSurfaceVariant,
          ),
        ),
        GestureDetector(
          onTap: _toggleAuthMode,
          child: Text(
            _isSignIn ? 'Sign Up' : 'Sign In',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: ModernTheme.primaryColor,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
