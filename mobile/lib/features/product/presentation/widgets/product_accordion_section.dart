import 'package:flutter/material.dart';

import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_theme_ext.dart';
import '../../../../core/widgets/nuvi_accordion.dart';
import '../../domain/product_review.dart';

/// Product information accordions, all closed by default. Returns and
/// Payment carry the same policy copy the page already shows.
class ProductAccordionSection extends StatelessWidget {
  final String? description;
  final List<String>? fabricAndCare;

  const ProductAccordionSection({
    super.key,
    this.description,
    this.fabricAndCare,
  });

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 1, color: NuviColors.line),
        if (description != null)
          NuviAccordion(
            title: 'Product Details',
            icon: Icons.description_outlined,
            content: Text(description!, style: x.bodyMuted),
          ),
        if (fabricAndCare != null && fabricAndCare!.isNotEmpty)
          NuviAccordion(
            title: 'Fabric & Care',
            icon: Icons.local_laundry_service_outlined,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: fabricAndCare!
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8, right: 8),
                            child: Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: x.gold,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Expanded(child: Text(item, style: x.bodyMuted)),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        NuviAccordion(
          title: 'Returns',
          icon: Icons.autorenew_rounded,
          content: Text(
            'Easy 7-day returns and 7-day exchanges.',
            style: x.bodyMuted,
          ),
        ),
        NuviAccordion(
          title: 'Payment',
          icon: Icons.payments_outlined,
          content: Text(
            'Pay securely online, or choose Cash on Delivery where available.',
            style: x.bodyMuted,
          ),
        ),
      ],
    );
  }
}

/// Reviews summary: average, stars, count and the latest reviews.
class ProductReviewsSummary extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final List<ProductReview> reviews;

  const ProductReviewsSummary({
    super.key,
    required this.rating,
    required this.reviewCount,
    required this.reviews,
  });

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
          Text('Reviews', style: x.h3.copyWith(color: NuviColors.pdpInk)),
          const SizedBox(height: NuviSpacing.s12),
          Row(
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: x.baloo(
                  34,
                  weight: FontWeight.w800,
                  color: NuviColors.pdpInk,
                ),
              ),
              const SizedBox(width: NuviSpacing.s12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NuviStars(rating: rating, size: 18),
                  Text('Based on $reviewCount reviews', style: x.small),
                ],
              ),
            ],
          ),
          for (final review in reviews.take(2)) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: NuviSpacing.s12),
              child: Divider(height: 1, color: NuviColors.line),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    review.author,
                    style: x.nunito(14, weight: FontWeight.w800),
                  ),
                ),
                Text(review.date, style: x.small),
              ],
            ),
            const SizedBox(height: 2),
            NuviStars(rating: review.rating, size: 14),
            const SizedBox(height: 4),
            Text(review.comment, style: x.bodyMuted),
          ],
        ],
      ),
    );
  }
}

class NuviStars extends StatelessWidget {
  final double rating;
  final double size;

  const NuviStars({super.key, required this.rating, this.size = 16});

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return Semantics(
      label: '${rating.toStringAsFixed(1)} out of 5 stars',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (i) {
            final icon = rating >= i + 1
                ? Icons.star_rounded
                : rating >= i + 0.5
                ? Icons.star_half_rounded
                : Icons.star_outline_rounded;
            return Icon(icon, size: size, color: x.gold);
          }),
        ),
      ),
    );
  }
}
