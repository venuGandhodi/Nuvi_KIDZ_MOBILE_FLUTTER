import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/nuvi_colors.dart';
import '../../../core/widgets/nuvi_loading_indicator.dart';
import 'category_listing_screen.dart';
import 'category_menu_controller.dart';

/// Shop tab: the category explorer opened on the first shoppable menu item.
class ShopTabScreen extends ConsumerStatefulWidget {
  const ShopTabScreen({super.key});

  @override
  ConsumerState<ShopTabScreen> createState() => _ShopTabScreenState();
}

class _ShopTabScreenState extends ConsumerState<ShopTabScreen> {
  String? _startId;

  @override
  void initState() {
    super.initState();
    if (ref.read(categoryMenuControllerProvider).categories.isEmpty) {
      Future.microtask(
        () => ref.read(categoryMenuControllerProvider.notifier).loadMenu(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryMenuControllerProvider).categories;
    final shoppable = categories.where(
      (c) =>
          c.title.trim().toLowerCase() != 'home' &&
          (c.collectionHandle != null || c.items.isNotEmpty),
    );
    if (shoppable.isEmpty) {
      return const Material(
        color: NuviColors.cream,
        child: Center(child: NuviLoadingIndicator()),
      );
    }
    if (_startId == null) {
      final selectedId = ref
          .read(categoryMenuControllerProvider)
          .selectedCategoryId;
      _startId = shoppable.any((c) => c.id == selectedId)
          ? selectedId
          : shoppable.first.id;
    }
    return CategoryListingScreen(categoryId: _startId!);
  }
}
