// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get ac => 'AC';

  @override
  String get backspace => '⌫';

  @override
  String get swap => '⇌';

  @override
  String get share => 'Compartir';

  @override
  String get crypto => 'Cripto';

  @override
  String get close => 'Cerrar';

  @override
  String get searchCurrency => 'Buscar moneda';

  @override
  String get searchCrypto => 'Buscar cripto';

  @override
  String get searchLanguage => 'Buscar idioma';

  @override
  String get settings => 'Ajustes';

  @override
  String get baseCurrency => 'Primera moneda\npreferida';

  @override
  String get row2Currency => 'Segunda moneda\npreferida';

  @override
  String get row3Currency => 'Tercera moneda\npreferida';

  @override
  String get done => 'Listo';

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get lightMode => 'Modo claro';

  @override
  String get language => 'Idioma';

  @override
  String get thirdCurrencyRow => 'Tercera fila de monedas';

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
