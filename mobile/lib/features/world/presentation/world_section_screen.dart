import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/nuvi_colors.dart';
import '../../../core/theme/nuvi_radii.dart';
import '../../../core/theme/nuvi_spacing.dart';
import '../../../core/theme/nuvi_theme_ext.dart';
import '../../../core/widgets/nuvi_bottom_sheet.dart';
import '../../../core/widgets/nuvi_button.dart';
import '../../../core/widgets/nuvi_input_field.dart';
import '../../../core/widgets/nuvi_pressable.dart';
import '../../../core/widgets/nuvi_top_bar.dart';
import '../data/hospital_plan_repository.dart';
import '../data/world_repository.dart';
import '../domain/hospital_plan.dart';
import '../domain/world_section.dart';
import 'widgets/article_list.dart';

/// One NUVI World area: an intro card, the area's tool (pregnancy tracker
/// or hospital planner) when it has one, and its Shopify blog articles.
class WorldSectionScreen extends ConsumerWidget {
  final WorldSection section;

  const WorldSectionScreen({super.key, required this.section});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final x = context.nuvi;
    return Scaffold(
      backgroundColor: NuviColors.cream,
      appBar: NuviTopBar(
        title: Text(section.title, style: x.h3),
        showBackButton: true,
        showCart: false,
      ),
      body: RefreshIndicator(
        color: NuviColors.ink,
        onRefresh: () => ref.refresh(worldArticlesProvider(section).future),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            NuviSpacing.gutter,
            NuviSpacing.sm,
            NuviSpacing.gutter,
            NuviSpacing.xxl,
          ),
          children: [
            _IntroCard(section: section),
            const SizedBox(height: NuviSpacing.lg),
            if (section == WorldSection.pregnancyJourney) ...[
              const PregnancyTracker(),
              const SizedBox(height: NuviSpacing.lg),
            ],
            if (section == WorldSection.hospitalPlanner) ...[
              const HospitalPlanner(),
              const SizedBox(height: NuviSpacing.lg),
            ],
            ArticleList(
              section: section,
              heading: switch (section) {
                WorldSection.pregnancyJourney => 'Guides for your journey',
                WorldSection.hospitalPlanner => 'Helpful reads',
                _ => 'Latest articles',
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  final WorldSection section;

  const _IntroCard({required this.section});

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: section.tone.tint,
        borderRadius: BorderRadius.circular(NuviRadii.cardLarge),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: NuviColors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(section.icon, size: 28, color: section.tone.accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              section.blurb,
              style: x.nunito(
                15,
                weight: FontWeight.w600,
                color: NuviColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<DateTime?> _pickDueDate(BuildContext context, DateTime? current) {
  final today = DateTime.now();
  return showDatePicker(
    context: context,
    initialDate: current ?? today.add(const Duration(days: 120)),
    firstDate: today.subtract(const Duration(days: 30)),
    lastDate: today.add(const Duration(days: 300)),
    helpText: 'Select your due date',
  );
}

class _Panel extends StatelessWidget {
  final Widget child;

  const _Panel({required this.child});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(NuviRadii.cardLarge);
    // A Material (not a coloured box) so checklist ink splashes show.
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F78461E),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: NuviColors.white,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );
  }
}

/// Week-by-week progress from the due date saved in the hospital plan.
class PregnancyTracker extends ConsumerWidget {
  const PregnancyTracker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final x = context.nuvi;
    final plan = ref.watch(hospitalPlanProvider);
    final controller = ref.read(hospitalPlanProvider.notifier);
    final due = plan.dueDate;

    Future<void> edit() async {
      final picked = await _pickDueDate(context, due);
      if (picked != null) await controller.setDueDate(picked);
    }

    if (due == null) {
      return _Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Track your pregnancy', style: x.h3),
            const SizedBox(height: 6),
            Text(
              'Add your due date to see which week you’re in and how many '
              'days are left.',
              style: x.nunito(14, color: NuviColors.inkMuted),
            ),
            const SizedBox(height: 14),
            NuviButton(
              text: 'Add due date',
              type: NuviButtonType.leaf,
              icon: const Icon(Icons.event_rounded),
              onPressed: edit,
            ),
          ],
        ),
      );
    }

    final p = PregnancyProgress.from(due, DateTime.now());
    final status = p.daysToGo > 0
        ? '${p.daysToGo} days to go'
        : p.daysToGo == 0
        ? 'Your due date is today'
        : 'Due date was ${-p.daysToGo} days ago';
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Week ${p.week}',
                      style: x.baloo(
                        30,
                        weight: FontWeight.w800,
                        color: NuviColors.nightGreen,
                      ),
                    ),
                    Text(
                      '${p.dayOfWeek} day${p.dayOfWeek == 1 ? '' : 's'} · '
                      'Trimester ${p.trimester}',
                      style: x.nunito(14, color: NuviColors.inkMuted),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: edit,
                icon: const Icon(Icons.edit_calendar_rounded, size: 18),
                label: const Text('Due date'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(NuviRadii.pill),
            child: LinearProgressIndicator(
              value: p.fraction,
              minHeight: 10,
              color: x.leaf,
              backgroundColor: NuviColors.sageSoft,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(status, style: x.nunito(13.5, weight: FontWeight.w700)),
              const Spacer(),
              Text(
                'Due ${formatArticleDate(due)}',
                style: x.nunito(13, color: NuviColors.inkMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Always follow your doctor’s advice for your pregnancy.',
            style: x.nunito(12, color: NuviColors.inkFaint),
          ),
        ],
      ),
    );
  }
}

/// Delivery details plus a hospital-bag checklist you can tick, add to and
/// remove from. Everything is saved on the phone.
class HospitalPlanner extends ConsumerWidget {
  const HospitalPlanner({super.key});

  Future<void> _editDetails(BuildContext context, WidgetRef ref) async {
    final plan = ref.read(hospitalPlanProvider);
    final hospital = TextEditingController(text: plan.hospitalName);
    final doctor = TextEditingController(text: plan.doctorName);
    final phone = TextEditingController(text: plan.doctorPhone);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheet) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheet).viewInsets.bottom,
        ),
        child: NuviSheet(
          title: 'Delivery details',
          footer: NuviButton(
            text: 'Save',
            type: NuviButtonType.leaf,
            onPressed: () {
              ref
                  .read(hospitalPlanProvider.notifier)
                  .setDetails(
                    hospitalName: hospital.text.trim(),
                    doctorName: doctor.text.trim(),
                    doctorPhone: phone.text.trim(),
                  );
              Navigator.pop(sheet);
            },
          ),
          child: Column(
            children: [
              NuviInputField(
                label: 'Hospital',
                hint: 'Hospital name',
                controller: hospital,
              ),
              const SizedBox(height: 12),
              NuviInputField(
                label: 'Doctor',
                hint: 'Doctor’s name',
                controller: doctor,
              ),
              const SizedBox(height: 12),
              NuviInputField(
                label: 'Doctor’s phone',
                hint: 'Phone number',
                controller: phone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
              ),
            ],
          ),
        ),
      ),
    );
    hospital.dispose();
    doctor.dispose();
    phone.dispose();
  }

  Future<void> _addItem(
    BuildContext context,
    WidgetRef ref,
    String group,
  ) async {
    final text = TextEditingController();
    final label = await showDialog<String>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text('Add to $group'),
        content: TextField(
          controller: text,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'e.g. Water bottle'),
          onSubmitted: (v) => Navigator.pop(dialog, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialog, text.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    text.dispose();
    if (label != null) {
      await ref.read(hospitalPlanProvider.notifier).addItem(group, label);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final x = context.nuvi;
    final plan = ref.watch(hospitalPlanProvider);
    final controller = ref.read(hospitalPlanProvider.notifier);
    final total = plan.items.length;

    Widget detail(
      IconData icon,
      String label,
      String value, {
      VoidCallback? onTap,
    }) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 20, color: x.leaf),
          const SizedBox(width: 10),
          Text('$label: ', style: x.nunito(14, weight: FontWeight.w700)),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Text(
                value.isEmpty ? 'Not added' : value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: x
                    .nunito(
                      14,
                      color: value.isEmpty
                          ? NuviColors.inkFaint
                          : (onTap != null
                                ? NuviColors.leafDark
                                : NuviColors.ink),
                    )
                    .copyWith(
                      decoration: onTap != null && value.isNotEmpty
                          ? TextDecoration.underline
                          : null,
                    ),
              ),
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: Text('Delivery details', style: x.h3)),
                  TextButton(
                    onPressed: () => _editDetails(context, ref),
                    child: const Text('Edit'),
                  ),
                ],
              ),
              detail(
                Icons.event_rounded,
                'Due date',
                plan.dueDate == null ? '' : formatArticleDate(plan.dueDate!),
                onTap: () async {
                  final picked = await _pickDueDate(context, plan.dueDate);
                  if (picked != null) await controller.setDueDate(picked);
                },
              ),
              detail(
                Icons.local_hospital_outlined,
                'Hospital',
                plan.hospitalName,
              ),
              detail(Icons.person_outline_rounded, 'Doctor', plan.doctorName),
              detail(
                Icons.call_outlined,
                'Phone',
                plan.doctorPhone,
                onTap: plan.doctorPhone.isEmpty
                    ? null
                    : () =>
                          launchUrl(Uri(scheme: 'tel', path: plan.doctorPhone)),
              ),
            ],
          ),
        ),
        const SizedBox(height: NuviSpacing.md),
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Hospital bag checklist', style: x.h3),
              const SizedBox(height: 6),
              Text(
                '${plan.doneCount} of $total packed',
                style: x.nunito(13.5, color: NuviColors.inkMuted),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(NuviRadii.pill),
                child: LinearProgressIndicator(
                  value: total == 0 ? 0 : plan.doneCount / total,
                  minHeight: 8,
                  color: x.leaf,
                  backgroundColor: NuviColors.sageSoft,
                ),
              ),
              for (final group in HospitalPlan.groups) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        group,
                        style: x.nunito(
                          15,
                          weight: FontWeight.w800,
                          color: NuviColors.nightGreen,
                        ),
                      ),
                    ),
                    NuviPressable(
                      onTap: () => _addItem(context, ref, group),
                      semanticLabel: 'Add item to $group',
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Row(
                          children: [
                            Icon(Icons.add_rounded, size: 18, color: x.leaf),
                            Text(
                              'Add',
                              style: x.nunito(
                                13.5,
                                weight: FontWeight.w700,
                                color: NuviColors.leafDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                for (final item in plan.items.where((i) => i.group == group))
                  Dismissible(
                    key: ValueKey(item.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => controller.removeItem(item.id),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 12),
                      color: NuviColors.saleSoft,
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: NuviColors.sale,
                      ),
                    ),
                    child: CheckboxListTile(
                      value: item.done,
                      onChanged: (_) => controller.toggle(item.id),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: x.leaf,
                      title: Text(
                        item.label,
                        style: x
                            .nunito(14.5)
                            .copyWith(
                              decoration: item.done
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: item.done
                                  ? NuviColors.inkFaint
                                  : NuviColors.ink,
                            ),
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: 6),
              Text(
                'Swipe an item left to remove it.',
                style: x.nunito(12, color: NuviColors.inkFaint),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
