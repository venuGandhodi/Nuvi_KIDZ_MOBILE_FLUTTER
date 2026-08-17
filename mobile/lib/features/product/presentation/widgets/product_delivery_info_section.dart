import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_typography.dart';
import '../../../../core/widgets/nuvi_button.dart';
import '../../domain/delivery_serviceability.dart';
import '../delivery_serviceability_controller.dart';

enum _CheckState { initial, checking, serviceable, notServiceable, unavailable }

const _monthNames = [
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

String _formatDate(DateTime date) {
  return '${_monthNames[date.month - 1]} ${date.day}';
}

class ProductDeliveryInfoSection extends ConsumerStatefulWidget {
  const ProductDeliveryInfoSection({super.key});

  @override
  ConsumerState<ProductDeliveryInfoSection> createState() =>
      _ProductDeliveryInfoSectionState();
}

class _ProductDeliveryInfoSectionState
    extends ConsumerState<ProductDeliveryInfoSection> {
  _CheckState _state = _CheckState.initial;
  DeliveryServiceabilityResult? _result;
  String? _pincode;

  Future<void> _runCheck(String pincode) async {
    setState(() {
      _pincode = pincode;
      _state = _CheckState.checking;
    });

    final repository = ref.read(deliveryServiceabilityRepositoryProvider);
    try {
      final result = await repository.checkPincode(pincode);
      if (!mounted) return;
      setState(() {
        _result = result;
        _state = result.serviceable
            ? _CheckState.serviceable
            : _CheckState.notServiceable;
      });
    } on DeliveryCheckException {
      if (!mounted) return;
      setState(() {
        _result = null;
        _state = _CheckState.unavailable;
      });
    }
  }

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
        String? errorText;
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: NuviSpacing.lg,
                right: NuviSpacing.lg,
                top: NuviSpacing.lg,
                bottom:
                    MediaQuery.of(sheetContext).viewInsets.bottom +
                    NuviSpacing.lg,
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
                    decoration: InputDecoration(
                      hintText: 'Enter 6-digit pincode',
                      counterText: '',
                      errorText: errorText,
                    ),
                  ),
                  const SizedBox(height: NuviSpacing.md),
                  NuviButton.primary(
                    text: 'Check',
                    onPressed: () {
                      final value = controller.text.trim();
                      if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                        setSheetState(
                          () => errorText = 'Enter a valid 6-digit pincode.',
                        );
                        return;
                      }
                      Navigator.of(sheetContext).pop(value);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result != null && mounted) {
      _runCheck(result);
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
              Expanded(child: _buildHeadline()),
              GestureDetector(
                onTap: _state == _CheckState.checking
                    ? null
                    : _openPincodeSheet,
                child: Text(
                  _state == _CheckState.initial ? 'Enter Pincode' : 'Change',
                  style: NuviTypography.textTheme.bodySmall?.copyWith(
                    color: NuviColors.accent,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _buildSubtext(),
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

  Widget _buildHeadline() {
    final style = NuviTypography.textTheme.labelLarge?.copyWith(
      fontSize: 12,
      color: NuviColors.primary,
      fontWeight: FontWeight.bold,
    );

    switch (_state) {
      case _CheckState.initial:
        return Text('Check delivery availability', style: style);
      case _CheckState.checking:
        return Text('Checking delivery availability...', style: style);
      case _CheckState.serviceable:
        final date = _result?.estimatedDeliveryDate;
        return Text(
          date != null
              ? 'Get it by ${_formatDate(date)}'
              : 'Delivery available to this pincode',
          style: style,
        );
      case _CheckState.notServiceable:
        return Text(
          'Sorry, we currently cannot deliver to this pincode.',
          style: style,
        );
      case _CheckState.unavailable:
        return Text(
          'Unable to check delivery right now. Please try again.',
          style: style,
        );
    }
  }

  Widget _buildSubtext() {
    final smallStyle = NuviTypography.textTheme.bodySmall?.copyWith(
      color: NuviColors.onSurface.withValues(alpha: 0.6),
      fontSize: 11,
    );

    if (_state == _CheckState.serviceable && _result != null) {
      return Row(
        children: [
          _AvailabilityBadge(label: 'COD', available: _result!.codAvailable),
          const SizedBox(width: NuviSpacing.sm),
          _AvailabilityBadge(
            label: 'Prepaid',
            available: _result!.prepaidAvailable,
          ),
        ],
      );
    }

    return Text(
      'Select pincode and size to get the exact delivery date',
      style: smallStyle,
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  final String label;
  final bool available;

  const _AvailabilityBadge({required this.label, required this.available});

  @override
  Widget build(BuildContext context) {
    final color = available ? NuviColors.success : NuviColors.error;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          available ? Icons.check_circle : Icons.cancel,
          size: 12,
          color: color,
        ),
        const SizedBox(width: 3),
        Text(
          available ? '$label available' : '$label unavailable',
          style: NuviTypography.textTheme.bodySmall?.copyWith(
            color: color,
            fontSize: 10,
          ),
        ),
      ],
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
