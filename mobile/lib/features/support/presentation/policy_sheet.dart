import 'package:flutter/material.dart';

import '../../../core/theme/nuvi_colors.dart';
import '../../../core/theme/nuvi_theme_ext.dart';
import '../../../core/widgets/nuvi_bottom_sheet.dart';
import '../domain/store_policy.dart';

/// Opens a Shopify policy / help page in a full-height reading sheet.
void showPolicySheet(BuildContext context, StorePolicy policy) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => NuviSheet(
      title: policy.title,
      fullHeight: true,
      child: Text(
        policy.body,
        style: context.nuvi.nunito(14.5, color: NuviColors.ink, height: 1.6),
      ),
    ),
  );
}
