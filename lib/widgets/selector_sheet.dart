import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moneymorpheus/l10n/app_localizations.dart';

import '../core/selector_item.dart';

/// Reusable bottom sheet with search + carousel for selecting an item.
/// Unified style for dark/light mode, centered text, clear selection highlight.
class SelectorSheet extends StatefulWidget {
  final List<SelectorItem>? items;
  final Future<List<SelectorItem>>? itemsFuture;
  final String currentId;
  final void Function(String) onSelected;
  final bool isDarkMode;
  final String searchHint;

  const SelectorSheet({
    super.key,
    this.items,
    this.itemsFuture,
    required this.currentId,
    required this.onSelected,
    required this.isDarkMode,
    required this.searchHint,
  }) : assert(items != null || itemsFuture != null);

  static Future<void> show(
    BuildContext context, {
    List<SelectorItem>? items,
    Future<List<SelectorItem>>? itemsFuture,
    required String currentId,
    required void Function(String) onSelected,
    required bool isDarkMode,
    required String searchHint,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SelectorSheet(
        items: items,
        itemsFuture: itemsFuture,
        currentId: currentId,
        onSelected: onSelected,
        isDarkMode: isDarkMode,
        searchHint: searchHint,
      ),
    );
  }

  @override
  State<SelectorSheet> createState() => _SelectorSheetState();
}

class _SelectorSheetState extends State<SelectorSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SelectorItem> _filteredItems(List<SelectorItem> items) {
    if (_searchQuery.isEmpty) return items;
    return items.where((e) {
      return e.searchableText.contains(_searchQuery);
    }).toList();
  }

  Color _textColor() => widget.isDarkMode
      ? Colors.white.withValues(alpha: 0.95)
      : Colors.black.withValues(alpha: 0.9);

  Color _hintColor() => widget.isDarkMode
      ? Colors.white.withValues(alpha: 0.5)
      : Colors.black.withValues(alpha: 0.4);

  Color _selectionColor() => widget.isDarkMode
      ? const Color(0xFF658FA4).withValues(alpha: 0.35)
      : const Color(0xFF4A7A8C).withValues(alpha: 0.35);

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    if (items != null) {
      return _buildWithItems(context, items);
    }
    return FutureBuilder<List<SelectorItem>>(
      future: widget.itemsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _buildWithItems(context, snapshot.data!);
        }
        return _buildLoading(context);
      },
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: (widget.isDarkMode ? Colors.black : Colors.white).withValues(
          alpha: 0.3,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: widget.isDarkMode ? Colors.white54 : Colors.black54,
        ),
      ),
    );
  }

  Widget _buildWithItems(BuildContext context, List<SelectorItem> items) {
    final filtered = _filteredItems(items);
    if (filtered.isNotEmpty && _selectedIndex >= filtered.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedIndex = filtered.length - 1);
      });
    }
    if (filtered.isNotEmpty && _selectedIndex < filtered.length) {
      final idx = filtered.indexWhere((e) => e.id == widget.currentId);
      if (idx >= 0 && idx != _selectedIndex) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _selectedIndex = idx);
        });
      }
    }
    final l10n = AppLocalizations.of(context)!;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: (widget.isDarkMode ? Colors.black : Colors.white).withValues(
          alpha: 0.3,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: widget.isDarkMode
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.black.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _hintColor(),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _searchController,
                  style: TextStyle(color: _textColor(), fontSize: 16),
                  decoration: InputDecoration(
                    hintText: widget.searchHint,
                    hintStyle: TextStyle(color: _hintColor()),
                    prefixIcon: Icon(Icons.search, color: _hintColor()),
                    filled: true,
                    fillColor: (widget.isDarkMode ? Colors.white : Colors.black)
                        .withValues(alpha: 0.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(
                            'No results',
                            style: TextStyle(color: _hintColor()),
                          ),
                        )
                      : ListWheelScrollView.useDelegate(
                          itemExtent: 52,
                          diameterRatio: 1.5,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedIndex = index);
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: filtered.length,
                            builder: (context, index) {
                              final item = filtered[index];
                              final isSelected = index == _selectedIndex;
                              return Center(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? _selectionColor()
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (item.leading != null) ...[
                                        item.leading!,
                                        const SizedBox(width: 12),
                                      ],
                                      Text(
                                        item.label,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: _textColor(),
                                        ),
                                      ),
                                      if (item.subtitle != null &&
                                          item.subtitle!.isNotEmpty) ...[
                                        const SizedBox(width: 12),
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth: 180,
                                          ),
                                          child: Text(
                                            item.subtitle!,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: _hintColor(),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      if (filtered.isNotEmpty) {
                        final idx = _selectedIndex.clamp(
                          0,
                          filtered.length - 1,
                        );
                        widget.onSelected(filtered[idx].id);
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.isDarkMode
                          ? Colors.white.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.1),
                      foregroundColor: _textColor(),
                    ),
                    child: Text(l10n.done),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
