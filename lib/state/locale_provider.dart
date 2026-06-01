import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Module-level [SharedPreferences] handle.
///
/// Set once from `main()` (after `WidgetsFlutterBinding.ensureInitialized()`)
/// so that [LocaleNotifier.build] can read the persisted preference
/// synchronously. Tests may leave this unset; [LocaleNotifier] guards against
/// that and simply falls back to "follow system".
SharedPreferences? localePrefs;

/// Preferences key under which the selected locale code is stored.
const String kLocalePrefKey = 'locale';

/// Holds the user's language preference.
///
/// A value of `null` means "follow the system locale". A non-null [Locale]
/// (`en` or `zh`) means the user explicitly picked a language. The choice is
/// persisted to [SharedPreferences] so it survives restarts.
class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    final code = localePrefs?.getString(kLocalePrefKey);
    return _localeFromCode(code);
  }

  /// Sets the active locale (or `null` to follow the system) and persists it.
  Future<void> setLocale(Locale? locale) async {
    state = locale;
    final prefs = localePrefs;
    if (prefs == null) return;
    if (locale == null) {
      await prefs.remove(kLocalePrefKey);
    } else {
      await prefs.setString(kLocalePrefKey, locale.languageCode);
    }
  }

  static Locale? _localeFromCode(String? code) {
    switch (code) {
      case 'en':
        return const Locale('en');
      case 'zh':
        return const Locale('zh');
      default:
        return null;
    }
  }
}

/// Provides the current language preference (`null` => follow system).
final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(
  LocaleNotifier.new,
);
