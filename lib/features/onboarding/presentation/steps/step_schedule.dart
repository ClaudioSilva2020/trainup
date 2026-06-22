import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../onboarding_provider.dart';
import '_option_card.dart';
import 'step_shell.dart';

class StepSchedule extends ConsumerWidget {
  const StepSchedule({super.key});

  static const _equipmentOptions = [
    (
      value: 'academia',
      label: 'Academia completa',
      subtitle: 'Acesso a máquinas, barras e halteres',
      icon: Icons.business,
    ),
    (
      value: 'halteres',
      label: 'Halteres em casa',
      subtitle: 'Treino com halteres ajustáveis ou fixos',
      icon: Icons.sports_gymnastics,
    ),
    (
      value: 'peso_corporal',
      label: 'Peso corporal',
      subtitle: 'Sem equipamento — funcional e calistenia',
      icon: Icons.self_improvement,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingDraftProvider);

    return StepShell(
      title: 'Agenda e equipamento',
      subtitle: 'Quantos dias por semana e onde você vai treinar?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Dias por semana',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (i) {
              final days = i + 2; // 2–6
              final selected = draft.daysPerWeek == days;
              return GestureDetector(
                onTap: () => ref
                    .read(onboardingDraftProvider.notifier)
                    .setDaysPerWeek(days),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.navy : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? AppColors.navy
                          : AppColors.grey.withAlpha(60),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$days',
                        style: TextStyle(
                          color: selected ? AppColors.green : AppColors.navy,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        days == 1 ? 'dia' : 'dias',
                        style: TextStyle(
                          color: selected ? Colors.white70 : AppColors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 28),
          Text(
            'Onde você vai treinar?',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          ..._equipmentOptions.map(
            (o) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OptionCard(
                label: o.value,
                title: o.label,
                subtitle: o.subtitle,
                icon: o.icon,
                selected: draft.equipment == o.value,
                onTap: () => ref
                    .read(onboardingDraftProvider.notifier)
                    .setEquipment(o.value),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
