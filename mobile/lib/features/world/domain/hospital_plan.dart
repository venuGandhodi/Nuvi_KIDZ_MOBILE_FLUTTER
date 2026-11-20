/// One hospital-bag checklist entry.
class PlanItem {
  final String id;
  final String group;
  final String label;
  final bool done;

  const PlanItem({
    required this.id,
    required this.group,
    required this.label,
    this.done = false,
  });

  PlanItem copyWith({bool? done}) =>
      PlanItem(id: id, group: group, label: label, done: done ?? this.done);

  Map<String, Object> toJson() => {
    'id': id,
    'group': group,
    'label': label,
    'done': done,
  };

  static PlanItem? fromJson(Object? j) {
    if (j is! Map) return null;
    final id = j['id'], group = j['group'], label = j['label'];
    if (id is! String || group is! String || label is! String) return null;
    return PlanItem(
      id: id,
      group: group,
      label: label,
      done: j['done'] == true,
    );
  }
}

/// Delivery details and hospital-bag checklist, kept on the phone.
class HospitalPlan {
  static const groups = ['Documents', 'For Mom', 'For Baby'];

  /// A starting checklist the parent can tick, add to or remove from.
  static final List<PlanItem> defaultItems = [
    for (final (g, labels) in const [
      (
        'Documents',
        [
          'ID proof',
          'Hospital registration card',
          'Health insurance card',
          'Previous reports & scans',
        ],
      ),
      (
        'For Mom',
        [
          'Comfortable nightwear',
          'Nursing bras',
          'Maternity pads',
          'Toiletries',
          'Slippers',
          'Phone charger',
        ],
      ),
      (
        'For Baby',
        [
          'Baby clothes (2–3 sets)',
          'Swaddle or soft blanket',
          'Newborn diapers',
          'Baby wipes',
          'Cap, mittens & socks',
        ],
      ),
    ])
      for (final (i, l) in labels.indexed)
        PlanItem(
          id: '${g.toLowerCase().replaceAll(' ', '-')}-$i',
          group: g,
          label: l,
        ),
  ];

  final DateTime? dueDate;
  final String hospitalName;
  final String doctorName;
  final String doctorPhone;
  final List<PlanItem> items;

  const HospitalPlan({
    this.dueDate,
    this.hospitalName = '',
    this.doctorName = '',
    this.doctorPhone = '',
    this.items = const [],
  });

  factory HospitalPlan.initial() => HospitalPlan(items: defaultItems);

  int get doneCount => items.where((i) => i.done).length;

  HospitalPlan copyWith({
    DateTime? dueDate,
    bool clearDueDate = false,
    String? hospitalName,
    String? doctorName,
    String? doctorPhone,
    List<PlanItem>? items,
  }) => HospitalPlan(
    dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
    hospitalName: hospitalName ?? this.hospitalName,
    doctorName: doctorName ?? this.doctorName,
    doctorPhone: doctorPhone ?? this.doctorPhone,
    items: items ?? this.items,
  );

  Map<String, Object?> toJson() => {
    'dueDate': dueDate?.toIso8601String(),
    'hospitalName': hospitalName,
    'doctorName': doctorName,
    'doctorPhone': doctorPhone,
    'items': [for (final i in items) i.toJson()],
  };

  static HospitalPlan fromJson(Map<String, Object?> j) => HospitalPlan(
    dueDate: DateTime.tryParse(j['dueDate'] as String? ?? ''),
    hospitalName: j['hospitalName'] as String? ?? '',
    doctorName: j['doctorName'] as String? ?? '',
    doctorPhone: j['doctorPhone'] as String? ?? '',
    items: [
      for (final i in (j['items'] as List?) ?? const []) ?PlanItem.fromJson(i),
    ],
  );
}

/// Where a pregnancy is, worked out from the due date (40 weeks = 280 days).
class PregnancyProgress {
  final int week;
  final int dayOfWeek;
  final int daysToGo;

  const PregnancyProgress._(this.week, this.dayOfWeek, this.daysToGo);

  factory PregnancyProgress.from(DateTime dueDate, DateTime today) {
    final due = DateTime.utc(dueDate.year, dueDate.month, dueDate.day);
    final now = DateTime.utc(today.year, today.month, today.day);
    final daysToGo = due.difference(now).inDays;
    final elapsed = (280 - daysToGo).clamp(0, 294);
    return PregnancyProgress._(elapsed ~/ 7, elapsed % 7, daysToGo);
  }

  int get trimester => week < 14 ? 1 : (week < 28 ? 2 : 3);

  double get fraction => ((week * 7 + dayOfWeek) / 280).clamp(0.0, 1.0);
}
