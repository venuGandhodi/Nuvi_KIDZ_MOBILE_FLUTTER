import 'package:flutter/material.dart';

import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_typography.dart';
import '../../../../core/widgets/nuvi_button.dart';

class ProductDeliveryInfoSection extends StatefulWidget {
  const ProductDeliveryInfoSection({super.key});

  @override
  State<ProductDeliveryInfoSection> createState() =>
      _ProductDeliveryInfoSectionState();
}

class _ProductDeliveryInfoSectionState
    extends State<ProductDeliveryInfoSection> {
  String? _pincode;

  Future<void> _openPincodeSheet() async {
    final controller = TextEditingController(text: _pincode);
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: NuviColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(NuviRadii.card),
        ),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: NuviSpacing.lg,
            right: NuviSpacing.lg,
            top: NuviSpacing.lg,
            bottom:
                MediaQuery.of(sheetContext).viewInsets.bottom + NuviSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Check delivery date',
                style: NuviTypography.textTheme.headlineMedium?.copyWith(
                  color: NuviColors.primary,
                ),
              ),
              const SizedBox(height: NuviSpacing.md),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  hintText: 'Enter 6-digit pincode',
                  counterText: '',
                ),
              ),
              const SizedBox(height: NuviSpacing.md),
              NuviButton.primary(
                text: 'Check',
                onPressed: () {
                  final value = controller.text.trim();
                  if (value.length == 6) {
                    Navigator.of(sheetContext).pop(value);
                  }
                },
              ),
            ],
          ),
        );
      },
    );

    if (result != null && mounted) {
      setState(() => _pincode = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(NuviSpacing.md),
      decoration: BoxDecoration(
        color: NuviColors.surface,
        borderRadius: BorderRadius.circular(NuviRadii.card / 2),
        border: Border.all(color: NuviColors.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _pincode == null
                      ? 'Get it in 3-4 days'
                      : 'Delivery to $_pincode in 3-4 days',
                  style: NuviTypography.textTheme.labelLarge?.copyWith(
                    fontSize: 12,
                    color: NuviColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _openPincodeSheet,
                child: Text(
                  _pincode == null ? 'Enter Pincode' : 'Change',
                  style: NuviTypography.textTheme.bodySmall?.copyWith(
                    color: NuviColors.accent,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Select pincode and size to get the exact delivery date',
            style: NuviTypography.textTheme.bodySmall?.copyWith(
              color: NuviColors.onSurface.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: NuviSpacing.sm),
          Divider(color: NuviColors.border.withValues(alpha: 0.6), height: 1),
          const SizedBox(height: NuviSpacing.sm),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _DeliveryInfoItem(
                icon: Icons.replay_outlined,
                label: '7 Day Return',
              ),
              _DeliveryInfoItem(
                icon: Icons.swap_horiz,
                label: '7 Day Exchange',
              ),
              _DeliveryInfoItem(
                icon: Icons.currency_rupee,
                label: 'Cash on Delivery',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeliveryInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DeliveryInfoItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: NuviColors.primary),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: NuviTypography.textTheme.bodySmall?.copyWith(
            color: NuviColors.onSurface.withValues(alpha: 0.7),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
