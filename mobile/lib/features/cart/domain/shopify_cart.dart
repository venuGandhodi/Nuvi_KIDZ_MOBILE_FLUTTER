import 'package:flutter/material.dart';
import '../../home/domain/product.dart';
import '../../product/domain/product_color.dart';
import '../../product/domain/product_variant.dart';
import '../../shopify/data/shopify_product_mapper.dart';
import 'cart_item.dart';

class ShopifyCartMoney {
  final double amount;
  final String currencyCode;

  const ShopifyCartMoney({required this.amount, this.currencyCode = 'INR'});

  String get formatted {
    final formattedAmount = amount.toStringAsFixed(
      amount.truncateToDouble() == amount ? 0 : 2,
    );
    return currencyCode == 'INR'
        ? '₹$formattedAmount'
        : '$currencyCode $formattedAmount';
  }

  factory ShopifyCartMoney.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ShopifyCartMoney(amount: 0.0, currencyCode: 'INR');
    }
    final amount = double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0;
    final currency = json['currencyCode']?.toString() ?? 'INR';
    return ShopifyCartMoney(amount: amount, currencyCode: currency);
  }
}

class ShopifyCartCost {
  final ShopifyCartMoney subtotalAmount;
  final ShopifyCartMoney totalAmount;
  final ShopifyCartMoney? totalTaxAmount;
  final ShopifyCartMoney? totalDutyAmount;

  const ShopifyCartCost({
    required this.subtotalAmount,
    required this.totalAmount,
    this.totalTaxAmount,
    this.totalDutyAmount,
  });

  factory ShopifyCartCost.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ShopifyCartCost(
        subtotalAmount: ShopifyCartMoney(amount: 0.0),
        totalAmount: ShopifyCartMoney(amount: 0.0),
      );
    }
    return ShopifyCartCost(
      subtotalAmount: ShopifyCartMoney.fromJson(
        json['subtotalAmount'] as Map<String, dynamic>?,
      ),
      totalAmount: ShopifyCartMoney.fromJson(
        json['totalAmount'] as Map<String, dynamic>?,
      ),
      totalTaxAmount: json['totalTaxAmount'] != null
          ? ShopifyCartMoney.fromJson(
              json['totalTaxAmount'] as Map<String, dynamic>?,
            )
          : null,
      totalDutyAmount: json['totalDutyAmount'] != null
          ? ShopifyCartMoney.fromJson(
              json['totalDutyAmount'] as Map<String, dynamic>?,
            )
          : null,
    );
  }
}

class ShopifyCartLine {
  final String id;
  final int quantity;
  final String merchandiseVariantId;
  final String title;
  final String productTitle;
  final String productHandle;
  final String? imageUrl;
  final ShopifyCartMoney price;
  final ShopifyCartMoney? compareAtPrice;
  final Map<String, String> selectedOptions;

  const ShopifyCartLine({
    required this.id,
    required this.quantity,
    required this.merchandiseVariantId,
    required this.title,
    required this.productTitle,
    required this.productHandle,
    this.imageUrl,
    required this.price,
    this.compareAtPrice,
    this.selectedOptions = const {},
  });

  ShopifyCartMoney get lineTotal => ShopifyCartMoney(
    amount: price.amount * quantity,
    currencyCode: price.currencyCode,
  );

  String? get selectedColorName {
    for (final entry in selectedOptions.entries) {
      final key = entry.key.toLowerCase();
      if (key == 'color' || key == 'colour') {
        return entry.value;
      }
    }
    return null;
  }

  String? get selectedSize {
    for (final entry in selectedOptions.entries) {
      final key = entry.key.toLowerCase();
      if (key == 'size') {
        return entry.value;
      }
    }
    return null;
  }

  CartItem toCartItem() {
    ProductColor? productColor;
    if (selectedColorName != null) {
      productColor = ProductColor(
        id: selectedColorName!.toLowerCase().replaceAll(' ', '_'),
        name: selectedColorName!,
        color: const Color(0xFF8E8E93),
      );
    }

    final product = Product(
      id: productHandle.isNotEmpty ? productHandle : merchandiseVariantId,
      handle: productHandle,
      title: productTitle,
      price: price.formatted,
      imageUrl: imageUrl ?? ShopifyProductMapper.fallbackImageUrl,
      variants: [
        ProductVariant(
          id: merchandiseVariantId,
          title: title,
          priceAmount: price.amount,
          currencyCode: price.currencyCode,
          compareAtPriceAmount: compareAtPrice?.amount,
          selectedOptions: selectedOptions,
          size: selectedSize,
          color: selectedColorName,
        ),
      ],
    );

    return CartItem(
      id: id,
      product: product,
      shopifyVariantId: merchandiseVariantId,
      selectedColor: productColor,
      selectedSize: selectedSize,
      quantity: quantity,
      unitPrice: price.amount,
      currencyCode: price.currencyCode,
    );
  }

  factory ShopifyCartLine.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? '';
    final quantity = json['quantity'] as int? ?? 1;

    String merchandiseVariantId = '';
    String title = '';
    String productTitle = '';
    String productHandle = '';
    String? imageUrl;
    ShopifyCartMoney price = const ShopifyCartMoney(amount: 0.0);
    ShopifyCartMoney? compareAtPrice;
    final selectedOptions = <String, String>{};

    final merchandise = json['merchandise'] as Map<String, dynamic>?;
    if (merchandise != null) {
      merchandiseVariantId = merchandise['id'] as String? ?? '';
      title = merchandise['title'] as String? ?? '';

      price = ShopifyCartMoney.fromJson(
        merchandise['price'] as Map<String, dynamic>?,
      );

      if (merchandise['compareAtPrice'] != null) {
        compareAtPrice = ShopifyCartMoney.fromJson(
          merchandise['compareAtPrice'] as Map<String, dynamic>?,
        );
      }

      if (merchandise['image'] != null && merchandise['image']['url'] != null) {
        imageUrl = merchandise['image']['url'] as String?;
      }

      final product = merchandise['product'] as Map<String, dynamic>?;
      if (product != null) {
        productTitle = product['title'] as String? ?? '';
        productHandle = product['handle'] as String? ?? '';

        if (imageUrl == null &&
            product['images'] != null &&
            product['images']['nodes'] != null) {
          final nodes = product['images']['nodes'] as List<dynamic>;
          if (nodes.isNotEmpty && nodes.first['url'] != null) {
            imageUrl = nodes.first['url'] as String?;
          }
        }
      }

      if (merchandise['selectedOptions'] != null) {
        final options = merchandise['selectedOptions'] as List<dynamic>;
        for (final opt in options) {
          if (opt is Map<String, dynamic>) {
            final name = opt['name']?.toString() ?? '';
            final val = opt['value']?.toString() ?? '';
            selectedOptions[name] = val;
          }
        }
      }
    }

    return ShopifyCartLine(
      id: id,
      quantity: quantity,
      merchandiseVariantId: merchandiseVariantId,
      title: title,
      productTitle: productTitle.isNotEmpty ? productTitle : title,
      productHandle: productHandle,
      imageUrl: imageUrl,
      price: price,
      compareAtPrice: compareAtPrice,
      selectedOptions: selectedOptions,
    );
  }
}

class ShopifyCart {
  final String id;
  final int totalQuantity;
  final String checkoutUrl;
  final ShopifyCartCost cost;
  final List<ShopifyCartLine> lines;

  const ShopifyCart({
    required this.id,
    required this.totalQuantity,
    required this.checkoutUrl,
    required this.cost,
    required this.lines,
  });

  factory ShopifyCart.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? '';
    final totalQuantity = json['totalQuantity'] as int? ?? 0;
    final checkoutUrl = json['checkoutUrl'] as String? ?? '';

    final cost = ShopifyCartCost.fromJson(
      json['cost'] as Map<String, dynamic>?,
    );

    final linesList = <ShopifyCartLine>[];
    if (json['lines'] != null && json['lines']['nodes'] != null) {
      final nodes = json['lines']['nodes'] as List<dynamic>;
      for (final node in nodes) {
        if (node is Map<String, dynamic>) {
          linesList.add(ShopifyCartLine.fromJson(node));
        }
      }
    }

    return ShopifyCart(
      id: id,
      totalQuantity: totalQuantity,
      checkoutUrl: checkoutUrl,
      cost: cost,
      lines: linesList,
    );
  }
}
