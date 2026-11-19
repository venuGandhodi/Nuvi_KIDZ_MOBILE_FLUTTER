import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/category/data/shopify_category_repository.dart';
import 'package:nuvi_kidz/features/category/domain/category_filter.dart';
import 'package:nuvi_kidz/features/category/domain/collection_filter.dart';
import 'package:nuvi_kidz/features/category/presentation/category_controller.dart';

void main() {
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

    test('collects values for a group and tracks selections', () {
      const age = CollectionFilterValue(id: 'a1', label: '0 – 2Y', input: '{}');
      const state = CategoryState(
        availableFilters: [
          CollectionFilter(id: 'f', label: 'Age', type: 'LIST', values: [age]),
        ],
        selectedFilters: [SelectedFilterValue(CollectionFilterKind.age, age)],
      );
      expect(state.valuesFor(CollectionFilterKind.age), [age]);
      expect(state.selectedIdsFor(CollectionFilterKind.age), {'a1'});
      expect(state.valuesFor(CollectionFilterKind.price), hasLength(4));
      expect(state.selectedFilters.single.chipLabel, 'Age: 0 – 2Y');
    });
  });
}
