class DeliveryMethod {
  final String id;
  final String title;
  final double price;
  final String estimatedDays;

  const DeliveryMethod({
    required this.id,
    required this.title,
    required this.price,
    required this.estimatedDays,
  });

  static const standard = DeliveryMethod(
    id: 'standard',
    title: 'Standard',
    price: 5.0,
    estimatedDays: '3-5 Business Days',
  );

  static const express = DeliveryMethod(
    id: 'express',
    title: 'Express',
    price: 15.0,
    estimatedDays: '1-2 Business Days',
  );
}
