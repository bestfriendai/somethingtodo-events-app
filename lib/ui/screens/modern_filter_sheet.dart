import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/modern_theme.dart';
import '../../models/event.dart';
import '../components/index.dart';

/// Modern filter sheet with glassmorphic design
class ModernFilterSheet extends StatefulWidget {
  final EventCategory? selectedCategory;
  final RangeValues? priceRange;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? freeOnly;
  final String? sortBy;
  final double? maxDistance;
  final Function(FilterOptions) onApply;

  const ModernFilterSheet({
    super.key,
    this.selectedCategory,
    this.priceRange,
    this.startDate,
    this.endDate,
    this.freeOnly,
    this.sortBy,
    this.maxDistance,
    required this.onApply,
  });

  static Future<void> show({
    required BuildContext context,
    EventCategory? selectedCategory,
    RangeValues? priceRange,
    DateTime? startDate,
    DateTime? endDate,
    bool? freeOnly,
    String? sortBy,
    double? maxDistance,
    required Function(FilterOptions) onApply,
  }) {
    HapticFeedback.lightImpact();

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => ModernFilterSheet(
        selectedCategory: selectedCategory,
        priceRange: priceRange,
        startDate: startDate,
        endDate: endDate,
        freeOnly: freeOnly,
        sortBy: sortBy,
        maxDistance: maxDistance,
        onApply: onApply,
      ),
    );
  }

  @override
  State<ModernFilterSheet> createState() => _ModernFilterSheetState();
}

class _ModernFilterSheetState extends State<ModernFilterSheet>
    with TickerProviderStateMixin {
  late EventCategory? _selectedCategory;
  late RangeValues _priceRange;
  late DateTime? _startDate;
  late DateTime? _endDate;
  late bool _freeOnly;
  late String _sortBy;
  late double _maxDistance;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _priceRange = widget.priceRange ?? const RangeValues(0, 200);
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    _freeOnly = widget.freeOnly ?? false;
    _sortBy = widget.sortBy ?? 'relevance';
    _maxDistance = widget.maxDistance ?? 50.0;

    _animationController = AnimationController(
      duration: ModernTheme.animationMedium,
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    HapticFeedback.mediumImpact();
    widget.onApply(
      FilterOptions(
        category: _selectedCategory,
        priceRange: _priceRange,
        startDate: _startDate,
        endDate: _endDate,
        freeOnly: _freeOnly,
        sortBy: _sortBy,
        maxDistance: _maxDistance,
      ),
    );
    Navigator.of(context).pop();
  }

  void _resetFilters() {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedCategory = null;
      _priceRange = const RangeValues(0, 200);
      _startDate = null;
      _endDate = null;
      _freeOnly = false;
      _sortBy = 'relevance';
      _maxDistance = 50.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
              height: screenHeight * 0.85,
              decoration: BoxDecoration(
                color: isDark ? ModernTheme.darkBackground : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(ModernTheme.radius2xl),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: EdgeInsets.only(top: ModernTheme.spaceSm),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? ModernTheme.darkOnSurfaceVariant
                          : ModernTheme.lightOnSurfaceVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: EdgeInsets.all(ModernTheme.spaceLg),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filters',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextButton(
                          onPressed: _resetFilters,
                          child: Text(
                            'Reset',
                            style: TextStyle(
                              color: ModernTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: ModernTheme.spaceLg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSortSection(),
                          _buildDivider(),
                          _buildCategorySection(),
                          _buildDivider(),
                          _buildPriceSection(),
                          _buildDivider(),
                          _buildDateSection(),
                          _buildDivider(),
                          _buildDistanceSection(),
                          SizedBox(height: ModernTheme.spaceLg),
                        ],
                      ),
                    ),
                  ),
                  // Apply button
                  _buildBottomBar(),
                ],
              ),
            )
            .animate()
            .slideY(begin: 1, duration: ModernTheme.animationMedium)
            .fadeIn(duration: ModernTheme.animationFast);
      },
    );
  }

  Widget _buildSortSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort By',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: ModernTheme.spaceMd),
        Wrap(
          spacing: ModernTheme.spaceSm,
          runSpacing: ModernTheme.spaceSm,
          children: [
            _buildSortChip('relevance', 'Relevance', Icons.auto_awesome),
            _buildSortChip('date', 'Date', Icons.calendar_today),
            _buildSortChip('price_low', 'Price ↑', Icons.arrow_upward),
            _buildSortChip('price_high', 'Price ↓', Icons.arrow_downward),
            _buildSortChip('distance', 'Distance', Icons.location_on),
          ],
        ),
      ],
    );
  }

  Widget _buildSortChip(String value, String label, IconData icon) {
    final isSelected = _sortBy == value;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _sortBy = value);
      },
      child: AnimatedContainer(
        duration: ModernTheme.animationFast,
        padding: EdgeInsets.symmetric(
          horizontal: ModernTheme.spaceMd,
          vertical: ModernTheme.spaceSm,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: ModernTheme.primaryGradient,
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(ModernTheme.radiusFull),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : ModernTheme.darkOnSurfaceVariant,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Colors.white
                  : ModernTheme.darkOnSurfaceVariant,
            ),
            SizedBox(width: ModernTheme.spaceXs),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : ModernTheme.darkOnSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: ModernTheme.spaceMd),
        Wrap(
          spacing: ModernTheme.spaceSm,
          runSpacing: ModernTheme.spaceSm,
          children: EventCategory.values.map((category) {
            final isSelected = _selectedCategory == category;

            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedCategory = isSelected ? null : category;
                });
              },
              child: AnimatedContainer(
                duration: ModernTheme.animationFast,
                padding: EdgeInsets.symmetric(
                  horizontal: ModernTheme.spaceMd,
                  vertical: ModernTheme.spaceSm,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: ModernTheme.getCategoryGradient(
                            category.name,
                          ),
                        )
                      : null,
                  color: isSelected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(ModernTheme.radiusFull),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : ModernTheme.darkOnSurfaceVariant,
                    width: 1,
                  ),
                ),
                child: Text(
                  category.displayName,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : ModernTheme.darkOnSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Price Range',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Switch(
              value: _freeOnly,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                setState(() => _freeOnly = value);
              },
              activeColor: ModernTheme.primaryColor,
            ),
          ],
        ),
        if (_freeOnly)
          Text(
            'Free events only',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: ModernTheme.successColor,
            ),
          )
        else ...[
          SizedBox(height: ModernTheme.spaceSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${_priceRange.start.toStringAsFixed(0)}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '\$${_priceRange.end.toStringAsFixed(0)}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: ModernTheme.primaryColor,
              inactiveTrackColor: ModernTheme.darkSurfaceVariant,
              thumbColor: ModernTheme.primaryColor,
              overlayColor: ModernTheme.primaryColor.withValues(alpha: 0.2),
            ),
            child: RangeSlider(
              values: _priceRange,
              min: 0,
              max: 500,
              divisions: 50,
              onChanged: (values) {
                HapticFeedback.selectionClick();
                setState(() => _priceRange = values);
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDateSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: ModernTheme.spaceMd),
        Row(
          children: [
            Expanded(
              child: _buildDatePicker(
                label: 'From',
                date: _startDate,
                onTap: () => _selectDate(true),
              ),
            ),
            SizedBox(width: ModernTheme.spaceMd),
            Expanded(
              child: _buildDatePicker(
                label: 'To',
                date: _endDate,
                onTap: () => _selectDate(false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    DateTime? date,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(ModernTheme.spaceMd),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ModernTheme.radiusMd),
          border: Border.all(color: ModernTheme.darkOnSurfaceVariant, width: 1),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 18,
              color: ModernTheme.darkOnSurfaceVariant,
            ),
            SizedBox(width: ModernTheme.spaceSm),
            Expanded(
              child: Text(
                date != null ? '${date.month}/${date.day}/${date.year}' : label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: date != null
                      ? theme.colorScheme.onSurface
                      : ModernTheme.darkOnSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      HapticFeedback.selectionClick();
      setState(() {
        if (isStart) {
          _startDate = date;
        } else {
          _endDate = date;
        }
      });
    }
  }

  Widget _buildDistanceSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Maximum Distance',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${_maxDistance.toStringAsFixed(0)} km',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: ModernTheme.primaryColor,
              ),
            ),
          ],
        ),
        SizedBox(height: ModernTheme.spaceMd),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: ModernTheme.primaryColor,
            inactiveTrackColor: ModernTheme.darkSurfaceVariant,
            thumbColor: ModernTheme.primaryColor,
            overlayColor: ModernTheme.primaryColor.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: _maxDistance,
            min: 1,
            max: 100,
            divisions: 99,
            onChanged: (value) {
              HapticFeedback.selectionClick();
              setState(() => _maxDistance = value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ModernTheme.spaceLg),
      child: Container(
        height: 1,
        color: ModernTheme.darkSurfaceVariant.withValues(alpha: 0.2),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(ModernTheme.spaceLg),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: ModernButton(
          text: 'Apply Filters',
          onPressed: _applyFilters,
          variant: ModernButtonVariant.primary,
          size: ModernButtonSize.large,
          isFullWidth: true,
          leadingIcon: Icons.check_rounded,
        ),
      ),
    );
  }
}

/// Filter options model
class FilterOptions {
  final EventCategory? category;
  final RangeValues priceRange;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool freeOnly;
  final String sortBy;
  final double maxDistance;

  FilterOptions({
    this.category,
    required this.priceRange,
    this.startDate,
    this.endDate,
    required this.freeOnly,
    required this.sortBy,
    required this.maxDistance,
  });
}
