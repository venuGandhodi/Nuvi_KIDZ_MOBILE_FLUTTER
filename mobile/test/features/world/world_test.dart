import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nuvi_kidz/features/shopify/data/shopify_storefront_client.dart';
import 'package:nuvi_kidz/features/world/data/hospital_plan_repository.dart';
import 'package:nuvi_kidz/features/world/data/world_repository.dart';
import 'package:nuvi_kidz/features/world/domain/hospital_plan.dart';
import 'package:nuvi_kidz/features/world/domain/world_section.dart';
import 'package:nuvi_kidz/features/world/presentation/world_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeClient extends ShopifyStorefrontClient {
  Map<String, dynamic>? lastVariables;

  _FakeClient()
    : super(domain: 'test.myshopify.com', storefrontAccessToken: 'test');

  @override
  Future<Map<String, dynamic>> query({
    required String query,
    Map<String, dynamic>? variables,
  }) async {
    lastVariables = variables;
    if (variables?['handle'] == 'parenting') return {'blog': null};
    return {
      'blog': {
        'articles': {
          'nodes': [
            {
              'handle': 'first-week',
              'title': 'Your first week',
              'excerpt': '',
              'publishedAt': '2026-03-01T10:00:00Z',
              'contentHtml': '<p>Rest &amp; hydrate.</p><p>Sleep well.</p>',
              'authorV2': {'name': 'NUVI'},
              'image': {'url': 'https://cdn.example/a.jpg'},
            },
            {'handle': '', 'title': 'Broken'},
          ],
        },
      },
    };
  }
}

void main() {
  group('WorldRepository', () {
    test('reads articles from the section blog', () async {
      final client = _FakeClient();
      final articles = await WorldRepository(
        client: client,
      ).getArticles(WorldSection.pregnancyJourney);
      expect(client.lastVariables?['handle'], 'pregnancy-journey');
      expect(articles, hasLength(1));
      final a = articles.single;
      expect(a.title, 'Your first week');
      expect(a.body, 'Rest & hydrate.\n\nSleep well.');
      expect(a.excerpt, 'Rest & hydrate.');
      expect(a.author, 'NUVI');
      expect(a.imageUrl, 'https://cdn.example/a.jpg');
      expect(a.publishedAt, DateTime.utc(2026, 3, 1, 10));
    });

    test('a missing blog gives no articles', () async {
      final articles = await WorldRepository(
        client: _FakeClient(),
      ).getArticles(WorldSection.parentingBlogs);
      expect(articles, isEmpty);
    });
  });

  test('WorldSection.fromSlug', () {
    expect(
      WorldSection.fromSlug('hospital-planner'),
      WorldSection.hospitalPlanner,
    );
    expect(WorldSection.fromSlug('nope'), isNull);
  });

  group('PregnancyProgress', () {
    test('counts weeks back from the due date', () {
      final today = DateTime(2026, 6, 1);
      final p = PregnancyProgress.from(
        today.add(const Duration(days: 100)),
        today,
      );
      expect(p.daysToGo, 100);
      expect(p.week, 25);
      expect(p.dayOfWeek, 5);
      expect(p.trimester, 2);
      expect(p.fraction, closeTo(180 / 280, 1e-9));
    });

    test('clamps early and overdue dates', () {
      final today = DateTime(2026, 6, 1);
      expect(
        PregnancyProgress.from(
          today.add(const Duration(days: 400)),
          today,
        ).week,
        0,
      );
      final late = PregnancyProgress.from(
        today.subtract(const Duration(days: 3)),
        today,
      );
      expect(late.daysToGo, -3);
      expect(late.trimester, 3);
      expect(late.fraction, 1.0);
    });
  });

  test('HospitalPlan survives a JSON round trip', () {
    final plan = HospitalPlan.initial().copyWith(
      dueDate: DateTime(2026, 9, 12),
      hospitalName: 'City Hospital',
    );
    final back = HospitalPlan.fromJson(plan.toJson());
    expect(back.dueDate, DateTime(2026, 9, 12));
    expect(back.hospitalName, 'City Hospital');
    expect(back.items.length, plan.items.length);
  });

  test('HospitalPlanController toggles, adds, removes and saves', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(hospitalPlanProvider.notifier);
    await Future<void>.delayed(Duration.zero);

    final first = container.read(hospitalPlanProvider).items.first;
    await controller.toggle(first.id);
    expect(container.read(hospitalPlanProvider).doneCount, 1);

    await controller.addItem('For Baby', '  Water bottle ');
    await controller.addItem('For Baby', '   ');
    final added = container.read(hospitalPlanProvider).items.last;
    expect(added.label, 'Water bottle');
    expect(added.group, 'For Baby');

    await controller.removeItem(first.id);
    expect(
      container.read(hospitalPlanProvider).items.any((i) => i.id == first.id),
      isFalse,
    );

    final saved = await HospitalPlanRepository().load();
    expect(saved.items.last.label, 'Water bottle');
    expect(saved.doneCount, 0);
  });

  testWidgets('hub shows six areas and opens one', (tester) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: '/world',
      routes: [
        GoRoute(path: '/world', builder: (_, _) => const WorldScreen()),
        GoRoute(
          path: '/world/:section',
          builder: (_, s) => Text('open ${s.pathParameters['section']}'),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('NUVI KIDZ World'), findsOneWidget);
    expect(
      find.text('A world of learning, care and parenting.'),
      findsOneWidget,
    );
    for (final s in WorldSection.values) {
      expect(find.text(s.title), findsOneWidget);
    }
    await tester.tap(find.text('Hospital Planner'));
    await tester.pumpAndSettle();
    expect(find.text('open hospital-planner'), findsOneWidget);
  });
}
