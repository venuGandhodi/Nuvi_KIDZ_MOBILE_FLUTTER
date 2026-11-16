import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/cart/presentation/cart_controller.dart';
import '../../features/wishlist/presentation/wishlist_controller.dart';
import '../theme/nuvi_colors.dart';
import 'nuvi_announcement_bar.dart';
import 'nuvi_bottom_nav.dart';
import 'nuvi_header.dart';

class AppShell extends ConsumerStatefulWidget {
  final Widget child;
  final GoRouterState state;

  const AppShell({super.key, required this.child, required this.state});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final ValueNotifier<bool> _scrolled = ValueNotifier(false);

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

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.matchedLocation != widget.state.matchedLocation) {
      _scrolled.value = false;
    }
  }

  @override
  void dispose() {
    _scrolled.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.depth == 0 && notification.metrics.axis == Axis.vertical) {
      _scrolled.value = notification.metrics.pixels > 4;
    }
    return false;
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = widget.state.matchedLocation;
    final selectedIndex = _calculateSelectedIndex(location);
    final isHome = location.startsWith('/home');
    // The bag has its own pinned checkout footer, so the tab bar steps aside.
    final hideTabBar = location.startsWith('/cart');
    final bagCount = ref.watch(
      cartControllerProvider.select((s) => s.totalItemCount),
    );
    final wishlistCount = ref.watch(
      wishlistControllerProvider.select((s) => s.wishlistProductIds.length),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: NuviColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: NuviColors.cream,
        body: Column(
          children: [
            const NuviAnnouncementBar(),
            NuviHeader(
              showBack: !isHome,
              onBack: _back,
              onLogoTap: isHome ? null : () => context.go('/home'),
              scrolled: _scrolled,
              wishlistCount: wishlistCount,
              bagCount: bagCount,
              onSearch: () => context.push('/search'),
              onWishlist: () => context.go('/wishlist'),
              onAccount: () => context.go('/account'),
              onBag: () => context.go('/cart'),
            ),
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: NotificationListener<ScrollNotification>(
                  onNotification: _onScroll,
                  child: widget.child,
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: hideTabBar
            ? null
            : NuviBottomNav(
                currentIndex: selectedIndex,
                cartCount: bagCount,
                wishlistCount: wishlistCount,
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
      ),
    );
  }
}
