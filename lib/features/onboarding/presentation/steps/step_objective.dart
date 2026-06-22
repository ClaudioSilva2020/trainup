import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../onboarding_provider.dart';
import '_option_card.dart';
import 'step_shell.dart';

class StepObjective extends ConsumerWidget {
  const StepObjective({super.key});

  static const _options = [
    (
      value: 'hipertrofia',
      label: 'Ganhar massa muscular',
      subtitle: 'Treinos de força com volume progressivo',
      icon: Icons.fitness_center,
    ),
    (
      value: 'perda_gordura',
      label: 'Perder gordura',
      subtitle: 'Alta frequência, menor descanso entre séries',
      icon: Icons.local_fire_department,
    ),
    (
      value: 'condicionamento',
      label: 'Melhorar condicionamento',
      subtitle: 'Resistência cardiovascular e funcional',
      icon: Icons.directions_run,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(onboardingDraftProvider).objective;

    return StepShell(
      title: 'Qual é o seu objetivo?',
      subtitle: 'Vamos montar o treino ideal para a sua meta.',
      child: Column(
        children: _options
            .map(
              (o) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: OptionCard(
                  label: o.value,
                  title: o.label,
                  subtitle: o.subtitle,
                  icon: o.icon,
                  selected: selected == o.value,
                  onTap: () => ref
                      .read(onboardingDraftProvider.notifier)
                      .setObjective(o.value),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
