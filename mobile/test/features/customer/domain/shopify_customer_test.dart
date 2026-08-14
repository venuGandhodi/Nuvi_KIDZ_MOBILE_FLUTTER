import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/customer/domain/shopify_customer.dart';

void main() {
  group('ShopifyCustomer Domain Model Tests', () {
    test(
      'fromJson parses customer profile, addresses, and orders correctly',
      () {
        final json = {
          'id': 'gid://shopify/Customer/12345',
          'firstName': 'Jane',
          'lastName': 'Doe',
          'displayName': 'Jane Doe',
          'email': 'jane.doe@example.com',
          'phone': '+919876543210',
          'defaultAddress': {
            'id': 'gid://shopify/MailingAddress/54321',
            'address1': '123 Palm Street',
            'address2': 'Apt 4B',
            'city': 'Bengaluru',
            'province': 'Karnataka',
            'zip': '560001',
            'country': 'India',
            'phone': '+919876543210',
          },
          'addresses': {
            'edges': [
              {
                'node': {
                  'id': 'gid://shopify/MailingAddress/54321',
                  'address1': '123 Palm Street',
                  'city': 'Bengaluru',
                  'province': 'Karnataka',
                  'zip': '560001',
                  'country': 'India',
                },
              },
            ],
          },
          'orders': {
            'edges': [
              {
                'node': {
                  'id': 'gid://shopify/Order/1001',
                  'name': '#1001',
                  'orderNumber': 1001,
                  'processedAt': '2026-08-14T10:00:00Z',
                  'financialStatus': 'PAID',
                  'fulfillmentStatus': 'UNFULFILLED',
                  'currentTotalPrice': {
                    'amount': '1299.00',
                    'currencyCode': 'INR',
                  },
                  'lineItems': {
                    'edges': [
                      {
                        'node': {
                          'id': 'gid://shopify/LineItem/2001',
                          'title': 'Dino T-Shirt',
                          'quantity': 1,
                          'originalTotalPrice': {
                            'amount': '1299.00',
                            'currencyCode': 'INR',
                          },
                        },
                      },
                    ],
                  },
                },
              },
            ],
          },
        };

        final customer = ShopifyCustomer.fromJson(json);

        expect(customer.id, equals('gid://shopify/Customer/12345'));
        expect(customer.firstName, equals('Jane'));
        expect(customer.lastName, equals('Doe'));
        expect(customer.fullName, equals('Jane Doe'));
        expect(customer.email, equals('jane.doe@example.com'));
        expect(customer.phone, equals('+919876543210'));

        expect(customer.defaultAddress, isNotNull);
        expect(customer.defaultAddress!.city, equals('Bengaluru'));
        expect(
          customer.defaultAddress!.formattedAddress,
          contains(
            '123 Palm Street, Apt 4B, Bengaluru, Karnataka, 560001, India',
          ),
        );

        expect(customer.addresses.length, equals(1));
        expect(customer.orders.length, equals(1));
        expect(customer.orders.first.name, equals('#1001'));
        expect(customer.orders.first.currentTotalPrice.amount, equals(1299.00));
      },
    );

    test(
      'fromJson parses sanitized Edge Function JSON list format correctly',
      () {
        final edgeJson = {
          'id': 'gid://shopify/Customer/888',
          'firstName': 'Anita',
          'lastName': 'Roy',
          'displayName': 'Anita Roy',
          'email': 'anita@example.com',
          'addresses': [
            {
              'id': 'gid://shopify/MailingAddress/1',
              'address1': '45 Lake View Road',
              'city': 'Mumbai',
            },
          ],
          'orders': [
            {
              'id': 'gid://shopify/Order/55',
              'name': '#1055',
              'currentTotalPrice': {'amount': 899.0, 'currencyCode': 'INR'},
            },
          ],
          'ordersCount': 1,
        };

        final customer = ShopifyCustomer.fromJson(edgeJson);
        expect(customer.id, 'gid://shopify/Customer/888');
        expect(customer.fullName, 'Anita Roy');
        expect(customer.addresses.length, 1);
        expect(customer.addresses.first.city, 'Mumbai');
        expect(customer.orders.length, 1);
        expect(customer.ordersCount, 1);
      },
    );

    test('fullName falls back gracefully when name fields are missing', () {
      final customer = const ShopifyCustomer(
        id: '1',
        email: 'parent@example.com',
      );

      expect(customer.fullName, equals('parent'));
    });
  });
}
