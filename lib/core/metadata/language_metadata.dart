import 'package:flutter/material.dart';

import 'asset_metadata.dart';

/// Language metadata: code, displayName, flag, displayCode (capitalized).
class LanguageMetadata extends AssetMetadata {
  @override
  final String id;

  final String displayName;

  final String? flagEmoji;

  const LanguageMetadata({
    required this.id,
    required this.displayName,
    this.flagEmoji,
  });

  @override
  String get displayLabel => displayName;

  @override
  String? get displaySubtitle => null;

  @override
  Widget? get leadingWidget => flagEmoji != null
      ? Text(flagEmoji!, style: const TextStyle(fontSize: 24))
      : null;

  static const List<LanguageMetadata> supported = [
    LanguageMetadata(id: 'en', displayName: 'En', flagEmoji: '🇺🇸'),
    LanguageMetadata(id: 'fr', displayName: 'Fr', flagEmoji: '🇫🇷'),
    LanguageMetadata(id: 'es', displayName: 'Es', flagEmoji: '🇪🇸'),
    LanguageMetadata(id: 'ru', displayName: 'Ru', flagEmoji: '🇷🇺'),
    LanguageMetadata(id: 'ar', displayName: 'Ar', flagEmoji: '🇸🇦'),
    LanguageMetadata(id: 'zh', displayName: 'Zh', flagEmoji: '🇨🇳'),
    LanguageMetadata(id: 'uk', displayName: 'Ukr', flagEmoji: '🇺🇦'),
    LanguageMetadata(id: 'pl', displayName: 'Pl', flagEmoji: '🇵🇱'),
    LanguageMetadata(id: 'ro', displayName: 'Ro', flagEmoji: '🇷🇴'),
  ];

  static String displayLabelForCode(String code) {
    final c = code.length >= 2 ? code.substring(0, 2) : code;
    for (final item in supported) {
      if (item.id == c) return item.displayName;
    }
    return c.toUpperCase();
  }
}
