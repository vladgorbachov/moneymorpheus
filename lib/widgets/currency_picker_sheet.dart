import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:moneymorpheus/l10n/app_localizations.dart';

import '../core/currencies.dart';

enum CurrencyPickerTarget { base, row2, row3 }

class CurrencyPickerSheet extends ConsumerStatefulWidget {
  final CurrencyPickerTarget target;
  final String currentCurrency;
  final void Function(String) onSelected;
  final bool isDarkMode;

  const CurrencyPickerSheet({
    super.key,
    required this.target,
    required this.currentCurrency,
    required this.onSelected,
    required this.isDarkMode,
  });

  static Future<void> show(
    BuildContext context, {
    required CurrencyPickerTarget target,
    required String currentCurrency,
    required void Function(String) onSelected,
    required bool isDarkMode,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CurrencyPickerSheet(
        target: target,
        currentCurrency: currentCurrency,
        onSelected: onSelected,
        isDarkMode: isDarkMode,
      ),
    );
  }

  @override
  ConsumerState<CurrencyPickerSheet> createState() =>
      _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends ConsumerState<CurrencyPickerSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
    _selectedIndex = supportedCurrencies
        .indexWhere((e) => e.key == widget.currentCurrency);
    if (_selectedIndex < 0) _selectedIndex = 0;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MapEntry<String, String>> get _filteredCurrencies {
    if (_searchQuery.isEmpty) return supportedCurrencies;
    return supportedCurrencies.where((e) {
      return e.key.toLowerCase().contains(_searchQuery) ||
          e.value.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  Color _textColor() => widget.isDarkMode
      ? Colors.white.withValues(alpha: 0.95)
      : Colors.black.withValues(alpha: 0.9);

  Color _hintColor() => widget.isDarkMode
      ? Colors.white.withValues(alpha: 0.5)
      : Colors.black.withValues(alpha: 0.4);

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredCurrencies;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: (widget.isDarkMode ? Colors.black : Colors.white)
            .withValues(alpha: 0.3),
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
                    hintText: l10n.searchCurrency,
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
                              final entry = filtered[index];
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
                                        ? (widget.isDarkMode
                                                ? const Color(0xFF658FA4)
                                                : const Color(0xFF4A7A8C))
                                            .withValues(alpha: 0.3)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        entry.key,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: _textColor(),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          entry.value,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: _hintColor(),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
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
                        final idx = _selectedIndex.clamp(0, filtered.length - 1);
                        widget.onSelected(filtered[idx].key);
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
