import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/nuvi_colors.dart';
import '../theme/nuvi_decorations.dart';
import '../theme/nuvi_motion.dart';
import '../theme/nuvi_theme_ext.dart';
import 'nuvi_decor.dart';
import 'nuvi_icon_button.dart';
import 'nuvi_icons.dart';

/// Sticky cream header: back chevron (except on Home), NUVI logo, then
/// search, wishlist (count), account and bag (count). Gains a soft shadow
/// once the page scrolls.
class NuviHeader extends StatelessWidget {
  final bool showBack;
  final VoidCallback? onBack;
  final VoidCallback? onLogoTap;
  final VoidCallback? onSearch;
  final VoidCallback? onWishlist;
  final VoidCallback? onAccount;
  final VoidCallback? onBag;
  final int wishlistCount;
  final int bagCount;
  final ValueListenable<bool> scrolled;

  const NuviHeader({
    super.key,
    required this.showBack,
    required this.scrolled,
    this.onBack,
    this.onLogoTap,
    this.onSearch,
    this.onWishlist,
    this.onAccount,
    this.onBag,
    this.wishlistCount = 0,
    this.bagCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: scrolled,
      builder: (context, isScrolled, child) => AnimatedContainer(
        duration: NuviMotion.of(context),
        decoration: BoxDecoration(
          color: NuviColors.cream,
          boxShadow: isScrolled ? NuviShadows.header : const [],
        ),
        child: child,
      ),
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            const SizedBox(width: 4),
            if (showBack)
              NuviIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                iconSize: 19,
                semanticLabel: 'Back',
                onPressed: onBack,
              )
            else
              const SizedBox(width: 8),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Semantics(
                  button: onLogoTap != null,
                  label: 'NUVI KIDZ home',
                  child: GestureDetector(
                    onTap: onLogoTap,
                    child: const _HeaderLogo(),
                  ),
                ),
              ),
            ),
            NuviIconButton(
              semanticLabel: 'Search',
              onPressed: onSearch,
              child: NuviIcons.search(color: NuviColors.ink),
            ),
            NuviIconButton(
              semanticLabel: 'Wishlist',
              badgeCount: wishlistCount,
              onPressed: onWishlist,
              child: NuviIcons.wishlist(color: NuviColors.ink, size: 22),
            ),
            NuviIconButton(
              semanticLabel: 'Account',
              onPressed: onAccount,
              child: NuviIcons.person(color: NuviColors.ink, size: 22),
            ),
            NuviIconButton(
              semanticLabel: 'Bag',
              badgeCount: bagCount,
              onPressed: onBag,
              child: NuviIcons.bag(color: NuviColors.ink, size: 23),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

/// Logo (which carries the elephant) pops in once per app session with a
/// sprout, then stays still.
class _HeaderLogo extends StatefulWidget {
  const _HeaderLogo();

  static bool _playedThisSession = false;

  @override
  State<_HeaderLogo> createState() => _HeaderLogoState();
}

class _HeaderLogoState extends State<_HeaderLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    if (_HeaderLogo._playedThisSession) {
      _controller.value = 1;
    } else {
      _HeaderLogo._playedThisSession = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (NuviMotion.reduced(context)) {
          _controller.value = 1;
        } else {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    final logo = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.6, curve: Curves.easeOutBack),
    );
    final buddy = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 1, curve: Curves.easeOutBack),
    );
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FadeTransition(
            opacity: logo,
            child: ScaleTransition(
              scale: Tween(begin: 0.7, end: 1.0).animate(logo),
              alignment: Alignment.centerLeft,
              child: Image.asset(
                kNuviLogoAsset,
                height: 44,
                cacheHeight: 176,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    Text('NUVI KIDZ', style: x.h3),
              ),
            ),
          ),
          ScaleTransition(
            scale: buddy,
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: NuviLeaf(size: 12, color: x.sage, angle: -0.9),
            ),
          ),
        ],
      ),
    );
  }
}
