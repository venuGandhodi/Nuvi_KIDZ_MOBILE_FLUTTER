import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/cart/data/cart_repository.dart';
import 'package:nuvi_kidz/features/cart/domain/cart_item.dart';
import 'package:nuvi_kidz/features/home/domain/product.dart';
import 'package:nuvi_kidz/features/product/domain/product_color.dart';

void main() {
  late MockCartRepository repository;

  final sampleProduct = const Product(
    id: 'p1',
    title: 'Test Romper',
    price: '\$30.00',
  );

  final colorSage = const ProductColor(
    id: 'sage',
    name: 'Sage',
    color: Colors.green,
  );

  final colorMustard = const ProductColor(
    id: 'mustard',
    name: 'Mustard',
    color: Colors.yellow,
  );

  setUp(() {
    repository = MockCartRepository();
  });

  group('MockCartRepository Tests', () {
    test('initial cart is empty', () async {
      final items = await repository.getCartItems();
      expect(items, isEmpty);
    });

    test('addItem adds new line item', () async {
      final item = CartItem(
        id: 'c1',
        product: sampleProduct,
        selectedColor: colorSage,
        selectedSize: '12-18M',
        quantity: 1,
        unitPrice: 30.0,
      );

      final items = await repository.addItem(item);
      expect(items.length, equals(1));
      expect(items.first.quantity, equals(1));
    });

    test('addItem merges quantity for exact same variant', () async {
      final item1 = CartItem(
        id: 'c1',
        product: sampleProduct,
        selectedColor: colorSage,
        selectedSize: '12-18M',
        quantity: 1,
        unitPrice: 30.0,
      );

      final item2 = CartItem(
        id: 'c2',
        product: sampleProduct,
        selectedColor: colorSage,
        selectedSize: '12-18M',
        quantity: 2,
        unitPrice: 30.0,
      );

      await repository.addItem(item1);
      final items = await repository.addItem(item2);

      expect(items.length, equals(1));
      expect(items.first.quantity, equals(3));
    });

    test('addItem creates separate line item for different variant', () async {
      final item1 = CartItem(
        id: 'c1',
        product: sampleProduct,
        selectedColor: colorSage,
        selectedSize: '12-18M',
        quantity: 1,
        unitPrice: 30.0,
      );

      final item2 = CartItem(
        id: 'c2',
        product: sampleProduct,
        selectedColor: colorMustard,
        selectedSize: '12-18M',
        quantity: 1,
        unitPrice: 30.0,
      );

      await repository.addItem(item1);
      final items = await repository.addItem(item2);

      expect(items.length, equals(2));
    });

    test('updateQuantity updates or removes item when quantity <= 0', () async {
      final item = CartItem(
        id: 'c1',
        product: sampleProduct,
        selectedColor: colorSage,
        selectedSize: '12-18M',
        quantity: 2,
        unitPrice: 30.0,
      );

      await repository.addItem(item);
      var items = await repository.updateQuantity('c1', 5);
      expect(items.first.quantity, equals(5));

      items = await repository.updateQuantity('c1', 0);
      expect(items, isEmpty);
    });

    test('removeItem and clearCart work correctly', () async {
      final item = CartItem(
        id: 'c1',
        product: sampleProduct,
        selectedColor: colorSage,
        selectedSize: '12-18M',
        quantity: 1,
        unitPrice: 30.0,
      );

      await repository.addItem(item);
      var items = await repository.removeItem('c1');
      expect(items, isEmpty);

      await repository.addItem(item);
      items = await repository.clearCart();
      expect(items, isEmpty);
    });
  });
}
