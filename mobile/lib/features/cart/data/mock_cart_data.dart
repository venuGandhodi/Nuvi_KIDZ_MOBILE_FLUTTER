import 'package:flutter/material.dart';
import '../../home/domain/product.dart';
import '../../product/domain/product_color.dart';
import '../domain/cart_item.dart';

class MockCartData {
  static final Product sampleRomper = Product(
    id: 'prod_dream_romper',
    title: 'Organic Cotton Romper',
    price: '\$34.00',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuA4YcJAXl68abbwhiW4eNdqaDB30ctNA8J7ZtKUybe3YXu7JDkn2IJyhr4nVOsGZ6QMsPZelzw-0jj6QbUQielSW1XbDSEcuxTJc1mhm16rkoV-Uz92SQDhiKQ-9CJch-5si8xvW6U6qPYqf0-D1R4hGWrNM7mSrKeoqGWCi4IeT9U0QyI50TzcuZx-x7CmeJEgC4NlRUDYeioMyDCNAhtPeBNVzQglzv-eY6InaQAdF7uRkZKD3bvkgQ',
  );

  static final Product sampleBooties = Product(
    id: 'prod_knit_booties',
    title: 'Chunky Knit Booties',
    price: '\$22.00',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAmwf_sVsk7G6tNWTtRnKWV61USPee-j0c8eGxIdAtV_qvlRuG6wHIjvnhdOEDnR2oWkZKKWFNeV9TyGLhVn3dQtag9tI3TRsDl6rcEOqui2YDupCuLC0tvc3v2fawBoNJXdzirH2JYD0NytGEqI3hnDFuPqhgsLjR7acCzadiNnX-wX_c0nhCB3h1V0gTm7lrnbu8VDtCtr3COCJcYlcJipVxwKLSAJhQarQ5O6vBqdzZF7ED_f88_4A',
  );

  static final sampleCartItems = [
    CartItem(
      id: 'cart_item_1',
      product: sampleRomper,
      selectedColor: const ProductColor(
        id: 'sage_green',
        name: 'Sage Green',
        color: Color(0xFFA3B8A8),
      ),
      selectedSize: '12-18M',
      quantity: 1,
      unitPrice: 34.0,
    ),
    CartItem(
      id: 'cart_item_2',
      product: sampleBooties,
      selectedColor: const ProductColor(
        id: 'mustard',
        name: 'Mustard',
        color: Color(0xFFEAB83D),
      ),
      selectedSize: '6-12M',
      quantity: 1,
      unitPrice: 22.0,
    ),
  ];
}
