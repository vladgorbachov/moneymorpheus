import 'package:flutter/material.dart';

/// Reusable model for items in search + carousel selector sheets.
class SelectorItem {
  final String id;
  final String label;
  final String? subtitle;
  final Widget? leading;

  const SelectorItem({
    required this.id,
    required this.label,
    this.subtitle,
    this.leading,
  });

  String get searchableText => '$id $label ${subtitle ?? ''}'.toLowerCase();
}
