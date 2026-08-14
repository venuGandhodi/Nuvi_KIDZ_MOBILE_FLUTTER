import '../../order/domain/shopify_order.dart';

class ShopifyAddress {
  final String id;
  final String? address1;
  final String? address2;
  final String? city;
  final String? province;
  final String? zip;
  final String? country;
  final String? phone;

  const ShopifyAddress({
    required this.id,
    this.address1,
    this.address2,
    this.city,
    this.province,
    this.zip,
    this.country,
    this.phone,
  });

  factory ShopifyAddress.fromJson(Map<String, dynamic> json) {
    return ShopifyAddress(
      id: json['id'] as String? ?? '',
      address1: json['address1'] as String?,
      address2: json['address2'] as String?,
      city: json['city'] as String?,
      province: json['province'] as String?,
      zip: json['zip'] as String?,
      country: json['country'] as String?,
      phone: json['phone'] as String?,
    );
  }

  String get formattedAddress {
    final parts = [
      if (address1 != null && address1!.isNotEmpty) address1!,
      if (address2 != null && address2!.isNotEmpty) address2!,
      if (city != null && city!.isNotEmpty) city!,
      if (province != null && province!.isNotEmpty) province!,
      if (zip != null && zip!.isNotEmpty) zip!,
      if (country != null && country!.isNotEmpty) country!,
    ];
    return parts.join(', ');
  }
}

class ShopifyCustomer {
  final String id;
  final String? firstName;
  final String? lastName;
  final String? displayName;
  final String email;
  final String? phone;
  final ShopifyAddress? defaultAddress;
  final List<ShopifyAddress> addresses;
  final List<ShopifyOrder> orders;
  final int ordersCount;

  const ShopifyCustomer({
    required this.id,
    this.firstName,
    this.lastName,
    this.displayName,
    required this.email,
    this.phone,
    this.defaultAddress,
    this.addresses = const [],
    this.orders = const [],
    this.ordersCount = 0,
  });

  String get fullName {
    if (displayName != null && displayName!.trim().isNotEmpty) {
      return displayName!.trim();
    }
    final first = firstName ?? '';
    final last = lastName ?? '';
    final combined = '$first $last'.trim();
    return combined.isNotEmpty ? combined : email.split('@').first;
  }

  factory ShopifyCustomer.fromJson(Map<String, dynamic> json) {
    final defaultAddrJson = json['defaultAddress'] as Map<String, dynamic>?;
    final defaultAddress = defaultAddrJson != null
        ? ShopifyAddress.fromJson(defaultAddrJson)
        : null;

    // Parse addresses (handles both plain List and GraphQL edges format)
    List<ShopifyAddress> addresses = [];
    if (json['addresses'] is List) {
      addresses = (json['addresses'] as List)
          .map((item) => ShopifyAddress.fromJson(item as Map<String, dynamic>))
          .toList();
    } else if (json['addresses'] is Map && json['addresses']['edges'] is List) {
      addresses = (json['addresses']['edges'] as List)
          .map(
            (e) => ShopifyAddress.fromJson(e['node'] as Map<String, dynamic>),
          )
          .toList();
    }

    // Parse orders (handles both plain List and GraphQL edges format)
    List<ShopifyOrder> orders = [];
    if (json['orders'] is List) {
      orders = (json['orders'] as List)
          .map((item) => ShopifyOrder.fromJson(item as Map<String, dynamic>))
          .toList();
    } else if (json['orders'] is Map && json['orders']['edges'] is List) {
      orders = (json['orders']['edges'] as List)
          .map((e) => ShopifyOrder.fromJson(e['node'] as Map<String, dynamic>))
          .toList();
    }

    final count = json['ordersCount'] is int
        ? json['ordersCount'] as int
        : orders.length;

    return ShopifyCustomer(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      displayName: json['displayName'] as String?,
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      defaultAddress: defaultAddress,
      addresses: addresses,
      orders: orders,
      ordersCount: count,
    );
  }
}
