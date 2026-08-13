import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/cart/presentation/cart_controller.dart';
import 'package:nuvi_kidz/features/home/domain/product.dart';

void main() {
  late ProviderContainer container;

  final sampleProduct = const Product(
    id: 'p1',
    title: 'Test Romper',
    price: '\$34.00',
  );

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('CartController Tests', () {
    test('initial state is empty after loadCart', () async {
      final controller = container.read(cartControllerProvider.notifier);
      await controller.loadCart();
      final state = container.read(cartControllerProvider);

      expect(state.isLoading, isFalse);
      expect(state.items, isEmpty);
      expect(state.totalItemCount, equals(0));
      expect(state.subtotal, equals(0.0));
      expect(state.shippingCost, equals(0.0));
      expect(state.grandTotal, equals(0.0));
    });

    test(
      'addItem updates state, totalItemCount, and pricing calculations',
      () async {
        final controller = container.read(cartControllerProvider.notifier);
        await controller.loadCart();
        await controller.addItem(
          product: sampleProduct,
          selectedSize: '12-18M',
          quantity: 2,
        );

        final state = container.read(cartControllerProvider);
        expect(state.items.length, equals(1));
        expect(state.totalItemCount, equals(2));
        expect(state.subtotal, equals(68.0));
        expect(state.shippingCost, equals(5.0));
        expect(state.estimatedTax, equals(68.0 * 0.08));
        expect(state.grandTotal, equals(68.0 + 5.0 + (68.0 * 0.08)));
      },
    );

    test('updateQuantity and removeItem update calculations', () async {
      final controller = container.read(cartControllerProvider.notifier);
      await controller.loadCart();
      await controller.addItem(
        product: sampleProduct,
        selectedSize: '12-18M',
        quantity: 1,
      );

      var state = container.read(cartControllerProvider);
      final itemId = state.items.first.id;

      await controller.updateQuantity(itemId, 3);
      state = container.read(cartControllerProvider);
      expect(state.totalItemCount, equals(3));
      expect(state.subtotal, equals(102.0));

      await controller.removeItem(itemId);
      state = container.read(cartControllerProvider);
      expect(state.items, isEmpty);
      expect(state.totalItemCount, equals(0));
      expect(state.subtotal, equals(0.0));
    });
  });
}
