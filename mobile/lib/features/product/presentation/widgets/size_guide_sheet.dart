import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_theme_ext.dart';
import '../../../../core/widgets/nuvi_bottom_sheet.dart';
import '../../../../core/widgets/nuvi_loading_indicator.dart';
import '../../../../core/widgets/nuvi_size_pill.dart';
import '../../../support/data/support_repository.dart';
import '../../../support/domain/store_policy.dart';

/// Opens the size guide for a product. Sizes come from the product; the
/// chart and measuring tips come from the Shopify page `size-guide`.
void showSizeGuideSheet(
  BuildContext context, {
  required List<String> sizes,
  String? selectedSize,
  ValueChanged<String>? onSelectSize,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => SizeGuideSheet(
      sizes: sizes,
      selectedSize: selectedSize,
      onSelectSize: onSelectSize,
    ),
  );
}

class SizeGuideSheet extends ConsumerStatefulWidget {
  final List<String> sizes;
  final String? selectedSize;
  final ValueChanged<String>? onSelectSize;

  const SizeGuideSheet({
    super.key,
    required this.sizes,
    this.selectedSize,
    this.onSelectSize,
  });

  @override
  ConsumerState<SizeGuideSheet> createState() => _SizeGuideSheetState();
}

class _SizeGuideSheetState extends ConsumerState<SizeGuideSheet> {
  late String? _size = widget.selectedSize;

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    final content = ref.watch(supportContentProvider);
    return NuviSheet(
      title: 'Size Guide',
      fullHeight: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.sizes.isNotEmpty) ...[
            Text('Sizes for this product', style: x.h3),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in widget.sizes)
                  NuviSizePill(
                    label: s,
                    selected: s == _size,
                    onTap: () {
                      setState(() => _size = s);
                      widget.onSelectSize?.call(s);
                    },
                  ),
              ],
            ),
            const SizedBox(height: NuviSpacing.lg),
          ],
          content.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: NuviLoadingIndicator()),
            ),
            error: (_, _) => _Note(
              text: 'We couldn’t load the size chart. Please try again.',
              onRetry: () => ref.invalidate(supportContentProvider),
            ),
            data: (c) => c.sizeGuide == null
                ? const _Note(
                    text:
                        'The size chart will appear here soon. Need help '
                        'choosing? Write to ${SupportRepository.supportEmail}.',
                  )
                : _GuideBody(guide: c.sizeGuide!, highlight: _size),
          ),
        ],
      ),
    );
  }
}

class _GuideBody extends StatelessWidget {
  final StorePolicy guide;
  final String? highlight;

  const _GuideBody({required this.guide, this.highlight});

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    final table = guide.firstTable;
    final text = table.isEmpty ? guide.body : guide.bodyWithoutTable;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (table.isNotEmpty) ...[
          Text('Size chart', style: x.h3),
          const SizedBox(height: 10),
          _SizeTable(rows: table, highlight: highlight),
          const SizedBox(height: NuviSpacing.lg),
        ],
        if (text.isNotEmpty)
          Text(text, style: x.nunito(14.5, color: NuviColors.ink, height: 1.6)),
      ],
    );
  }
}

/// Size chart; the row whose first cell matches [highlight] is tinted.
class _SizeTable extends StatelessWidget {
  final List<List<String>> rows;
  final String? highlight;

  const _SizeTable({required this.rows, this.highlight});

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    final cols = rows.map((r) => r.length).reduce((a, b) => a > b ? a : b);
    String norm(String v) => v.toLowerCase().replaceAll(RegExp(r'\s'), '');
    return ClipRRect(
      borderRadius: BorderRadius.circular(NuviRadii.card),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          defaultColumnWidth: const IntrinsicColumnWidth(),
          border: TableBorder.all(color: NuviColors.orderBorder),
          children: [
            for (final (i, row) in rows.indexed)
              TableRow(
                decoration: BoxDecoration(
                  color: i == 0
                      ? NuviColors.sageSoft
                      : (highlight != null &&
                            row.isNotEmpty &&
                            norm(row.first) == norm(highlight!))
                      ? NuviColors.goldSoft
                      : NuviColors.white,
                ),
                children: [
                  for (var c = 0; c < cols; c++)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Text(
                        c < row.length ? row[c] : '',
                        style: x.nunito(
                          13.5,
                          weight: i == 0 ? FontWeight.w800 : FontWeight.w500,
                          color: NuviColors.nightGreen,
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  final String text;
  final VoidCallback? onRetry;

  const _Note({required this.text, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NuviColors.goldSoft,
        borderRadius: BorderRadius.circular(NuviRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: x.nunito(14, color: NuviColors.ink)),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
