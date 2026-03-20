import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferencesAsync _prefs;

  static const _keyBaseCurrency = 'base_currency';
  static const _keyRow2Currency = 'row2_currency';
  static const _keyRow3Currency = 'row3_currency';
  static const _keyBaseCrypto = 'base_crypto';
  static const _keyRow2Crypto = 'row2_crypto';
  static const _keyRow3Crypto = 'row3_crypto';
  static const _keyIsRow2Visible = 'is_row2_visible';
  static const _keyIsRow3Visible = 'is_row3_visible';
  static const _keyIsDarkMode = 'is_dark_mode';
  static const _keyLocale = 'locale';
  static const _keySpeechOutputEnabled = 'speech_output_enabled';
  static const _keyVoiceInterpretation = 'voice_interpretation';

  Future<String> getBaseCurrency() async {
    return (await _prefs.getString(_keyBaseCurrency)) ?? 'EUR';
  }

  Future<String> getRow2Currency() async {
    return (await _prefs.getString(_keyRow2Currency)) ?? 'USD';
  }

  Future<String> getRow3Currency() async {
    return (await _prefs.getString(_keyRow3Currency)) ?? 'USD';
  }

  Future<String> getBaseCrypto() async {
    return (await _prefs.getString(_keyBaseCrypto)) ?? 'BTC';
  }

  Future<String> getRow2Crypto() async {
    return (await _prefs.getString(_keyRow2Crypto)) ?? 'ETH';
  }

  Future<String> getRow3Crypto() async {
    return (await _prefs.getString(_keyRow3Crypto)) ?? 'ETH';
  }

  Future<bool> getIsRow2Visible() async {
    return (await _prefs.getBool(_keyIsRow2Visible)) ?? true;
  }

  Future<bool> getIsRow3Visible() async {
    return (await _prefs.getBool(_keyIsRow3Visible)) ?? false;
  }

  Future<bool> getIsDarkMode() async {
    return (await _prefs.getBool(_keyIsDarkMode)) ?? true;
  }

  Future<String> getLocale() async {
    return (await _prefs.getString(_keyLocale)) ?? 'en';
  }

  Future<bool> getSpeechOutputEnabled() async {
    return (await _prefs.getBool(_keySpeechOutputEnabled)) ?? true;
  }

  Future<String> getVoiceInterpretation() async {
    return (await _prefs.getString(_keyVoiceInterpretation)) ??
        VoiceInterpretationMode.openAi.storageValue;
  }

  Future<void> setBaseCurrency(String value) async {
    await _prefs.setString(_keyBaseCurrency, value);
  }

  Future<void> setRow2Currency(String value) async {
    await _prefs.setString(_keyRow2Currency, value);
  }

  Future<void> setRow3Currency(String value) async {
    await _prefs.setString(_keyRow3Currency, value);
  }

  Future<void> setBaseCrypto(String value) async {
    await _prefs.setString(_keyBaseCrypto, value);
  }

  Future<void> setRow2Crypto(String value) async {
    await _prefs.setString(_keyRow2Crypto, value);
  }

  Future<void> setRow3Crypto(String value) async {
    await _prefs.setString(_keyRow3Crypto, value);
  }

  Future<void> setIsRow2Visible(bool value) async {
    await _prefs.setBool(_keyIsRow2Visible, value);
  }

  Future<void> setIsRow3Visible(bool value) async {
    await _prefs.setBool(_keyIsRow3Visible, value);
  }

  Future<void> setIsDarkMode(bool value) async {
    await _prefs.setBool(_keyIsDarkMode, value);
  }

  Future<void> setLocale(String value) async {
    await _prefs.setString(_keyLocale, value);
  }

  Future<void> setSpeechOutputEnabled(bool value) async {
    await _prefs.setBool(_keySpeechOutputEnabled, value);
  }

  Future<void> setVoiceInterpretation(String value) async {
    await _prefs.setString(_keyVoiceInterpretation, value);
  }
}

/// How spoken phrases are turned into amounts and currency pairs.
enum VoiceInterpretationMode {
  /// OpenAI API (multilingual); requires `OPENAI_API_KEY` in `.env`.
  openAi,

  /// Android speech engine only: extracts a number into the calculator (legacy).
  deviceRecognizer,
}

extension VoiceInterpretationModeStorage on VoiceInterpretationMode {
  String get storageValue => name;

  static VoiceInterpretationMode parse(String? raw) {
    for (final v in VoiceInterpretationMode.values) {
      if (v.name == raw) return v;
    }
    return VoiceInterpretationMode.openAi;
  }
}
