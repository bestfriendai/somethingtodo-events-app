import 'package:flutter/material.dart';
import '../../config/consolidated_design_system.dart';
import '../../config/responsive_breakpoints.dart';
import '../../utils/ui_validation.dart';

/// Enhanced theme preview widget that demonstrates all design system components
/// with responsive layout and accessibility features
class EnhancedThemePreview extends StatelessWidget {
  final String variantName;
  final bool isDark;

  const EnhancedThemePreview({
    super.key,
    required this.variantName,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Validate theme on build (development only)
    assert(() {
      UIValidation.quickValidation(context);
      return true;
    }());

    return SingleChildScrollView(
      padding: context.responsivePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          SizedBox(height: ConsolidatedDesignSystem.responsiveSpacing(context, ConsolidatedDesignSystem.spacing5)),
          
          if (context.isDesktop) 
            _buildDesktopLayout(context)
          else if (context.isTablet)
            _buildTabletLayout(context)
          else
            _buildMobileLayout(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ConsolidatedDesignSystem.modernCard(
      context: context,
      semanticLabel: 'Theme preview for $variantName',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                color: Theme.of(context).colorScheme.primary,
                size: ConsolidatedDesignSystem.responsiveSpacing(context, 24),
              ),
              SizedBox(width: ConsolidatedDesignSystem.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$variantName Theme',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: ConsolidatedDesignSystem.responsiveTextSize(context, 24),
                      ),
                    ),
                    Text(
                      '${isDark ? 'Dark' : 'Light'} Mode Preview',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: ConsolidatedDesignSystem.spacing4),
          _buildContrastInfo(context),
        ],
      ),
    );
  }

  Widget _buildContrastInfo(BuildContext context) {
    final theme = Theme.of(context);
    final primaryRatio = theme.primaryContrastRatio;
    final isAccessible = primaryRatio >= 4.5;

    return Container(
      padding: EdgeInsets.all(ConsolidatedDesignSystem.spacing3),
      decoration: BoxDecoration(
        color: isAccessible ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ConsolidatedDesignSystem.radiusSm),
        border: Border.all(
          color: isAccessible ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isAccessible ? Icons.accessibility : Icons.warning,
            color: isAccessible ? Colors.green : Colors.red,
            size: 16,
          ),
          SizedBox(width: ConsolidatedDesignSystem.spacing2),
          Text(
            'Contrast Ratio: ${primaryRatio.toStringAsFixed(1)}:1 ${isAccessible ? '(WCAG AA)' : '(Below WCAG AA)'}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isAccessible ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _buildButtonSection(context),
        SizedBox(height: ConsolidatedDesignSystem.spacing5),
        _buildInputSection(context),
        SizedBox(height: ConsolidatedDesignSystem.spacing5),
        _buildCardSection(context),
        SizedBox(height: ConsolidatedDesignSystem.spacing5),
        _buildColorPalette(context),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildButtonSection(context)),
            SizedBox(width: ConsolidatedDesignSystem.spacing5),
            Expanded(child: _buildInputSection(context)),
          ],
        ),
        SizedBox(height: ConsolidatedDesignSystem.spacing6),
        _buildCardSection(context),
        SizedBox(height: ConsolidatedDesignSystem.spacing6),
        _buildColorPalette(context),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildButtonSection(context),
              SizedBox(height: ConsolidatedDesignSystem.spacing5),
              _buildInputSection(context),
            ],
          ),
        ),
        SizedBox(width: ConsolidatedDesignSystem.spacing6),
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildCardSection(context),
              SizedBox(height: ConsolidatedDesignSystem.spacing6),
              _buildColorPalette(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildButtonSection(BuildContext context) {
    return ConsolidatedDesignSystem.modernCard(
      context: context,
      semanticLabel: 'Button components preview',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Buttons',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: ConsolidatedDesignSystem.spacing4),
          Wrap(
            spacing: ConsolidatedDesignSystem.spacing3,
            runSpacing: ConsolidatedDesignSystem.spacing3,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: const Text('Elevated'),
              ),
              FilledButton(
                onPressed: () {},
                child: const Text('Filled'),
              ),
              OutlinedButton(
                onPressed: () {},
                child: const Text('Outlined'),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Text'),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.star, size: 16),
                label: const Text('Icon'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection(BuildContext context) {
    return ConsolidatedDesignSystem.modernCard(
      context: context,
      semanticLabel: 'Input components preview',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Inputs',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: ConsolidatedDesignSystem.spacing4),
          TextField(
            decoration: InputDecoration(
              labelText: 'Text Field',
              hintText: 'Enter text here',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {},
              ),
            ),
          ),
          SizedBox(height: ConsolidatedDesignSystem.spacing4),
          Row(
            children: [
              Expanded(
                child: SwitchListTile(
                  title: const Text('Switch'),
                  subtitle: const Text('Toggle option'),
                  value: true,
                  onChanged: (_) {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardSection(BuildContext context) {
    return ConsolidatedDesignSystem.modernCard(
      context: context,
      semanticLabel: 'Card components preview',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cards & Chips',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: ConsolidatedDesignSystem.spacing4),
          Card(
            child: Padding(
              padding: EdgeInsets.all(ConsolidatedDesignSystem.spacing4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sample Card',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: ConsolidatedDesignSystem.spacing2),
                  Text(
                    'This is a preview of how cards look in the current theme.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: ConsolidatedDesignSystem.spacing4),
          Wrap(
            spacing: ConsolidatedDesignSystem.spacing2,
            children: [
              Chip(
                label: const Text('Chip'),
                avatar: const Icon(Icons.star, size: 16),
              ),
              ActionChip(
                label: const Text('Action'),
                onPressed: () {},
              ),
              FilterChip(
                label: const Text('Filter'),
                selected: true,
                onSelected: (_) {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorPalette(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return ConsolidatedDesignSystem.modernCard(
      context: context,
      semanticLabel: 'Color palette preview',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Color Palette',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: ConsolidatedDesignSystem.spacing4),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: context.isMobile ? 3 : 6,
            mainAxisSpacing: ConsolidatedDesignSystem.spacing2,
            crossAxisSpacing: ConsolidatedDesignSystem.spacing2,
            childAspectRatio: context.isMobile ? 1.5 : 2.0,
            children: [
              _buildColorSwatch(context, 'Primary', colorScheme.primary, colorScheme.onPrimary),
              _buildColorSwatch(context, 'Secondary', colorScheme.secondary, colorScheme.onSecondary),
              _buildColorSwatch(context, 'Tertiary', colorScheme.tertiary, colorScheme.onTertiary),
              _buildColorSwatch(context, 'Surface', colorScheme.surface, colorScheme.onSurface),
              _buildColorSwatch(context, 'Error', colorScheme.error, colorScheme.onError),
              _buildColorSwatch(context, 'Outline', colorScheme.outline, colorScheme.surface),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorSwatch(BuildContext context, String name, Color color, Color onColor) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(ConsolidatedDesignSystem.radiusSm),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Center(
        child: Text(
          name,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: onColor,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}