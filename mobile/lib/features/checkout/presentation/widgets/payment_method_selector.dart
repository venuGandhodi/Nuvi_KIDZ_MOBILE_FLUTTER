import 'package:flutter/material.dart';
import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_typography.dart';
import '../../../../core/widgets/nuvi_input_field.dart';
import '../../domain/payment_method_type.dart';

class PaymentMethodSelector extends StatelessWidget {
  final PaymentMethodType selectedMethod;
  final ValueChanged<PaymentMethodType> onMethodSelected;
  final ValueChanged<String> onCardNumberChanged;
  final ValueChanged<String> onExpiryDateChanged;
  final ValueChanged<String> onCvcChanged;
  final ValueChanged<String> onUpiIdChanged;

  const PaymentMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onMethodSelected,
    required this.onCardNumberChanged,
    required this.onExpiryDateChanged,
    required this.onCvcChanged,
    required this.onUpiIdChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(NuviSpacing.lg),
      decoration: BoxDecoration(
        color: NuviColors.surfaceVariant.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(NuviRadii.card),
        border: Border.all(color: NuviColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.payments_outlined,
                color: NuviColors.secondary,
                size: 24,
              ),
              const SizedBox(width: NuviSpacing.xs),
              Text(
                'Payment',
                style: NuviTypography.textTheme.headlineMedium?.copyWith(
                  color: NuviColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: NuviSpacing.md),

          // Credit Card Option
          _buildPaymentOption(
            type: PaymentMethodType.creditCard,
            title: 'Credit Card',
            icon: Icons.credit_card,
            child: Column(
              children: [
                const SizedBox(height: NuviSpacing.md),
                NuviInputField(
                  label: '',
                  hint: 'Card Number',
                  keyboardType: TextInputType.number,
                  onChanged: onCardNumberChanged,
                ),
                const SizedBox(height: NuviSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: NuviInputField(
                        label: '',
                        hint: 'MM/YY',
                        keyboardType: TextInputType.datetime,
                        onChanged: onExpiryDateChanged,
                      ),
                    ),
                    const SizedBox(width: NuviSpacing.md),
                    Expanded(
                      child: NuviInputField(
                        label: '',
                        hint: 'CVC',
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        onChanged: onCvcChanged,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: NuviSpacing.sm),

          // Google Pay Option
          _buildPaymentOption(
            type: PaymentMethodType.googlePay,
            title: 'Google Pay',
            icon: Icons.contactless,
          ),
          const SizedBox(height: NuviSpacing.sm),

          // UPI Option
          _buildPaymentOption(
            type: PaymentMethodType.upi,
            title: 'UPI ID',
            icon: Icons.qr_code_scanner,
            child: Column(
              children: [
                const SizedBox(height: NuviSpacing.md),
                NuviInputField(
                  label: '',
                  hint: 'user@upi',
                  onChanged: onUpiIdChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required PaymentMethodType type,
    required String title,
    required IconData icon,
    Widget? child,
  }) {
    final isSelected = selectedMethod == type;

    return GestureDetector(
      onTap: () => onMethodSelected(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(NuviSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? NuviColors.primary.withValues(alpha: 0.05)
              : NuviColors.surface,
          borderRadius: BorderRadius.circular(NuviRadii.card / 2),
          border: Border.all(
            color: isSelected ? NuviColors.primary : NuviColors.border,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? NuviColors.primary
                          : NuviColors.border,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: NuviColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
                Text(
                  title,
                  style: NuviTypography.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: NuviColors.primary,
                  ),
                ),
                const Spacer(),
                Icon(icon, color: NuviColors.primary.withValues(alpha: 0.7)),
              ],
            ),
            if (isSelected && child != null) child,
          ],
        ),
      ),
    );
  }
}
