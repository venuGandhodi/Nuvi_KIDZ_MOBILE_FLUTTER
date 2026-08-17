import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/nuvi_colors.dart';
import '../../../core/theme/nuvi_spacing.dart';
import '../../../core/theme/nuvi_typography.dart';
import '../../../core/widgets/nuvi_button.dart';
import '../../../core/widgets/nuvi_top_bar.dart';
import '../../cart/presentation/cart_controller.dart';
import '../data/shopify_customer_repository.dart';
import '../domain/shopify_customer.dart';
import 'customer_controller.dart';
import 'widgets/address_card.dart';
import 'widgets/address_form_sheet.dart';

class SavedAddressesScreen extends ConsumerStatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  ConsumerState<SavedAddressesScreen> createState() =>
      _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends ConsumerState<SavedAddressesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(customerControllerProvider.notifier).loadCustomer();
    });
  }

  void _openAddressForm({ShopifyAddress? address}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddressFormSheet(
        isEditing: address != null,
        initialAddress: address,
        onSave: (addressData, makeDefault) async {
          final controller = ref.read(customerControllerProvider.notifier);
          if (address != null) {
            final success = await controller.updateAddress(
              address.id,
              addressData,
            );
            if (success && makeDefault) {
              await controller.setDefaultAddress(address.id);
            }
          } else {
            final success = await controller.createAddress(addressData);
            if (success && makeDefault) {
              final updatedCustomer = ref
                  .read(customerControllerProvider)
                  .customer;
              if (updatedCustomer != null &&
                  updatedCustomer.addresses.isNotEmpty) {
                await controller.setDefaultAddress(
                  updatedCustomer.addresses.first.id,
                );
              }
            }
          }
        },
      ),
    );
  }

  Future<void> _confirmDelete(ShopifyAddress address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(
          'Delete Address?',
          style: NuviTypography.textTheme.headlineSmall?.copyWith(
            color: NuviColors.primary,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this delivery address? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            style: TextButton.styleFrom(foregroundColor: NuviColors.accent),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref
          .read(customerControllerProvider.notifier)
          .deleteAddress(address.id);
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to delete address. Please try again.'),
            backgroundColor: NuviColors.accent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customerState = ref.watch(customerControllerProvider);
    final cartState = ref.watch(cartControllerProvider);

    return Scaffold(
      backgroundColor: NuviColors.surface,
      appBar: NuviTopBar(
        title: Text(
          'Saved Addresses',
          style: NuviTypography.textTheme.headlineMedium?.copyWith(
            color: NuviColors.primary,
          ),
        ),
        showBackButton: true,
        cartItemCount: cartState.totalItemCount,
        onCartTap: () => context.go('/cart'),
      ),
      body: _buildBody(context, customerState),
      bottomNavigationBar:
          (customerState.customer != null &&
              customerState.customer!.addresses.isNotEmpty)
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(NuviSpacing.lg),
                child: NuviButton(
                  text: '+ ADD NEW ADDRESS',
                  type: NuviButtonType.primary,
                  onPressed: () => _openAddressForm(),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildBody(BuildContext context, CustomerState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: NuviColors.primary),
      );
    }

    if (state.syncStatus == CustomerSyncStatus.notLinked) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(NuviSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.account_circle_outlined,
                size: 64,
                color: NuviColors.border,
              ),
              const SizedBox(height: NuviSpacing.lg),
              Text(
                'No Shopify Account Linked',
                style: NuviTypography.textTheme.headlineMedium?.copyWith(
                  color: NuviColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: NuviSpacing.sm),
              Text(
                'Your saved addresses will appear here once your account is linked after your first order.',
                style: NuviTypography.textTheme.bodyMedium?.copyWith(
                  color: NuviColors.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: NuviSpacing.xl),
              NuviButton(
                text: 'Explore Shop',
                type: NuviButtonType.primary,
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),
      );
    }

    final customer = state.customer;
    if (customer == null || customer.addresses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(NuviSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: NuviColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_off_outlined,
                  size: 40,
                  color: NuviColors.border,
                ),
              ),
              const SizedBox(height: NuviSpacing.lg),
              Text(
                'No saved addresses yet',
                style: NuviTypography.textTheme.headlineMedium?.copyWith(
                  color: NuviColors.primary,
                ),
              ),
              const SizedBox(height: NuviSpacing.sm),
              Text(
                'Add an address to make checkout faster and easier.',
                style: NuviTypography.textTheme.bodyMedium?.copyWith(
                  color: NuviColors.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: NuviSpacing.xxl),
              NuviButton(
                text: '+ ADD NEW ADDRESS',
                type: NuviButtonType.primary,
                onPressed: () => _openAddressForm(),
              ),
            ],
          ),
        ),
      );
    }

    final defaultAddrId = customer.defaultAddress?.id;
    final addresses = customer.addresses;

    return ListView.separated(
      padding: const EdgeInsets.all(NuviSpacing.lg),
      itemCount: addresses.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: NuviSpacing.md),
      itemBuilder: (context, index) {
        final address = addresses[index];
        final isDefault = address.id == defaultAddrId;

        return AddressCard(
          address: address,
          isDefault: isDefault,
          onEdit: () => _openAddressForm(address: address),
          onDelete: () => _confirmDelete(address),
          onSetDefault: isDefault
              ? null
              : () => ref
                    .read(customerControllerProvider.notifier)
                    .setDefaultAddress(address.id),
        );
      },
    );
  }
}
