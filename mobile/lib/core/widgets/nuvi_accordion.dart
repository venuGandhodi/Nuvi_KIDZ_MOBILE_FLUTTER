import 'package:flutter/material.dart';
import '../theme/nuvi_colors.dart';
import '../theme/nuvi_typography.dart';
import '../theme/nuvi_spacing.dart';
import '../theme/nuvi_radii.dart';

class NuviAccordion extends StatefulWidget {
  final String title;
  final Widget content;
  final bool initiallyExpanded;

  const NuviAccordion({
    super.key,
    required this.title,
    required this.content,
    this.initiallyExpanded = false,
  });

  @override
  State<NuviAccordion> createState() => _NuviAccordionState();
}

class _NuviAccordionState extends State<NuviAccordion> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: NuviColors.surface,
        borderRadius: BorderRadius.circular(NuviRadii.small),
        border: Border.all(color: NuviColors.border),
      ),
      margin: const EdgeInsets.only(bottom: NuviSpacing.sm),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: widget.initiallyExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          title: Text(widget.title, style: NuviTypography.textTheme.labelLarge),
          trailing: Icon(
            _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: NuviColors.primary,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            NuviSpacing.md,
            0,
            NuviSpacing.md,
            NuviSpacing.md,
          ),
          children: [widget.content],
        ),
      ),
    );
  }
}
