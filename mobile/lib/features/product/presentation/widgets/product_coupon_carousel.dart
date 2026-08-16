import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_typography.dart';
import '../../domain/coupon.dart';
import '../coupon_controller.dart';

class ProductCouponCarousel extends ConsumerStatefulWidget {
  const ProductCouponCarousel({super.key});

  @override
  ConsumerState<ProductCouponCarousel> createState() =>
      _ProductCouponCarouselState();
}

class _ProductCouponCarouselState extends ConsumerState<ProductCouponCarousel> {
  final _controller = PageController();
  Timer? _timer;
  int _page = 0;
  int _itemCount = 0;

  void _startAutoScroll() {
    _timer?.cancel();
    if (_itemCount <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_controller.hasClients) return;
      _page = (_page + 1) % _itemCount;
      _controller.animateToPage(
        _page,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Copied "$code"')));
  }

  @override
  Widget build(BuildContext context) {
    final couponsAsync = ref.watch(activeCouponsProvider);

    return couponsAsync.when(
      data: (coupons) {
        if (coupons.isEmpty) return const SizedBox.shrink();
        if (_itemCount != coupons.length) {
          _itemCount = coupons.length;
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _startAutoScroll(),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 112,
              child: PageView.builder(
                controller: _controller,
                itemCount: coupons.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, index) =>
                    _buildCouponCard(coupons[index]),
              ),
            ),
            if (coupons.length > 1) ...[
              const SizedBox(height: NuviSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(coupons.length, (i) {
                  final isActive = i == _page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? NuviColors.primary
                          : NuviColors.primary.withValues(alpha: 0.25),
                    ),
                  );
                }),
              ),
            ],
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }

  Widget _buildCouponCard(Coupon coupon) {
    return Container(
      padding: const EdgeInsets.all(NuviSpacing.md),
      decoration: BoxDecoration(
        color: NuviColors.secondary,
        borderRadius: BorderRadius.circular(NuviRadii.card / 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            coupon.description,
            style: NuviTypography.textTheme.labelLarge?.copyWith(
              fontSize: 12,
              color: NuviColors.onSecondary,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: NuviSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: NuviColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: NuviColors.onSecondary.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  coupon.code,
                  style: NuviTypography.textTheme.labelLarge?.copyWith(
                    fontSize: 12,
                    color: NuviColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _copyCode(coupon.code),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: NuviColors.primary,
                    borderRadius: BorderRadius.circular(NuviRadii.pill),
                  ),
                  child: Text(
                    'Copy',
                    style: NuviTypography.textTheme.labelLarge?.copyWith(
                      fontSize: 11,
                      color: NuviColors.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
