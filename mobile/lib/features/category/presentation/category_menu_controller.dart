import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/menu_category.dart';
import 'category_controller.dart';

class CategoryMenuState {
  final List<MenuCategory> categories;
  final String? selectedCategoryId;
  final bool isLoading;
  final String? errorMessage;

  const CategoryMenuState({
    this.categories = const [],
    this.selectedCategoryId,
    this.isLoading = false,
    this.errorMessage,
  });

  MenuCategory? get selected {
    for (final category in categories) {
      if (category.id == selectedCategoryId) return category;
    }
    return categories.isNotEmpty ? categories.first : null;
  }

  CategoryMenuState copyWith({
    List<MenuCategory>? categories,
    String? selectedCategoryId,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CategoryMenuState(
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class CategoryMenuController extends Notifier<CategoryMenuState> {
  @override
  CategoryMenuState build() {
    return const CategoryMenuState(isLoading: true);
  }

  Future<void> loadMenu() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repository = ref.read(categoryRepositoryProvider);
      final categories = await repository.getCategoryMenu();
      state = state.copyWith(
        categories: categories,
        selectedCategoryId: categories.isNotEmpty ? categories.first.id : null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load categories.',
      );
    }
  }

  void selectCategory(String id) {
    state = state.copyWith(selectedCategoryId: id);
  }
}

final categoryMenuControllerProvider =
    NotifierProvider<CategoryMenuController, CategoryMenuState>(() {
      return CategoryMenuController();
    });
