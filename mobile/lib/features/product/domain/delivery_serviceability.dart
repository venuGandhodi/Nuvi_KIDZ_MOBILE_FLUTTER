class DeliveryServiceabilityResult {
  final bool serviceable;
  final String pincode;
  final bool codAvailable;
  final bool prepaidAvailable;
  final DateTime? estimatedDeliveryDate;
  final String? remarks;

  const DeliveryServiceabilityResult({
    required this.serviceable,
    required this.pincode,
    required this.codAvailable,
    required this.prepaidAvailable,
    this.estimatedDeliveryDate,
    this.remarks,
  });

  factory DeliveryServiceabilityResult.fromJson(Map<String, dynamic> json) {
    final rawDate = json['estimatedDeliveryDate'] as String?;
    return DeliveryServiceabilityResult(
      serviceable: json['serviceable'] as bool? ?? false,
      pincode: json['pincode'] as String? ?? '',
      codAvailable: json['codAvailable'] as bool? ?? false,
      prepaidAvailable: json['prepaidAvailable'] as bool? ?? false,
      estimatedDeliveryDate: rawDate != null
          ? DateTime.tryParse(rawDate)
          : null,
      remarks: json['remarks'] as String?,
    );
  }
}

enum DeliveryCheckFailureReason { invalidPincode, unavailable }

class DeliveryCheckException implements Exception {
  final DeliveryCheckFailureReason reason;

  const DeliveryCheckException(this.reason);
}
