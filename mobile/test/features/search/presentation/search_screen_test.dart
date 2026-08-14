import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/core/widgets/nuvi_product_card.dart';
import 'package:nuvi_kidz/features/home/domain/product.dart';
import 'package:nuvi_kidz/features/search/data/search_repository.dart';
import 'package:nuvi_kidz/features/search/domain/page_info.dart';
import 'package:nuvi_kidz/features/search/domain/search_filter_state.dart';
import 'package:nuvi_kidz/features/search/presentation/search_controller.dart';
import 'package:nuvi_kidz/features/search/presentation/search_screen.dart';

class MockSearchRepository implements SearchRepository {
  SearchResult searchResult = const SearchResult(
    products: [],
    pageInfo: PageInfo(hasNextPage: false),
  );
  bool shouldDelay = false;

  @override
  Future<SearchResult> search({
    required SearchFilterState filterState,
    int first = 20,
    String? after,
  }) async {
    if (shouldDelay) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    return searchResult;
  }
}

void main() {
  late MockSearchRepository mockRepository;

  const sampleProduct = Product(
    id: 'prod_dream_romper',
    title: 'Organic Cotton Dream Romper',
    price: '₹799',
    salePrice: '₹799',
    rating: 5.0,
  );

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [searchRepositoryProvider.overrideWithValue(mockRepository)],
      child: const MaterialApp(home: SearchScreen()),
    );
  }

  setUp(() {
    mockRepository = MockSearchRepository();
  });

  group('SearchScreen Widget Tests', () {
    testWidgets(
      '1. Renders search input field and quick suggestions initially',
      (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        expect(find.byType(TextField), findsOneWidget);
        expect(
          find.text('Search products, colors, and styles'),
          findsOneWidget,
        );
        expect(find.text('Quick Suggestions'), findsOneWidget);
        expect(find.text('Rompers'), findsOneWidget);
        expect(find.text('Dresses'), findsOneWidget);
        expect(find.text('Cardigans'), findsOneWidget);
      },
    );

    testWidgets(
      '2. Tapping a quick suggestion executes search and updates text field',
      (tester) async {
        mockRepository.searchResult = const SearchResult(
          products: [sampleProduct],
          pageInfo: PageInfo(hasNextPage: false),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        await tester.tap(find.text('Rompers'));
        await tester.pumpAndSettle();

        expect(find.text('1 style found'), findsOneWidget);
        expect(find.byType(NuviProductCard), findsOneWidget);
        expect(find.text('Organic Cotton Dream Romper'), findsOneWidget);
        expect(find.text('₹799'), findsWidgets);
      },
    );

    testWidgets('3. Renders empty search result state when no items match', (
      tester,
    ) async {
      mockRepository.searchResult = const SearchResult(
        products: [],
        pageInfo: PageInfo(hasNextPage: false),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'xyznonexistent');
      // Wait for debounce and async completion
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.text('No products found'), findsOneWidget);
      expect(find.text('Clear Search'), findsOneWidget);
    });

    testWidgets('4. Clear button in search bar resets back to initial state', (
      tester,
    ) async {
      mockRepository.searchResult = const SearchResult(
        products: [sampleProduct],
        pageInfo: PageInfo(hasNextPage: false),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'romper');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.byType(NuviProductCard), findsOneWidget);

      // Find clear icon button
      final clearButton = find.byIcon(Icons.clear);
      expect(clearButton, findsOneWidget);
      await tester.tap(clearButton);
      await tester.pumpAndSettle();

      expect(find.text('Quick Suggestions'), findsOneWidget);
      expect(find.byType(NuviProductCard), findsNothing);
    });

    testWidgets('5. Tapping Filters & Sort opens the filter bottom sheet', (
      tester,
    ) async {
      mockRepository.searchResult = const SearchResult(
        products: [sampleProduct],
        pageInfo: PageInfo(hasNextPage: false),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'romper');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Filters & Sort'));
      await tester.pumpAndSettle();

      expect(find.text('Sort By'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('In Stock Only'), findsOneWidget);
      expect(find.text('Apply Filters'), findsOneWidget);
    });
  });
}
