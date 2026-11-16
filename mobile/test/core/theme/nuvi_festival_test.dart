import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/core/theme/nuvi_colors.dart';
import 'package:nuvi_kidz/core/theme/nuvi_festival.dart';
import 'package:nuvi_kidz/core/theme/nuvi_theme.dart';
import 'package:nuvi_kidz/core/theme/nuvi_theme_ext.dart';

void main() {
  group('NuviFestivals.resolve', () {
    test('auto picks Christmas on 10 Dec', () {
      expect(
        NuviFestivals.resolve('auto', DateTime(2026, 12, 10))?.id,
        'christmas',
      );
    });

    test('auto picks New Year on both sides of the year wrap', () {
      expect(
        NuviFestivals.resolve('auto', DateTime(2026, 12, 28))?.id,
        'new-year',
      );
      expect(
        NuviFestivals.resolve('auto', DateTime(2027, 1, 5))?.id,
        'new-year',
      );
      expect(NuviFestivals.resolve('auto', DateTime(2027, 1, 6)), isNull);
    });

    test('range edges are inclusive', () {
      expect(
        NuviFestivals.resolve('auto', DateTime(2026, 12, 26))?.id,
        'christmas',
      );
      expect(
        NuviFestivals.resolve('auto', DateTime(2026, 12, 27))?.id,
        'new-year',
      );
    });

    test('off always disables, explicit id always wins', () {
      expect(NuviFestivals.resolve('off', DateTime(2026, 12, 10)), isNull);
      expect(
        NuviFestivals.resolve('diwali', DateTime(2026, 6, 1))?.id,
        'diwali',
      );
    });

    test('Eid is manual only', () {
      final eid = NuviFestivals.byId('eid')!;
      for (var month = 1; month <= 12; month++) {
        expect(eid.contains(DateTime(2026, month, 15)), isFalse);
      }
    });
  });

  group('NuviThemeX', () {
    test('day theme uses the base palette and Baloo 2 headings', () {
      final x = NuviTheme.build(null).extension<NuviThemeX>()!;
      expect(x.gold, NuviColors.gold);
      expect(x.headingFont, 'Baloo2');
      expect(x.isFestive, isFalse);
    });

    test('Christmas swaps accents and heading font', () {
      final x = NuviTheme.build(
        NuviFestivals.byId('christmas'),
      ).extension<NuviThemeX>()!;
      expect(x.gold, const Color(0xFFC0392B));
      expect(x.headingFont, 'MountainsofChristmas');
      expect(x.h1.fontFamily, 'MountainsofChristmas');
      expect(x.bagHeading, const Color(0xFF0F3D2E));
    });

    test('text on gold and small gold text stay readable', () {
      for (final festival in [null, ...NuviFestivals.all]) {
        final x = NuviThemeX.forFestival(festival);
        expect(_contrast(x.onGold, x.gold), greaterThanOrEqualTo(3.0));
        expect(
          _contrast(x.goldText, NuviColors.cream),
          greaterThanOrEqualTo(4.5),
        );
      }
    });
  });
}

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return ((la > lb ? la : lb) + 0.05) / ((la > lb ? lb : la) + 0.05);
}
