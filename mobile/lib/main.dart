import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/nuvi_festival.dart';
import 'core/theme/nuvi_font_licenses.dart';
import 'core/theme/nuvi_theme.dart';
import 'core/router/app_router.dart';
import 'core/utils/nuvi_logger.dart';
import 'core/widgets/nuvi_festival_overlay.dart';

void main() async {
  nuviLog('NUVI-APP', 'main() START');
  WidgetsFlutterBinding.ensureInitialized();
  registerNuviFontLicenses();

  nuviLog('NUVI-APP', 'Loading environment START');
  try {
    await dotenv.load(fileName: ".env");
    nuviLog('NUVI-APP', 'Loading environment COMPLETE');
  } catch (e, st) {
    nuviLog('NUVI-APP', 'ERROR: Environment load failed: $e');
    nuviLog('NUVI-APP', 'STACK TRACE:\n$st');
  }

  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    nuviLog('NUVI-APP', 'Supabase initialization START');
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        // ignore: deprecated_member_use
        anonKey: supabaseAnonKey,
      );
      nuviLog('NUVI-APP', 'Supabase initialization COMPLETE');

      // Listen for Supabase auth state changes
      Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        final event = data.event;
        final isAuth = data.session != null;
        nuviLog('NUVI-AUTH', 'AUTH EVENT: ${event.name.toUpperCase()}');
        nuviLog('NUVI-AUTH', 'authenticated=$isAuth');
      });
    } catch (e, st) {
      nuviLog('NUVI-APP', 'ERROR: Supabase initialization failed: $e');
      nuviLog('NUVI-APP', 'STACK TRACE:\n$st');
    }
  } else {
    nuviLog(
      'NUVI-APP',
      'WARNING: Supabase URL or Anon Key is empty in environment.',
    );
  }

  nuviLog('NUVI-APP', 'runApp START');
  runApp(const ProviderScope(child: NuviKidzApp()));
}

class NuviKidzApp extends ConsumerWidget {
  const NuviKidzApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final festival = ref.watch(activeFestivalProvider);

    return MaterialApp.router(
      title: 'Nuvi Kidz',
      theme: NuviTheme.build(festival),
      themeMode: ThemeMode.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.3,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ?child,
            if (festival != null) NuviFestivalOverlay(festival: festival),
          ],
        ),
      ),
    );
  }
}
