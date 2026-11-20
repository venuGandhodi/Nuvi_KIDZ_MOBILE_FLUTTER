import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_theme_ext.dart';
import '../../../../core/widgets/nuvi_loading_indicator.dart';
import '../../../../core/widgets/nuvi_pressable.dart';
import '../../../../core/widgets/nuvi_skeleton.dart';
import '../../data/world_repository.dart';
import '../../domain/world_article.dart';
import '../../domain/world_section.dart';

String formatArticleDate(DateTime d) {
  const m = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${d.day} ${m[d.month - 1]} ${d.year}';
}

/// The section's Shopify blog articles as cards, with loading, empty and
/// error states. Designed to sit inside a scrolling column.
class ArticleList extends ConsumerWidget {
  final WorldSection section;
  final String heading;

  const ArticleList({super.key, required this.section, this.heading = ''});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final x = context.nuvi;
    final articles = ref.watch(worldArticlesProvider(section));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (heading.isNotEmpty) ...[
          Text(heading, style: x.h3),
          const SizedBox(height: 10),
        ],
        articles.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: NuviLoadingIndicator()),
          ),
          error: (_, _) => _Message(
            text: 'We couldn’t load these articles. Check your connection.',
            onRetry: () => ref.invalidate(worldArticlesProvider(section)),
          ),
          data: (list) => list.isEmpty
              ? const _Message(
                  text: 'New articles are on their way. Check back soon!',
                )
              : Column(
                  children: [
                    for (final a in list) ...[
                      _ArticleCard(section: section, article: a),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final WorldSection section;
  final WorldArticle article;

  const _ArticleCard({required this.section, required this.article});

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return NuviPressable(
      onTap: () => context.push(
        '/world/${section.slug}/${article.handle}',
        extra: article,
      ),
      semanticLabel: article.title,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: NuviColors.white,
          borderRadius: BorderRadius.circular(NuviRadii.cardLarge),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F78461E),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(NuviRadii.image),
              child: SizedBox(
                width: 92,
                height: 92,
                child: article.imageUrl == null
                    ? ColoredBox(
                        color: section.tone.tint,
                        child: Icon(
                          section.icon,
                          size: 34,
                          color: section.tone.accent,
                        ),
                      )
                    : NuviImage(url: article.imageUrl, tile: NuviTile.peach),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: x.nunito(
                      15.5,
                      weight: FontWeight.w800,
                      color: NuviColors.nightGreen,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.excerpt,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: x.nunito(13, color: NuviColors.inkMuted),
                  ),
                  if (article.publishedAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      formatArticleDate(article.publishedAt!),
                      style: x.nunito(11.5, color: NuviColors.inkFaint),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final String text;
  final VoidCallback? onRetry;

  const _Message({required this.text, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: NuviColors.white,
        borderRadius: BorderRadius.circular(NuviRadii.cardLarge),
      ),
      child: Column(
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: x.nunito(14, color: NuviColors.inkMuted),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
