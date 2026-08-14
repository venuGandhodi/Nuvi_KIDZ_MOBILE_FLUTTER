import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/nuvi_colors.dart';
import '../../../core/theme/nuvi_radii.dart';
import '../../../core/theme/nuvi_spacing.dart';
import '../../../core/theme/nuvi_typography.dart';
import '../../../core/widgets/nuvi_bottom_nav.dart';
import '../../../core/widgets/nuvi_button.dart';
import '../../../core/widgets/nuvi_top_bar.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../cart/presentation/cart_controller.dart';
import 'customer_controller.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerState = ref.watch(customerControllerProvider);
    final cartState = ref.watch(cartControllerProvider);
    final authRepo = ref.read(authRepositoryProvider);
    final currentUser = authRepo.currentUser;

    final customer = customerState.customer;
    final displayName =
        customer?.fullName ??
        currentUser?.userMetadata?['display_name'] as String? ??
        currentUser?.email?.split('@').first ??
        'Nuvi Parent';
    final email = customer?.email ?? currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: NuviColors.surface,
      appBar: NuviTopBar(
        showBackButton: false,
        cartItemCount: cartState.totalItemCount,
        onCartTap: () => context.push('/cart'),
      ),
      body: customerState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: NuviColors.primary),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.only(
                left: NuviSpacing.md,
                right: NuviSpacing.md,
                top: NuviSpacing.md,
                bottom:
                    kBottomNavigationBarHeight +
                    MediaQuery.of(context).padding.bottom +
                    32.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Card
                  Container(
                    padding: const EdgeInsets.all(NuviSpacing.lg),
                    decoration: BoxDecoration(
                      color: NuviColors.surfaceVariant.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(NuviRadii.card),
                      border: Border.all(
                        color: NuviColors.border.withValues(alpha: 0.8),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: NuviColors.secondary,
                          child: Text(
                            displayName.isNotEmpty
                                ? displayName[0].toUpperCase()
                                : 'N',
                            style: NuviTypography.textTheme.headlineMedium
                                ?.copyWith(
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
                                style: NuviTypography.textTheme.headlineMedium
                                    ?.copyWith(
                                      color: NuviColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                email,
                                style: NuviTypography.textTheme.bodyMedium
                                    ?.copyWith(
                                      color: NuviColors.onSurface.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: NuviSpacing.xl),

                  // Section Title: Quick Actions
                  Text(
                    'My Account',
                    style: NuviTypography.textTheme.headlineMedium?.copyWith(
                      color: NuviColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: NuviSpacing.md),

                  // Menu Option 1: My Orders
                  _buildMenuItem(
                    icon: Icons.receipt_long_outlined,
                    title: 'My Orders',
                    subtitle: customerState.orders.isNotEmpty
                        ? '${customerState.orders.length} orders placed'
                        : 'View order history and track shipments',
                    trailingBadge: customerState.orders.isNotEmpty
                        ? '${customerState.orders.length}'
                        : null,
                    onTap: () => context.push('/orders'),
                  ),
                  const SizedBox(height: NuviSpacing.sm),

                  // Menu Option 2: Wishlist
                  _buildMenuItem(
                    icon: Icons.favorite_outline,
                    title: 'Wishlist',
                    subtitle: 'View and manage your saved tiny styles',
                    onTap: () => context.push('/wishlist'),
                  ),
                  const SizedBox(height: NuviSpacing.sm),

                  // Menu Option 3: Saved Addresses
                  _buildMenuItem(
                    icon: Icons.location_on_outlined,
                    title: 'Saved Addresses',
                    subtitle: customer?.defaultAddress != null
                        ? customer!.defaultAddress!.formattedAddress
                        : 'Manage delivery addresses',
                    onTap: () => context.push('/addresses'),
                  ),
                  const SizedBox(height: NuviSpacing.sm),

                  // Menu Option 3: Support & Help
                  _buildMenuItem(
                    icon: Icons.headset_mic_outlined,
                    title: 'Help & Support',
                    subtitle: 'Customer care, returns and sizing guide',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Contact support at support@nuvikidz.com',
                          ),
                          backgroundColor: NuviColors.primary,
                        ),
                      );
                    },
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
              ),
            ),
      bottomNavigationBar: NuviBottomNav(
        currentIndex: 4,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/category/toddler');
              break;
            case 2:
              // Search tab
              break;
            case 3:
              // Wishlist tab
              break;
            case 4:
              // Active Account
              break;
          }
        },
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
}
