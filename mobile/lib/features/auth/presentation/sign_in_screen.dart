import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/nuvi_colors.dart';
import '../../../core/theme/nuvi_spacing.dart';
import '../../../core/theme/nuvi_decorations.dart';
import '../../../core/theme/nuvi_radii.dart';
import '../../../core/theme/nuvi_theme_ext.dart';
import '../../../core/widgets/nuvi_decor.dart';
import '../../../core/utils/nuvi_logger.dart';
import '../../../core/widgets/nuvi_animations.dart';
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
    return Scaffold(
      backgroundColor: NuviColors.cream,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _WelcomePanel(top: MediaQuery.paddingOf(context).top),
              Transform.translate(
                offset: const Offset(0, -28),
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: NuviSpacing.gutter,
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  decoration: BoxDecoration(
                    color: NuviColors.card,
                    borderRadius: BorderRadius.circular(NuviRadii.sheet),
                    boxShadow: NuviShadows.soft,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Welcome back',
                        style: x.h2,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sign in to continue your Nuvi journey',
                        style: x.small,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: NuviSpacing.lg),
                      NuviInputField(
                        label: 'Email',
                        hint: 'Enter your email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined),
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
                      const SizedBox(height: NuviSpacing.lg),
                      NuviInputField(
                        label: 'Password',
                        hint: 'Enter your password',
                        controller: _passwordController,
                        obscureText: true,
                        prefixIcon: const Icon(Icons.lock_outline),
                        enabled: !isLoading,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: NuviSpacing.md),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: isLoading
                              ? null
                              : () => context.go('/forgot-password'),
                          child: Text(
                            'Forgot Password?',
                            style: x
                                .nunito(13.5, weight: FontWeight.w800)
                                .copyWith(decoration: TextDecoration.underline),
                          ),
                        ),
                      ),
                      const SizedBox(height: NuviSpacing.sm),
                      NuviButton(
                        text: 'Sign In',
                        type: NuviButtonType.dark,
                        isLoading: isLoading,
                        trailingIcon: const Icon(Icons.arrow_forward_rounded),
                        onPressed: _onSignIn,
                      ),
                      const SizedBox(height: NuviSpacing.md),
                      Row(
                        children: [
                          const Expanded(
                            child: Divider(color: NuviColors.line),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: NuviSpacing.md,
                            ),
                            child: Text(
                              'OR',
                              style: x.micro.copyWith(
                                color: NuviColors.inkFaint,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Divider(color: NuviColors.line),
                          ),
                        ],
                      ),
                      const SizedBox(height: NuviSpacing.md),
                      NuviButton.social(
                        text: 'Continue with Google',
                        icon: const Icon(Icons.g_mobiledata, size: 24),
                        onPressed: isLoading ? null : _onGoogleSignIn,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: NuviSpacing.gutter,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _Perk(
                      icon: Icons.local_shipping_outlined,
                      title: 'Track every order',
                      tone: NuviTone.sky,
                    ),
                    const _Perk(
                      icon: Icons.favorite_border_rounded,
                      title: 'Keep a wishlist of favourites',
                      tone: NuviTone.pink,
                    ),
                    const _Perk(
                      icon: Icons.home_outlined,
                      title: 'Save addresses for quicker checkout',
                      tone: NuviTone.sage,
                    ),
                    const SizedBox(height: NuviSpacing.md),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text('Don\'t have an account? ', style: x.body),
                        GestureDetector(
                          onTap: isLoading
                              ? null
                              : () => context.go('/sign-up'),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'Sign Up',
                              style: x
                                  .baloo(15, weight: FontWeight.w700)
                                  .copyWith(
                                    decoration: TextDecoration.underline,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height:
                          MediaQuery.paddingOf(context).bottom + NuviSpacing.md,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomePanel extends StatelessWidget {
  final double top;

  const _WelcomePanel({required this.top});

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.2),
          radius: 0.9,
          colors: [x.peachSoft, NuviColors.cream],
        ),
      ),
      padding: EdgeInsets.only(top: top + NuviSpacing.lg),
      child: Stack(
        children: [
          Positioned(
            top: 10,
            left: 32,
            child: NuviSparkle(size: 16, color: x.gold),
          ),
          Positioned(
            top: 64,
            right: 40,
            child: NuviSparkle(size: 11, color: x.peach),
          ),
          Positioned(
            top: 120,
            left: 54,
            child: NuviLeaf(size: 22, color: x.sage, angle: -0.6),
          ),
          Column(
            children: [
              const NuviMascotAnimated(
                loop: NuviMascotLoop.wave,
                child: NuviMascot(size: 120, semanticLabel: 'NUVI elephant'),
              ),
              const SizedBox(height: NuviSpacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: NuviSpacing.xl),
                child: Column(
                  children: [
                    Text(
                      'Welcome to the NUVI family',
                      textAlign: TextAlign.center,
                      style: x.h1,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tiny styles, big smiles, beautiful memories.',
                      textAlign: TextAlign.center,
                      style: x.bodyMuted,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: NuviSpacing.sm),
              const NuviHills(height: 70),
            ],
          ),
        ],
      ),
    );
  }
}

class _Perk extends StatelessWidget {
  final IconData icon;
  final String title;
  final NuviTone tone;

  const _Perk({required this.icon, required this.title, required this.tone});

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return Padding(
      padding: const EdgeInsets.only(bottom: NuviSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: tone.tint, shape: BoxShape.circle),
            child: Icon(icon, size: 19, color: tone.accent),
          ),
          const SizedBox(width: NuviSpacing.s12),
          Expanded(
            child: Text(title, style: x.nunito(14.5, weight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
