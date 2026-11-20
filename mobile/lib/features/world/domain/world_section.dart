import 'package:flutter/material.dart';

import '../../../core/theme/nuvi_colors.dart';

/// The six NUVI World areas. Each reads its articles from the Shopify blog
/// with [blogHandle] (Online Store → Blog posts).
enum WorldSection {
  kidsLearning(
    slug: 'kids-learning',
    title: 'Kids Learning World',
    blogHandle: 'kids-learning-world',
    blurb: 'Stories, rhymes and early-learning ideas for little minds.',
    icon: Icons.menu_book_rounded,
    tone: NuviTone.sage,
  ),
  gamesActivities(
    slug: 'games-activities',
    title: 'Games & Activities',
    blogHandle: 'games-activities',
    blurb: 'Playful games and crafts to enjoy together.',
    icon: Icons.sports_esports_outlined,
    tone: NuviTone.cream,
  ),
  pregnancyJourney(
    slug: 'pregnancy-journey',
    title: 'Pregnancy Journey',
    blogHandle: 'pregnancy-journey',
    blurb: 'Track your weeks and read guides for every trimester.',
    icon: Icons.pregnant_woman_rounded,
    tone: NuviTone.peach,
  ),
  babyCare(
    slug: 'baby-care',
    title: 'Baby Care & Health',
    blogHandle: 'baby-care-health',
    blurb: 'Everyday care, sleep, feeding and wellness tips.',
    icon: Icons.favorite_border_rounded,
    tone: NuviTone.pink,
  ),
  hospitalPlanner(
    slug: 'hospital-planner',
    title: 'Hospital Planner',
    blogHandle: 'hospital-planner',
    blurb: 'Your hospital bag checklist and delivery details.',
    icon: Icons.local_hospital_outlined,
    tone: NuviTone.sky,
  ),
  parentingBlogs(
    slug: 'parenting-blogs',
    title: 'Parenting Blogs',
    blogHandle: 'parenting',
    blurb: 'Real stories and advice from the NUVI family.',
    icon: Icons.auto_stories_outlined,
    tone: NuviTone.sun,
  );

  final String slug;
  final String title;
  final String blogHandle;
  final String blurb;
  final IconData icon;
  final NuviTone tone;

  const WorldSection({
    required this.slug,
    required this.title,
    required this.blogHandle,
    required this.blurb,
    required this.icon,
    required this.tone,
  });

  static WorldSection? fromSlug(String? slug) {
    for (final s in values) {
      if (s.slug == slug) return s;
    }
    return null;
  }
}
