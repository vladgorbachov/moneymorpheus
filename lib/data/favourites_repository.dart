import 'package:shared_preferences/shared_preferences.dart';

class FavouritesRepository {
  FavouritesRepository(this._prefs);

  final SharedPreferencesAsync _prefs;

  static const _keyFavourites = 'crypto_favourites';

  Future<Set<String>> getFavourites() async {
    final list = await _prefs.getStringList(_keyFavourites);
    return list != null ? list.toSet() : <String>{};
  }

  Future<void> setFavourites(Set<String> symbols) async {
    await _prefs.setStringList(_keyFavourites, symbols.toList());
  }

  Future<void> toggleFavourite(String symbol) async {
    final current = await getFavourites();
    final next = <String>{...current};
    if (next.contains(symbol)) {
      next.remove(symbol);
    } else {
      next.add(symbol);
    }
    await setFavourites(next);
  }
}
