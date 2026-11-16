import 'package:flutter/material.dart';

import 'nuvi_chip.dart';

/// Selectable pill; renders as a [NuviChip].
class NuviPillSelector extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDisabled;
  final bool dense;
  final VoidCallback? onTap;

  const NuviPillSelector({
    super.key,
    required this.label,
    this.isSelected = false,
    this.isDisabled = false,
    this.dense = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDisabled ? 0.5 : 1,
      child: NuviChip(
        label: label,
        selected: isSelected,
        dense: dense,
        onTap: isDisabled ? null : onTap,
      ),
    );
  }
}
