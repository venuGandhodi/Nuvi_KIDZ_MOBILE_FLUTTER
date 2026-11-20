import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/settings/data/app_preferences_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('preferences default, then save and load back', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = AppPreferencesRepository(
      preferences: await SharedPreferences.getInstance(),
    );
    final initial = await repo.load();
    expect(initial.orderUpdates, isTrue);
    expect(initial.offersAndNewArrivals, isFalse);

    await repo.save(initial.copyWith(offersAndNewArrivals: true));
    final loaded = await repo.load();
    expect(loaded.offersAndNewArrivals, isTrue);
    expect(loaded.orderUpdates, isTrue);
  });
}
