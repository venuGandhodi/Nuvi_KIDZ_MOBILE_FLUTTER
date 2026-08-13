// PHASE 1 PLACEHOLDER — Replace with full NUVI KIDZ Home implementation.
// This screen exists solely to validate the authentication + navigation
// lifecycle during Phase 1 development. It must be replaced before any
// production or user-facing release.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/nuvi_colors.dart';
import '../../../core/theme/nuvi_typography.dart';
import '../../../core/widgets/nuvi_button.dart';
import '../../auth/presentation/auth_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: NuviColors.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // NUVI KIDZ brand mark
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: NuviColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      'assets/images/brand/nuvi_kidz_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'NUVI KIDZ',
                  style: NuviTypography.textTheme.displayMedium?.copyWith(
                    color: NuviColors.primary,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Welcome!',
                  style: NuviTypography.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'You are signed in successfully.',
                  style: NuviTypography.textTheme.bodyMedium?.copyWith(
                    color: NuviColors.onSurface.withValues(alpha: 0.65),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: NuviColors.secondary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: NuviColors.secondary.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    'Phase 1 — Development Placeholder',
                    style: NuviTypography.textTheme.labelSmall?.copyWith(
                      color: NuviColors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                NuviButton(
                  text: 'Sign Out',
                  onPressed: () async {
                    await ref.read(authControllerProvider.notifier).signOut();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
