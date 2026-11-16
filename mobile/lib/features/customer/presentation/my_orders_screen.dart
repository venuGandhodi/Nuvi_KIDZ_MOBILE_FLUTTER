import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/nuvi_colors.dart';
import '../../../core/theme/nuvi_spacing.dart';
import '../../../core/theme/nuvi_theme_ext.dart';
import '../../../core/widgets/nuvi_chip.dart';
import '../../../core/widgets/nuvi_empty_state.dart';
import '../../../core/widgets/nuvi_section_header.dart';
import '../../order/domain/shopify_order.dart';
import '../../../core/widgets/nuvi_loading_indicator.dart';
import 'customer_controller.dart';
import 'widgets/order_card.dart';

enum _OrderFilter { all, processing, shipped, cancelled }

extension on _OrderFilter {
  String get label => switch (this) {
    _OrderFilter.all => 'All',
    _OrderFilter.processing => 'Processing',
    _OrderFilter.shipped => 'Shipped',
    _OrderFilter.cancelled => 'Cancelled',
  };

  bool matches(ShopifyOrder order) {
    final fin = order.financialStatus?.toUpperCase() ?? '';
    final ful = order.fulfillmentStatus?.toUpperCase() ?? '';
    final cancelled = fin == 'VOIDED' || fin == 'REFUNDED';
    return switch (this) {
      _OrderFilter.all => true,
      _OrderFilter.cancelled => cancelled,
      _OrderFilter.shipped => !cancelled && ful == 'FULFILLED',
      _OrderFilter.processing => !cancelled && ful != 'FULFILLED',
    };
  }
}

class MyOrdersScreen extends ConsumerStatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  ConsumerState<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends ConsumerState<MyOrdersScreen> {
  _OrderFilter _filter = _OrderFilter.all;

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    final customerState = ref.watch(customerControllerProvider);
    final orders = customerState.orders;
    final visible = orders.where(_filter.matches).toList();

    return Material(
      color: NuviColors.cream,
      child: customerState.isLoading
          ? const Center(child: NuviLoadingIndicator())
          : RefreshIndicator(
              color: NuviColors.ink,
              backgroundColor: NuviColors.cream,
              onRefresh: () =>
                  ref.read(customerControllerProvider.notifier).loadCustomer(),
              child: orders.isEmpty
                  ? _buildEmptyOrdersState(context)
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(
                        NuviSpacing.gutter,
                        NuviSpacing.sm,
                        NuviSpacing.gutter,
                        NuviSpacing.xl,
                      ),
                      children: [
                        const NuviEyebrow('My Orders', lines: false),
                        const SizedBox(height: 4),
                        Text('Order History', style: x.h1),
                        const SizedBox(height: NuviSpacing.s12),
                        Wrap(
                          spacing: NuviSpacing.sm,
                          children: [
                            for (final f in _OrderFilter.values)
                              NuviChip(
                                label: f.label,
                                selected: _filter == f,
                                onTap: () => setState(() => _filter = f),
                              ),
                          ],
                        ),
                        const SizedBox(height: NuviSpacing.s12),
                        if (visible.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: NuviSpacing.xl,
                            ),
                            child: Text(
                              'No ${_filter.label.toLowerCase()} orders right now.',
                              textAlign: TextAlign.center,
                              style: x.bodyMuted,
                            ),
                          ),
                        for (final order in visible) ...[
                          OrderCard(
                            order: order,
                            onTap: () {
                              final targetParam = order.name.isNotEmpty
                                  ? order.name.replaceAll('#', '')
                                  : order.id;
                              context.push('/orders/$targetParam');
                            },
                          ),
                          const SizedBox(height: NuviSpacing.md),
                        ],
                      ],
                    ),
            ),
    );
  }

  Widget _buildEmptyOrdersState(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.08),
        NuviEmptyState(
          title: 'No orders yet',
          message:
              'When you place orders through Shopify, they will appear here.',
          actionLabel: 'START SHOPPING',
          onAction: () => context.go('/home'),
        ),
      ],
    );
  }
}
