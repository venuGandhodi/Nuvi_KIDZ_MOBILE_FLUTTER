import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/cart/presentation/cart_controller.dart';
import '../../features/wishlist/presentation/wishlist_controller.dart';
import '../theme/nuvi_colors.dart';
import '../theme/nuvi_festival.dart';
import 'nuvi_announcement_bar.dart';
import 'nuvi_bottom_nav.dart';
import 'nuvi_header.dart';
import 'nuvi_menu_drawer.dart';

class AppShell extends ConsumerStatefulWidget {
  final Widget child;
  final GoRouterState state;

  const AppShell({super.key, required this.child, required this.state});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final ValueNotifier<bool> _scrolled = ValueNotifier(false);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // -1 = no bottom-tab matches (e.g. Shop/Profile, reached via the category
  // circles or the header profile icon rather than a footer tab).
  int _calculateSelectedIndex(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/shop') || location.startsWith('/category')) {
      return 1;
    }
    if (location.startsWith('/styled')) return 2;
    if (location.startsWith('/world')) return 3;
    if (location.startsWith('/account') || location.startsWith('/orders')) {
      return 4;
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
    final festive = ref.watch(activeFestivalProvider) != null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (festive ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: NuviColors.white,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: NuviColors.cream,
        drawer: const NuviMenuDrawer(),
        body: Column(
          children: [
            if (festive)
              const NuviAnnouncementBar()
            else
              SizedBox(height: MediaQuery.paddingOf(context).top),
            NuviHeader(
              showBack: !isHome,
              onBack: _back,
              onMenu: () => _scaffoldKey.currentState?.openDrawer(),
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
                onTap: (index) => context.go(
                  const [
                    '/home',
                    '/shop',
                    '/styled',
                    '/world',
                    '/account',
                  ][index],
                ),
              ),
      ),
    );
  }
}
