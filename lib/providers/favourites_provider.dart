import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/favourites_repository.dart';
import 'settings_provider.dart';

final favouritesRepositoryProvider = Provider<FavouritesRepository>((ref) {
  return FavouritesRepository(ref.read(sharedPreferencesAsyncProvider));
});

class FavouritesNotifier extends AsyncNotifier<Set<String>> {
  FavouritesRepository get _repository =>
      ref.read(favouritesRepositoryProvider);

  @override
  Future<Set<String>> build() async {
    return _repository.getFavourites();
  }

  Future<void> toggle(String symbol) async {
    await _repository.toggleFavourite(symbol);
    state = AsyncData(await _repository.getFavourites());
  }
}

final favouritesProvider =
    AsyncNotifierProvider<FavouritesNotifier, Set<String>>(
      FavouritesNotifier.new,
    );
