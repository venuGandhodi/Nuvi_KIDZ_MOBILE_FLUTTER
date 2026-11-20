import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/nuvi_colors.dart';
import '../../../core/theme/nuvi_radii.dart';
import '../../../core/theme/nuvi_spacing.dart';
import '../../../core/theme/nuvi_theme_ext.dart';
import '../../../core/widgets/nuvi_empty_state.dart';
import '../../../core/widgets/nuvi_loading_indicator.dart';
import '../../../core/widgets/nuvi_skeleton.dart';
import '../../../core/widgets/nuvi_top_bar.dart';
import '../data/world_repository.dart';
import '../domain/world_article.dart';
import '../domain/world_section.dart';
import 'widgets/article_list.dart';

final _articleProvider =
    FutureProvider.family<WorldArticle?, (WorldSection, String)>(
      (ref, key) =>
          ref.read(worldRepositoryProvider).getArticle(key.$1, key.$2),
    );

/// Reads one blog article. Uses the article passed from the list when
/// available, otherwise fetches it from Shopify (e.g. a shared link).
class WorldArticleScreen extends ConsumerWidget {
  final WorldSection section;
  final String handle;
  final WorldArticle? initial;

  const WorldArticleScreen({
    super.key,
    required this.section,
    required this.handle,
    this.initial,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final x = context.nuvi;
    final Widget body;
    if (initial != null) {
      body = _ArticleBody(article: initial!, section: section);
    } else {
      body = ref
          .watch(_articleProvider((section, handle)))
          .when(
            loading: () => const Center(child: NuviLoadingIndicator()),
            error: (_, _) => NuviEmptyState(
              title: 'We couldn’t load this article',
              message: 'Check your connection and try again.',
              actionLabel: 'Retry',
              onAction: () =>
                  ref.invalidate(_articleProvider((section, handle))),
            ),
            data: (a) => a == null
                ? const NuviEmptyState(
                    title: 'Article not found',
                    message: 'It may have been moved or removed.',
                  )
                : _ArticleBody(article: a, section: section),
          );
    }
    return Scaffold(
      backgroundColor: NuviColors.cream,
      appBar: NuviTopBar(
        title: Text(section.title, style: x.h3),
        showBackButton: true,
        showCart: false,
      ),
      body: body,
    );
  }
}

class _ArticleBody extends StatelessWidget {
  final WorldArticle article;
  final WorldSection section;

  const _ArticleBody({required this.article, required this.section});

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    final meta = [
      ?article.author,
      if (article.publishedAt != null) formatArticleDate(article.publishedAt!),
    ].join(' · ');
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        NuviSpacing.gutter,
        NuviSpacing.sm,
        NuviSpacing.gutter,
        NuviSpacing.xxl,
      ),
      children: [
        if (article.imageUrl != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(NuviRadii.cardLarge),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: NuviImage(url: article.imageUrl, tile: NuviTile.peach),
            ),
          ),
          const SizedBox(height: NuviSpacing.md),
        ],
        Text(
          article.title,
          style: x.baloo(
            24,
            weight: FontWeight.w800,
            color: NuviColors.nightGreen,
          ),
        ),
        if (meta.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(meta, style: x.nunito(13, color: NuviColors.inkFaint)),
        ],
        const SizedBox(height: NuviSpacing.md),
        Text(article.body, style: x.article),
      ],
    );
  }
}
