import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/nuvi_colors.dart';
import '../../../core/theme/nuvi_spacing.dart';
import '../../../core/theme/nuvi_theme_ext.dart';
import '../../../core/utils/nuvi_logger.dart';
import '../../../core/widgets/nuvi_welcome_backdrop.dart';
import '../../onboarding/presentation/onboarding_assets.dart';
import '../../../core/widgets/nuvi_button.dart';
import '../../../core/widgets/nuvi_input_field.dart';
import '../../auth/domain/auth_exception.dart' as domain;
import 'auth_controller.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignIn() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref
          .read(authControllerProvider.notifier)
          .signIn(_emailController.text.trim(), _passwordController.text);

      if (success && mounted) {
        _navigateAfterSignIn();
      }
    }
  }

  void _onGoogleSignIn() async {
    nuviLog('NUVI-GOOGLE', 'Google login button PRESSED');
    final success = await ref
        .read(authControllerProvider.notifier)
        .signInWithGoogle();

    if (success && mounted) {
      nuviLog(
        'NUVI-GOOGLE',
        'Google sign-in completed successfully in SignInScreen',
      );
      _navigateAfterSignIn();
    }
  }

  // SignInScreen is often reached via context.push() (e.g. from AccountScreen's
  // "Sign In" prompts), which puts it on top of the Navigator stack outside of
  // GoRouter's declarative redirect — the router's reactive redirect (based on
  // authStateProvider) only resolves the underlying location, it can't pop a
  // page that was pushed imperatively. go('/home') replaces the whole stack,
  // so it both dismisses any pushed sign-in page and lands on the post-login
  // landing screen regardless of how this screen was reached.
  void _navigateAfterSignIn() {
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          String message = 'An error occurred';
          if (error is domain.AuthException) {
            message = error.message;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: NuviColors.error),
          );
        },
      );
    });

    final x = context.nuvi;
    final canPop = context.canPop();
    final linkStyle = x
        .nunito(13.5, weight: FontWeight.w700, color: NuviColors.leafDark)
        .copyWith(decoration: TextDecoration.underline);
    return Scaffold(
      backgroundColor: NuviColors.cream,
      body: NuviWelcomeBackdrop(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Back when opened from inside the app; Skip (browse as a
                  // guest) when this is the first screen after onboarding.
                  Row(
                    children: [
                      if (canPop)
                        IconButton(
                          tooltip: 'Back',
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.chevron_left_rounded),
                        ),
                      const Spacer(),
                      if (!canPop)
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () => context.go('/home'),
                          child: Text(
                            'Skip',
                            style: x.nunito(14, weight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                  Center(
                    child: Image.asset(
                      kNuviLogoAsset,
                      width: 112,
                      semanticLabel: 'NUVI KIDZ',
                    ),
                  ),
                  Center(
                    child: Image.asset(
                      kOnboardingLaptopAsset,
                      width: 210,
                      excludeFromSemantics: true,
                    ),
                  ),
                  const SizedBox(height: NuviSpacing.sm),
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(text: 'Welcome to the\nNUVI Family '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Icon(
                            Icons.favorite_border_rounded,
                            size: 24,
                            color: x.peach,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    style: x
                        .baloo(
                          26,
                          weight: FontWeight.w800,
                          color: NuviColors.nightGreen,
                        )
                        .copyWith(height: 1.15),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sign in to continue your NUVI journey.',
                    textAlign: TextAlign.center,
                    style: x.nunito(14.5, color: NuviColors.inkMuted),
                  ),
                  const SizedBox(height: NuviSpacing.md),
                  NuviInputField(
                    label: 'Email',
                    hint: 'Email',
                    showLabel: false,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.mail_outline_rounded),
                    enabled: !isLoading,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  NuviInputField(
                    label: 'Password',
                    hint: 'Password',
                    showLabel: false,
                    controller: _passwordController,
                    obscureText: true,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    enabled: !isLoading,
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: isLoading
                          ? null
                          : () => context.go('/forgot-password'),
                      child: Text('Forgot Password?', style: linkStyle),
                    ),
                  ),
                  NuviButton(
                    text: 'Sign In',
                    type: NuviButtonType.leaf,
                    isLoading: isLoading,
                    trailingIcon: const Icon(Icons.arrow_forward_rounded),
                    onPressed: _onSignIn,
                  ),
                  const SizedBox(height: NuviSpacing.md),
                  Row(
                    children: [
                      const Expanded(child: Divider(color: NuviColors.line)),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: NuviSpacing.md,
                        ),
                        child: Text(
                          'OR',
                          style: x.micro.copyWith(color: NuviColors.inkFaint),
                        ),
                      ),
                      const Expanded(child: Divider(color: NuviColors.line)),
                    ],
                  ),
                  const SizedBox(height: NuviSpacing.md),
                  NuviButton.social(
                    text: 'Continue with Google',
                    icon: const Icon(Icons.g_mobiledata, size: 24),
                    onPressed: isLoading ? null : _onGoogleSignIn,
                  ),
                  const SizedBox(height: NuviSpacing.sm),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'New to NUVI KIDZ? ',
                        style: x.nunito(14, color: NuviColors.ink),
                      ),
                      GestureDetector(
                        onTap: isLoading ? null : () => context.go('/sign-up'),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text('Create an Account', style: linkStyle),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
