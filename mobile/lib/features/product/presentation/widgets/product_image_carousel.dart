import 'package:flutter/material.dart';
import '../../../../core/theme/nuvi_colors.dart';

class ProductImageCarousel extends StatelessWidget {
  final List<String> images;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  const ProductImageCarousel({
    super.key,
    required this.images,
    required this.currentIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 220,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: images.isEmpty
                ? Container(
                    color: NuviColors.surfaceVariant,
                    child: const Icon(
                      Icons.image,
                      size: 48,
                      color: NuviColors.border,
                    ),
                  )
                : PageView.builder(
                    itemCount: images.length,
                    onPageChanged: onPageChanged,
                    itemBuilder: (context, index) {
                      return Image.network(
                        images[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: NuviColors.surfaceVariant,
                          child: const Icon(
                            Icons.broken_image,
                            size: 48,
                            color: NuviColors.border,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (index) {
              final isSelected = index == currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? NuviColors.primary : NuviColors.border,
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
