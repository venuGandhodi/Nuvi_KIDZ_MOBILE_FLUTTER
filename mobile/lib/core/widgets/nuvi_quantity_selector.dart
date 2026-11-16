import 'package:flutter/material.dart';

import '../theme/nuvi_colors.dart';
import '../theme/nuvi_radii.dart';
import '../theme/nuvi_theme_ext.dart';
import 'nuvi_pressable.dart';

/// Pill stepper: − / value / +. Each side is enabled independently so
/// callers keep their own rules (e.g. the bag removes the line at 1).
class NuviQuantityStepper extends StatelessWidget {
  final int value;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;
  final Color borderColor;
  final Color? background;

  const NuviQuantityStepper({
    super.key,
    required this.value,
    this.onDecrease,
    this.onIncrease,
    this.borderColor = NuviColors.line,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: background ?? NuviColors.card,
        borderRadius: BorderRadius.circular(NuviRadii.pill),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove_rounded,
            label: 'Decrease quantity',
            onTap: onDecrease,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 26),
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: x.baloo(15, weight: FontWeight.w700),
            ),
          ),
          _StepButton(
            icon: Icons.add_rounded,
            label: 'Increase quantity',
            onTap: onIncrease,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _StepButton({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return NuviPressable(
      onTap: onTap,
      semanticLabel: label,
      child: SizedBox(
        width: 40,
        height: 36,
        child: Icon(
          icon,
          size: 18,
          color: onTap == null ? NuviColors.inkFaint : NuviColors.ink,
        ),
      ),
    );
  }
}

class NuviQuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int>? onChanged;
  final bool isDisabled;

  const NuviQuantitySelector({
    super.key,
    required this.quantity,
    this.onChanged,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final canDecrement = !isDisabled && quantity > 1;
    final canIncrement = !isDisabled && quantity < 99;
    return NuviQuantityStepper(
      value: quantity,
      onDecrease: canDecrement ? () => onChanged?.call(quantity - 1) : null,
      onIncrease: canIncrement ? () => onChanged?.call(quantity + 1) : null,
    );
  }
}
