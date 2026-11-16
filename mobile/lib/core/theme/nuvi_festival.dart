import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NuviFestivalEffect {
  snow,
  confetti,
  crackers,
  colourPuffs,
  petals,
  moonStars,
}

class NuviMonthDay {
  final int month;
  final int day;

  const NuviMonthDay(this.month, this.day);

  int get _key => month * 100 + day;
}

class NuviFestival {
  final String id;
  final String label;
  final String emoji;

  /// Inclusive date range; both null means the festival is manual-only.
  final NuviMonthDay? start;
  final NuviMonthDay? end;

  final Color gold;
  final Color peach;
  final Color lavender;
  final Color sage;
  final String headingFont;
  final NuviFestivalEffect effect;
  final List<String> announcements;

  const NuviFestival({
    required this.id,
    required this.label,
    required this.emoji,
    this.start,
    this.end,
    required this.gold,
    required this.peach,
    required this.lavender,
    required this.sage,
    required this.headingFont,
    required this.effect,
    required this.announcements,
  });

  bool contains(DateTime date) {
    if (start == null || end == null) return false;
    final key = date.month * 100 + date.day;
    // A range whose start is after its end wraps the year (New Year).
    if (start!._key <= end!._key) {
      return key >= start!._key && key <= end!._key;
    }
    return key >= start!._key || key <= end!._key;
  }
}

/// Every festival theme and its date window, in one place.
class NuviFestivals {
  static const List<NuviFestival> all = [
    NuviFestival(
      id: 'christmas',
      label: 'Christmas',
      emoji: '🎄',
      start: NuviMonthDay(12, 1),
      end: NuviMonthDay(12, 26),
      gold: Color(0xFFC0392B),
      peach: Color(0xFF2E7D5B),
      lavender: Color(0xFF0F3D2E),
      sage: Color(0xFF2E7D5B),
      headingFont: 'MountainsofChristmas',
      effect: NuviFestivalEffect.snow,
      announcements: [
        '❄️ Happy Holidays from the NUVI Universe ❄️',
        '🎄 Christmas styles now under the tree',
      ],
    ),
    NuviFestival(
      id: 'new-year',
      label: 'New Year',
      emoji: '🎆',
      start: NuviMonthDay(12, 27),
      end: NuviMonthDay(1, 5),
      gold: Color(0xFFEAB83D),
      peach: Color(0xFFD9C7EA),
      lavender: Color(0xFF241B4D),
      sage: Color(0xFF9AA38C),
      headingFont: 'PaytoneOne',
      effect: NuviFestivalEffect.confetti,
      announcements: [
        '🎆 Happy New Year from the NUVI Universe 🎆',
        '✨ New year, new little styles — shop now',
      ],
    ),
    NuviFestival(
      id: 'diwali',
      label: 'Diwali',
      emoji: '🪔',
      start: NuviMonthDay(10, 12),
      end: NuviMonthDay(11, 15),
      gold: Color(0xFFD9A400),
      peach: Color(0xFFE9622D),
      lavender: Color(0xFF5C1A2E),
      sage: Color(0xFF8A4B12),
      headingFont: 'YesevaOne',
      effect: NuviFestivalEffect.crackers,
      announcements: [
        '🪔 Happy Diwali from the NUVI Universe 🪔',
        '✨ Festive styles for your little lights',
      ],
    ),
    NuviFestival(
      id: 'navratri',
      label: 'Navratri',
      emoji: '💃',
      start: NuviMonthDay(9, 22),
      end: NuviMonthDay(10, 2),
      gold: Color(0xFFE0A400),
      peach: Color(0xFFD6336C),
      lavender: Color(0xFF3A1E70),
      sage: Color(0xFF0E7C7B),
      headingFont: 'Kalam',
      effect: NuviFestivalEffect.colourPuffs,
      announcements: [
        '💃 Happy Navratri from the NUVI Universe 💃',
        '✨ Nine nights of little festive styles',
      ],
    ),
    NuviFestival(
      id: 'ganesh-chaturthi',
      label: 'Ganesh Chaturthi',
      emoji: '🐘',
      start: NuviMonthDay(8, 22),
      end: NuviMonthDay(9, 17),
      gold: Color(0xFFE8A324),
      peach: Color(0xFFD8482A),
      lavender: Color(0xFF274E13),
      sage: Color(0xFF4C7A2A),
      headingFont: 'YatraOne',
      effect: NuviFestivalEffect.petals,
      announcements: [
        '🐘 Happy Ganesh Chaturthi from the NUVI Universe',
        '🌼 Festive styles for little celebrations',
      ],
    ),
    NuviFestival(
      id: 'raksha-bandhan',
      label: 'Raksha Bandhan',
      emoji: '🎗️',
      start: NuviMonthDay(8, 1),
      end: NuviMonthDay(8, 20),
      gold: Color(0xFFD9A441),
      peach: Color(0xFFE0607E),
      lavender: Color(0xFF7A2340),
      sage: Color(0xFFB9772F),
      headingFont: 'RozhaOne',
      effect: NuviFestivalEffect.petals,
      announcements: [
        '🎗️ Happy Raksha Bandhan from the NUVI Universe',
        '💛 Matching styles for brothers & sisters',
      ],
    ),
    NuviFestival(
      id: 'holi',
      label: 'Holi',
      emoji: '🎨',
      start: NuviMonthDay(3, 1),
      end: NuviMonthDay(3, 20),
      gold: Color(0xFFE94E77),
      peach: Color(0xFF3AA6A0),
      lavender: Color(0xFF7B4FA6),
      sage: Color(0xFFF2B705),
      headingFont: 'Baloo2',
      effect: NuviFestivalEffect.colourPuffs,
      announcements: [
        '🎨 Happy Holi from the NUVI Universe 🎨',
        '🌈 Colourful styles for little hands',
      ],
    ),
    NuviFestival(
      id: 'eid',
      label: 'Eid',
      emoji: '🌙',
      gold: Color(0xFFC9A227),
      peach: Color(0xFF1E7A5F),
      lavender: Color(0xFF0B3D2E),
      sage: Color(0xFF2F8F6B),
      headingFont: 'Katibeh',
      effect: NuviFestivalEffect.moonStars,
      announcements: [
        '🌙 Eid Mubarak from the NUVI Universe 🌙',
        '✨ Festive styles for little celebrations',
      ],
    ),
  ];

  static NuviFestival? byId(String id) {
    for (final festival in all) {
      if (festival.id == id) return festival;
    }
    return null;
  }

  static NuviFestival? forDate(DateTime date) {
    for (final festival in all) {
      if (festival.contains(date)) return festival;
    }
    return null;
  }

  /// `off`, `auto` (by device date) or a festival id.
  static NuviFestival? resolve(String mode, DateTime now) {
    if (mode == 'off') return null;
    if (mode == 'auto') return forDate(now);
    return byId(mode);
  }
}

/// Festival mode: `off`, `auto` or a festival id. Defaults to `auto`; override
/// at build time with `--dart-define=NUVI_FESTIVAL=christmas`.
class FestivalModeController extends Notifier<String> {
  @override
  String build() =>
      const String.fromEnvironment('NUVI_FESTIVAL', defaultValue: 'auto');

  void setMode(String mode) => state = mode;
}

final festivalModeProvider = NotifierProvider<FestivalModeController, String>(
  FestivalModeController.new,
);

final activeFestivalProvider = Provider<NuviFestival?>((ref) {
  final mode = ref.watch(festivalModeProvider);
  return NuviFestivals.resolve(mode, DateTime.now());
});
