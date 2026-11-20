import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/services.dart';

import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_theme_ext.dart';
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

  final TextEditingController _pinController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _pinController.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      setState(() => _errorText = 'Enter a valid 6-digit pincode.');
      return;
    }
    setState(() => _errorText = null);
    FocusScope.of(context).unfocus();
    _runCheck(value);
  }

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return Container(
      padding: const EdgeInsets.all(NuviSpacing.md),
      decoration: BoxDecoration(
        color: NuviColors.cardPdp,
        borderRadius: BorderRadius.circular(NuviRadii.cardLarge),
        border: Border.all(color: NuviColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: x.goldSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_shipping_outlined,
                  size: 19,
                  color: NuviColors.ink,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Check delivery',
                  style: x.baloo(
                    16,
                    weight: FontWeight.w700,
                    color: NuviColors.pdpInk,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: NuviSpacing.s12),
          Container(
            height: 48,
            padding: const EdgeInsets.only(left: 16, right: 4),
            decoration: BoxDecoration(
              color: NuviColors.card,
              borderRadius: BorderRadius.circular(NuviRadii.pill),
              border: Border.all(
                color: _errorText != null ? NuviColors.sale : NuviColors.line,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    onSubmitted: (_) => _submit(),
                    style: x.nunito(15, weight: FontWeight.w700),
                    decoration: const InputDecoration(
                      hintText: 'Enter 6-digit pincode',
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                NuviButton(
                  text: _state == _CheckState.checking ? 'Checking' : 'Check',
                  type: NuviButtonType.dark,
                  isFullWidth: false,
                  height: 40,
                  isLoading: _state == _CheckState.checking,
                  onPressed: _state == _CheckState.checking ? null : _submit,
                ),
              ],
            ),
          ),
          if (_errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 14),
              child: Text(
                _errorText!,
                style: x.nunito(
                  12.5,
                  weight: FontWeight.w700,
                  color: NuviColors.sale,
                ),
              ),
            ),
          const SizedBox(height: NuviSpacing.s12),
          if (_pincode != null && _state != _CheckState.initial) ...[
            Text('Pincode $_pincode', style: x.small),
            const SizedBox(height: 4),
          ],
          _buildHeadline(),
          const SizedBox(height: 4),
          _buildSubtext(),
        ],
      ),
    );
  }

  Widget _resultLine(String text, {bool? ok}) {
    final x = context.nuvi;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ok != null) ...[
          Icon(
            ok ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 18,
            color: ok ? NuviColors.leaf : NuviColors.sale,
          ),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: Text(
            text,
            style: x.nunito(
              13.5,
              weight: FontWeight.w700,
              color: NuviColors.pdpInk,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeadline() {
    switch (_state) {
      case _CheckState.initial:
        return _resultLine('Check delivery availability');
      case _CheckState.checking:
        return _resultLine('Checking delivery availability...');
      case _CheckState.serviceable:
        final date = _result?.estimatedDeliveryDate;
        return _resultLine(
          date != null
              ? 'Get it by ${_formatDate(date)}'
              : 'Delivery available to this pincode',
          ok: true,
        );
      case _CheckState.notServiceable:
        return _resultLine(
          'Sorry, we currently cannot deliver to this pincode.',
          ok: false,
        );
      case _CheckState.unavailable:
        return _resultLine(
          'Unable to check delivery right now. Please try again.',
          ok: false,
        );
    }
  }

  Widget _buildSubtext() {
    final x = context.nuvi;
    if (_state == _CheckState.serviceable && _result != null) {
      return Column(
        children: [
          _resultLine(
            _result!.codAvailable ? 'COD available' : 'COD unavailable',
            ok: _result!.codAvailable,
          ),
          const SizedBox(height: 2),
          _resultLine(
            _result!.prepaidAvailable
                ? 'Prepaid available'
                : 'Prepaid unavailable',
            ok: _result!.prepaidAvailable,
          ),
        ],
      );
    }
    return Text(
      'Select pincode and size to get the exact delivery date',
      style: x.small,
    );
  }
}

/// One-line promises: returns, exchange, cash on delivery.
/// Three store promises in a white card, icon above label.
class ProductPromisesRow extends StatelessWidget {
  const ProductPromisesRow({super.key});

  static const _items = [
    (Icons.autorenew_rounded, '7 Day Return'),
    (Icons.swap_horiz_rounded, '7 Day Exchange'),
    (Icons.payments_outlined, 'Cash on Delivery'),
  ];

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: BoxDecoration(
        color: NuviColors.white,
        borderRadius: BorderRadius.circular(NuviRadii.cardLarge),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (final (i, (icon, label)) in _items.indexed) ...[
              if (i > 0)
                const VerticalDivider(width: 1, color: NuviColors.line),
              Expanded(
                child: Column(
                  children: [
                    Icon(icon, size: 26, color: x.leaf),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: x.nunito(
                        13,
                        weight: FontWeight.w800,
                        color: NuviColors.nightGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
