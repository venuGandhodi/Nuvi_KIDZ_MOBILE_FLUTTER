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
        // Guest User Row
        Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: NuviColors.primary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Image.asset(
                'assets/images/brand/nuvi_elephant_mascot.png',
                width: 42,
                height: 42,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.person,
                  size: 28,
                  color: NuviColors.onPrimary,
                ),
              ),
            ),
            const SizedBox(width: NuviSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Guest User',
                  style: NuviTypography.textTheme.headlineMedium?.copyWith(
                    color: NuviColors.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 19,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Welcome to the Store',
                  style: NuviTypography.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: NuviColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: NuviSpacing.lg),

        // Push Notifications Card
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: NuviSpacing.lg,
            vertical: NuviSpacing.md,
          ),
          decoration: BoxDecoration(
            color: NuviColors.surfaceVariant,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: NuviColors.textTertiary.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
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
                      style: NuviTypography.textTheme.labelLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: NuviColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Enable to track your orders in real-time',
                      style: NuviTypography.textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                        color: NuviColors.textSecondary,
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
          padding: const EdgeInsets.symmetric(
            horizontal: NuviSpacing.xl,
            vertical: 26,
          ),
          decoration: BoxDecoration(
            color: NuviColors.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: NuviColors.primary.withValues(alpha: 0.28),
                blurRadius: 26,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Unlock Premium Features',
                style: NuviTypography.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: NuviColors.onPrimary,
                  fontSize: 19,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: NuviSpacing.sm),
              Text(
                'Login to sync your orders, addresses and wishlist across all your devices.',
                style: NuviTypography.textTheme.bodyMedium?.copyWith(
                  fontSize: 13.5,
                  color: NuviColors.onPrimary.withValues(alpha: 0.85),
                  height: 1.55,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: NuviSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.push('/sign-in'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NuviColors.secondary,
                    foregroundColor: NuviColors.onSecondary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(NuviRadii.pill),
                    ),
                  ),
                  child: Text(
                    'Login / Register',
                    style: NuviTypography.textTheme.labelLarge?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: NuviColors.onSecondary,
                    ),
                  ),
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
                iconColor: const Color(0xFFB06B60),
                count: '${wishlistState.wishlistProductIds.length}',
                label: 'WISHLIST',
                onTap: () => context.go('/wishlist'),
              ),
            ),
            const SizedBox(width: NuviSpacing.sm),
            Expanded(
              child: _buildStatCard(
                icon: Icons.work_outline,
                iconColor: const Color(0xFF7B865D),
                count: '0',
                label: 'ORDERS',
                onTap: () => context.push('/sign-in'),
              ),
            ),
            const SizedBox(width: NuviSpacing.sm),
            Expanded(
              child: _buildStatCard(
                icon: Icons.location_on_outlined,
                iconColor: const Color(0xFFCA933E),
                count: '0',
                label: 'ADDRESS',
                onTap: () => context.push('/sign-in'),
              ),
            ),
          ],
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
              color: NuviColors.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 26,
            ),
          ),
        ),
        const SizedBox(height: NuviSpacing.xl),

        // User Profile Row
        Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: NuviColors.primary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : 'N',
                style: NuviTypography.textTheme.headlineMedium?.copyWith(
                  color: NuviColors.onPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
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
                      color: NuviColors.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 19,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: NuviTypography.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: NuviColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: NuviSpacing.lg),

        // 3 Stat Cards (Wishlist, Orders, Addresses)
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.favorite_outline,
                iconColor: const Color(0xFFB06B60),
                count: '${wishlistState.wishlistProductIds.length}',
                label: 'WISHLIST',
                onTap: () => context.go('/wishlist'),
              ),
            ),
            const SizedBox(width: NuviSpacing.sm),
            Expanded(
              child: _buildStatCard(
                icon: Icons.work_outline,
                iconColor: const Color(0xFF7B865D),
                count: '${customerState.orders.length}',
                label: 'ORDERS',
                onTap: () => context.go('/orders'),
              ),
            ),
            const SizedBox(width: NuviSpacing.sm),
            Expanded(
              child: _buildStatCard(
                icon: Icons.location_on_outlined,
                iconColor: const Color(0xFFCA933E),
                count: '${customer?.addresses.length ?? 0}',
                label: 'ADDRESS',
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
            color: NuviColors.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 19,
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
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: NuviSpacing.md,
          horizontal: 4,
        ),
        decoration: BoxDecoration(
          color: NuviColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: NuviColors.textTertiary.withValues(alpha: 0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: iconColor ?? NuviColors.primary),
            const SizedBox(height: 6),
            Text(
              count,
              style: NuviTypography.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: NuviColors.onSurface,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: NuviTypography.textTheme.bodySmall?.copyWith(
                color: NuviColors.textSecondary,
                fontSize: 10,
                letterSpacing: 0.06,
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
          color: NuviColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: NuviColors.textTertiary.withValues(alpha: 0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
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
                    style: NuviTypography.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: NuviColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: NuviTypography.textTheme.bodySmall?.copyWith(
                      color: NuviColors.textSecondary,
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
