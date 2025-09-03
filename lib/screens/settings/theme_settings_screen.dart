import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../config/consolidated_design_system.dart';
import '../../widgets/theme/enhanced_theme_preview.dart';
import '../../config/responsive_breakpoints.dart';

/// Theme settings screen for switching between design variants
class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Theme Settings'), elevation: 0),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(ConsolidatedDesignSystem.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  context,
                  'Design Style',
                  'Choose your preferred visual design',
                ),
                const SizedBox(height: ConsolidatedDesignSystem.spacingMd),
                _buildThemeVariantSelector(context, themeProvider),
                const SizedBox(height: ConsolidatedDesignSystem.spacingXl),

                _buildSectionHeader(
                  context,
                  'Appearance',
                  'Customize brightness and system integration',
                ),
                const SizedBox(height: ConsolidatedDesignSystem.spacingMd),
                _buildAppearanceSettings(context, themeProvider),
                const SizedBox(height: ConsolidatedDesignSystem.spacingXl),

                _buildSectionHeader(
                  context,
                  'Preview',
                  'See how your theme looks',
                ),
                const SizedBox(height: ConsolidatedDesignSystem.spacingMd),
                _buildThemePreview(context, themeProvider),
                const SizedBox(height: ConsolidatedDesignSystem.spacingXl),

                _buildResetButton(context, themeProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: ConsolidatedDesignSystem.spacingXs),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeVariantSelector(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    return Column(
      children: themeProvider.availableVariants.map((variant) {
        final isSelected = themeProvider.currentVariant == variant.id;

        return Container(
          margin: const EdgeInsets.only(bottom: ConsolidatedDesignSystem.spacingSm),
          child: Card(
            elevation: isSelected ? 4 : 1,
            child: InkWell(
              onTap: () => themeProvider.setThemeVariant(variant.id),
              borderRadius: BorderRadius.circular(ConsolidatedDesignSystem.radiusLg),
              child: Padding(
                padding: const EdgeInsets.all(ConsolidatedDesignSystem.spacingMd),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(
                          ConsolidatedDesignSystem.radiusMd,
                        ),
                      ),
                      child: Icon(
                        variant.icon,
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: ConsolidatedDesignSystem.spacingMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            variant.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                          ),
                          const SizedBox(height: ConsolidatedDesignSystem.spacingXs),
                          Text(
                            variant.description,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAppearanceSettings(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ConsolidatedDesignSystem.spacingMd),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Follow System Theme'),
              subtitle: const Text(
                'Automatically switch between light and dark mode',
              ),
              value: themeProvider.useSystemTheme,
              onChanged: (value) => themeProvider.setSystemTheme(value),
              secondary: const Icon(Icons.brightness_auto),
            ),
            if (!themeProvider.useSystemTheme) ...[
              const Divider(),
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Use dark theme colors'),
                value: themeProvider.isDarkMode,
                onChanged: (value) => themeProvider.setDarkMode(value),
                secondary: Icon(
                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildThemePreview(BuildContext context, ThemeProvider themeProvider) {
    return EnhancedThemePreview(
      variantName: themeProvider.currentVariantDisplayName,
      isDark: themeProvider.isDarkMode,
    );
  }

  Widget _buildResetButton(BuildContext context, ThemeProvider themeProvider) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Reset Theme'),
              content: const Text(
                'This will reset all theme settings to their default values. Continue?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Reset'),
                ),
              ],
            ),
          );

          if (confirmed == true) {
            await themeProvider.resetToDefaults();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Theme settings reset to defaults'),
                ),
              );
            }
          }
        },
        icon: const Icon(Icons.restore),
        label: const Text('Reset to Defaults'),
      ),
    );
  }
}
