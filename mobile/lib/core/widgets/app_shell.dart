import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/nuvi_colors.dart';
import '../theme/nuvi_typography.dart';
import 'nuvi_bottom_nav.dart';
import 'nuvi_top_bar.dart';
import '../../features/cart/presentation/cart_controller.dart';

class AppShell extends ConsumerWidget {
  final Widget child;
  final GoRouterState state;

  const AppShell({super.key, required this.child, required this.state});

  int _calculateSelectedIndex(String location) {
    if (location.startsWith('/category')) {
      return 1;
    } else if (location.startsWith('/search')) {
      return 2;
    } else if (location.startsWith('/wishlist')) {
      return 3;
    } else if (location.startsWith('/account')) {
      return 4;
    }
    return 0; // /home
  }

  Widget _buildTopBarTitle(String location) {
    if (location.startsWith('/account')) {
      return Text(
        'Profile',
        style: NuviTypography.textTheme.headlineMedium?.copyWith(
          color: NuviColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      );
    } else if (location.startsWith('/wishlist')) {
      return Text(
        'Wishlist',
        style: NuviTypography.textTheme.headlineMedium?.copyWith(
          color: NuviColors.primary,
          fontWeight: FontWeight.bold,
        ),
      );
    } else if (location.startsWith('/search')) {
      return Text(
        'Search',
        style: NuviTypography.textTheme.headlineMedium?.copyWith(
          color: NuviColors.primary,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    return Image.asset(
      'assets/images/brand/nuvi_kidz_logo.png',
      height: 32,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Text(
        'Nuvi Kidz',
        style: NuviTypography.textTheme.headlineMedium?.copyWith(
          color: NuviColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartControllerProvider);
    final location = state.matchedLocation;
    final selectedIndex = _calculateSelectedIndex(location);

    return Scaffold(
      backgroundColor: NuviColors.surface,
      appBar: NuviTopBar(
        title: _buildTopBarTitle(location),
        showBackButton: false,
        cartItemCount: cartState.totalItemCount,
        onCartTap: () => context.push('/cart'),
      ),
      body: child,
      bottomNavigationBar: NuviBottomNav(
        currentIndex: selectedIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/category/toddler');
              break;
            case 2:
              context.go('/search');
              break;
            case 3:
              context.go('/wishlist');
              break;
            case 4:
              context.go('/account');
              break;
          }
        },
      ),
    );
  }
}
