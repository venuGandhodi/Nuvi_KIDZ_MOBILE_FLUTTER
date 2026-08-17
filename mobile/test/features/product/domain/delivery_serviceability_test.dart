import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/product/domain/delivery_serviceability.dart';

void main() {
  group('DeliveryServiceabilityResult.fromJson', () {
    test('parses a serviceable result with an estimated delivery date', () {
      final result = DeliveryServiceabilityResult.fromJson({
        'serviceable': true,
        'pincode': '500081',
        'codAvailable': true,
        'prepaidAvailable': true,
        'estimatedDeliveryDate': '2026-08-22',
        'remarks': null,
      });

      expect(result.serviceable, isTrue);
      expect(result.pincode, '500081');
      expect(result.codAvailable, isTrue);
      expect(result.prepaidAvailable, isTrue);
      expect(result.estimatedDeliveryDate, DateTime.parse('2026-08-22'));
      expect(result.remarks, isNull);
    });

    test('parses a serviceable result with an unresolved TAT as null date', () {
      final result = DeliveryServiceabilityResult.fromJson({
        'serviceable': true,
        'pincode': '500081',
        'codAvailable': false,
        'prepaidAvailable': true,
        'estimatedDeliveryDate': null,
        'remarks': null,
      });

      expect(result.serviceable, isTrue);
      expect(result.codAvailable, isFalse);
      expect(result.estimatedDeliveryDate, isNull);
    });

    test('parses a non-serviceable result', () {
      final result = DeliveryServiceabilityResult.fromJson({
        'serviceable': false,
        'pincode': '999999',
        'codAvailable': false,
        'prepaidAvailable': false,
        'estimatedDeliveryDate': null,
        'remarks': 'Embargo',
      });

      expect(result.serviceable, isFalse);
      expect(result.remarks, 'Embargo');
    });

    test('defaults missing fields to safe non-serviceable values', () {
      final result = DeliveryServiceabilityResult.fromJson(const {});

      expect(result.serviceable, isFalse);
      expect(result.pincode, '');
      expect(result.codAvailable, isFalse);
      expect(result.prepaidAvailable, isFalse);
      expect(result.estimatedDeliveryDate, isNull);
    });
  });
}
