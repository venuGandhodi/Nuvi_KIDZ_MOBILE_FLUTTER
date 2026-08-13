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

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignUp() async {
    if (_formKey.currentState!.validate() && _acceptedTerms) {
      final success = await ref
          .read(authControllerProvider.notifier)
          .signUp(
            _emailController.text.trim(),
            _passwordController.text,
            _nameController.text.trim(),
          );

      if (success && mounted) {
        // Success handling handled by authState changes in router
      }
    } else if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms & Conditions'),
          backgroundColor: NuviColors.error,
        ),
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
                Text(
                  'Create Account',
                  style: NuviTypography.textTheme.displayMedium,
                ),
                const SizedBox(height: NuviSpacing.sm),
                Text(
                  'Join Nuvi Kidz for exclusive perks and tiny styles.',
                  style: NuviTypography.textTheme.bodyMedium?.copyWith(
                    color: NuviColors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: NuviSpacing.xxl),
                NuviInputField(
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  controller: _nameController,
                  prefixIcon: const Icon(Icons.person_outline),
                  enabled: !isLoading,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
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
                  hint: 'Create a password',
                  controller: _passwordController,
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outline),
                  enabled: !isLoading,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: NuviSpacing.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _acceptedTerms,
                        onChanged: isLoading
                            ? null
                            : (val) {
                                setState(() {
                                  _acceptedTerms = val ?? false;
                                });
                              },
                        activeColor: NuviColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: NuviSpacing.sm),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: NuviTypography.textTheme.bodySmall?.copyWith(
                            color: NuviColors.onSurface.withValues(alpha: 0.7),
                          ),
                          children: [
                            const TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Terms & Conditions',
                              style: const TextStyle(
                                color: NuviColors.primary,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                              ),
                              // Recognizer would go here for linking
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: const TextStyle(
                                color: NuviColors.primary,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                              ),
                              // Recognizer would go here
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: NuviSpacing.xxl),
                NuviButton(
                  text: 'Create Account',
                  isLoading: isLoading,
                  onPressed: _onSignUp,
                ),
                const SizedBox(height: NuviSpacing.xxl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: NuviTypography.textTheme.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: isLoading ? null : () => context.go('/sign-in'),
                      child: Text(
                        'Sign In',
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
