import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/category/data/shopify_category_repository.dart';
import 'package:nuvi_kidz/features/category/domain/category_filter.dart';
import 'package:nuvi_kidz/features/category/domain/collection_filter.dart';
import 'package:nuvi_kidz/features/category/presentation/category_controller.dart';
import 'package:nuvi_kidz/features/category/presentation/widgets/quick_add_size_sheet.dart';
import 'package:nuvi_kidz/features/home/domain/product.dart';
import 'package:nuvi_kidz/features/product/domain/product_color.dart';
import 'package:nuvi_kidz/features/product/domain/product_variant.dart';

void main() {
  productFilterTests();

  group('CollectionFilterKind.of', () {
    test('maps Shopify filter labels to filter groups', () {
      expect(CollectionFilterKind.of('Age', 'LIST'), CollectionFilterKind.age);
      expect(CollectionFilterKind.of('Size', 'LIST'), CollectionFilterKind.age);
      expect(
        CollectionFilterKind.of('Colour', 'LIST'),
        CollectionFilterKind.color,
      );
      expect(
        CollectionFilterKind.of('Gender', 'LIST'),
        CollectionFilterKind.gender,
      );
      expect(
        CollectionFilterKind.of('Product type', 'LIST'),
        CollectionFilterKind.category,
      );
      expect(
        CollectionFilterKind.of('Delivery time', 'LIST'),
        CollectionFilterKind.delivery,
      );
      expect(
        CollectionFilterKind.of('Price', 'PRICE_RANGE'),
        CollectionFilterKind.price,
      );
      expect(CollectionFilterKind.of('Vendor', 'LIST'), isNull);
    });
  });

  group('isGenderSpecificCollection', () {
    test('detects boys and girls collections', () {
      expect(isGenderSpecificCollection('Boys', 'boys'), isTrue);
      expect(isGenderSpecificCollection('Girls Dresses', null), isTrue);
      expect(isGenderSpecificCollection(null, 'boys-shirts'), isTrue);
    });

    test('treats other collections as generic', () {
      expect(isGenderSpecificCollection('Winter Collection', 'winter'), false);
      expect(isGenderSpecificCollection('New Born', 'new-born'), false);
      expect(isGenderSpecificCollection('Tomboy Style', 'tomboy'), false);
    });
  });

  test('price bands carry Shopify price inputs', () {
    final under500 = jsonDecode(CollectionFilterValue.priceBands.first.input);
    expect(under500, {
      'price': {'min': 0, 'max': 499},
    });
    final top = jsonDecode(CollectionFilterValue.priceBands.last.input);
    expect(top, {
      'price': {'min': 2000},
    });
  });

  group('ShopifyCategoryRepository filters', () {
    test('parses filters and drops empty values', () {
      final filters = ShopifyCategoryRepository.parseCollectionFilters([
        {
          'id': 'filter.v.option.age',
          'label': 'Age',
          'type': 'LIST',
          'values': [
            {
              'id': 'a1',
              'label': '0 – 2Y',
              'count': 4,
              'input': '{"variantOption":{"name":"age","value":"0 – 2Y"}}',
            },
            {'id': 'a2', 'label': '3 – 5Y', 'count': 0, 'input': '{}'},
          ],
        },
      ]);
      expect(filters.single.kind, CollectionFilterKind.age);
      expect(filters.single.values.single.label, '0 – 2Y');
      expect(filters.single.values.single.count, 4);
    });

    test('maps sort options to Shopify sort keys', () {
      expect(
        ShopifyCategoryRepository.collectionSortKey(SortOption.priceHighToLow),
        ('PRICE', true),
      );
      expect(ShopifyCategoryRepository.collectionSortKey(SortOption.newest), (
        'CREATED',
        true,
      ));
    });
  });

  group('CategoryState filter options', () {
    test('hides Gender in a boys collection', () {
      const state = CategoryState(categoryId: 'boys');
      expect(state.filterKinds, isNot(contains(CollectionFilterKind.gender)));
    });

    test('shows Gender in a generic collection', () {
      const state = CategoryState(categoryId: 'winter-collection');
      expect(state.filterKinds, contains(CollectionFilterKind.gender));
    });

    test('collects Shopify values for a group and tracks selections', () {
      const festive = CollectionFilterValue(
        id: 'o1',
        label: 'Festive',
        input: '{}',
      );
      const state = CategoryState(
        availableFilters: [
          CollectionFilter(
            id: 'f',
            label: 'Occasion',
            type: 'LIST',
            values: [festive],
          ),
        ],
        selectedFilters: [
          SelectedFilterValue(CollectionFilterKind.occasion, festive),
        ],
      );
      expect(state.valuesFor(CollectionFilterKind.occasion), [festive]);
      expect(state.selectedIdsFor(CollectionFilterKind.occasion), {'o1'});
      expect(state.valuesFor(CollectionFilterKind.price), hasLength(4));
      expect(state.selectedFilters.single.chipLabel, 'Occasion: Festive');
    });
  });
}

const _red = ProductColor(id: 'red', name: 'Red', color: Color(0xFFD32F2F));
const _blue = ProductColor(id: 'blue', name: 'Blue', color: Color(0xFF1976D2));

Product _p(
  String id, {
  List<ProductColor>? colors,
  List<String>? sizes,
  String? type,
  List<ProductVariant>? variants,
}) => Product(
  id: id,
  title: id,
  price: '₹999',
  availableColors: colors,
  availableSizes: sizes,
  productType: type,
  variants: variants,
);

void productFilterTests() {
  final shirt = _p(
    'shirt',
    colors: [_red],
    sizes: ['0-2Y', '3-5Y'],
    type: 'Shirts',
  );
  final dress = _p(
    'dress',
    colors: [_red, _blue],
    sizes: ['3-5Y'],
    type: 'Dresses',
  );
  final all = [shirt, dress];

  group('product-based filters', () {
    test('collects colours, sizes and categories from products', () {
      final colors = productFilterValues(CollectionFilterKind.color, all);
      expect(colors.map((v) => (v.label, v.count)), [('Blue', 1), ('Red', 2)]);
      final ages = productFilterValues(CollectionFilterKind.age, all);
      expect(ages.map((v) => v.label), ['0-2Y', '3-5Y']);
      final cats = productFilterValues(CollectionFilterKind.category, all);
      expect(cats.map((v) => v.label), ['Dresses', 'Shirts']);
    });

    test('filters with OR inside a group and AND across groups', () {
      SelectedFilterValue sel(CollectionFilterKind k, String label) =>
          SelectedFilterValue(
            k,
            CollectionFilterValue(
              id: '${k.name}:$label',
              label: label,
              input: '',
            ),
          );
      expect(
        filterProductsLocally(all, [sel(CollectionFilterKind.color, 'Blue')]),
        [dress],
      );
      expect(
        filterProductsLocally(all, [
          sel(CollectionFilterKind.color, 'Red'),
          sel(CollectionFilterKind.age, '0-2Y'),
        ]),
        [shirt],
      );
      expect(
        filterProductsLocally(all, [
          sel(CollectionFilterKind.category, 'Shirts'),
          sel(CollectionFilterKind.category, 'Dresses'),
        ]),
        all,
      );
    });

    test('CategoryState shows only matching products', () {
      final state = CategoryState(
        products: all,
        selectedFilters: [
          SelectedFilterValue(
            CollectionFilterKind.color,
            const CollectionFilterValue(
              id: 'color:Blue',
              label: 'Blue',
              input: '',
            ),
          ),
        ],
      );
      expect(state.allProducts, hasLength(2));
      expect(state.products, [dress]);
      expect(state.valuesFor(CollectionFilterKind.color), hasLength(2));
    });
  });

  group('quickAddSizes', () {
    test('marks sizes with no stock as sold out', () {
      final p = _p(
        'p',
        sizes: ['S', 'M'],
        variants: const [
          ProductVariant(id: 'v1', title: 'S', priceAmount: 1, size: 'S'),
          ProductVariant(
            id: 'v2',
            title: 'M',
            priceAmount: 1,
            size: 'M',
            availableForSale: false,
          ),
        ],
      );
      final sizes = quickAddSizes(p);
      expect(sizes.map((s) => s.$1), ['S', 'M']);
      expect(sizes.first.$2?.id, 'v1');
      expect(sizes.last.$2, isNull);
    });

    test('returns nothing for products without sizes', () {
      expect(quickAddSizes(_p('p')), isEmpty);
    });
  });
}
