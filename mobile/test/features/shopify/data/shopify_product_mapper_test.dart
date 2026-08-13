import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/shopify/data/shopify_product_mapper.dart';

void main() {
  group('ShopifyProductMapper Tests', () {
    test(
      'mapToProduct maps title, handle, prices, variants, and colors correctly',
      () {
        final sampleJson = {
          'id': 'gid://shopify/Product/101',
          'title': 'Boys Check Shirt',
          'handle': 'boys-check-shirt',
          'descriptionHtml': '<p>100% Cotton shirt</p>',
          'images': {
            'edges': [
              {
                'node': {
                  'url': 'https://cdn.shopify.com/s/files/shirt.jpg',
                  'altText': 'Shirt Image',
                },
              },
            ],
          },
          'variants': {
            'edges': [
              {
                'node': {
                  'id': 'gid://shopify/ProductVariant/9991',
                  'title': '3-4Y / Red',
                  'availableForSale': true,
                  'price': {'amount': '899.0', 'currencyCode': 'INR'},
                  'compareAtPrice': {'amount': '1299.0', 'currencyCode': 'INR'},
                  'selectedOptions': [
                    {'name': 'Size', 'value': '3-4Y'},
                    {'name': 'Color', 'value': 'Red'},
                  ],
                },
              },
            ],
          },
        };

        final product = ShopifyProductMapper.mapToProduct(sampleJson);

        expect(product.id, equals('boys-check-shirt'));
        expect(product.handle, equals('boys-check-shirt'));
        expect(product.title, equals('Boys Check Shirt'));
        expect(product.description, equals('100% Cotton shirt'));
        expect(
          product.imageUrl,
          equals('https://cdn.shopify.com/s/files/shirt.jpg'),
        );

        expect(product.salePrice, equals('₹899'));
        expect(product.compareAtPrice, equals('₹1299'));

        expect(product.variants, isNotNull);
        expect(product.variants!.length, equals(1));
        expect(
          product.variants!.first.id,
          equals('gid://shopify/ProductVariant/9991'),
        );
        expect(product.variants!.first.size, equals('3-4Y'));
        expect(product.variants!.first.color, equals('Red'));
        expect(product.variants!.first.availableForSale, isTrue);

        expect(product.availableColors, isNotNull);
        expect(product.availableColors!.first.name, equals('Red'));
        expect(product.availableSizes, contains('3-4Y'));
      },
    );

    test(
      'mapToProduct gracefully uses fallback image when product images are empty',
      () {
        final sampleJson = {
          'id': 'gid://shopify/Product/102',
          'title': 'Boys Dino T-Shirt',
          'handle': 'boys-dino-tshirt',
          'images': {'edges': []},
          'variants': {
            'edges': [
              {
                'node': {
                  'id': 'gid://shopify/ProductVariant/9992',
                  'title': 'Default Title',
                  'availableForSale': true,
                  'price': {'amount': '499.0', 'currencyCode': 'INR'},
                },
              },
            ],
          },
        };

        final product = ShopifyProductMapper.mapToProduct(sampleJson);

        expect(product.imageUrl, equals(ShopifyProductMapper.fallbackImageUrl));
        expect(product.images, contains(ShopifyProductMapper.fallbackImageUrl));
        expect(product.price, equals('₹499'));
      },
    );

    test('mapToHomeHero parses metaobject fields correctly', () {
      final sampleHeroJson = {
        'id': 'gid://shopify/Metaobject/888',
        'fields': [
          {'key': 'title', 'value': 'Spring Sunshine Collection'},
          {'key': 'description', 'value': 'Light, airy organic styles.'},
          {'key': 'button_text', 'value': 'Discover Now'},
          {'key': 'collection_handle', 'value': 'girls-clothing'},
          {'key': 'is_active', 'value': 'true'},
          {
            'key': 'image',
            'reference': {
              'image': {
                'url': 'https://cdn.shopify.com/s/files/hero.jpg',
                'altText': 'Hero Banner',
              },
            },
          },
        ],
      };

      final hero = ShopifyProductMapper.mapToHomeHero(sampleHeroJson);

      expect(hero.id, equals('gid://shopify/Metaobject/888'));
      expect(hero.title, equals('Spring Sunshine Collection'));
      expect(hero.description, equals('Light, airy organic styles.'));
      expect(hero.buttonText, equals('Discover Now'));
      expect(hero.collectionHandle, equals('girls-clothing'));
      expect(hero.isActive, isTrue);
      expect(hero.imageUrl, equals('https://cdn.shopify.com/s/files/hero.jpg'));
    });

    test('mapToCategory extracts collection image when present', () {
      final sampleCategoryJson = {
        'id': 'gid://shopify/Collection/1234',
        'title': 'Boys Clothing',
        'handle': 'boys-clothing',
        'image': {
          'url': 'https://cdn.shopify.com/s/files/boys_cat.jpg',
          'altText': 'Boys Category',
        },
      };

      final category = ShopifyProductMapper.mapToCategory(sampleCategoryJson);

      expect(category.id, equals('boys-clothing'));
      expect(category.name, equals('Boys Clothing'));
      expect(category.handle, equals('boys-clothing'));
      expect(
        category.imageUrl,
        equals('https://cdn.shopify.com/s/files/boys_cat.jpg'),
      );
    });
  });
}
