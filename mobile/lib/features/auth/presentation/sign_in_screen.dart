import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/nuvi_colors.dart';
import '../../../core/theme/nuvi_spacing.dart';
import '../../../core/theme/nuvi_typography.dart';
import '../../../core/utils/nuvi_logger.dart';
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
        // Success handling handled by authState changes in router
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
    }
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

    return Scaffold(
      backgroundColor: NuviColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(NuviSpacing.gutter),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: NuviSpacing.xl),
                // Logo placeholder
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: NuviColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Image.asset(
                        'assets/images/brand/nuvi_kidz_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: NuviSpacing.xl),
                Text(
                  'Welcome Back',
                  style: NuviTypography.textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: NuviSpacing.sm),
                Text(
                  'Sign in to continue your Nuvi journey',
                  style: NuviTypography.textTheme.bodyMedium?.copyWith(
                    color: NuviColors.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: NuviSpacing.xxl),
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
                      style: NuviTypography.textTheme.labelLarge?.copyWith(
                        color: NuviColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: NuviSpacing.xl),
                NuviButton(
                  text: 'Sign In',
                  isLoading: isLoading,
                  onPressed: _onSignIn,
                ),
                const SizedBox(height: NuviSpacing.xxl),
                Row(
                  children: [
                    Expanded(child: Divider(color: NuviColors.border)),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: NuviSpacing.md,
                      ),
                      child: Text(
                        'OR',
                        style: NuviTypography.textTheme.bodySmall?.copyWith(
                          color: NuviColors.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: NuviColors.border)),
                  ],
                ),
                const SizedBox(height: NuviSpacing.xl),
                NuviButton.social(
                  text: 'Continue with Google',
                  icon: const Icon(Icons.g_mobiledata, size: 24),
                  onPressed: isLoading ? null : _onGoogleSignIn,
                ),
                const SizedBox(height: NuviSpacing.xxl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account? ',
                      style: NuviTypography.textTheme.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: isLoading ? null : () => context.go('/sign-up'),
                      child: Text(
                        'Sign Up',
                        style: NuviTypography.textTheme.labelLarge?.copyWith(
                          color: NuviColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: NuviSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
