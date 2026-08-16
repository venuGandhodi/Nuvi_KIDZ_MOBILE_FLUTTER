import 'package:flutter/material.dart';
import '../../home/domain/product.dart';
import '../domain/category_detail.dart';
import '../domain/menu_category.dart';

class MockCategoryData {
  static const List<MenuCategory> menu = [
    MenuCategory(
      id: 'menu_trending',
      title: 'Trending',
      collectionHandle: 'new-arrivals',
    ),
    MenuCategory(
      id: 'menu_boys',
      title: 'Boys',
      collectionHandle: 'boys-clothing',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAckyM6Tg65_MvBPntWmJz3WidK1xsIwuN4aqpAGOwhxzQYhUxrTfmXzvm2uGNyBRgGNKAy8hMtPiC2PATH29IWUyOSZHfL-jj5vvpXovdUx1zOt1uUyQHWAMgUKcTkXkDxMpb5JezUlPxmF_i7rvf6nViII0jaDito0aOuOKlQt_XsM5pUi_jlIEPtTPCZ0X316M3_YCLDaA4P2hee1OGaSL6_0Lz2kveRoZ9xGy14eEzW07620152Xw',
      items: [
        MenuCategory(
          id: 'menu_boys_coord',
          title: 'Co-ord Sets',
          collectionHandle: 'boys-clothing',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuBix0QHHolKpcjTCVQ559lX8hOA7v1xLfD2z_N9C_q_8Kab7R3vKVinH92RUdhMKZU3kwXTVQXxpwJoqMTWhr9M85n9svnKa3JZxFVwdEItNWJBOx7hun_USCoGmmc37vywlcHuo89NznnIp5xdswVSn-1-3AKU8Ees9fKTewk4CdF7mbwrs2VuSlXJ81PxGobpjD5_kRiUb09atMibFFbjmJvdqQNiPH7Bh0hOU9Y42oAf0cx8XrKzuA',
        ),
        MenuCategory(
          id: 'menu_boys_tees',
          title: 'Tees',
          collectionHandle: 'boys-clothing',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCaBNmVtKjI30NYJHzyHtBHC4VJmRAqDcepbgakG60TnlpI5lxLNiBs1EzWmqMH0JNwMH7wwfaoYjlVc-QVgsOqybMwKxscSenDFjsyFmEaocQ6YHfRhPFnC70UmFTwy0fDaKal0ItjTFB1yPJ9iO8cCGd21yFJUZ6Sq-NTN8Fh6yC2NosEgQvmuJrdLFnwdeXaOASvzic3vRyBA0sj2tBhoiLnB1RrRbHiIKuapDpdhQJr5ZKpxeebug',
        ),
        MenuCategory(
          id: 'menu_boys_shirts',
          title: 'Shirts',
          collectionHandle: 'boys-clothing',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCWCMOCwnxTbEk9Qgo3Ix6Kkb-12-I-4SJkli9KG4rsyP8ESS0sglbsgB-8coHvXdBG3vlVdUaNCCa5S1mCuLMctlozUs4jEQgyfCFs2ZIM16U_urGZkt5rc7d1MFwGcAI6Kf3sbwrFUXdvQpV6-utn2C3EaSu0AD_dv8XaejJb98a3xrkB1IAaffonYEbkjEGHCVizSo8psiYOyHiJCeojnXwVOcYXz23EMIaeYnNhJjXlvosUx2t44Q',
        ),
        MenuCategory(
          id: 'menu_boys_denims',
          title: 'Denims',
          collectionHandle: 'boys-clothing',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDyTBRr1l-8ITkOUQApLDu9CDLQqhSVZMd-LJNazRZOF7KqFGFgjf-wbgZMZbS5HODjv9a9WMyDkc_8UUTzXmrH7pMbLDnP-KmJZyZE0q-eZq87BKfYZt6ojuDqddz8XJyBl-GI7h-aM_YCRoKCvl_R_0629FwI83ECMFyJUNT5dpycm2cPl4Jxd7KKXcTASLbMwwBGbJJZwtJz6PqMiFQMxk2Ocj466SPBfnMsTDq2ET7DElZ0zktBsw',
        ),
        MenuCategory(
          id: 'menu_boys_bottoms',
          title: 'Bottoms',
          collectionHandle: 'boys-clothing',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCzNIhEQx2UML_N_ZGCjEyI6u6492OcdCZdv1igR3bEvXrxgN026OmBZyoQCpkIIXWiqTsJqV9zbRaDMOJAifgoB36fiGO5l-_M8e_eJA1WW-h6dOhhFjdHB3o2rv3Or8i7z5ex3emoga8oZi9jVkWugnaBhDTsLgf05juEjndWT4b-WVc6UVr7Nbj4qY0nJpyLhB_JkFJmGti2ykpAK2jpl9jrNMbUDrR0jHJMo4-wCKwn0LZptlVH3g',
        ),
        MenuCategory(
          id: 'menu_boys_partywear',
          title: 'Partywear',
          collectionHandle: 'boys-clothing',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDpMtuBbxQMRPGs0TXtQ0HHM_hYTFCMGu3sly2d3mrvit72RaJ4j9wSA3dY6QyGFqGvV6UyPVqoMu4I3Wdy7WbNTsl7Jc6hUeY4jFgHlTFsZ_QJonyobLYaU210XJPO_80YHyiJh8WWAtlgP84NTERahfpXMF1ryjZE3QwaaGkEqdvYDcK5bh9vTlSiSNeQ8co4BJdxkQPHE4H1Cz6y9tZIv6lg_Qomj1kTjZDENOzkl24B1vGrqwZ_Ww',
        ),
        MenuCategory(
          id: 'menu_boys_winterwear',
          title: 'Winterwear',
          collectionHandle: 'boys-clothing',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCWCMOCwnxTbEk9Qgo3Ix6Kkb-12-I-4SJkli9KG4rsyP8ESS0sglbsgB-8coHvXdBG3vlVdUaNCCa5S1mCuLMctlozUs4jEQgyfCFs2ZIM16U_urGZkt5rc7d1MFwGcAI6Kf3sbwrFUXdvQpV6-utn2C3EaSu0AD_dv8XaejJb98a3xrkB1IAaffonYEbkjEGHCVizSo8psiYOyHiJCeojnXwVOcYXz23EMIaeYnNhJjXlvosUx2t44Q',
        ),
        MenuCategory(
          id: 'menu_boys_all',
          title: 'All',
          collectionHandle: 'boys-clothing',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuAckyM6Tg65_MvBPntWmJz3WidK1xsIwuN4aqpAGOwhxzQYhUxrTfmXzvm2uGNyBRgGNKAy8hMtPiC2PATH29IWUyOSZHfL-jj5vvpXovdUx1zOt1uUyQHWAMgUKcTkXkDxMpb5JezUlPxmF_i7rvf6nViII0jaDito0aOuOKlQt_XsM5pUi_jlIEPtTPCZ0X316M3_YCLDaA4P2hee1OGaSL6_0Lz2kveRoZ9xGy14eEzW07620152Xw',
        ),
      ],
    ),
    MenuCategory(
      id: 'menu_girls',
      title: 'Girls',
      collectionHandle: 'girls-clothing',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBHEOpEgbz_wHgxUxOQHvE-0UgXW1Rg5FblJilz3mXzfN8SHYEBK1qj8B0MOf0_uqyjRbOKDMP0yho_gVnQ7_5tND0Pd4W3D7RDBfUXLi3zHOQ8OXACUiK1WvGIAhpi9UA-KqVUcYDuosMD2ZWS_oWJ7doMLFurSxBdhzOT-YK4cg4FzBqsIj7777trxhUZKSXdfKbeB0CSl8ydJlnGNQSxnp0BZIUIFRuu9pZpoDRXtfuUxs7zwKJ05w',
      items: [
        MenuCategory(
          id: 'menu_girls_dresses',
          title: 'Dresses',
          collectionHandle: 'girls-clothing',
        ),
        MenuCategory(
          id: 'menu_girls_coord',
          title: 'Co-ord Sets',
          collectionHandle: 'girls-clothing',
        ),
        MenuCategory(
          id: 'menu_girls_all',
          title: 'All',
          collectionHandle: 'girls-clothing',
        ),
      ],
    ),
    MenuCategory(
      id: 'menu_baby',
      title: 'Baby',
      collectionHandle: 'frontpage',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCzNIhEQx2UML_N_ZGCjEyI6u6492OcdCZdv1igR3bEvXrxgN026OmBZyoQCpkIIXWiqTsJqV9zbRaDMOJAifgoB36fiGO5l-_M8e_eJA1WW-h6dOhhFjdHB3o2rv3Or8i7z5ex3emoga8oZi9jVkWWugnaBhDTsLgf05juEjndWT4b-WVc6UVr7Nbj4qY0nJpyLhB_JkFJmGti2ykpAK2jpl9jrNMbUDrR0jHJMo4-wCKwn0LZptlVH3g',
      items: [
        MenuCategory(
          id: 'menu_baby_rompers',
          title: 'Rompers',
          collectionHandle: 'frontpage',
        ),
        MenuCategory(
          id: 'menu_baby_all',
          title: 'All',
          collectionHandle: 'frontpage',
        ),
      ],
    ),
    MenuCategory(
      id: 'menu_footwear',
      title: 'Footwear',
      collectionHandle: 'accessories',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDpMtuBbxQMRPGs0TXtQ0HHM_hYTFCMGu3sly2d3mrvit72RaJ4j9wSA3dY6QyGFqGvV6UyPVqoMu4I3Wdy7WbNTsl7Jc6hUeY4jFgHlTFsZ_QJonyobLYaU210XJPO_80YHyiJh8WWAtlgP84NTERahfpXMF1ryjZE3QwaaGkEqdvYDcK5bh9vTlSiSNeQ8co4BJdxkQPHE4H1Cz6y9tZIv6lg_Qomj1kTjZDENOzkl24B1vGrqwZ_Ww',
    ),
  ];

  static const Map<String, CategoryDetail> categories = {
    'toddler': CategoryDetail(
      id: 'toddler',
      title: 'Toddler Collection',
      description: 'Playful & cozy styles for little explorers.',
      productsCount: 4,
    ),
    'cat_girls': CategoryDetail(
      id: 'cat_girls',
      title: 'Girls Collection',
      description: 'Dresses, sets, and organic cotton essentials for girls.',
      productsCount: 4,
    ),
    'cat_boys': CategoryDetail(
      id: 'cat_boys',
      title: 'Boys Collection',
      description: 'Comfortable knits, pants, and durable playwear.',
      productsCount: 4,
    ),
    'cat_baby': CategoryDetail(
      id: 'cat_baby',
      title: 'Baby Collection',
      description: 'Soft rompers, swaddles, and organic newborn clothing.',
      productsCount: 4,
    ),
    'cat_footwear': CategoryDetail(
      id: 'cat_footwear',
      title: 'Footwear Collection',
      description: 'Ethically crafted leather shoes and booties.',
      productsCount: 4,
    ),
  };

  static const List<Product> products = [
    Product(
      id: 'prod_dress_mustard',
      title: 'Starry Mustard Dress',
      price: '\$42.00',
      rating: 4.9,
      reviewCount: 28,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDyTBRr1l-8ITkOUQApLDu9CDLQqhSVZMd-LJNazRZOF7KqFGFgjf-wbgZMZbS5HODjv9a9WMyDkc_8UUTzXmrH7pMbLDnP-KmJZyZE0q-eZq87BKfYZt6ojuDqddz8XJyBl-GI7h-aM_YCRoKCvl_R_0629FwI83ECMFyJUNT5dpycm2cPl4Jxd7KKXcTASLbMwwBGbJJZwtJz6PqMiFQMxk2Ocj466SPBfnMsTDq2ET7DElZ0zktBsw',
      colorSwatches: [Color(0xFFFDB244), Color(0xFF1F3D2E)],
    ),
    Product(
      id: 'prod_knit_cardigan',
      title: 'Forest Knit Cardigan',
      price: '\$55.00',
      rating: 5.0,
      reviewCount: 34,
      badgeText: 'NEW',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCaBNmVtKjI30NYJHzyHtBHC4VJmRAqDcepbgakG60TnlpI5lxLNiBs1EzWmqMH0JNwMH7wwfaoYjlVc-QVgsOqybMwKxscSenDFjsyFmEaocQ6YHfRhPFnC70UmFTwy0fDaKal0ItjTFB1yPJ9iO8cCGd21yFJUZ6Sq-NTN8Fh6yC2NosEgQvmuJrdLFnwdeXaOASvzic3vRyBA0sj2tBhoiLnB1RrRbHiIKuapDpdhQJr5ZKpxeebug',
      colorSwatches: [Color(0xFF1F3D2E)],
    ),
    Product(
      id: 'prod_terracotta_overalls',
      title: 'Terracotta Overalls',
      price: '\$48.00',
      salePrice: '\$38.00',
      rating: 4.8,
      reviewCount: 19,
      badgeText: 'SALE',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCWCMOCwnxTbEk9Qgo3Ix6Kkb-12-I-4SJkli9KG4rsyP8ESS0sglbsgB-8coHvXdBG3vlVdUaNCCa5S1mCuLMctlozUs4jEQgyfCFs2ZIM16U_urGZkt5rc7d1MFwGcAI6Kf3sbwrFUXdvQpV6-utn2C3EaSu0AD_dv8XaejJb98a3xrkB1IAaffonYEbkjEGHCVizSo8psiYOyHiJCeojnXwVOcYXz23EMIaeYnNhJjXlvosUx2t44Q',
      colorSwatches: [Color(0xFFEB8467), Color(0xFFFFF8F0)],
    ),
    Product(
      id: 'prod_sage_lounge_set',
      title: 'Sage Abstract Lounge Set',
      price: '\$45.00',
      rating: 4.7,
      reviewCount: 45,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBix0QHHolKpcjTCVQ559lX8hOA7v1xLfD2z_N9C_q_8Kab7R3vKVinH92RUdhMKZU3kwXTVQXxpwJoqMTWhr9M85n9svnKa3JZxFVwdEItNWJBOx7hun_USCoGmmc37vywlcHuo89NznnIp5xdswVSn-1-3AKU8Ees9fKTewk4CdF7mbwrs2VuSlXJ81PxGobpjD5_kRiUb09atMibFFbjmJvdqQNiPH7Bh0hOU9Y42oAf0cx8XrKzuA',
      colorSwatches: [Color(0xFF87A894)],
    ),
  ];
}
