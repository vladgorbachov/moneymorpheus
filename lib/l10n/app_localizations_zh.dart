// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get ac => 'AC';

  @override
  String get backspace => '⌫';

  @override
  String get swap => '⇌';

  @override
  String get share => '分享';

  @override
  String get crypto => '加密货币';

  @override
  String get close => '关闭';

  @override
  String get searchCurrency => '搜索货币';

  @override
  String get searchCrypto => '搜索加密货币';

  @override
  String get searchLanguage => '搜索语言';

  @override
  String get settings => '设置';

  @override
  String get baseCurrency => '首选货币\n一';

  @override
  String get row2Currency => '首选货币\n二';

  @override
  String get row3Currency => '首选货币\n三';

  @override
  String get done => '完成';

  @override
  String get darkMode => '深色模式';

  @override
  String get lightMode => '浅色模式';

  @override
  String get language => '语言';

  @override
  String get thirdCurrencyRow => '第三货币行';

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
