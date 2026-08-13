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

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onUpdatePassword() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref
          .read(authControllerProvider.notifier)
          .updatePassword(_passwordController.text);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Password updated successfully. Please sign in with your new password.',
            ),
            backgroundColor: NuviColors.success,
          ),
        );
        // Sign out to clear the recovery session, routing redirect will automatically send to /sign-in
        await ref.read(authControllerProvider.notifier).signOut();
      }
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
                  'Reset Password',
                  style: NuviTypography.textTheme.displayMedium,
                ),
                const SizedBox(height: NuviSpacing.sm),
                Text(
                  'Enter your new password below.',
                  style: NuviTypography.textTheme.bodyMedium?.copyWith(
                    color: NuviColors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: NuviSpacing.xxl),
                NuviInputField(
                  label: 'New Password',
                  hint: 'Enter your new password',
                  controller: _passwordController,
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outline),
                  enabled: !isLoading,
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
                NuviInputField(
                  label: 'Confirm Password',
                  hint: 'Confirm your new password',
                  controller: _confirmPasswordController,
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outline),
                  enabled: !isLoading,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirm password is required';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: NuviSpacing.xxl),
                NuviButton(
                  text: 'Update Password',
                  isLoading: isLoading,
                  onPressed: _onUpdatePassword,
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
