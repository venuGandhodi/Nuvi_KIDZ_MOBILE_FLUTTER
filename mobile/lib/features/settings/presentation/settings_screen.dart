import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/nuvi_colors.dart';
import '../../../core/theme/nuvi_spacing.dart';
import '../../../core/theme/nuvi_theme_ext.dart';
import '../../../core/widgets/nuvi_menu_tile.dart';
import '../../../core/widgets/nuvi_toast.dart';
import '../../../core/widgets/nuvi_top_bar.dart';
import '../../support/data/support_repository.dart';
import '../../support/domain/store_policy.dart';
import '../../support/presentation/policy_sheet.dart';
import '../data/app_preferences_repository.dart';

/// Settings: notification preferences (saved on this device), privacy and
/// legal pages from Shopify, and a shortcut to Help & Support.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _openPolicy(
    BuildContext context,
    WidgetRef ref,
    StorePolicy? Function(SupportContent c) pick,
    String name,
  ) {
    final content = ref.read(supportContentProvider).value;
    final policy = content == null ? null : pick(content);
    if (policy == null) {
      ref.invalidate(supportContentProvider);
      NuviToast.show(
        context,
        message: '$name isn’t available right now',
        success: false,
      );
      return;
    }
    showPolicySheet(context, policy);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final x = context.nuvi;
    final prefs = ref.watch(appPreferencesProvider);
    final controller = ref.read(appPreferencesProvider.notifier);
    // Warm up the policies so Privacy / Terms open instantly.
    ref.watch(supportContentProvider);

    Widget toggle(bool value, ValueChanged<bool> onChanged) => Switch.adaptive(
      value: value,
      activeThumbColor: NuviColors.white,
      activeTrackColor: x.leaf,
      onChanged: onChanged,
    );

    return Scaffold(
      backgroundColor: NuviColors.cream,
      appBar: NuviTopBar(
        title: Text('Settings', style: x.h3),
        showBackButton: true,
        showCart: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          NuviSpacing.gutter,
          NuviSpacing.sm,
          NuviSpacing.gutter,
          NuviSpacing.xl,
        ),
        children: [
          Text('Notifications', style: x.h3),
          const SizedBox(height: NuviSpacing.s12),
          NuviMenuTile(
            icon: Icons.local_shipping_outlined,
            iconColor: NuviColors.leaf,
            tint: NuviColors.sageSoft,
            title: 'Order updates',
            subtitle: 'Shipping and delivery updates for your orders',
            trailing: toggle(
              prefs.orderUpdates,
              (v) => controller.update(prefs.copyWith(orderUpdates: v)),
            ),
          ),
          const SizedBox(height: 10),
          NuviMenuTile(
            icon: Icons.local_offer_outlined,
            iconColor: NuviColors.sale,
            tint: NuviColors.saleSoft,
            title: 'Offers & new arrivals',
            subtitle: 'Sales, festive drops and new collections',
            trailing: toggle(
              prefs.offersAndNewArrivals,
              (v) => controller.update(prefs.copyWith(offersAndNewArrivals: v)),
            ),
          ),
          const SizedBox(height: NuviSpacing.lg),
          Text('Privacy & legal', style: x.h3),
          const SizedBox(height: NuviSpacing.s12),
          NuviMenuTile(
            icon: Icons.lock_outline_rounded,
            iconColor: NuviTone.lavender.accent,
            tint: NuviTone.lavender.tint,
            title: 'Privacy Policy',
            subtitle: 'How we use and protect your data',
            onTap: () => _openPolicy(
              context,
              ref,
              (c) => c.privacyPolicy,
              'Privacy Policy',
            ),
          ),
          const SizedBox(height: 10),
          NuviMenuTile(
            icon: Icons.description_outlined,
            iconColor: NuviTone.sky.accent,
            tint: NuviTone.sky.tint,
            title: 'Terms of Service',
            subtitle: 'The terms for shopping with NUVI KIDZ',
            onTap: () => _openPolicy(
              context,
              ref,
              (c) => c.termsOfService,
              'Terms of Service',
            ),
          ),
          const SizedBox(height: NuviSpacing.lg),
          Text('Support', style: x.h3),
          const SizedBox(height: NuviSpacing.s12),
          NuviMenuTile(
            icon: Icons.headset_mic_outlined,
            iconColor: NuviTone.sky.accent,
            tint: NuviTone.sky.tint,
            title: 'Help & Support',
            subtitle: 'Customer care, returns and sizing guide',
            onTap: () => context.push('/help'),
          ),
          const SizedBox(height: NuviSpacing.xl),
          Center(
            child: Text(
              'NUVI KIDZ · Tiny styles, big smiles.',
              style: x.nunito(12.5, color: NuviColors.inkFaint),
            ),
          ),
        ],
      ),
    );
  }
}
