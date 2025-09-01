import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../config/unified_design_system.dart';

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
            padding: const EdgeInsets.all(UnifiedDesignSystem.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  context,
                  'Design Style',
                  'Choose your preferred visual design',
                ),
                const SizedBox(height: UnifiedDesignSystem.spacingMd),
                _buildThemeVariantSelector(context, themeProvider),
                const SizedBox(height: UnifiedDesignSystem.spacingXl),

                _buildSectionHeader(
                  context,
                  'Appearance',
                  'Customize brightness and system integration',
                ),
                const SizedBox(height: UnifiedDesignSystem.spacingMd),
                _buildAppearanceSettings(context, themeProvider),
                const SizedBox(height: UnifiedDesignSystem.spacingXl),

                _buildSectionHeader(
                  context,
                  'Preview',
                  'See how your theme looks',
                ),
                const SizedBox(height: UnifiedDesignSystem.spacingMd),
                _buildThemePreview(context, themeProvider),
                const SizedBox(height: UnifiedDesignSystem.spacingXl),

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
        const SizedBox(height: UnifiedDesignSystem.spacingXs),
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
          margin: const EdgeInsets.only(bottom: UnifiedDesignSystem.spacingSm),
          child: Card(
            elevation: isSelected ? 4 : 1,
            child: InkWell(
              onTap: () => themeProvider.setThemeVariant(variant.id),
              borderRadius: BorderRadius.circular(UnifiedDesignSystem.radiusLg),
              child: Padding(
                padding: const EdgeInsets.all(UnifiedDesignSystem.spacingMd),
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
                          UnifiedDesignSystem.radiusMd,
                        ),
                      ),
                      child: Icon(
                        variant.icon,
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: UnifiedDesignSystem.spacingMd),
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
                          const SizedBox(height: UnifiedDesignSystem.spacingXs),
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
        padding: const EdgeInsets.all(UnifiedDesignSystem.spacingMd),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UnifiedDesignSystem.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preview Components',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: UnifiedDesignSystem.spacingMd),

            // Button previews
            Wrap(
              spacing: UnifiedDesignSystem.spacingSm,
              runSpacing: UnifiedDesignSystem.spacingSm,
              children: [
                ElevatedButton(onPressed: () {}, child: const Text('Elevated')),
                FilledButton(onPressed: () {}, child: const Text('Filled')),
                OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
                TextButton(onPressed: () {}, child: const Text('Text')),
              ],
            ),
            const SizedBox(height: UnifiedDesignSystem.spacingMd),

            // Chip previews
            Wrap(
              spacing: UnifiedDesignSystem.spacingSm,
              children: [
                Chip(
                  label: const Text('Chip'),
                  avatar: const Icon(Icons.star, size: 16),
                ),
                const Chip(
                  label: Text('Selected'),
                  backgroundColor: Colors.blue,
                ),
                ActionChip(label: const Text('Action'), onPressed: () {}),
              ],
            ),
            const SizedBox(height: UnifiedDesignSystem.spacingMd),

            // Text field preview
            TextField(
              decoration: const InputDecoration(
                labelText: 'Sample Input',
                hintText: 'Enter some text...',
                prefixIcon: Icon(Icons.search),
              ),
              enabled: false,
            ),
          ],
        ),
      ),
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
