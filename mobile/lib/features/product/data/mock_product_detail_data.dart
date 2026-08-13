import 'package:flutter/material.dart';
import '../../home/domain/product.dart';
import '../domain/product_color.dart';
import '../domain/product_review.dart';

class MockProductDetailData {
  static final Product defaultDreamRomper = Product(
    id: 'prod_dream_romper',
    title: 'Organic Cotton Dream Romper',
    price: '\$45.00',
    rating: 4.5,
    reviewCount: 42,
    badgeText: 'NEW',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuB1RXAFMcCdiW7n1ArnxSKeZibMLXEuMEPbtcXPtRmODgJbYShIpNU3CbgbpXN9hlYAAQh0ofzfFxA7zZe7B-Yc-oJvCZW3geeWDj51bJ5VUNnAq7XeXoDLpPdTVPn9R6-VRPgDN6SfUX-jfFIzWCh4CzyOkW53ILzjIoxMyACJKQrtLmKk1URvMDUXS54G1FgNNbwSrfK6dtmTP9WYJjcpcW_NeJ3mhEmSktdC5pdAWBgp5itN8dA4FA',
    images: [
      'https://lh3.googleusercontent.com/aida-public/AB6AXuB1RXAFMcCdiW7n1ArnxSKeZibMLXEuMEPbtcXPtRmODgJbYShIpNU3CbgbpXN9hlYAAQh0ofzfFxA7zZe7B-Yc-oJvCZW3geeWDj51bJ5VUNnAq7XeXoDLpPdTVPn9R6-VRPgDN6SfUX-jfFIzWCh4CzyOkW53ILzjIoxMyACJKQrtLmKk1URvMDUXS54G1FgNNbwSrfK6dtmTP9WYJjcpcW_NeJ3mhEmSktdC5pdAWBgp5itN8dA4FA',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDyTBRr1l-8ITkOUQApLDu9CDLQqhSVZMd-LJNazRZOF7KqFGFgjf-wbgZMZbS5HODjv9a9WMyDkc_8UUTzXmrH7pMbLDnP-KmJZyZE0q-eZq87BKfYZt6ojuDqddz8XJyBl-GI7h-aM_YCRoKCvl_R_0629FwI83ECMFyJUNT5dpycm2cPl4Jxd7KKXcTASLbMwwBGbJJZwtJz6PqMiFQMxk2Ocj466SPBfnMsTDq2ET7DElZ0zktBsw',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuCWCMOCwnxTbEk9Qgo3Ix6Kkb-12-I-4SJkli9KG4rsyP8ESS0sglbsgB-8coHvXdBG3vlVdUaNCCa5S1mCuLMctlozUs4jEQgyfCFs2ZIM16U_urGZkt5rc7d1MFwGcAI6Kf3sbwrFUXdvQpV6-utn2C3EaSu0AD_dv8XaejJb98a3xrkB1IAaffonYEbkjEGHCVizSo8psiYOyHiJCeojnXwVOcYXz23EMIaeYnNhJjXlvosUx2t44Q',
    ],
    description:
        'Wrap your little one in the softest, most breathable organic cotton. Perfect for playtime and naptime, designed with gentle stretch for active days. Our signature Dream Romper features an easy-access bottom snap closure for quick changes. The relaxed fit allows for maximum movement, while the ribbed cuffs keep tiny wrists and ankles cozy.',
    availableColors: const [
      ProductColor(
        id: 'terracotta',
        name: 'Terracotta',
        color: Color(0xFFE58A7A),
      ),
      ProductColor(
        id: 'sage_green',
        name: 'Sage Green',
        color: Color(0xFFA3B8A8),
      ),
      ProductColor(id: 'oatmeal', name: 'Oatmeal', color: Color(0xFFF2DEBA)),
    ],
    availableSizes: const ['0-3M', '3-6M', '6-12M', '12-18M'],
    fabricAndCare: const [
      '100% GOTS Certified Organic Cotton',
      'Non-toxic, eco-friendly dyes',
      'Machine wash cold with like colors',
      'Tumble dry low or line dry',
    ],
    reviews: const [
      ProductReview(
        id: 'rev_1',
        author: 'Sarah M.',
        rating: 5.0,
        comment:
            "Absolutely love the quality. It's so soft and washes incredibly well!",
        date: '2 days ago',
      ),
      ProductReview(
        id: 'rev_2',
        author: 'Elena R.',
        rating: 4.5,
        comment:
            'Super cute color and cozy fit for my 6-month-old. Highly recommend!',
        date: '1 week ago',
      ),
    ],
  );

  static final List<Product> relatedProducts = [
    const Product(
      id: 'prod_beanie_set',
      title: 'Snuggle Beanie Set',
      price: '\$22.00',
      rating: 4.8,
      reviewCount: 15,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBcGJmgWdt1jNpDVbq-68XpwoqMc3369cSuDRurjCabs29Zqo3YtHXLDTn2UFQ7vnD3T09HTA_dkxIoFESfHN8ruIAiCn2cEju6DeJa4GTgZ7DsmYKCIq8k23Zt_MLJsKxh_Hc14gqpdOw-_8AJGC7mRfYazmB7_lh7ZczbQZRst7i9XaVcZwMPi22vL9cYef_jsfoL2xdrdsjTQFDa2UeJyId-vN-hMTXwWcUV0quWYdeocM24gWfoUA',
    ),
    const Product(
      id: 'prod_bloomers',
      title: 'Ruffle Bloomers',
      price: '\$28.00',
      rating: 4.9,
      reviewCount: 22,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBYX49PydHeIYsa862nMciUog_I-CpvI0eQakcN7BhePiLTXeY0AcFjPzoesIbd_5JIkIFcJJghEMV9CZV9kuTnW2zyOYKT_GB_J5fPaiSHed4XJEszAXhH1Ff6i4hbHy9JXJW371UfGZcff5segxnDTfvXneMWPmBpUo8jPWq6EzFar0Kd2bvm3cw9_DfhO4Q24NUrKmteiqI2sVxLBXpe6zjpR9XiGp-cjiXWZsD2FrgebKurSh0AYQ',
    ),
    const Product(
      id: 'prod_cardigan',
      title: 'Chunky Knit Cardigan',
      price: '\$55.00',
      rating: 5.0,
      reviewCount: 30,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCb-aq1AJmdKr23r7qNNzl9JK0Y2Byt31g_Xr3LmyJdcMYaya1YTBV9SvSbidaey0esHeltjHCEhxEGJUEfRKI03Jhao-ZZlKMgAaU0LDO4PPVuSjdW0COIQoz9GaTHhHH-LXruYN4ayS2e-dcQVgV9V06WvBS2noWmy8joT28pmlqNsWTnjT1PbsniSOw30EhRi-iWTwGXPH-Pq74lsKvqQX_GA4REYAmGWJhdNIcmunJc_REcxPe5dA',
    ),
  ];
}
