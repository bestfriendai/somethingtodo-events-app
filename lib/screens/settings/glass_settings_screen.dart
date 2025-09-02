import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';

import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../models/event.dart';

class GlassSettingsScreen extends StatefulWidget {
  const GlassSettingsScreen({super.key});

  @override
  State<GlassSettingsScreen> createState() => _GlassSettingsScreenState();
}

class _GlassSettingsScreenState extends State<GlassSettingsScreen>
    with TickerProviderStateMixin {
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  bool _marketingEmails = false;
  String _selectedTheme = 'system';
  double _maxDistance = 25.0;
  String _pricePreference = 'any';

  late AnimationController _orbController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _orbController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _orbController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _loadSettings() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    final preferences = user?.preferences;
    
    if (preferences != null) {
      setState(() {
        _notificationsEnabled = preferences.notificationsEnabled;
        _locationEnabled = preferences.locationEnabled;
        _marketingEmails = preferences.marketingEmails;
        _selectedTheme = preferences.theme;
        _maxDistance = preferences.maxDistance;
        _pricePreference = preferences.pricePreference;
      });
    }
  }

  Future<void> _saveSettings() async {
    HapticFeedback.lightImpact();
    final authProvider = context.read<AuthProvider>();
    // In a real app, you would save these settings to the backend
    // await authProvider.updatePreferences(...)
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Settings saved successfully'),
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _buildGlassAppBar(),
      body: Stack(
        children: [
          // Animated floating orbs background
          _buildFloatingOrbs(),
          
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: FadeTransition(
                opacity: _fadeController,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    _buildGlassSection(
                      'Notifications',
                      Icons.notifications_outlined,
                      [
                        _buildGlassSwitchTile(
                          'Push Notifications',
                          'Receive notifications about events',
                          _notificationsEnabled,
                          (value) => setState(() => _notificationsEnabled = value),
                        ),
                        _buildGlassSwitchTile(
                          'Marketing Emails',
                          'Receive promotional emails about events',
                          _marketingEmails,
                          (value) => setState(() => _marketingEmails = value),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    _buildGlassSection(
                      'Location & Privacy',
                      Icons.location_on_outlined,
                      [
                        _buildGlassSwitchTile(
                          'Location Services',
                          'Find events near your location',
                          _locationEnabled,
                          (value) => setState(() => _locationEnabled = value),
                        ),
                        _buildGlassSliderTile(
                          'Search Radius',
                          'Maximum distance to search for events',
                          _maxDistance,
                          1.0,
                          100.0,
                          '${_maxDistance.round()} km',
                          (value) => setState(() => _maxDistance = value),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    _buildGlassSection(
                      'Appearance',
                      Icons.palette_outlined,
                      [
                        _buildGlassDropdownTile(
                          'Theme',
                          'Choose your preferred theme',
                          _selectedTheme,
                          [
                            const DropdownMenuItem(value: 'light', child: Text('Light')),
                            const DropdownMenuItem(value: 'dark', child: Text('Dark')),
                            const DropdownMenuItem(value: 'system', child: Text('System')),
                          ],
                          (value) => setState(() => _selectedTheme = value!),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    _buildGlassSection(
                      'Event Preferences',
                      Icons.tune_outlined,
                      [
                        _buildGlassDropdownTile(
                          'Price Preference',
                          'Default price filter for events',
                          _pricePreference,
                          [
                            const DropdownMenuItem(value: 'any', child: Text('Any Price')),
                            const DropdownMenuItem(value: 'free', child: Text('Free Only')),
                            const DropdownMenuItem(value: 'paid', child: Text('Paid Only')),
                          ],
                          (value) => setState(() => _pricePreference = value!),
                        ),
                        _buildGlassListTile(
                          'Preferred Categories',
                          'Choose your favorite event categories',
                          Icons.category_outlined,
                          () => _showCategoriesDialog(),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    _buildGlassSection(
                      'Account',
                      Icons.account_circle_outlined,
                      [
                        _buildGlassListTile(
                          'Change Password',
                          'Update your account password',
                          Icons.lock_outline,
                          () => _showChangePasswordDialog(),
                        ),
                        _buildGlassListTile(
                          'Delete Account',
                          'Permanently delete your account',
                          Icons.delete_forever_outlined,
                          () => _showDeleteAccountDialog(),
                          textColor: Colors.red.shade300,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    _buildGlassSection(
                      'About',
                      Icons.info_outline,
                      [
                        _buildGlassListTile(
                          'Terms of Service',
                          'Read our terms and conditions',
                          Icons.description_outlined,
                          () => _showTermsDialog(),
                        ),
                        _buildGlassListTile(
                          'Privacy Policy',
                          'How we handle your data',
                          Icons.privacy_tip_outlined,
                          () => _showPrivacyDialog(),
                        ),
                        _buildGlassListTile(
                          'Contact Support',
                          'Get help or report issues',
                          Icons.support_outlined,
                          () => _contactSupport(),
                        ),
                        _buildGlassListTile(
                          'App Version',
                          'v1.0.0 (Build 1)',
                          Icons.info_outline,
                          null,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildGlassAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text(
        'Settings',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      leading: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
        child: Container(
          margin: const EdgeInsets.all(8),
          child: GlassmorphicContainer(
            width: 40,
            height: 40,
            borderRadius: 20,
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
              colors: [
                Colors.white.withValues(alpha: 0.2),
                Colors.white.withValues(alpha: 0.1),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: _saveSettings,
            child: GlassmorphicContainer(
              width: 80,
              height: 40,
              borderRadius: 20,
              blur: 20,
              alignment: Alignment.center,
              border: 2,
              linearGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor.withValues(alpha: 0.3),
                  AppTheme.primaryColor.withValues(alpha: 0.1),
                ],
              ),
              borderGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor.withValues(alpha: 0.6),
                  AppTheme.primaryColor.withValues(alpha: 0.2),
                ],
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingOrbs() {
    return AnimatedBuilder(
      animation: _orbController,
      builder: (context, child) {
        return Stack(
          children: [
            // Large primary orb
            Positioned(
              left: -50 + (100 * math.sin(_orbController.value * 2 * math.pi * 0.3)),
              top: 100 + (50 * math.cos(_orbController.value * 2 * math.pi * 0.2)),
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryColor.withValues(alpha: 0.3),
                      AppTheme.primaryColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            
            // Secondary orb
            Positioned(
              right: -30 + (80 * math.cos(_orbController.value * 2 * math.pi * 0.4)),
              top: 200 + (60 * math.sin(_orbController.value * 2 * math.pi * 0.3)),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.secondaryColor.withValues(alpha: 0.2),
                      AppTheme.secondaryColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            
            // Small accent orb
            Positioned(
              left: MediaQuery.of(context).size.width / 2 + (40 * math.sin(_orbController.value * 2 * math.pi * 0.6)),
              bottom: 150 + (30 * math.cos(_orbController.value * 2 * math.pi * 0.5)),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.purple.withValues(alpha: 0.2),
                      Colors.purple.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGlassSection(String title, IconData icon, List<Widget> children) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 60,
      borderRadius: 20,
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
        colors: [
          Colors.white.withValues(alpha: 0.2),
          Colors.white.withValues(alpha: 0.1),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryColor.withValues(alpha: 0.3),
                        AppTheme.primaryColor.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ...children.map((child) => 
            child == children.last ? child : Column(
              children: [
                child, 
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 100.ms).slideY(begin: 0.3);
  }

  Widget _buildGlassSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildGlassSwitch(value, onChanged),
        ],
      ),
    );
  }

  Widget _buildGlassSwitch(bool value, ValueChanged<bool> onChanged) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: value
                ? [
                    AppTheme.primaryColor.withValues(alpha: 0.8),
                    AppTheme.primaryColor.withValues(alpha: 0.6),
                  ]
                : [
                    Colors.white.withValues(alpha: 0.2),
                    Colors.white.withValues(alpha: 0.1),
                  ],
          ),
          border: Border.all(
            color: value
                ? AppTheme.primaryColor.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.3),
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(2),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassSliderTile(
    String title,
    String subtitle,
    double value,
    double min,
    double max,
    String valueLabel,
    ValueChanged<double> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.primaryColor,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
              thumbColor: Colors.white,
              overlayColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: (max - min).toInt(),
              onChanged: (newValue) {
                HapticFeedback.selectionClick();
                onChanged(newValue);
              },
            ),
          ),
          Text(
            valueLabel,
            style: TextStyle(
              color: AppTheme.primaryColor.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassDropdownTile<T>(
    String title,
    String subtitle,
    T value,
    List<DropdownMenuItem<T>> items,
    ValueChanged<T?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                items: items.map((item) => DropdownMenuItem<T>(
                  value: item.value,
                  child: DefaultTextStyle(
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    child: item.child!,
                  ),
                )).toList(),
                onChanged: (newValue) {
                  HapticFeedback.selectionClick();
                  onChanged(newValue);
                },
                dropdownColor: Colors.grey.shade900,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                isExpanded: true,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassListTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback? onTap, {
    Color? textColor,
  }) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          HapticFeedback.lightImpact();
          onTap();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [
                    (textColor ?? Colors.white).withValues(alpha: 0.2),
                    (textColor ?? Colors.white).withValues(alpha: 0.1),
                  ],
                ),
              ),
              child: Icon(
                icon, 
                color: textColor ?? Colors.white.withValues(alpha: 0.9),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor ?? Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: (textColor ?? Colors.white).withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withValues(alpha: 0.5),
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  void _showCategoriesDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildGlassDialog(
        'Preferred Categories',
        SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: EventCategory.values.length,
            itemBuilder: (context, index) {
              final category = EventCategory.values[index];
              return CheckboxListTile(
                title: Text(
                  category.displayName,
                  style: const TextStyle(color: Colors.white),
                ),
                value: false, // This would come from user preferences
                onChanged: (value) {
                  HapticFeedback.selectionClick();
                  // Update category preferences
                },
                activeColor: AppTheme.primaryColor,
                checkColor: Colors.white,
              );
            },
          ),
        ),
        [
          _buildGlassDialogButton('Cancel', () => Navigator.pop(context)),
          _buildGlassDialogButton('Save', () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Categories updated'),
                backgroundColor: Colors.green.withValues(alpha: 0.8),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }, isPrimary: true),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => _buildGlassDialog(
        'Change Password',
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildGlassTextField(
              oldPasswordController,
              'Current Password',
              Icons.lock_outline,
              obscureText: true,
            ),
            const SizedBox(height: 16),
            _buildGlassTextField(
              newPasswordController,
              'New Password',
              Icons.lock,
              obscureText: true,
            ),
            const SizedBox(height: 16),
            _buildGlassTextField(
              confirmPasswordController,
              'Confirm New Password',
              Icons.lock,
              obscureText: true,
            ),
          ],
        ),
        [
          _buildGlassDialogButton('Cancel', () => Navigator.pop(context)),
          _buildGlassDialogButton('Update', () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Password updated successfully'),
                backgroundColor: Colors.green.withValues(alpha: 0.8),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }, isPrimary: true),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildGlassDialog(
        'Delete Account',
        const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete your account?',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              'This action cannot be undone. All your data will be permanently deleted.',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
        [
          _buildGlassDialogButton('Cancel', () => Navigator.pop(context)),
          _buildGlassDialogButton('Delete', () {
            Navigator.pop(context);
            _showDeleteConfirmationDialog();
          }, isPrimary: true, isDestructive: true),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    final passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => _buildGlassDialog(
        'Confirm Deletion',
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Please enter your password to confirm account deletion:',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            _buildGlassTextField(
              passwordController,
              'Password',
              Icons.lock,
              obscureText: true,
            ),
          ],
        ),
        [
          _buildGlassDialogButton('Cancel', () => Navigator.pop(context)),
          _buildGlassDialogButton('Confirm Delete', () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Account deletion initiated'),
                backgroundColor: Colors.red.withValues(alpha: 0.8),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }, isPrimary: true, isDestructive: true),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildGlassDialog(
        'Terms of Service',
        const SingleChildScrollView(
          child: Text(
            'Terms of Service content would go here. This would include the full legal terms and conditions for using the SomethingToDo app.',
            style: TextStyle(color: Colors.white),
          ),
        ),
        [
          _buildGlassDialogButton('Close', () => Navigator.pop(context)),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildGlassDialog(
        'Privacy Policy',
        const SingleChildScrollView(
          child: Text(
            'Privacy Policy content would go here. This would explain how user data is collected, used, and protected.',
            style: TextStyle(color: Colors.white),
          ),
        ),
        [
          _buildGlassDialogButton('Close', () => Navigator.pop(context)),
        ],
      ),
    );
  }

  void _contactSupport() {
    showDialog(
      context: context,
      builder: (context) => _buildGlassDialog(
        'Contact Support',
        const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Need help? Contact our support team:',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.email, color: Colors.white70),
                SizedBox(width: 8),
                Text(
                  'support@somethingtodo.app',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, color: Colors.white70),
                SizedBox(width: 8),
                Text(
                  '+1 (555) 123-4567',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ],
        ),
        [
          _buildGlassDialogButton('Close', () => Navigator.pop(context)),
          _buildGlassDialogButton('Send Email', () {
            Navigator.pop(context);
            // Open email client
          }, isPrimary: true),
        ],
      ),
    );
  }

  Widget _buildGlassDialog(String title, Widget content, List<Widget> actions) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 300,
        borderRadius: 20,
        blur: 20,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black.withValues(alpha: 0.8),
            Colors.black.withValues(alpha: 0.6),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.2),
            Colors.white.withValues(alpha: 0.1),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              content,
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassDialogButton(
    String text, 
    VoidCallback onPressed, {
    bool isPrimary = false,
    bool isDestructive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: isPrimary
                ? LinearGradient(
                    colors: isDestructive
                        ? [
                            Colors.red.withValues(alpha: 0.8),
                            Colors.red.withValues(alpha: 0.6),
                          ]
                        : [
                            AppTheme.primaryColor.withValues(alpha: 0.8),
                            AppTheme.primaryColor.withValues(alpha: 0.6),
                          ],
                  )
                : LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                  ),
            border: Border.all(
              color: isPrimary
                  ? (isDestructive ? Colors.red : AppTheme.primaryColor).withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
          prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.7)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}