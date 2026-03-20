// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get ac => 'AC';

  @override
  String get backspace => '⌫';

  @override
  String get swap => '⇌';

  @override
  String get share => 'مشاركة';

  @override
  String get crypto => 'العملات المشفرة';

  @override
  String get close => 'إغلاق';

  @override
  String get searchCurrency => 'البحث عن العملة';

  @override
  String get searchCrypto => 'البحث عن العملة المشفرة';

  @override
  String get searchLanguage => 'البحث عن اللغة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get baseCurrency => 'العملة المفضلة\nالأولى';

  @override
  String get row2Currency => 'العملة المفضلة\nالثانية';

  @override
  String get row3Currency => 'العملة المفضلة\nالثالثة';

  @override
  String get done => 'تم';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get lightMode => 'الوضع الفاتح';

  @override
  String get language => 'اللغة';

  @override
  String get thirdCurrencyRow => 'صف العملة الثالث';

  @override
  String get cryptoSortMenu => 'Sort list';

  @override
  String get cryptoSortVolumeDesc => '24h USDT volume: high → low';

  @override
  String get cryptoSortVolumeAsc => '24h USDT volume: low → high';

  @override
  String get cryptoSortSymbolAsc => 'Symbol A–Z';

  @override
  String get cryptoSortSymbolDesc => 'Symbol Z–A';

  @override
  String get speakConversionResult => 'Speak conversion result';

  @override
  String get voiceUnderstanding => 'Voice conversion';

  @override
  String get voiceOpenAiLabel => 'OpenAI (any language)';

  @override
  String get voiceDeviceLabel => 'Device: number only';

  @override
  String get voiceCouldNotParse =>
      'Could not parse phrase; entered number only';

  @override
  String get voiceAddOpenAiKeyHint =>
      'Add OPENAI_API_KEY to .env for full voice conversion';
}
