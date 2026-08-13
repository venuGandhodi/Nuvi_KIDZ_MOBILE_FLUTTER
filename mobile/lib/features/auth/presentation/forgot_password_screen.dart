import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/nuvi_colors.dart';
import '../../../core/theme/nuvi_spacing.dart';
import '../../../core/theme/nuvi_typography.dart';
import '../../../core/widgets/nuvi_button.dart';
import '../../../core/widgets/nuvi_input_field.dart';
import '../../auth/domain/auth_exception.dart' as domain;
import 'auth_controller.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSendResetLink() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref
          .read(authControllerProvider.notifier)
          .sendPasswordReset(_emailController.text.trim());

      if (success && mounted) {
        setState(() {
          _emailSent = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      if (!_emailSent) {
        next.whenOrNull(
          error: (error, stackTrace) {
            String message = 'An error occurred';
            if (error is domain.AuthException) {
              message = error.message;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: NuviColors.error,
              ),
            );
          },
        );
      }
    });

    return Scaffold(
      backgroundColor: NuviColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: NuviColors.onSurface),
          onPressed: isLoading ? null : () => context.go('/sign-in'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: NuviSpacing.gutter),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: NuviSpacing.md),
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
                const SizedBox(height: NuviSpacing.lg),
                if (!_emailSent) ...[
                  Text(
                    'Forgot Password',
                    style: NuviTypography.textTheme.displayMedium,
                  ),
                  const SizedBox(height: NuviSpacing.sm),
                  Text(
                    "Enter your email and we'll send you a link to reset your password.",
                    style: NuviTypography.textTheme.bodyMedium?.copyWith(
                      color: NuviColors.onSurface.withValues(alpha: 0.7),
                    ),
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
                  const SizedBox(height: NuviSpacing.xxl),
                  NuviButton(
                    text: 'Send Reset Link',
                    isLoading: isLoading,
                    onPressed: _onSendResetLink,
                  ),
                ] else ...[
                  const Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: NuviColors.success,
                  ),
                  const SizedBox(height: NuviSpacing.lg),
                  Text(
                    'Email Sent!',
                    style: NuviTypography.textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: NuviSpacing.sm),
                  Text(
                    'A password reset link has been sent to ${_emailController.text.trim()}. Please check your email inbox.',
                    style: NuviTypography.textTheme.bodyMedium?.copyWith(
                      color: NuviColors.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: NuviSpacing.xxl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () => context.go('/sign-in'),
                      child: Text(
                        'Back to Sign In',
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
