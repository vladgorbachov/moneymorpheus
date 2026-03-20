// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get ac => 'AC';

  @override
  String get backspace => '⌫';

  @override
  String get swap => '⇌';

  @override
  String get share => 'Поделиться';

  @override
  String get crypto => 'Крипто';

  @override
  String get close => 'Закрыть';

  @override
  String get searchCurrency => 'Поиск валюты';

  @override
  String get searchCrypto => 'Поиск криптовалюты';

  @override
  String get searchLanguage => 'Поиск языка';

  @override
  String get settings => 'Настройки';

  @override
  String get baseCurrency => 'Первая предпочтительная\nвалюта';

  @override
  String get row2Currency => 'Вторая предпочтительная\nвалюта';

  @override
  String get row3Currency => 'Третья предпочтительная\nвалюта';

  @override
  String get done => 'Готово';

  @override
  String get darkMode => 'Тёмный режим';

  @override
  String get lightMode => 'Светлый режим';

  @override
  String get language => 'Язык';

  @override
  String get thirdCurrencyRow => 'Третья строка валют';

  @override
  String get cryptoSortMenu => 'Сортировка';

  @override
  String get cryptoSortVolumeDesc => 'Объём USDT 24ч: больше → меньше';

  @override
  String get cryptoSortVolumeAsc => 'Объём USDT 24ч: меньше → больше';

  @override
  String get cryptoSortSymbolAsc => 'Символ А–Я';

  @override
  String get cryptoSortSymbolDesc => 'Символ Я–А';

  @override
  String get speakConversionResult => 'Озвучивать результат';

  @override
  String get voiceUnderstanding => 'Голосовой перевод';

  @override
  String get voiceOpenAiLabel => 'OpenAI (любой язык)';

  @override
  String get voiceDeviceLabel => 'Устройство: только число';

  @override
  String get voiceCouldNotParse => 'Не разобрал фразу; введено только число';

  @override
  String get voiceAddOpenAiKeyHint =>
      'Добавьте OPENAI_API_KEY в .env для полного голосового ввода';
}
