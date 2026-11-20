import '../../support/domain/store_policy.dart';

/// A Shopify blog article shown in NUVI World.
class WorldArticle {
  final String handle;
  final String title;
  final String excerpt;
  final String? imageUrl;
  final DateTime? publishedAt;
  final String? author;

  /// Article body as plain paragraphs.
  final String body;

  const WorldArticle({
    required this.handle,
    required this.title,
    required this.body,
    this.excerpt = '',
    this.imageUrl,
    this.publishedAt,
    this.author,
  });

  static WorldArticle? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final title = (raw['title'] as String?)?.trim() ?? '';
    final handle = (raw['handle'] as String?)?.trim() ?? '';
    if (title.isEmpty || handle.isEmpty) return null;
    final body = StorePolicy.plainText(raw['contentHtml'] as String? ?? '');
    final excerpt = (raw['excerpt'] as String?)?.trim();
    final image = raw['image'];
    final author = raw['authorV2'];
    return WorldArticle(
      handle: handle,
      title: title,
      body: body,
      excerpt: excerpt == null || excerpt.isEmpty
          ? body.split('\n').first
          : excerpt,
      imageUrl: image is Map ? image['url'] as String? : null,
      publishedAt: DateTime.tryParse(raw['publishedAt'] as String? ?? ''),
      author: author is Map ? author['name'] as String? : null,
    );
  }
}
