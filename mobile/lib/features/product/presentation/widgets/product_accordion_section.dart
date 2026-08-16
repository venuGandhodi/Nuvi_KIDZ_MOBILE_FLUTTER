import 'package:flutter/material.dart';
import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_typography.dart';
import '../../domain/product_review.dart';

class ProductAccordionSection extends StatefulWidget {
  final String? description;
  final List<String>? fabricAndCare;
  final List<ProductReview>? reviews;

  const ProductAccordionSection({
    super.key,
    this.description,
    this.fabricAndCare,
    this.reviews,
  });

  @override
  State<ProductAccordionSection> createState() =>
      _ProductAccordionSectionState();
}

class _ProductAccordionSectionState extends State<ProductAccordionSection> {
  bool _isDescriptionExpanded = true;
  bool _isFabricExpanded = false;
  bool _isReviewsExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Description Accordion
        if (widget.description != null) ...[
          _buildAccordionTile(
            title: 'Product Details',
            isExpanded: _isDescriptionExpanded,
            onTap: () => setState(
              () => _isDescriptionExpanded = !_isDescriptionExpanded,
            ),
            content: Text(
              widget.description!,
              style: NuviTypography.textTheme.bodyMedium?.copyWith(
                color: NuviColors.onSurface.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: NuviSpacing.sm),
        ],

        // Fabric & Care Accordion
        if (widget.fabricAndCare != null &&
            widget.fabricAndCare!.isNotEmpty) ...[
          _buildAccordionTile(
            title: 'Fabric & Care',
            isExpanded: _isFabricExpanded,
            onTap: () => setState(() => _isFabricExpanded = !_isFabricExpanded),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.fabricAndCare!.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ',
                        style: NuviTypography.textTheme.bodyMedium?.copyWith(
                          color: NuviColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item,
                          style: NuviTypography.textTheme.bodyMedium?.copyWith(
                            color: NuviColors.onSurface.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: NuviSpacing.sm),
        ],

        // Reviews Accordion
        if (widget.reviews != null && widget.reviews!.isNotEmpty) ...[
          _buildAccordionTile(
            title: 'Reviews (${widget.reviews!.length})',
            isExpanded: _isReviewsExpanded,
            onTap: () =>
                setState(() => _isReviewsExpanded = !_isReviewsExpanded),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.reviews!.map((rev) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: NuviSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            rev.author,
                            style: NuviTypography.textTheme.labelLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: NuviColors.primary,
                                ),
                          ),
                          Text(
                            rev.date,
                            style: NuviTypography.textTheme.bodySmall?.copyWith(
                              color: NuviColors.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '"${rev.comment}"',
                        style: NuviTypography.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: NuviColors.onSurface.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAccordionTile({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: NuviColors.surface,
        borderRadius: BorderRadius.circular(NuviRadii.card / 2),
        border: Border.all(color: NuviColors.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(NuviRadii.card / 2),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: NuviSpacing.sm,
                vertical: NuviSpacing.xs,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: NuviTypography.textTheme.labelLarge?.copyWith(
                      fontSize: 12,
                      color: NuviColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.expand_more,
                      color: NuviColors.primary,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(
                left: NuviSpacing.sm,
                right: NuviSpacing.sm,
                bottom: NuviSpacing.sm,
              ),
              child: content,
            ),
        ],
      ),
    );
  }
}
