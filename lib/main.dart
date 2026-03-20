import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxly/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/util/legacy_to_async_migration_util.dart';

import 'core/constants.dart';
import 'providers/settings_provider.dart';
import 'screens/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  final legacyPrefs = await SharedPreferences.getInstance();
  await migrateLegacySharedPreferencesToSharedPreferencesAsyncIfNecessary(
    legacySharedPreferencesInstance: legacyPrefs,
    sharedPreferencesAsyncOptions: const SharedPreferencesOptions(),
    migrationCompletedKey: 'fluxly_migration_completed',
  );
  runApp(const ProviderScope(child: FluxlyApp()));
}

class FluxlyApp extends ConsumerWidget {
  const FluxlyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return settingsAsync.when(
      data: (settings) => MaterialApp(
        title: 'Fluxly',
        debugShowCheckedModeBanner: false,
        locale: settings.localeValue,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          brightness: Brightness.light,
          useMaterial3: true,
          fontFamily: kLarazFontFamily,
          textTheme: ThemeData.light().textTheme.apply(
            fontFamily: kLarazFontFamily,
          ),
          colorScheme: ColorScheme.light(
            surface: lightBackgroundColor,
            primary: lightAccentColor,
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          fontFamily: kLarazFontFamily,
          textTheme: ThemeData.dark().textTheme.apply(fontFamily: kLarazFontFamily),
          colorScheme: ColorScheme.dark(
            surface: darkBackgroundColor,
            primary: darkAccentColor,
          ),
        ),
        themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: const MainScreen(),
      ),
      loading: () => MaterialApp(
        home: Scaffold(
          backgroundColor: darkBackgroundColor,
          body: Center(child: CircularProgressIndicator(color: accentColor)),
        ),
      ),
      error: (e, _) => MaterialApp(
        home: Scaffold(body: Center(child: Text('Error: $e'))),
      ),
    );
  }
}
