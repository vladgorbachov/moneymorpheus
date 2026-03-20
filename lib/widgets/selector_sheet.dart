import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moneymorpheus/l10n/app_localizations.dart';

import '../core/constants.dart';
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
  final ScrollController _lightListScrollController = ScrollController();
  String _searchQuery = '';
  int _selectedIndex = 0;

  static const double _lightListRowExtent = 53;

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
    _lightListScrollController.dispose();
    super.dispose();
  }

  void _scheduleScrollLightListToSelection(int itemCount) {
    if (widget.isDarkMode || itemCount <= 0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_lightListScrollController.hasClients) return;
      final maxScroll = _lightListScrollController.position.maxScrollExtent;
      final target =
          (_selectedIndex * _lightListRowExtent).clamp(0.0, maxScroll);
      _lightListScrollController.jumpTo(target);
    });
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
    final h = MediaQuery.sizeOf(context).height;
    if (widget.isDarkMode) {
      return Container(
        constraints: BoxConstraints(maxHeight: h * 0.7),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white54),
        ),
      );
    }
    return Container(
      constraints: BoxConstraints(maxHeight: h * 0.8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.45),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: lightAccentColor.withValues(alpha: 0.08),
            blurRadius: 28,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.black54),
          ),
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

    if (!widget.isDarkMode && filtered.isNotEmpty) {
      _scheduleScrollLightListToSelection(filtered.length);
    }

    if (widget.isDarkMode) {
      return _buildDarkPickerContent(context, filtered, l10n);
    }
    return _buildLightPickerContent(context, filtered, l10n);
  }

  /// Dark theme: wheel carousel (unchanged behavior).
  Widget _buildDarkPickerContent(
    BuildContext context,
    List<SelectorItem> filtered,
    AppLocalizations l10n,
  ) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.7,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
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
                  style: TextStyle(
                    color: _textColor(),
                    fontSize: 17,
                    fontFamily: 'DejaVuSans',
                  ),
                  decoration: InputDecoration(
                    hintText: widget.searchHint,
                    hintStyle: TextStyle(
                      color: _hintColor(),
                      fontFamily: 'DejaVuSans',
                    ),
                    prefixIcon: Icon(Icons.search, color: _hintColor()),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.08),
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
                            style: TextStyle(
                              color: _hintColor(),
                              fontFamily: 'DejaVuSans',
                            ),
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
                                          fontFamily: 'DejaVuSans',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 19,
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
                                              fontFamily: 'DejaVuSans',
                                              fontSize: 15,
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
                    onPressed: () => _confirmSelection(context, filtered),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      foregroundColor: _textColor(),
                    ),
                    child: Text(
                      l10n.done,
                      style: const TextStyle(
                        fontFamily: 'Cormorant',
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Light theme: flat list + shell aligned with [SettingsSheet] (no wheel shading).
  Widget _buildLightPickerContent(
    BuildContext context,
    List<SelectorItem> filtered,
    AppLocalizations l10n,
  ) {
    final dividerColor = const Color(0xFF0D0D0D).withValues(alpha: 0.08);
    final doneTextColor = const Color(0xFF0D0D0D);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.45),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: lightAccentColor.withValues(alpha: 0.08),
            blurRadius: 28,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 56,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _hintColor(),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _searchController,
                  style: TextStyle(
                    color: _textColor(),
                    fontSize: 17,
                    fontFamily: 'DejaVuSans',
                  ),
                  decoration: InputDecoration(
                    hintText: widget.searchHint,
                    hintStyle: TextStyle(
                      color: _hintColor(),
                      fontFamily: 'DejaVuSans',
                    ),
                    prefixIcon: Icon(Icons.search, color: _hintColor()),
                    filled: true,
                    fillColor: Colors.black.withValues(alpha: 0.08),
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
                            style: TextStyle(
                              color: _hintColor(),
                              fontFamily: 'DejaVuSans',
                            ),
                          ),
                        )
                      : ListView.separated(
                          controller: _lightListScrollController,
                          itemCount: filtered.length,
                          separatorBuilder: (context, index) =>
                              Divider(height: 1, color: dividerColor),
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            final isSelected = index == _selectedIndex;
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => _selectedIndex = index);
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? _selectionColor()
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      if (item.leading != null) ...[
                                        item.leading!,
                                        const SizedBox(width: 12),
                                      ],
                                      Expanded(
                                        child: Text(
                                          item.label,
                                          style: TextStyle(
                                            fontFamily: 'DejaVuSans',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 19,
                                            color: _textColor(),
                                          ),
                                        ),
                                      ),
                                      if (item.subtitle != null &&
                                          item.subtitle!.isNotEmpty) ...[
                                        const SizedBox(width: 12),
                                        Flexible(
                                          child: Text(
                                            item.subtitle!,
                                            style: TextStyle(
                                              fontFamily: 'DejaVuSans',
                                              fontSize: 15,
                                              color: _hintColor(),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 62,
                  child: DecoratedBox(
                    decoration: glassButtonDecoration(
                      isDarkMode: false,
                      borderRadius: BorderRadius.circular(20),
                      highlight: true,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => _confirmSelection(context, filtered),
                        child: Center(
                          child: Text(
                            l10n.done,
                            style: TextStyle(
                              fontFamily: 'Cormorant',
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: doneTextColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmSelection(BuildContext context, List<SelectorItem> filtered) {
    if (filtered.isEmpty) return;
    final idx = _selectedIndex.clamp(0, filtered.length - 1);
    widget.onSelected(filtered[idx].id);
    Navigator.of(context).pop();
  }
}
