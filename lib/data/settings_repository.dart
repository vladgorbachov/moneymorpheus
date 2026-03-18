import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const _keyBaseCurrency = 'base_currency';
  static const _keyRow2Currency = 'row2_currency';
  static const _keyRow3Currency = 'row3_currency';
  static const _keyIsRow2Visible = 'is_row2_visible';
  static const _keyIsRow3Visible = 'is_row3_visible';

  Future<String> getBaseCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyBaseCurrency) ?? 'USD';
  }

  Future<String> getRow2Currency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRow2Currency) ?? 'EUR';
  }

  Future<String> getRow3Currency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRow3Currency) ?? 'UAH';
  }

  Future<bool> getIsRow2Visible() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsRow2Visible) ?? true;
  }

  Future<bool> getIsRow3Visible() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsRow3Visible) ?? true;
  }

  Future<void> setBaseCurrency(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBaseCurrency, value);
  }

  Future<void> setRow2Currency(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRow2Currency, value);
  }

  Future<void> setRow3Currency(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRow3Currency, value);
  }

  Future<void> setIsRow2Visible(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsRow2Visible, value);
  }

  Future<void> setIsRow3Visible(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsRow3Visible, value);
  }
}
