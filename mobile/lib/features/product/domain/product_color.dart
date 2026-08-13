import 'package:flutter/material.dart';

class ProductColor {
  final String id;
  final String name;
  final Color color;
  final bool isAvailable;

  const ProductColor({
    required this.id,
    required this.name,
    required this.color,
    this.isAvailable = true,
  });
}
