import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/nuvi_colors.dart';
import '../../../core/theme/nuvi_radii.dart';
import '../../../core/theme/nuvi_spacing.dart';
import '../../../core/theme/nuvi_typography.dart';
import '../../../core/widgets/nuvi_button.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../wishlist/presentation/wishlist_controller.dart';
import 'customer_controller.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  bool _pushNotificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final authRepo = ref.watch(authRepositoryProvider);
    final currentUser = authRepo.currentUser;
    final isAuthenticated =
        (authState.value?.session != null) || (currentUser != null);

    final customerState = ref.watch(customerControllerProvider);
    final wishlistState = ref.watch(wishlistControllerProvider);

    return Material(
      color: NuviColors.surface,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: NuviSpacing.lg,
          vertical: NuviSpacing.md,
        ),
        child: isAuthenticated
            ? _buildAuthenticatedContent(
                context,
                customerState,
                wishlistState,
                currentUser,
              )
            : _buildGuestContent(context, wishlistState),
      ),
    );
  }

  /// Guest Profile Layout (matching attached reference)
  Widget _buildGuestContent(BuildContext context, WishlistState wishlistState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Guest User Card
        Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: NuviColors.surfaceVariant.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 36,
                color: NuviColors.primary,
              ),
            ),
            const SizedBox(width: NuviSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Guest User',
                  style: NuviTypography.textTheme.displayMedium?.copyWith(
                    color: NuviColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Welcome to the Store',
                  style: NuviTypography.textTheme.bodyMedium?.copyWith(
                    color: NuviColors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: NuviSpacing.xl),

        // Push Notifications Card
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: NuviSpacing.lg,
            vertical: NuviSpacing.md,
          ),
          decoration: BoxDecoration(
            color: NuviColors.surfaceVariant.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(NuviRadii.card),
            border: Border.all(color: NuviColors.border.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Push Notifications',
                      style: NuviTypography.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: NuviColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Enable to track your orders in real-time',
                      style: NuviTypography.textTheme.bodySmall?.copyWith(
                        color: NuviColors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: _pushNotificationsEnabled,
                activeThumbColor: NuviColors.primary,
                activeTrackColor: NuviColors.primary.withValues(alpha: 0.5),
                onChanged: (value) {
                  setState(() {
                    _pushNotificationsEnabled = value;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: NuviSpacing.lg),

        // Unlock Premium Features Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(NuviSpacing.xl),
          decoration: BoxDecoration(
            color: NuviColors.surfaceVariant.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(NuviRadii.card),
            border: Border.all(color: NuviColors.border.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              Text(
                'Unlock Premium Features',
                style: NuviTypography.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: NuviColors.primary,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: NuviSpacing.sm),
              Text(
                'Login to sync your orders, addresses and wishlist across all your devices.',
                style: NuviTypography.textTheme.bodyMedium?.copyWith(
                  color: NuviColors.onSurface.withValues(alpha: 0.65),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: NuviSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: NuviButton(
                  text: 'Login / Register',
                  type: NuviButtonType.primary,
                  onPressed: () => context.push('/sign-in'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: NuviSpacing.lg),

        // 3 Stat Cards (Wishlist, Orders, Addresses)
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.favorite_outline,
                count: '${wishlistState.wishlistProductIds.length}',
                label: 'WISHLIST',
                onTap: () => context.go('/wishlist'),
              ),
            ),
            const SizedBox(width: NuviSpacing.md),
            Expanded(
              child: _buildStatCard(
                icon: Icons.shopping_bag_outlined,
                count: '0',
                label: 'ORDERS',
                onTap: () => context.push('/sign-in'),
              ),
            ),
            const SizedBox(width: NuviSpacing.md),
            Expanded(
              child: _buildStatCard(
                icon: Icons.location_on_outlined,
                count: '0',
                label: 'ADDRESSES',
                onTap: () => context.push('/sign-in'),
              ),
            ),
          ],
        ),
        const SizedBox(height: NuviSpacing.lg),

        // Menu Items List
        _buildMenuItem(
          icon: Icons.shopping_bag_outlined,
          title: 'My Orders',
          subtitle: 'View order history and track shipments',
          onTap: () => context.push('/sign-in'),
        ),
        const SizedBox(height: NuviSpacing.sm),
        _buildMenuItem(
          icon: Icons.location_on_outlined,
          title: 'My Addresses',
          subtitle: 'Manage saved delivery addresses',
          onTap: () => context.push('/sign-in'),
        ),
        const SizedBox(height: NuviSpacing.sm),
        _buildMenuItem(
          icon: Icons.headset_mic_outlined,
          title: 'Help & Support',
          subtitle: 'Customer care, returns and sizing guide',
          onTap: () => _showSupportSnackbar(context),
        ),
      ],
    );
  }

  /// Authenticated Profile Layout
  Widget _buildAuthenticatedContent(
    BuildContext context,
    CustomerState customerState,
    WishlistState wishlistState,
    dynamic currentUser,
  ) {
    final customer = customerState.customer;
    final displayName =
        customer?.fullName ??
        currentUser?.userMetadata?['display_name'] as String? ??
        currentUser?.email?.split('@').first ??
        'Nuvi Parent';
    final email = customer?.email ?? currentUser?.email ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title: Profile
        Center(
          child: Text(
            'Profile',
            style: NuviTypography.textTheme.headlineMedium?.copyWith(
              color: NuviColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        const SizedBox(height: NuviSpacing.xl),

        // User Profile Card
        Container(
          padding: const EdgeInsets.all(NuviSpacing.lg),
          decoration: BoxDecoration(
            color: NuviColors.surfaceVariant.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(NuviRadii.card),
            border: Border.all(color: NuviColors.border.withValues(alpha: 0.8)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: NuviColors.secondary,
                child: Text(
                  displayName.isNotEmpty ? displayName[0].toUpperCase() : 'N',
                  style: NuviTypography.textTheme.headlineMedium?.copyWith(
                    color: NuviColors.onSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: NuviSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: NuviTypography.textTheme.headlineMedium?.copyWith(
                        color: NuviColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: NuviTypography.textTheme.bodyMedium?.copyWith(
                        color: NuviColors.onSurface.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: NuviSpacing.lg),

        // 3 Stat Cards (Wishlist, Orders, Addresses)
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.favorite_outline,
                count: '${wishlistState.wishlistProductIds.length}',
                label: 'WISHLIST',
                onTap: () => context.go('/wishlist'),
              ),
            ),
            const SizedBox(width: NuviSpacing.md),
            Expanded(
              child: _buildStatCard(
                icon: Icons.shopping_bag_outlined,
                count: '${customerState.orders.length}',
                label: 'ORDERS',
                onTap: () => context.go('/orders'),
              ),
            ),
            const SizedBox(width: NuviSpacing.md),
            Expanded(
              child: _buildStatCard(
                icon: Icons.location_on_outlined,
                count: '${customer?.addresses.length ?? 0}',
                label: 'ADDRESSES',
                onTap: () => context.push('/addresses'),
              ),
            ),
          ],
        ),
        const SizedBox(height: NuviSpacing.xl),

        // Section: My Account
        Text(
          'My Account',
          style: NuviTypography.textTheme.headlineMedium?.copyWith(
            color: NuviColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: NuviSpacing.md),

        // Menu Option 1: Orders
        _buildMenuItem(
          icon: Icons.shopping_bag_outlined,
          title: 'My Orders',
          subtitle: customerState.orders.isNotEmpty
              ? '${customerState.orders.length} orders placed'
              : 'View order history and track shipments',
          trailingBadge: customerState.orders.isNotEmpty
              ? '${customerState.orders.length}'
              : null,
          onTap: () => context.go('/orders'),
        ),
        const SizedBox(height: NuviSpacing.sm),

        // Menu Option 2: Saved Addresses
        _buildMenuItem(
          icon: Icons.location_on_outlined,
          title: 'Saved Addresses',
          subtitle:
              customer?.defaultAddress?.formattedAddress ??
              'Manage delivery addresses',
          onTap: () => context.push('/addresses'),
        ),
        const SizedBox(height: NuviSpacing.sm),

        // Menu Option 3: Support & Help
        _buildMenuItem(
          icon: Icons.headset_mic_outlined,
          title: 'Help & Support',
          subtitle: 'Customer care, returns and sizing guide',
          onTap: () => _showSupportSnackbar(context),
        ),
        const SizedBox(height: NuviSpacing.xxl),

        // Logout Button
        NuviButton(
          text: 'LOG OUT',
          type: NuviButtonType.secondary,
          onPressed: () async {
            await ref.read(authControllerProvider.notifier).signOut();
          },
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String count,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(NuviRadii.card),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: NuviSpacing.md,
          horizontal: 4,
        ),
        decoration: BoxDecoration(
          color: NuviColors.surfaceVariant.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(NuviRadii.card),
          border: Border.all(color: NuviColors.border.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: NuviColors.primary),
            const SizedBox(height: NuviSpacing.xs),
            Text(
              count,
              style: NuviTypography.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: NuviColors.primary,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: NuviTypography.textTheme.labelSmall?.copyWith(
                color: NuviColors.onSurface.withValues(alpha: 0.6),
                fontSize: 8,
                letterSpacing: 0,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    String? trailingBadge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(NuviRadii.card),
      child: Container(
        padding: const EdgeInsets.all(NuviSpacing.md),
        decoration: BoxDecoration(
          color: NuviColors.surfaceVariant.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(NuviRadii.card),
          border: Border.all(color: NuviColors.border.withValues(alpha: 0.6)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: NuviColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: NuviColors.primary, size: 22),
            ),
            const SizedBox(width: NuviSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: NuviTypography.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: NuviColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: NuviTypography.textTheme.bodySmall?.copyWith(
                      color: NuviColors.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (trailingBadge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: NuviColors.secondary,
                  borderRadius: BorderRadius.circular(NuviRadii.pill),
                ),
                child: Text(
                  trailingBadge,
                  style: NuviTypography.textTheme.labelSmall?.copyWith(
                    color: NuviColors.onSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: NuviSpacing.xs),
            ],
            const Icon(
              Icons.chevron_right,
              color: NuviColors.onSurface,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showSupportSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contact support at support@nuvikidz.com'),
        backgroundColor: NuviColors.primary,
      ),
    );
  }
}
