import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shopify/data/shopify_storefront_client.dart';
import '../domain/world_article.dart';
import '../domain/world_section.dart';

/// Reads NUVI World articles from Shopify blogs. Needs the Storefront
/// permission `unauthenticated_read_content`.
class WorldRepository {
  final ShopifyStorefrontClient client;

  WorldRepository({ShopifyStorefrontClient? client})
    : client = client ?? ShopifyStorefrontClient();

  /// Newest articles of [section]'s blog; empty when the blog doesn't exist.
  Future<List<WorldArticle>> getArticles(WorldSection section) async {
    final data = await client.query(
      query: _articlesQuery,
      variables: {'handle': section.blogHandle, 'first': 30},
    );
    final nodes = data['blog']?['articles']?['nodes'];
    if (nodes is! List) return const [];
    return [for (final n in nodes) ?WorldArticle.fromJson(n)];
  }

  Future<WorldArticle?> getArticle(WorldSection section, String handle) async {
    final data = await client.query(
      query: _articleQuery,
      variables: {'blog': section.blogHandle, 'handle': handle},
    );
    return WorldArticle.fromJson(data['blog']?['articleByHandle']);
  }

  static const _fields = '''
    handle
    title
    excerpt
    publishedAt
    contentHtml
    authorV2 { name }
    image { url }
  ''';

  static const String _articlesQuery =
      r'''
    query WorldArticles($handle: String!, $first: Int!) {
      blog(handle: $handle) {
        articles(first: $first, sortKey: PUBLISHED_AT, reverse: true) {
          nodes {'''
      '$_fields'
      r'''
          }
        }
      }
    }
  ''';

  static const String _articleQuery =
      r'''
    query WorldArticle($blog: String!, $handle: String!) {
      blog(handle: $blog) {
        articleByHandle(handle: $handle) {'''
      '$_fields'
      r'''
        }
      }
    }
  ''';
}

final worldRepositoryProvider = Provider<WorldRepository>(
  (ref) => WorldRepository(),
);

final worldArticlesProvider =
    FutureProvider.family<List<WorldArticle>, WorldSection>(
      (ref, section) => ref.read(worldRepositoryProvider).getArticles(section),
    );
