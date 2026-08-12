import 'package:flutter/material.dart';
import '../theme/nuvi_colors.dart';
import '../theme/nuvi_radii.dart';
import '../theme/nuvi_typography.dart';

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

    return Container(
      decoration: BoxDecoration(
        color: NuviColors.surface,
        borderRadius: BorderRadius.circular(NuviRadii.pill),
        border: Border.all(color: NuviColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(
            icon: Icons.remove,
            enabled: canDecrement,
            onTap: () => onChanged?.call(quantity - 1),
          ),
          SizedBox(
            width: 32,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: NuviTypography.textTheme.labelLarge?.copyWith(
                color: isDisabled
                    ? NuviColors.onSurface.withValues(alpha: 0.5)
                    : NuviColors.onSurface,
              ),
            ),
          ),
          _buildButton(
            icon: Icons.add,
            enabled: canIncrement,
            onTap: () => onChanged?.call(quantity + 1),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(NuviRadii.pill),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? NuviColors.onSurface : NuviColors.border,
        ),
      ),
    );
  }
}
