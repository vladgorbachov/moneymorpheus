// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get ac => 'AC';

  @override
  String get backspace => '⌫';

  @override
  String get swap => '⇌';

  @override
  String get share => 'Поділитися';

  @override
  String get crypto => 'Крипто';

  @override
  String get close => 'Закрити';

  @override
  String get searchCurrency => 'Пошук валюти';

  @override
  String get searchCrypto => 'Пошук криптовалюти';

  @override
  String get searchLanguage => 'Пошук мови';

  @override
  String get settings => 'Налаштування';

  @override
  String get baseCurrency => 'Перша бажана\nвалюта';

  @override
  String get row2Currency => 'Друга бажана\nвалюта';

  @override
  String get row3Currency => 'Третя бажана\nвалюта';

  @override
  String get done => 'Готово';

  @override
  String get darkMode => 'Темний режим';

  @override
  String get lightMode => 'Світлий режим';

  @override
  String get language => 'Мова';

  @override
  String get thirdCurrencyRow => 'Третій ряд валют';

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
