import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../onboarding_provider.dart';
import '_option_card.dart';
import 'step_shell.dart';

class StepLevel extends ConsumerWidget {
  const StepLevel({super.key});

  static const _options = [
    (
      value: 'iniciante',
      label: 'Iniciante',
      subtitle: 'Menos de 1 ano de treino consistente',
      icon: Icons.emoji_people,
    ),
    (
      value: 'intermediario',
      label: 'Intermediário',
      subtitle: '1 a 3 anos de treino consistente',
      icon: Icons.trending_up,
    ),
    (
      value: 'avancado',
      label: 'Avançado',
      subtitle: 'Mais de 3 anos, boa base técnica',
      icon: Icons.military_tech,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(onboardingDraftProvider).level;

    return StepShell(
      title: 'Qual é o seu nível?',
      subtitle: 'Isso define a complexidade dos exercícios e o volume.',
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
                      .setLevel(o.value),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
