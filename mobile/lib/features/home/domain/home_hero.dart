class HomeHero {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String buttonText;
  final String collectionHandle;
  final bool isActive;

  const HomeHero({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.buttonText = 'Shop the Collection',
    this.collectionHandle = 'new-arrivals',
    this.isActive = true,
  });

  HomeHero copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? buttonText,
    String? collectionHandle,
    bool? isActive,
  }) {
    return HomeHero(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      buttonText: buttonText ?? this.buttonText,
      collectionHandle: collectionHandle ?? this.collectionHandle,
      isActive: isActive ?? this.isActive,
    );
  }
}
