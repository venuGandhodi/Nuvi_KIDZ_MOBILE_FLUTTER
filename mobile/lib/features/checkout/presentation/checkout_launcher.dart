import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/nuvi_colors.dart';

class ShopifyCheckoutLauncher {
  /// Validates whether a checkout URL is non-empty and well-formed.
  static bool isValidCheckoutUrl(String? url) {
    if (url == null || url.trim().isEmpty) return false;
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return false;
    return uri.hasScheme && (uri.scheme == 'https' || uri.scheme == 'http');
  }

  /// Launches the Shopify Hosted Checkout using the system browser / external application.
  /// Does NOT clear cart and does NOT simulate mock payment.
  static Future<bool> launchCheckout(
    BuildContext context,
    String? checkoutUrl,
  ) async {
    if (!isValidCheckoutUrl(checkoutUrl)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to initialize Shopify checkout. Please refresh your bag.',
            ),
            backgroundColor: NuviColors.error,
          ),
        );
      }
      return false;
    }

    try {
      final uri = Uri.parse(checkoutUrl!.trim());
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not open Shopify checkout. Please check your browser settings.',
            ),
            backgroundColor: NuviColors.error,
          ),
        );
      }
      return launched;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Checkout launch error: $e'),
            backgroundColor: NuviColors.error,
          ),
        );
      }
      return false;
    }
  }
}
