import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/nuvi_colors.dart';
import '../../../core/theme/nuvi_spacing.dart';
import '../../../core/theme/nuvi_theme_ext.dart';
import '../../../core/widgets/nuvi_button.dart';
import '../../../core/widgets/nuvi_decor.dart';
import '../../../core/widgets/nuvi_menu_tile.dart';
import '../../../core/widgets/nuvi_pressable.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../wishlist/presentation/wishlist_controller.dart';
import 'customer_controller.dart';

/// Account tab: profile header, Wishlist / Orders / Addresses counts, the
/// "Account & Settings" list and Log out (or Login for guests).
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final x = context.nuvi;
    final authState = ref.watch(authStateProvider);
    final currentUser = ref.watch(authRepositoryProvider).currentUser;
    final signedIn =
        (authState.value?.session != null) || (currentUser != null);
    final customerState = ref.watch(customerControllerProvider);
    final wishlistCount = ref
        .watch(wishlistControllerProvider)
        .wishlistProductIds
        .length;
    final customer = customerState.customer;

    // Orders and addresses need an account; guests are sent to sign in.
    void needsAccount(String route) =>
        signedIn ? context.push(route) : context.push('/sign-in');

    final name =
        customer?.fullName ??
        currentUser?.userMetadata?['display_name'] as String? ??
        currentUser?.email?.split('@').first ??
        'Nuvi Parent';
    final email = customer?.email ?? currentUser?.email ?? '';

    return Material(
      color: NuviColors.cream,
      child: ListView(
        padding: const EdgeInsets.only(top: NuviSpacing.md),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: NuviSpacing.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                signedIn
                    ? _ProfileHeader(name: name, email: email)
                    : const _GuestHeader(),
                const SizedBox(height: NuviSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.favorite_border_rounded,
                        color: NuviColors.sale,
                        tint: NuviColors.saleSoft,
                        count: wishlistCount,
                        label: 'WISHLIST',
                        onTap: () => context.go('/wishlist'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.shopping_bag_outlined,
                        color: NuviColors.leaf,
                        tint: NuviColors.sageSoft,
                        count: signedIn ? customerState.orders.length : 0,
                        label: 'ORDERS',
                        onTap: () => needsAccount('/orders'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.location_on_outlined,
                        color: NuviColors.amber,
                        tint: NuviColors.goldSoft,
                        count: signedIn ? (customer?.addresses.length ?? 0) : 0,
                        label: 'ADDRESSES',
                        onTap: () => needsAccount('/addresses'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: NuviSpacing.xl),
                Text(
                  'Account & Settings',
                  style: x.baloo(
                    22,
                    weight: FontWeight.w700,
                    color: NuviColors.nightGreen,
                  ),
                ),
                const SizedBox(height: NuviSpacing.s12),
                NuviMenuTile(
                  icon: Icons.shopping_bag_outlined,
                  iconColor: NuviColors.leaf,
                  tint: NuviColors.sageSoft,
                  title: 'My Orders',
                  subtitle: 'View order history and track shipments',
                  onTap: () => needsAccount('/orders'),
                ),
                const SizedBox(height: 10),
                NuviMenuTile(
                  icon: Icons.location_on_outlined,
                  iconColor: NuviColors.amber,
                  tint: NuviColors.goldSoft,
                  title: 'Saved Addresses',
                  subtitle: 'Manage your delivery addresses',
                  onTap: () => needsAccount('/addresses'),
                ),
                const SizedBox(height: 10),
                NuviMenuTile(
                  icon: Icons.favorite_border_rounded,
                  iconColor: NuviColors.sale,
                  tint: NuviColors.saleSoft,
                  title: 'My Wishlist',
                  subtitle: 'Your saved styles and products',
                  onTap: () => context.go('/wishlist'),
                ),
                const SizedBox(height: 10),
                NuviMenuTile(
                  icon: Icons.headset_mic_outlined,
                  iconColor: NuviTone.sky.accent,
                  tint: NuviTone.sky.tint,
                  title: 'Help & Support',
                  subtitle: 'Customer care, returns and sizing guide',
                  onTap: () => context.push('/help'),
                ),
                const SizedBox(height: 10),
                NuviMenuTile(
                  icon: Icons.settings_outlined,
                  iconColor: NuviTone.lavender.accent,
                  tint: NuviTone.lavender.tint,
                  title: 'Settings',
                  subtitle: 'Notifications, privacy and app preferences',
                  onTap: () => context.push('/settings'),
                ),
                const SizedBox(height: NuviSpacing.xl),
                Center(
                  child: signedIn
                      ? NuviButton(
                          text: 'LOG OUT',
                          type: NuviButtonType.outline,
                          isFullWidth: false,
                          height: 50,
                          icon: const Icon(Icons.logout_rounded),
                          onPressed: () => ref
                              .read(authControllerProvider.notifier)
                              .signOut(),
                        )
                      : NuviButton(
                          text: 'LOGIN / REGISTER',
                          type: NuviButtonType.leaf,
                          isFullWidth: false,
                          height: 50,
                          icon: const Icon(Icons.login_rounded),
                          onPressed: () => context.push('/sign-in'),
                        ),
                ),
              ],
            ),
          ),
          const _GardenFooter(),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;

  const _ProfileHeader({required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: x.leaf, shape: BoxShape.circle),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : 'N',
            style: x.baloo(
              24,
              weight: FontWeight.w700,
              color: NuviColors.cream,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: x.baloo(
                  20,
                  weight: FontWeight.w700,
                  color: NuviColors.nightGreen,
                ),
              ),
              if (email.isNotEmpty)
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: x.nunito(14, color: NuviColors.inkMuted),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GuestHeader extends StatelessWidget {
  const _GuestHeader();

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: NuviColors.goldSoft,
            shape: BoxShape.circle,
          ),
          child: const NuviMascot(size: 44),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi there!',
                style: x.baloo(
                  20,
                  weight: FontWeight.w700,
                  color: NuviColors.nightGreen,
                ),
              ),
              Text(
                'Sign in to see your orders and addresses',
                style: x.nunito(14, color: NuviColors.inkMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color tint;
  final int count;
  final String label;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.tint,
    required this.count,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return NuviPressable(
      onTap: onTap,
      semanticLabel: '$count $label',
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: x
                  .baloo(
                    24,
                    weight: FontWeight.w800,
                    color: NuviColors.nightGreen,
                  )
                  .copyWith(height: 1.1),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: x.nunito(
                  12,
                  weight: FontWeight.w600,
                  color: NuviColors.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Soft hills with a leaf sprout on the left and the elephant mascot.
class _GardenFooter extends StatelessWidget {
  const _GardenFooter();

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return SizedBox(
      height: 130,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: NuviHills(
              height: 70,
              back: NuviColors.sageSoft,
              front: const Color(0xFFE3E8D6),
            ),
          ),
          Positioned(
            left: 22,
            bottom: 34,
            child: ExcludeSemantics(
              child: SizedBox(
                width: 44,
                height: 44,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 2,
                      bottom: 4,
                      child: NuviLeaf(size: 26, color: x.sage, angle: -0.9),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 10,
                      child: NuviLeaf(size: 24, color: x.sage, angle: -0.2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(right: 26, bottom: 18, child: NuviMascot(size: 92)),
        ],
      ),
    );
  }
}
