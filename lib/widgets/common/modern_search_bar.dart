import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ModernSearchBar extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? hintText;
  final bool autofocus;

  const ModernSearchBar({
    super.key,
    this.onChanged,
    this.onSubmitted,
    this.hintText,
    this.autofocus = false,
  });

  @override
  State<ModernSearchBar> createState() => _ModernSearchBarState();
}

class _ModernSearchBarState extends State<ModernSearchBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();

    _controller.addListener(() {
      setState(() => _hasText = _controller.text.isNotEmpty);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _clear() {
    HapticFeedback.lightImpact();
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: _focusNode.hasFocus
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withValues(alpha: 0.2),
          width: _focusNode.hasFocus ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16, right: 8),
            child: Icon(
              Icons.search,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText:
                    widget.hintText ?? 'Search events, venues, artists...',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.6,
                  ),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          if (_hasText)
            IconButton(
              icon: Icon(
                Icons.clear,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              onPressed: _clear,
            ),
          if (!_hasText)
            IconButton(
              icon: Icon(Icons.tune, color: theme.colorScheme.onSurfaceVariant),
              onPressed: () {
                HapticFeedback.lightImpact();
                // Open filter sheet
              },
            ),
        ],
      ),
    );
  }
}
