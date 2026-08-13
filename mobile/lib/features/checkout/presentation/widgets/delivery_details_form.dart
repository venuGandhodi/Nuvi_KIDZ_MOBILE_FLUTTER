import 'package:flutter/material.dart';
import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_typography.dart';
import '../../../../core/widgets/nuvi_input_field.dart';
import '../../domain/shipping_address.dart';

class DeliveryDetailsForm extends StatelessWidget {
  final ShippingAddress address;
  final ValueChanged<ShippingAddress> onChanged;

  const DeliveryDetailsForm({
    super.key,
    required this.address,
    required this.onChanged,
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
                Icons.local_shipping_outlined,
                color: NuviColors.primary,
                size: 24,
              ),
              const SizedBox(width: NuviSpacing.xs),
              Text(
                'Delivery Details',
                style: NuviTypography.textTheme.headlineMedium?.copyWith(
                  color: NuviColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: NuviSpacing.md),

          // First Name & Last Name Row
          Row(
            children: [
              Expanded(
                child: NuviInputField(
                  label: 'First Name',
                  hint: 'Jane',
                  initialValue: address.firstName,
                  onChanged: (val) =>
                      onChanged(address.copyWith(firstName: val)),
                ),
              ),
              const SizedBox(width: NuviSpacing.md),
              Expanded(
                child: NuviInputField(
                  label: 'Last Name',
                  hint: 'Doe',
                  initialValue: address.lastName,
                  onChanged: (val) =>
                      onChanged(address.copyWith(lastName: val)),
                ),
              ),
            ],
          ),
          const SizedBox(height: NuviSpacing.md),

          // Address
          NuviInputField(
            label: 'Address',
            hint: '123 Playful Lane',
            initialValue: address.address,
            onChanged: (val) => onChanged(address.copyWith(address: val)),
          ),
          const SizedBox(height: NuviSpacing.md),

          // City, State, Zip Row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: NuviInputField(
                  label: 'City',
                  hint: 'Smileville',
                  initialValue: address.city,
                  onChanged: (val) => onChanged(address.copyWith(city: val)),
                ),
              ),
              const SizedBox(width: NuviSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'State',
                      style: NuviTypography.textTheme.labelMedium?.copyWith(
                        color: NuviColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: NuviColors.surface,
                        borderRadius: BorderRadius.circular(NuviRadii.pill / 2),
                        border: Border.all(color: NuviColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: address.state.isEmpty ? 'CA' : address.state,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(value: 'CA', child: Text('CA')),
                            DropdownMenuItem(value: 'NY', child: Text('NY')),
                            DropdownMenuItem(value: 'TX', child: Text('TX')),
                            DropdownMenuItem(value: 'FL', child: Text('FL')),
                            DropdownMenuItem(value: 'WA', child: Text('WA')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              onChanged(address.copyWith(state: val));
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: NuviSpacing.sm),
              Expanded(
                flex: 2,
                child: NuviInputField(
                  label: 'Zip Code',
                  hint: '90210',
                  keyboardType: TextInputType.number,
                  initialValue: address.zipCode,
                  onChanged: (val) => onChanged(address.copyWith(zipCode: val)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
