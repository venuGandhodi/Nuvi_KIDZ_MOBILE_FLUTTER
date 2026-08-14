class ShopifyOrderMoney {
  final double amount;
  final String currencyCode;

  const ShopifyOrderMoney({required this.amount, required this.currencyCode});

  factory ShopifyOrderMoney.fromJson(Map<String, dynamic> json) {
    return ShopifyOrderMoney(
      amount: double.tryParse(json['amount']?.toString() ?? '0.0') ?? 0.0,
      currencyCode: json['currencyCode'] as String? ?? 'INR',
    );
  }
}

class ShopifyOrderLineItem {
  final String id;
  final String title;
  final String? variantTitle;
  final int quantity;
  final ShopifyOrderMoney originalTotalPrice;
  final String? imageUrl;

  const ShopifyOrderLineItem({
    required this.id,
    required this.title,
    this.variantTitle,
    required this.quantity,
    required this.originalTotalPrice,
    this.imageUrl,
  });

  factory ShopifyOrderLineItem.fromJson(Map<String, dynamic> json) {
    final originalTotalPrice = json['originalTotalPrice'] != null
        ? ShopifyOrderMoney.fromJson(
            json['originalTotalPrice'] as Map<String, dynamic>,
          )
        : const ShopifyOrderMoney(amount: 0.0, currencyCode: 'INR');

    final variant = json['variant'] as Map<String, dynamic>?;
    final image = variant?['image'] as Map<String, dynamic>?;

    return ShopifyOrderLineItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      variantTitle: variant?['title'] as String?,
      quantity: json['quantity'] as int? ?? 1,
      originalTotalPrice: originalTotalPrice,
      imageUrl: image?['url'] as String?,
    );
  }
}

class ShopifyOrder {
  final String id;
  final String name;
  final int? orderNumber;
  final DateTime processedAt;
  final String? financialStatus;
  final String? fulfillmentStatus;
  final ShopifyOrderMoney currentTotalPrice;
  final ShopifyOrderMoney? currentTotalTax;
  final ShopifyOrderMoney? totalShippingPrice;
  final List<ShopifyOrderLineItem> lineItems;

  const ShopifyOrder({
    required this.id,
    required this.name,
    this.orderNumber,
    required this.processedAt,
    this.financialStatus,
    this.fulfillmentStatus,
    required this.currentTotalPrice,
    this.currentTotalTax,
    this.totalShippingPrice,
    this.lineItems = const [],
  });

  factory ShopifyOrder.fromJson(Map<String, dynamic> json) {
    final price = json['currentTotalPrice'] != null
        ? ShopifyOrderMoney.fromJson(
            json['currentTotalPrice'] as Map<String, dynamic>,
          )
        : const ShopifyOrderMoney(amount: 0.0, currencyCode: 'INR');

    final tax = json['currentTotalTax'] != null
        ? ShopifyOrderMoney.fromJson(
            json['currentTotalTax'] as Map<String, dynamic>,
          )
        : null;

    final shipping = json['totalShippingPrice'] != null
        ? ShopifyOrderMoney.fromJson(
            json['totalShippingPrice'] as Map<String, dynamic>,
          )
        : null;

    List<ShopifyOrderLineItem> lines = [];
    if (json['lineItems'] is List) {
      lines = (json['lineItems'] as List)
          .map(
            (item) =>
                ShopifyOrderLineItem.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } else if (json['lineItems'] is Map && json['lineItems']['edges'] is List) {
      lines = (json['lineItems']['edges'] as List)
          .map(
            (edge) => ShopifyOrderLineItem.fromJson(
              edge['node'] as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    return ShopifyOrder(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      orderNumber: json['orderNumber'] as int?,
      processedAt:
          DateTime.tryParse(json['processedAt']?.toString() ?? '') ??
          DateTime.now(),
      financialStatus: json['financialStatus'] as String?,
      fulfillmentStatus: json['fulfillmentStatus'] as String?,
      currentTotalPrice: price,
      currentTotalTax: tax,
      totalShippingPrice: shipping,
      lineItems: lines,
    );
  }
}
