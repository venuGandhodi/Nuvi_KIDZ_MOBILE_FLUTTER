import '../domain/age_filter.dart';
import '../domain/category.dart';
import '../domain/home_hero.dart';
import '../domain/product.dart';

class MockHomeData {
  static const HomeHero defaultHero = HomeHero(
    id: 'hero_autumn_adventures',
    title: 'Autumn Adventures\nAwait',
    description:
        'Discover our new collection of cozy, organic cotton essentials designed for little explorers.',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAFpju392Q1xn2AJbOH6i84veMzV8CIixbhDvSfev46-u4_JZayJQIFnXhrHEVwvacS8R3Yqz5xKPu96JKK13KMhQKxFxLkLnJXz9NyUwcIZ4wn0co3f1eqH4Qpm3q-U4Ugpoqku-8t-1F7pb_aL95IXewiYYQ8_64qWmtarZhwe1gnvFEtqcpH2u82uIp_phTTft_zPdY8hPZjpq2y0BYUg1FsGCMEoLThIKZ_Q5E5vMJdLVJRJbMjsQ',
    buttonText: 'Shop the Collection',
    collectionHandle: 'new-arrivals',
    isActive: true,
  );

  static const List<Category> categories = [
    Category(
      id: 'cat_girls',
      name: 'Girls',
      handle: 'girls-clothing',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBHEOpEgbz_wHgxUxOQHvE-0UgXW1Rg5FblJilz3mXzfN8SHYEBK1qj8B0MOf0_uqyjRbOKDMP0yho_gVnQ7_5tND0Pd4W3D7RDBfUXLi3zHOQ8OXACUiK1WvGIAhpi9UA-KqVUcYDuosMD2ZWS_oWJ7doMLFurSxBdhzOT-YK4cg4FzBqsIj7777trxhUZKSXdfKbeB0CSl8ydJlnGNQSxnp0BZIUIFRuu9pZpoDRXtfuUxs7zwKJ05w',
    ),
    Category(
      id: 'cat_boys',
      name: 'Boys',
      handle: 'boys-clothing',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAckyM6Tg65_MvBPntWmJz3WidK1xsIwuN4aqpAGOwhxzQYhUxrTfmXzvm2uGNyBRgGNKAy8hMtPiC2PATH29IWUyOSZHfL-jj5vvpXovdUx1zOt1uUyQHWAMgUKcTkXkDxMpb5JezUlPxmF_i7rvf6nViII0jaDito0aOuOKlQt_XsM5pUi_jlIEPtTPCZ0X316M3_YCLDaA4P2hee1OGaSL6_0Lz2kveRoZ9xGy14eEzW07620152Xw',
    ),
    Category(
      id: 'cat_baby',
      name: 'Baby',
      handle: 'frontpage',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCzNIhEQx2UML_N_ZGCjEyI6u6492OcdCZdv1igR3bEvXrxgN026OmBZyoQCpkIIXWiqTsJqV9zbRaDMOJAifgoB36fiGO5l-_M8e_eJA1WW-h6dOhhFjdHB3o2rv3Or8i7z5ex3emoga8oZi9jVkWugnaBhDTsLgf05juEjndWT4b-WVc6UVr7Nbj4qY0nJpyLhB_JkFJmGti2ykpAK2jpl9jrNMbUDrR0jHJMo4-wCKwn0LZptlVH3g',
    ),
    Category(
      id: 'cat_footwear',
      name: 'Footwear',
      handle: 'accessories',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDpMtuBbxQMRPGs0TXtQ0HHM_hYTFCMGu3sly2d3mrvit72RaJ4j9wSA3dY6QyGFqGvV6UyPVqoMu4I3Wdy7WbNTsl7Jc6hUeY4jFgHlTFsZ_QJonyobLYaU210XJPO_80YHyiJh8WWAtlgP84NTERahfpXMF1ryjZE3QwaaGkEqdvYDcK5bh9vTlSiSNeQ8co4BJdxkQPHE4H1Cz6y9tZIv6lg_Qomj1kTjZDENOzkl24B1vGrqwZ_Ww',
    ),
  ];

  static const List<Product> bestSellers = [
    Product(
      id: 'prod_romper',
      title: 'Forest Elephant Romper',
      price: '₹799',
      rating: 4.5,
      reviewCount: 42,
      badgeText: 'NEW',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBjOlTJOb3wyG119gfbl5Ws6ocbLMF5CgPcEEzQ4q8e7eniedbbrxidQxs_fDwT1KDOsBcid11yTaTrYqVxIZFMf8cWCbXFdZ1t-GQMu1QeEKNjOcM6V8PIqdUyuOmpdrCAzsMMvnSS3n3o7-3BZFS3uhpeYayd5YsO-YFzQMev60z2Ps5fHNKttLiGJSsrkvVqutS5eEWte5AyGcdel1SMRZfPnc83wOtQ3Mi1bppNb4b0MLQU3xBhVg',
    ),
    Product(
      id: 'prod_cardigan',
      title: 'Chunky Knit Cardigan',
      price: '₹1,099',
      rating: 5.0,
      reviewCount: 18,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB4zQAJpgatVxwXkHv4KuLaaIrFTuLlu49Impjv5KZ2wtZuicBmkCjhCK2XSm5rL2731b0-RNnlzKedXH3Jlb0AWUkVSHcYyIKkFic8-8vKpZWmpR7dHWdQkyzhhlwP5_l4YNPdD12wmbgwgI0CW8X6FUljkYX-ezlZjQWtnGxXskF8MCthcfcF5TCzxHLVn3YWS94KbUHurkeltDe7RCOagVieR4B9NmqJOSvIZkH02KDph0DV6-r2Zg',
    ),
    Product(
      id: 'prod_overalls',
      title: 'Classic Denim Overalls',
      price: '₹1,299',
      rating: 4.0,
      reviewCount: 9,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDUjYja6okPAB5c7YLGAFFPWPcvvoKHROb36epNO5tVMcb69H0SfuvaOVz8zgigWufm7ozgAL6ec5OPwId2gW5syhKJqPKh7z-xOyth0m8rJSUWsc0MCIFHTzG9Tzo0vPiEywSjmrmVvayK9RrH9nO0xw2cqJWvedto2w3vehg4Dd8T5o593u-rWp_nafgGwC8Zf7cIeA3QSJbrseTf78qHnmoNykBLWHrChQ7ZAoBX4Rrpf0fl5oWrhQ',
    ),
    Product(
      id: 'prod_beanie',
      title: 'Ribbed Beanie Set (3-Pack)',
      price: '₹699',
      rating: 5.0,
      reviewCount: 56,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuD3L0C_lxMUCPUqjt8hnij-59MihlE_go6teP-p1uc4yQsCkUoW2WuuJTt-KMZ9aOxLLp4NZjJeosaAufoAZkIQ06piIhZFoFRquIFsG8ecngMt40Vm-jwNUzBIrkjwJ8EDHqumrKpCgfKbFHo6kwLM4RigNL8hTClPty9YGewICFs9W1KN11PaP0rZsDBfJeX3RE6YYkepPe-2o8MIvkxvTeE5hE_Y4ozLs6NBK4v_dNAKvrb4ppqgqg',
    ),
  ];

  static const List<AgeFilter> ageFilters = [
    AgeFilter(
      id: '0-3m',
      label: '0-3m',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCzNIhEQx2UML_N_ZGCjEyI6u6492OcdCZdv1igR3bEvXrxgN026OmBZyoQCpkIIXWiqTsJqV9zbRaDMOJAifgoB36fiGO5l-_M8e_eJA1WW-h6dOhhFjdHB3o2rv3Or8i7z5ex3emoga8oZi9jVkWugnaBhDTsLgf05juEjndWT4b-WVc6UVr7Nbj4qY0nJpyLhB_JkFJmGti2ykpAK2jpl9jrNMbUDrR0jHJMo4-wCKwn0LZptlVH3g',
    ),
    AgeFilter(
      id: '3-6m',
      label: '3-6m',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCzNIhEQx2UML_N_ZGCjEyI6u6492OcdCZdv1igR3bEvXrxgN026OmBZyoQCpkIIXWiqTsJqV9zbRaDMOJAifgoB36fiGO5l-_M8e_eJA1WW-h6dOhhFjdHB3o2rv3Or8i7z5ex3emoga8oZi9jVkWugnaBhDTsLgf05juEjndWT4b-WVc6UVr7Nbj4qY0nJpyLhB_JkFJmGti2ykpAK2jpl9jrNMbUDrR0jHJMo4-wCKwn0LZptlVH3g',
    ),
    AgeFilter(
      id: '6-12m',
      label: '6-12m',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBHEOpEgbz_wHgxUxOQHvE-0UgXW1Rg5FblJilz3mXzfN8SHYEBK1qj8B0MOf0_uqyjRbOKDMP0yho_gVnQ7_5tND0Pd4W3D7RDBfUXLi3zHOQ8OXACUiK1WvGIAhpi9UA-KqVUcYDuosMD2ZWS_oWJ7doMLFurSxBdhzOT-YK4cg4FzBqsIj7777trxhUZKSXdfKbeB0CSl8ydJlnGNQSxnp0BZIUIFRuu9pZpoDRXtfuUxs7zwKJ05w',
    ),
    AgeFilter(
      id: '1-2y',
      label: '1-2y',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAckyM6Tg65_MvBPntWmJz3WidK1xsIwuN4aqpAGOwhxzQYhUxrTfmXzvm2uGNyBRgGNKAy8hMtPiC2PATH29IWUyOSZHfL-jj5vvpXovdUx1zOt1uUyQHWAMgUKcTkXkDxMpb5JezUlPxmF_i7rvf6nViII0jaDito0aOuOKlQt_XsM5pUi_jlIEPtTPCZ0X316M3_YCLDaA4P2hee1OGaSL6_0Lz2kveRoZ9xGy14eEzW07620152Xw',
    ),
    AgeFilter(
      id: '3-5y',
      label: '3-5y',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDpMtuBbxQMRPGs0TXtQ0HHM_hYTFCMGu3sly2d3mrvit72RaJ4j9wSA3dY6QyGFqGvV6UyPVqoMu4I3Wdy7WbNTsl7Jc6hUeY4jFgHlTFsZ_QJonyobLYaU210XJPO_80YHyiJh8WWAtlgP84NTERahfpXMF1ryjZE3QwaaGkEqdvYDcK5bh9vTlSiSNeQ8co4BJdxkQPHE4H1Cz6y9tZIv6lg_Qomj1kTjZDENOzkl24B1vGrqwZ_Ww',
    ),
    AgeFilter(
      id: '6-8y',
      label: '6-8y',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBjOlTJOb3wyG119gfbl5Ws6ocbLMF5CgPcEEzQ4q8e7eniedbbrxidQxs_fDwT1KDOsBcid11yTaTrYqVxIZFMf8cWCbXFdZ1t-GQMu1QeEKNjOcM6V8PIqdUyuOmpdrCAzsMMvnSS3n3o7-3BZFS3uhpeYayd5YsO-YFzQMev60z2Ps5fHNKttLiGJSsrkvVqutS5eEWte5AyGcdel1SMRZfPnc83wOtQ3Mi1bppNb4b0MLQU3xBhVg',
    ),
  ];
}
