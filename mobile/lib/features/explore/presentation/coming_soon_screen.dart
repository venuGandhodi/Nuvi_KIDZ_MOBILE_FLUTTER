import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/nuvi_colors.dart';
import '../../../core/widgets/nuvi_empty_state.dart';

/// Placeholder for tabs whose content isn't ready yet (Styled, NUVI World).
class ComingSoonScreen extends StatelessWidget {
  final String title;
  final String message;

  const ComingSoonScreen({
    super.key,
    required this.title,
    required this.message,
  });

  const ComingSoonScreen.styled({super.key})
    : title = 'Styled by NUVI',
      message =
          'Complete looks and curated outfits for every occasion are coming soon.';

  const ComingSoonScreen.world({super.key})
    : title = 'NUVI World',
      message =
          'Stories, parenting tips and little adventures from the NUVI family are coming soon.';

  @override
  Widget build(BuildContext context) {
    return Material(
      color: NuviColors.cream,
      child: NuviEmptyState(
        title: title,
        message: message,
        actionLabel: 'Keep shopping',
        onAction: () => context.go('/home'),
      ),
    );
  }
}
