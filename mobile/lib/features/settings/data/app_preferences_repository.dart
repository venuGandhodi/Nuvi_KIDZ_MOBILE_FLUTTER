import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Notification choices the shopper makes in Settings.
class AppPreferences {
  final bool orderUpdates;
  final bool offersAndNewArrivals;

  const AppPreferences({
    this.orderUpdates = true,
    this.offersAndNewArrivals = false,
  });

  AppPreferences copyWith({bool? orderUpdates, bool? offersAndNewArrivals}) =>
      AppPreferences(
        orderUpdates: orderUpdates ?? this.orderUpdates,
        offersAndNewArrivals: offersAndNewArrivals ?? this.offersAndNewArrivals,
      );
}

/// Stores [AppPreferences] on the device.
class AppPreferencesRepository {
  static const _orderUpdatesKey = 'pref_order_updates';
  static const _offersKey = 'pref_offers_new_arrivals';

  final SharedPreferences? _injected;

  AppPreferencesRepository({SharedPreferences? preferences})
    : _injected = preferences;

  Future<SharedPreferences> get _prefs async =>
      _injected ?? await SharedPreferences.getInstance();

  Future<AppPreferences> load() async {
    try {
      final p = await _prefs;
      const d = AppPreferences();
      return AppPreferences(
        orderUpdates: p.getBool(_orderUpdatesKey) ?? d.orderUpdates,
        offersAndNewArrivals: p.getBool(_offersKey) ?? d.offersAndNewArrivals,
      );
    } catch (_) {
      return const AppPreferences();
    }
  }

  Future<void> save(AppPreferences prefs) async {
    try {
      final p = await _prefs;
      await p.setBool(_orderUpdatesKey, prefs.orderUpdates);
      await p.setBool(_offersKey, prefs.offersAndNewArrivals);
    } catch (_) {
      // Preference saving is best-effort.
    }
  }
}

final appPreferencesRepositoryProvider = Provider<AppPreferencesRepository>(
  (ref) => AppPreferencesRepository(),
);

class AppPreferencesController extends Notifier<AppPreferences> {
  @override
  AppPreferences build() {
    Future.microtask(() async {
      state = await ref.read(appPreferencesRepositoryProvider).load();
    });
    return const AppPreferences();
  }

  Future<void> update(AppPreferences next) async {
    state = next;
    await ref.read(appPreferencesRepositoryProvider).save(next);
  }
}

final appPreferencesProvider =
    NotifierProvider<AppPreferencesController, AppPreferences>(
      AppPreferencesController.new,
    );
