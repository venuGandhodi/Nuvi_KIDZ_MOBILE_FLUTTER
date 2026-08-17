import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/nuvi_colors.dart';
import '../../../core/theme/nuvi_radii.dart';
import '../../../core/theme/nuvi_spacing.dart';
import '../../../core/theme/nuvi_typography.dart';
import '../../../core/utils/nuvi_logger.dart';
import '../../../core/widgets/nuvi_button.dart';
import '../../../core/widgets/nuvi_top_bar.dart';
import '../../cart/presentation/cart_controller.dart';
import '../../order/domain/shopify_order.dart';
import '../data/shopify_customer_repository.dart';
import 'customer_controller.dart';

class OrderDetailsScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen> {
  ShopifyOrder? _remoteOrder;
  bool _isLoadingRemote = false;
  String? _remoteErrorMessage;
  bool _attemptedRemoteFetch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndFetchRemoteOrderIfNeeded();
    });
  }

  void _checkAndFetchRemoteOrderIfNeeded() {
    final cleanId = widget.orderId.replaceAll('#', '');
    final notifier = ref.read(customerControllerProvider.notifier);
    final localOrder =
        notifier.getOrderById(cleanId) ??
        notifier.getOrderById('#$cleanId') ??
        notifier.getOrderById(widget.orderId);

    if (localOrder == null && !_attemptedRemoteFetch) {
      _fetchRemoteOrder();
    }
  }

  Future<void> _fetchRemoteOrder() async {
    setState(() {
      _isLoadingRemote = true;
      _remoteErrorMessage = null;
      _attemptedRemoteFetch = true;
    });

    try {
      nuviLog('NUVI-CUSTOMER', 'Fetching order remotely: ${widget.orderId}');
      final repo = ref.read(shopifyCustomerRepositoryProvider);
      final fetched = await repo.getCustomerOrder(widget.orderId);
      if (mounted) {
        setState(() {
          _remoteOrder = fetched;
          _isLoadingRemote = false;
          if (fetched == null) {
            _remoteErrorMessage = 'Order could not be found.';
          }
        });
      }
    } catch (e) {
      nuviLog('NUVI-CUSTOMER', 'Remote order fetch failed: $e');
      if (mounted) {
        setState(() {
          _isLoadingRemote = false;
          _remoteErrorMessage = 'Unable to load this order. Please try again.';
        });
      }
    }
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} at ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatPrice(ShopifyOrderMoney money) {
    final formatted = money.amount.toStringAsFixed(
      money.amount.truncateToDouble() == money.amount ? 0 : 2,
    );
    return money.currencyCode == 'INR'
        ? '₹$formatted'
        : '${money.currencyCode} $formatted';
  }

  Color _statusColor(String? status) {
    if (status == null) return NuviColors.onSurface.withValues(alpha: 0.6);
    final upper = status.toUpperCase();
    if (upper == 'PAID' || upper == 'FULFILLED') {
      return NuviColors.success;
    }
    if (upper == 'PENDING' || upper == 'UNFULFILLED') {
      return NuviColors.secondary;
    }
    if (upper == 'REFUNDED' || upper == 'VOIDED') {
      return NuviColors.error;
    }
    return NuviColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final customerState = ref.watch(customerControllerProvider);
    final cartState = ref.watch(cartControllerProvider);
    final notifier = ref.read(customerControllerProvider.notifier);

    final cleanId = widget.orderId.replaceAll('#', '');
    final localOrder =
        notifier.getOrderById(cleanId) ??
        notifier.getOrderById('#$cleanId') ??
        notifier.getOrderById(widget.orderId);
    final order = localOrder ?? _remoteOrder;

    final isLoading =
        (customerState.isLoading && localOrder == null) || _isLoadingRemote;

    return Scaffold(
      backgroundColor: NuviColors.surface,
      appBar: NuviTopBar(
        showBackButton: true,
        onBackTap: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/orders');
          }
        },
        cartItemCount: cartState.totalItemCount,
        onCartTap: () => context.go('/cart'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: NuviColors.primary),
            )
          : order == null
          ? _buildErrorState(
              context,
              _remoteErrorMessage ?? 'Order could not be found.',
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(NuviSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(NuviSpacing.lg),
                    decoration: BoxDecoration(
                      color: NuviColors.surfaceVariant.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(NuviRadii.card),
                      border: Border.all(
                        color: NuviColors.border.withValues(alpha: 0.8),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order.name.isNotEmpty
                                  ? order.name
                                  : 'Order #${order.orderNumber ?? ""}',
                              style: NuviTypography.textTheme.displayMedium
                                  ?.copyWith(
                                    color: NuviColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                            ),
                            Text(
                              _formatPrice(order.currentTotalPrice),
                              style: NuviTypography.textTheme.headlineMedium
                                  ?.copyWith(
                                    color: NuviColors.accent,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: NuviSpacing.xs),
                        Text(
                          'Placed on ${_formatDate(order.processedAt)}',
                          style: NuviTypography.textTheme.bodyMedium?.copyWith(
                            color: NuviColors.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: NuviSpacing.md),

                        // Status Badges
                        Wrap(
                          spacing: NuviSpacing.xs,
                          runSpacing: NuviSpacing.xs,
                          children: [
                            if (order.financialStatus != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _statusColor(
                                    order.financialStatus,
                                  ).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(
                                    NuviRadii.pill,
                                  ),
                                ),
                                child: Text(
                                  'Payment: ${order.financialStatus!.toUpperCase()}',
                                  style: NuviTypography.textTheme.labelSmall
                                      ?.copyWith(
                                        color: _statusColor(
                                          order.financialStatus,
                                        ),
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            if (order.fulfillmentStatus != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _statusColor(
                                    order.fulfillmentStatus,
                                  ).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(
                                    NuviRadii.pill,
                                  ),
                                ),
                                child: Text(
                                  'Status: ${order.fulfillmentStatus!.toUpperCase()}',
                                  style: NuviTypography.textTheme.labelSmall
                                      ?.copyWith(
                                        color: _statusColor(
                                          order.fulfillmentStatus,
                                        ),
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: NuviSpacing.xl),

                  // Line Items Heading
                  Text(
                    'Items in this Order (${order.lineItems.length})',
                    style: NuviTypography.textTheme.headlineMedium?.copyWith(
                      color: NuviColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: NuviSpacing.md),

                  // Line Items List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: order.lineItems.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: NuviSpacing.sm),
                    itemBuilder: (context, index) {
                      final item = order.lineItems[index];
                      return Container(
                        padding: const EdgeInsets.all(NuviSpacing.md),
                        decoration: BoxDecoration(
                          color: NuviColors.surfaceVariant.withValues(
                            alpha: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(NuviRadii.card),
                          border: Border.all(
                            color: NuviColors.border.withValues(alpha: 0.6),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Product Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                NuviRadii.card / 2,
                              ),
                              child: Container(
                                width: 56,
                                height: 56,
                                color: NuviColors.surfaceVariant,
                                child:
                                    item.imageUrl != null &&
                                        item.imageUrl!.isNotEmpty
                                    ? Image.network(
                                        item.imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.checkroom,
                                                  color: NuviColors.primary,
                                                ),
                                      )
                                    : const Icon(
                                        Icons.checkroom,
                                        color: NuviColors.primary,
                                      ),
                              ),
                            ),
                            const SizedBox(width: NuviSpacing.md),

                            // Item Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: NuviTypography.textTheme.bodyLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: NuviColors.primary,
                                        ),
                                  ),
                                  if (item.variantTitle != null &&
                                      item.variantTitle!.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      item.variantTitle!,
                                      style: NuviTypography.textTheme.bodySmall
                                          ?.copyWith(
                                            color: NuviColors.onSurface
                                                .withValues(alpha: 0.6),
                                          ),
                                    ),
                                  ],
                                  const SizedBox(height: 2),
                                  Text(
                                    'Qty: ${item.quantity}',
                                    style: NuviTypography.textTheme.bodySmall
                                        ?.copyWith(
                                          color: NuviColors.onSurface
                                              .withValues(alpha: 0.8),
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                            ),

                            // Item Price
                            Text(
                              _formatPrice(item.originalTotalPrice),
                              style: NuviTypography.textTheme.bodyLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: NuviColors.primary,
                                  ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: NuviSpacing.xl),

                  // Financial Summary Card
                  Container(
                    padding: const EdgeInsets.all(NuviSpacing.lg),
                    decoration: BoxDecoration(
                      color: NuviColors.surfaceVariant.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(NuviRadii.card),
                      border: Border.all(
                        color: NuviColors.border.withValues(alpha: 0.8),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Summary',
                          style: NuviTypography.textTheme.headlineMedium
                              ?.copyWith(
                                color: NuviColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: NuviSpacing.md),
                        if (order.totalShippingPrice != null) ...[
                          _buildSummaryRow(
                            'Shipping',
                            _formatPrice(order.totalShippingPrice!),
                          ),
                          const SizedBox(height: NuviSpacing.xs),
                        ],
                        if (order.currentTotalTax != null) ...[
                          _buildSummaryRow(
                            'Taxes',
                            _formatPrice(order.currentTotalTax!),
                          ),
                          const SizedBox(height: NuviSpacing.xs),
                        ],
                        const Divider(color: NuviColors.border),
                        const SizedBox(height: NuviSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Paid',
                              style: NuviTypography.textTheme.bodyLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: NuviColors.primary,
                                  ),
                            ),
                            Text(
                              _formatPrice(order.currentTotalPrice),
                              style: NuviTypography.textTheme.headlineMedium
                                  ?.copyWith(
                                    color: NuviColors.accent,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: NuviSpacing.xl),

                  // Action Buttons
                  NuviButton(
                    text: 'BACK TO MY ORDERS',
                    type: NuviButtonType.secondary,
                    onPressed: () => context.go('/orders'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: NuviTypography.textTheme.bodyMedium?.copyWith(
            color: NuviColors.onSurface.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: NuviTypography.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: NuviColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(NuviSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 48, color: NuviColors.primary),
            const SizedBox(height: NuviSpacing.md),
            Text(
              'Order Not Found',
              style: NuviTypography.textTheme.headlineMedium?.copyWith(
                color: NuviColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: NuviSpacing.xs),
            Text(
              message,
              style: NuviTypography.textTheme.bodyMedium?.copyWith(
                color: NuviColors.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: NuviSpacing.xl),
            NuviButton(
              text: 'TRY AGAIN',
              type: NuviButtonType.primary,
              onPressed: _fetchRemoteOrder,
            ),
            const SizedBox(height: NuviSpacing.md),
            NuviButton(
              text: 'VIEW ALL ORDERS',
              type: NuviButtonType.secondary,
              onPressed: () => context.go('/orders'),
            ),
          ],
        ),
      ),
    );
  }
}
