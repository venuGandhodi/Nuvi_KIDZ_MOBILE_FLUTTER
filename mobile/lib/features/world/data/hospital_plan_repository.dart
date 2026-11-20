import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/hospital_plan.dart';

/// Saves the hospital plan on the device.
class HospitalPlanRepository {
  static const _key = 'world_hospital_plan';
  final SharedPreferences? _injected;

  HospitalPlanRepository({SharedPreferences? preferences})
    : _injected = preferences;

  Future<SharedPreferences> get _prefs async =>
      _injected ?? await SharedPreferences.getInstance();

  Future<HospitalPlan> load() async {
    try {
      final raw = (await _prefs).getString(_key);
      if (raw == null) return HospitalPlan.initial();
      return HospitalPlan.fromJson(jsonDecode(raw) as Map<String, Object?>);
    } catch (_) {
      return HospitalPlan.initial();
    }
  }

  Future<void> save(HospitalPlan plan) async {
    try {
      await (await _prefs).setString(_key, jsonEncode(plan.toJson()));
    } catch (_) {
      // Best-effort: the plan stays in memory for this session.
    }
  }
}

final hospitalPlanRepositoryProvider = Provider<HospitalPlanRepository>(
  (ref) => HospitalPlanRepository(),
);

class HospitalPlanController extends Notifier<HospitalPlan> {
  @override
  HospitalPlan build() {
    Future.microtask(() async {
      state = await ref.read(hospitalPlanRepositoryProvider).load();
    });
    return HospitalPlan.initial();
  }

  Future<void> _set(HospitalPlan next) async {
    state = next;
    await ref.read(hospitalPlanRepositoryProvider).save(next);
  }

  Future<void> setDueDate(DateTime? date) => _set(
    date == null
        ? state.copyWith(clearDueDate: true)
        : state.copyWith(dueDate: date),
  );

  Future<void> setDetails({
    String? hospitalName,
    String? doctorName,
    String? doctorPhone,
  }) => _set(
    state.copyWith(
      hospitalName: hospitalName,
      doctorName: doctorName,
      doctorPhone: doctorPhone,
    ),
  );

  Future<void> toggle(String id) => _set(
    state.copyWith(
      items: [
        for (final i in state.items) i.id == id ? i.copyWith(done: !i.done) : i,
      ],
    ),
  );

  Future<void> addItem(String group, String label) {
    final text = label.trim();
    if (text.isEmpty) return Future.value();
    return _set(
      state.copyWith(
        items: [
          ...state.items,
          PlanItem(
            id: 'custom-${DateTime.now().microsecondsSinceEpoch}',
            group: group,
            label: text,
          ),
        ],
      ),
    );
  }

  Future<void> removeItem(String id) => _set(
    state.copyWith(
      items: [
        for (final i in state.items)
          if (i.id != id) i,
      ],
    ),
  );
}

final hospitalPlanProvider =
    NotifierProvider<HospitalPlanController, HospitalPlan>(
      HospitalPlanController.new,
    );
