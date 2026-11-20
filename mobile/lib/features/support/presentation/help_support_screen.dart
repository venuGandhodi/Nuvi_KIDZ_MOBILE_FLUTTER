import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/nuvi_colors.dart';
import '../../../core/theme/nuvi_spacing.dart';
import '../../../core/theme/nuvi_theme_ext.dart';
import '../../../core/widgets/nuvi_empty_state.dart';
import '../../../core/widgets/nuvi_loading_indicator.dart';
import '../../../core/widgets/nuvi_menu_tile.dart';
import '../../../core/widgets/nuvi_toast.dart';
import '../../../core/widgets/nuvi_top_bar.dart';
import '../data/support_repository.dart';
import '../domain/store_policy.dart';
import 'policy_sheet.dart';

/// Help & Support: contact the store, plus the size guide and policies
/// published in Shopify.
class HelpSupportScreen extends ConsumerWidget {
  const HelpSupportScreen({super.key});

  Future<void> _email(BuildContext context) async {
    final uri = Uri(scheme: 'mailto', path: SupportRepository.supportEmail);
    final opened = await launchUrl(uri);
    if (!opened && context.mounted) {
      NuviToast.show(
        context,
        message: 'Write to us at ${SupportRepository.supportEmail}',
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final x = context.nuvi;
    final content = ref.watch(supportContentProvider);
    return Scaffold(
      backgroundColor: NuviColors.cream,
      appBar: NuviTopBar(
        title: Text('Help & Support', style: x.h3),
        showBackButton: true,
        showCart: false,
      ),
      body: RefreshIndicator(
        color: NuviColors.ink,
        onRefresh: () => ref.refresh(supportContentProvider.future),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            NuviSpacing.gutter,
            NuviSpacing.sm,
            NuviSpacing.gutter,
            NuviSpacing.xl,
          ),
          children: [
            Text('Contact us', style: x.h3),
            const SizedBox(height: NuviSpacing.s12),
            NuviMenuTile(
              icon: Icons.mail_outline_rounded,
              iconColor: NuviColors.leaf,
              tint: NuviColors.sageSoft,
              title: 'Email customer care',
              subtitle: SupportRepository.supportEmail,
              onTap: () => _email(context),
            ),
            const SizedBox(height: NuviSpacing.lg),
            Text('Returns, shipping & sizing', style: x.h3),
            const SizedBox(height: NuviSpacing.s12),
            content.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: NuviSpacing.xl),
                child: Center(child: NuviLoadingIndicator()),
              ),
              error: (_, _) => NuviEmptyState(
                title: 'We couldn’t load help topics',
                message: 'Check your connection and try again.',
                actionLabel: 'Retry',
                onAction: () => ref.invalidate(supportContentProvider),
                mascotSize: 80,
              ),
              data: (c) => c.all.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'Help topics will appear here soon.',
                        textAlign: TextAlign.center,
                        style: x.nunito(14, color: NuviColors.inkMuted),
                      ),
                    )
                  : Column(
                      children: [
                        for (final p in c.all) ...[
                          _PolicyTile(policy: p, isSizeGuide: p == c.sizeGuide),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicyTile extends StatelessWidget {
  final StorePolicy policy;
  final bool isSizeGuide;

  const _PolicyTile({required this.policy, required this.isSizeGuide});

  @override
  Widget build(BuildContext context) {
    final t = policy.title.toLowerCase();
    final (icon, color, tint) = isSizeGuide
        ? (Icons.straighten_rounded, NuviColors.amber, NuviColors.goldSoft)
        : t.contains('refund') || t.contains('return')
        ? (
            Icons.assignment_return_outlined,
            NuviColors.sale,
            NuviColors.saleSoft,
          )
        : t.contains('ship')
        ? (Icons.local_shipping_outlined, NuviColors.leaf, NuviColors.sageSoft)
        : t.contains('privacy')
        ? (
            Icons.lock_outline_rounded,
            NuviTone.lavender.accent,
            NuviTone.lavender.tint,
          )
        : (Icons.description_outlined, NuviTone.sky.accent, NuviTone.sky.tint);
    return NuviMenuTile(
      icon: icon,
      iconColor: color,
      tint: tint,
      title: policy.title,
      subtitle: policy.body.split('\n').first,
      onTap: () => showPolicySheet(context, policy),
    );
  }
}
