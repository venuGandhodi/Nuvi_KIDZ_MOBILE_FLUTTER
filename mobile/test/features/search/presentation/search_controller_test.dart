import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/home/domain/product.dart';
import 'package:nuvi_kidz/features/search/data/search_repository.dart';
import 'package:nuvi_kidz/features/search/domain/page_info.dart';
import 'package:nuvi_kidz/features/search/domain/search_filter_state.dart';
import 'package:nuvi_kidz/features/search/presentation/search_controller.dart';

class FakeSearchRepository implements SearchRepository {
  SearchResult? resultToReturn;
  bool shouldThrow = false;
  int searchCallCount = 0;
  String? lastAfter;

  @override
  Future<SearchResult> search({
    required SearchFilterState filterState,
    int first = 20,
    String? after,
  }) async {
    searchCallCount++;
    lastAfter = after;
    if (shouldThrow) {
      throw Exception('Server error');
    }
    return resultToReturn ??
        const SearchResult(
          products: [],
          pageInfo: PageInfo(hasNextPage: false),
        );
  }
}

void main() {
  late FakeSearchRepository fakeRepository;
  late ProviderContainer container;

  const sampleProduct = Product(
    id: 'prod_1',
    title: 'Dream Romper',
    price: '₹799',
  );

  const sampleProduct2 = Product(
    id: 'prod_2',
    title: 'Knit Cardigan',
    price: '₹1,299',
  );

  setUp(() {
    fakeRepository = FakeSearchRepository();
    container = ProviderContainer(
      overrides: [searchRepositoryProvider.overrideWithValue(fakeRepository)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('SearchController Tests', () {
    test('1. Initial state is pristine', () {
      final state = container.read(searchControllerProvider);
      expect(state.query, '');
      expect(state.products, isEmpty);
      expect(state.isInitialState, isTrue);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    });

    test(
      '2. searchImmediately executes immediately without debounce delay',
      () async {
        fakeRepository.resultToReturn = const SearchResult(
          products: [sampleProduct],
          pageInfo: PageInfo(hasNextPage: false),
        );

        final controller = container.read(searchControllerProvider.notifier);
        controller.searchImmediately('romper');

        // Wait microtasks
        await Future<void>.delayed(const Duration(milliseconds: 10));

        final state = container.read(searchControllerProvider);
        expect(state.query, 'romper');
        expect(state.products.length, 1);
        expect(state.products.first.title, 'Dream Romper');
        expect(state.isLoading, isFalse);
        expect(state.isInitialState, isFalse);
        expect(fakeRepository.searchCallCount, 1);
      },
    );

    test(
      '3. search with 300ms debounce fires only once for rapid typing',
      () async {
        fakeRepository.resultToReturn = const SearchResult(
          products: [sampleProduct],
          pageInfo: PageInfo(hasNextPage: false),
        );

        final controller = container.read(searchControllerProvider.notifier);
        controller.search('r');
        controller.search('ro');
        controller.search('rom');
        controller.search('romper');

        expect(fakeRepository.searchCallCount, 0);

        // Advance clock past 300ms
        await Future<void>.delayed(const Duration(milliseconds: 350));

        expect(fakeRepository.searchCallCount, 1);
        final state = container.read(searchControllerProvider);
        expect(state.query, 'romper');
        expect(state.products.length, 1);
      },
    );

    test('4. clearSearch resets state to initial', () async {
      fakeRepository.resultToReturn = const SearchResult(
        products: [sampleProduct],
        pageInfo: PageInfo(hasNextPage: false),
      );

      final controller = container.read(searchControllerProvider.notifier);
      controller.searchImmediately('romper');
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(container.read(searchControllerProvider).products, isNotEmpty);

      controller.clearSearch();

      final state = container.read(searchControllerProvider);
      expect(state.query, '');
      expect(state.products, isEmpty);
      expect(state.isInitialState, isTrue);
    });

    test(
      '5. applyFilters triggers search immediately with updated filter state',
      () async {
        fakeRepository.resultToReturn = const SearchResult(
          products: [sampleProduct],
          pageInfo: PageInfo(hasNextPage: false),
        );

        const filter = SearchFilterState(
          category: 'Rompers',
          inStockOnly: true,
        );

        final controller = container.read(searchControllerProvider.notifier);
        controller.applyFilters(filter);
        await Future<void>.delayed(const Duration(milliseconds: 10));

        final state = container.read(searchControllerProvider);
        expect(state.selectedFilters.category, 'Rompers');
        expect(state.selectedFilters.inStockOnly, isTrue);
        expect(fakeRepository.searchCallCount, 1);
      },
    );

    test('6. changeSort updates sortOption and executes search', () async {
      fakeRepository.resultToReturn = const SearchResult(
        products: [sampleProduct],
        pageInfo: PageInfo(hasNextPage: false),
      );

      final controller = container.read(searchControllerProvider.notifier);
      controller.changeSort(SearchSortOption.priceLowHigh);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final state = container.read(searchControllerProvider);
      expect(state.sortOption, SearchSortOption.priceLowHigh);
      expect(fakeRepository.searchCallCount, 1);
    });

    test(
      '7. loadMore appends new products and updates pagination state',
      () async {
        fakeRepository.resultToReturn = const SearchResult(
          products: [sampleProduct],
          pageInfo: PageInfo(hasNextPage: true, endCursor: 'cur_page_1'),
        );

        final controller = container.read(searchControllerProvider.notifier);
        controller.searchImmediately('romper');
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(container.read(searchControllerProvider).products.length, 1);
        expect(container.read(searchControllerProvider).hasNextPage, isTrue);

        fakeRepository.resultToReturn = const SearchResult(
          products: [sampleProduct2],
          pageInfo: PageInfo(hasNextPage: false, endCursor: 'cur_page_2'),
        );

        await controller.loadMore();

        final state = container.read(searchControllerProvider);
        expect(state.products.length, 2);
        expect(state.products[1].title, 'Knit Cardigan');
        expect(state.hasNextPage, isFalse);
        expect(fakeRepository.lastAfter, 'cur_page_1');
      },
    );

    test(
      '8. Error during search sets friendly errorMessage and retry succeeds',
      () async {
        fakeRepository.shouldThrow = true;

        final controller = container.read(searchControllerProvider.notifier);
        controller.searchImmediately('error_test');
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(
          container.read(searchControllerProvider).errorMessage,
          "We couldn't load products right now.",
        );
        expect(container.read(searchControllerProvider).isLoading, isFalse);

        fakeRepository.shouldThrow = false;
        fakeRepository.resultToReturn = const SearchResult(
          products: [sampleProduct],
          pageInfo: PageInfo(hasNextPage: false),
        );

        controller.retry();
        await Future<void>.delayed(const Duration(milliseconds: 10));

        final state = container.read(searchControllerProvider);
        expect(state.errorMessage, isNull);
        expect(state.products.length, 1);
      },
    );
  });
}
