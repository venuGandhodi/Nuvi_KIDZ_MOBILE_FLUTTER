import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/nuvi_colors.dart';
import '../theme/nuvi_typography.dart';
import 'nuvi_bottom_nav.dart';
import 'nuvi_top_bar.dart';

class AppShell extends ConsumerWidget {
  final Widget child;
  final GoRouterState state;

  const AppShell({super.key, required this.child, required this.state});

  // -1 = no bottom-tab matches (e.g. Shop/Profile, reached via the category
  // circles or the header profile icon rather than a footer tab).
  int _calculateSelectedIndex(String location) {
    if (location.startsWith('/orders')) {
      return 1;
    } else if (location.startsWith('/cart')) {
      return 2;
    } else if (location.startsWith('/wishlist')) {
      return 3;
    } else if (location.startsWith('/home')) {
      return 0;
    }
    return -1;
  }

  // Home and Shop keep the left-aligned brand logo (centerTitle: false in
  // build()); Orders/Cart/Wishlist/Profile get a plain centered text title.
  bool _showsLogoTitle(String location) {
    return !location.startsWith('/account') &&
        !location.startsWith('/orders') &&
        !location.startsWith('/cart') &&
        !location.startsWith('/wishlist');
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
    } else if (location.startsWith('/orders')) {
      return Text(
        'My Orders',
        style: NuviTypography.textTheme.headlineMedium?.copyWith(
          color: NuviColors.primary,
          fontWeight: FontWeight.bold,
        ),
      );
    } else if (location.startsWith('/cart')) {
      return Text(
        'My Bag',
        style: NuviTypography.textTheme.headlineMedium?.copyWith(
          color: NuviColors.primary,
          fontWeight: FontWeight.bold,
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
    }
    return Image.asset(
      'assets/images/brand/nuvi_kidz_logo.png',
      height: 48,
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
    final location = state.matchedLocation;
    final selectedIndex = _calculateSelectedIndex(location);
    final isOnProfile = location.startsWith('/account');

    return Scaffold(
      backgroundColor: NuviColors.surface,
      appBar: NuviTopBar(
        title: _buildTopBarTitle(location),
        showBackButton: false,
        centerTitle: !_showsLogoTitle(location),
        showCart: false,
        showProfile: !isOnProfile,
        onProfileTap: () => context.go('/account'),
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
              context.go('/orders');
              break;
            case 2:
              context.go('/cart');
              break;
            case 3:
              context.go('/wishlist');
              break;
          }
        },
      ),
    );
  }
}
