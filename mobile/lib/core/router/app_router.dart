import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/auth/presentation/sign_up_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/sign-in',
    redirect: (context, state) {
      final isAuth = authState.value?.session != null;
      final isGoingToAuth =
          state.matchedLocation == '/sign-in' ||
          state.matchedLocation == '/sign-up';

      if (!isAuth && !isGoingToAuth) return '/sign-in';

      // If user is authenticated, redirect from auth screens to home
      if (isAuth && isGoingToAuth) {
        // We haven't implemented /home yet, but we will route there when we do.
        // For Phase 1, we will just stay on sign-in or route to a dummy home.
        // return '/home';
        return null;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/sign-up',
        builder: (context, state) => const SignUpScreen(),
      ),
    ],
  );
});
