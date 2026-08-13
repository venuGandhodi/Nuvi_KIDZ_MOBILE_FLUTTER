import '../domain/age_filter.dart';
import '../domain/category.dart';
import '../domain/home_hero.dart';
import '../domain/product.dart';
import 'mock_home_data.dart';

abstract class HomeRepository {
  Future<HomeHero?> getHero();
  Future<List<Category>> getCategories();
  Future<List<AgeFilter>> getAgeFilters();
  Future<List<Product>> getBestSellers();
}

class MockHomeRepository implements HomeRepository {
  @override
  Future<HomeHero?> getHero() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return MockHomeData.defaultHero;
  }

  @override
  Future<List<Category>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return MockHomeData.categories;
  }

  @override
  Future<List<AgeFilter>> getAgeFilters() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return MockHomeData.ageFilters;
  }

  @override
  Future<List<Product>> getBestSellers() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return MockHomeData.bestSellers;
  }
}
