import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/nuvi_colors.dart';
import '../../../core/theme/nuvi_radii.dart';
import '../../../core/theme/nuvi_spacing.dart';
import '../../../core/theme/nuvi_theme_ext.dart';
import '../../../core/widgets/nuvi_decor.dart';
import '../../../core/widgets/nuvi_pressable.dart';
import '../domain/world_section.dart';

const kWorldMascotAsset = 'assets/images/onboarding/mascot_book.png';

/// NUVI World hub: mascot header and a 3×2 grid of the six areas.
class WorldScreen extends StatelessWidget {
  const WorldScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return Material(
      color: NuviColors.cream,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          NuviSpacing.gutter,
          NuviSpacing.sm,
          NuviSpacing.gutter,
          NuviSpacing.xl,
        ),
        children: [
          Text(
            'NUVI KIDZ World',
            textAlign: TextAlign.center,
            style: x.baloo(
              24,
              weight: FontWeight.w800,
              color: NuviColors.nightGreen,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Positioned(
                  left: 40,
                  top: 30,
                  child: NuviLeaf(size: 34, angle: -0.6),
                ),
                const Positioned(
                  left: 70,
                  bottom: 26,
                  child: NuviLeaf(size: 26, angle: 0.5),
                ),
                const Positioned(
                  right: 44,
                  top: 24,
                  child: NuviLeaf(size: 30, angle: 0.7),
                ),
                const Positioned(
                  right: 62,
                  bottom: 30,
                  child: NuviLeaf(size: 24, angle: -0.4),
                ),
                const Positioned(
                  right: 90,
                  top: 10,
                  child: NuviSparkle(size: 14),
                ),
                Image.asset(
                  kWorldMascotAsset,
                  height: 170,
                  excludeFromSemantics: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'A world of learning, care and parenting.',
            textAlign: TextAlign.center,
            style: x.nunito(
              15,
              weight: FontWeight.w600,
              color: NuviColors.inkMuted,
            ),
          ),
          const SizedBox(height: NuviSpacing.lg),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.82,
            children: [
              for (final s in WorldSection.values) _WorldTile(section: s),
            ],
          ),
        ],
      ),
    );
  }
}

class _WorldTile extends StatelessWidget {
  final WorldSection section;

  const _WorldTile({required this.section});

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return NuviPressable(
      onTap: () => context.push('/world/${section.slug}'),
      semanticLabel: section.title,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 14, 8, 10),
        decoration: BoxDecoration(
          color: section.tone.tint,
          borderRadius: BorderRadius.circular(NuviRadii.cardLarge),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F78461E),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: section.tone.blob,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    section.icon,
                    size: 34,
                    color: section.tone.accent,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 36,
              child: Center(
                child: Text(
                  section.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: x
                      .nunito(
                        13,
                        weight: FontWeight.w800,
                        color: NuviColors.nightGreen,
                      )
                      .copyWith(height: 1.15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
