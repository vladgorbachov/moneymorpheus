import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferencesAsync _prefs;

  static const _keyBaseCurrency = 'base_currency';
  static const _keyRow2Currency = 'row2_currency';
  static const _keyRow3Currency = 'row3_currency';
  static const _keyIsRow2Visible = 'is_row2_visible';
  static const _keyIsRow3Visible = 'is_row3_visible';
  static const _keyIsDarkMode = 'is_dark_mode';
  static const _keyLocale = 'locale';

  Future<String> getBaseCurrency() async {
    return (await _prefs.getString(_keyBaseCurrency)) ?? 'USD';
  }

  Future<String> getRow2Currency() async {
    return (await _prefs.getString(_keyRow2Currency)) ?? 'EUR';
  }

  Future<String> getRow3Currency() async {
    return (await _prefs.getString(_keyRow3Currency)) ?? 'UAH';
  }

  Future<bool> getIsRow2Visible() async {
    return (await _prefs.getBool(_keyIsRow2Visible)) ?? true;
  }

  Future<bool> getIsRow3Visible() async {
    return (await _prefs.getBool(_keyIsRow3Visible)) ?? true;
  }

  Future<bool> getIsDarkMode() async {
    return (await _prefs.getBool(_keyIsDarkMode)) ?? true;
  }

  Future<String> getLocale() async {
    return (await _prefs.getString(_keyLocale)) ?? 'en';
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
}
