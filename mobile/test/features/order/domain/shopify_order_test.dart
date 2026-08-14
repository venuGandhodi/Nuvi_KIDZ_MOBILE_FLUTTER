import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/order/domain/shopify_order.dart';

void main() {
  group('ShopifyOrder Domain Model Tests', () {
    test('fromJson parses complete Shopify Order GraphQL payload', () {
      final json = {
        'id': 'gid://shopify/Order/1001',
        'name': '#1001',
        'orderNumber': 1001,
        'processedAt': '2026-08-14T10:00:00Z',
        'financialStatus': 'PAID',
        'fulfillmentStatus': 'UNFULFILLED',
        'currentTotalPrice': {'amount': '1299.00', 'currencyCode': 'INR'},
        'currentTotalTax': {'amount': '233.82', 'currencyCode': 'INR'},
        'totalShippingPrice': {'amount': '0.00', 'currencyCode': 'INR'},
        'lineItems': {
          'edges': [
            {
              'node': {
                'id': 'gid://shopify/LineItem/2001',
                'title': 'Nuvi Dream Romper',
                'quantity': 1,
                'originalTotalPrice': {
                  'amount': '1299.00',
                  'currencyCode': 'INR',
                },
                'variant': {
                  'title': '0-3M / Sky Blue',
                  'image': {'url': 'https://cdn.shopify.com/image.jpg'},
                },
              },
            },
          ],
        },
      };

      final order = ShopifyOrder.fromJson(json);

      expect(order.id, equals('gid://shopify/Order/1001'));
      expect(order.name, equals('#1001'));
      expect(order.orderNumber, equals(1001));
      expect(order.financialStatus, equals('PAID'));
      expect(order.fulfillmentStatus, equals('UNFULFILLED'));
      expect(order.currentTotalPrice.amount, equals(1299.00));
      expect(order.currentTotalPrice.currencyCode, equals('INR'));
      expect(order.currentTotalTax?.amount, equals(233.82));
      expect(order.lineItems.length, equals(1));
      expect(order.lineItems.first.title, equals('Nuvi Dream Romper'));
      expect(order.lineItems.first.variantTitle, equals('0-3M / Sky Blue'));
      expect(order.lineItems.first.originalTotalPrice.amount, equals(1299.00));
    });
  });
}
