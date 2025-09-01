import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/unified_design_system.dart';
import '../services/logging_service.dart';

/// Theme provider that manages unified design system variants and user preferences
class ThemeProvider extends ChangeNotifier {
  static const String _themeVariantKey = 'theme_variant';
  static const String _isDarkModeKey = 'is_dark_mode';
  static const String _systemThemeKey = 'use_system_theme';

  // Current theme state
  String _currentVariant = UnifiedDesignSystem.materialVariant;
  bool _isDarkMode = false;
  bool _useSystemTheme = true;
  SharedPreferences? _prefs;

  // Getters
  String get currentVariant => _currentVariant;
  bool get isDarkMode => _isDarkMode;
  bool get useSystemTheme => _useSystemTheme;
  
  /// Get current theme data based on variant and dark mode
  ThemeData get currentTheme {
    switch (_currentVariant) {
      case UnifiedDesignSystem.glassVariant:
        return UnifiedDesignSystem.glassTheme(isDark: _isDarkMode);
      case UnifiedDesignSystem.modernVariant:
        return UnifiedDesignSystem.modernTheme(isDark: _isDarkMode);
      case UnifiedDesignSystem.materialVariant:
      default:
        return UnifiedDesignSystem.materialTheme(isDark: _isDarkMode);
    }
  }

  /// Get current theme variant display name
  String get currentVariantDisplayName {
    switch (_currentVariant) {
      case UnifiedDesignSystem.glassVariant:
        return 'Glass';
      case UnifiedDesignSystem.modernVariant:
        return 'Modern';
      case UnifiedDesignSystem.materialVariant:
      default:
        return 'Material';
    }
  }

  /// Get all available theme variants
  List<ThemeVariantOption> get availableVariants => [
    ThemeVariantOption(
      id: UnifiedDesignSystem.materialVariant,
      name: 'Material',
      description: 'Clean and familiar Material Design',
      icon: Icons.design_services,
    ),
    ThemeVariantOption(
      id: UnifiedDesignSystem.glassVariant,
      name: 'Glass',
      description: 'Modern glassmorphism with blur effects',
      icon: Icons.blur_on,
    ),
    ThemeVariantOption(
      id: UnifiedDesignSystem.modernVariant,
      name: 'Modern',
      description: 'Vibrant and contemporary design',
      icon: Icons.auto_awesome,
    ),
  ];

  /// Initialize theme provider
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadThemePreferences();
      LoggingService.info('Theme provider initialized', tag: 'ThemeProvider');
    } catch (e) {
      LoggingService.error('Failed to initialize theme provider', error: e, tag: 'ThemeProvider');
    }
  }

  /// Load theme preferences from storage
  Future<void> _loadThemePreferences() async {
    if (_prefs == null) return;

    _currentVariant = _prefs!.getString(_themeVariantKey) ?? UnifiedDesignSystem.materialVariant;
    _isDarkMode = _prefs!.getBool(_isDarkModeKey) ?? false;
    _useSystemTheme = _prefs!.getBool(_systemThemeKey) ?? true;

    LoggingService.info(
      'Loaded theme preferences: variant=$_currentVariant, dark=$_isDarkMode, system=$_useSystemTheme',
      tag: 'ThemeProvider',
    );
  }

  /// Save theme preferences to storage
  Future<void> _saveThemePreferences() async {
    if (_prefs == null) return;

    try {
      await _prefs!.setString(_themeVariantKey, _currentVariant);
      await _prefs!.setBool(_isDarkModeKey, _isDarkMode);
      await _prefs!.setBool(_systemThemeKey, _useSystemTheme);
      
      LoggingService.info(
        'Saved theme preferences: variant=$_currentVariant, dark=$_isDarkMode, system=$_useSystemTheme',
        tag: 'ThemeProvider',
      );
    } catch (e) {
      LoggingService.error('Failed to save theme preferences', error: e, tag: 'ThemeProvider');
    }
  }

  /// Set theme variant
  Future<void> setThemeVariant(String variant) async {
    if (_currentVariant == variant) return;

    _currentVariant = variant;
    await _saveThemePreferences();
    notifyListeners();

    LoggingService.info('Theme variant changed to: $variant', tag: 'ThemeProvider');
  }

  /// Toggle dark mode
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _saveThemePreferences();
    notifyListeners();

    LoggingService.info('Dark mode toggled: $_isDarkMode', tag: 'ThemeProvider');
  }

  /// Set dark mode explicitly
  Future<void> setDarkMode(bool isDark) async {
    if (_isDarkMode == isDark) return;

    _isDarkMode = isDark;
    await _saveThemePreferences();
    notifyListeners();

    LoggingService.info('Dark mode set to: $isDark', tag: 'ThemeProvider');
  }

  /// Toggle system theme following
  Future<void> toggleSystemTheme() async {
    _useSystemTheme = !_useSystemTheme;
    await _saveThemePreferences();
    notifyListeners();

    LoggingService.info('System theme following toggled: $_useSystemTheme', tag: 'ThemeProvider');
  }

  /// Set system theme following explicitly
  Future<void> setSystemTheme(bool useSystem) async {
    if (_useSystemTheme == useSystem) return;

    _useSystemTheme = useSystem;
    await _saveThemePreferences();
    notifyListeners();

    LoggingService.info('System theme following set to: $useSystem', tag: 'ThemeProvider');
  }

  /// Update theme based on system brightness
  void updateSystemTheme(Brightness systemBrightness) {
    if (!_useSystemTheme) return;

    final shouldBeDark = systemBrightness == Brightness.dark;
    if (_isDarkMode != shouldBeDark) {
      _isDarkMode = shouldBeDark;
      notifyListeners();
      
      LoggingService.info(
        'System theme updated: dark=$_isDarkMode',
        tag: 'ThemeProvider',
      );
    }
  }

  /// Reset theme to defaults
  Future<void> resetToDefaults() async {
    _currentVariant = UnifiedDesignSystem.materialVariant;
    _isDarkMode = false;
    _useSystemTheme = true;
    
    await _saveThemePreferences();
    notifyListeners();

    LoggingService.info('Theme reset to defaults', tag: 'ThemeProvider');
  }

  /// Get theme variant option by ID
  ThemeVariantOption? getVariantOption(String variantId) {
    try {
      return availableVariants.firstWhere((option) => option.id == variantId);
    } catch (e) {
      return null;
    }
  }

  /// Check if current theme supports glass effects
  bool get supportsGlassEffects => _currentVariant == UnifiedDesignSystem.glassVariant;

  /// Check if current theme supports gradients
  bool get supportsGradients => _currentVariant != UnifiedDesignSystem.materialVariant;

  /// Get theme-specific animation duration
  Duration get animationDuration {
    switch (_currentVariant) {
      case UnifiedDesignSystem.glassVariant:
        return const Duration(milliseconds: 400);
      case UnifiedDesignSystem.modernVariant:
        return const Duration(milliseconds: 300);
      case UnifiedDesignSystem.materialVariant:
      default:
        return const Duration(milliseconds: 200);
    }
  }

  /// Get theme-specific animation curve
  Curve get animationCurve {
    switch (_currentVariant) {
      case UnifiedDesignSystem.glassVariant:
        return Curves.easeInOutCubic;
      case UnifiedDesignSystem.modernVariant:
        return Curves.easeInOutQuart;
      case UnifiedDesignSystem.materialVariant:
      default:
        return Curves.easeInOut;
    }
  }
}

/// Theme variant option model
class ThemeVariantOption {
  final String id;
  final String name;
  final String description;
  final IconData icon;

  const ThemeVariantOption({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeVariantOption &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
