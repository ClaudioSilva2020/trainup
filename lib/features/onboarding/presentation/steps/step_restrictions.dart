import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../onboarding_provider.dart';
import 'step_shell.dart';

class StepRestrictions extends ConsumerWidget {
  const StepRestrictions({super.key});

  static const _restrictions = [
    (value: 'joelho', label: 'Joelho', icon: Icons.accessibility_new),
    (value: 'lombar', label: 'Lombar / Coluna', icon: Icons.airline_seat_flat),
    (value: 'ombro', label: 'Ombro', icon: Icons.sports_handball),
    (value: 'cotovelo', label: 'Cotovelo', icon: Icons.back_hand),
    (value: 'tornozelo', label: 'Tornozelo', icon: Icons.directions_walk),
    (value: 'quadril', label: 'Quadril', icon: Icons.self_improvement),
    (value: 'pescoco', label: 'Pescoço / Cervical', icon: Icons.face),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(onboardingDraftProvider).restrictions;

    return StepShell(
      title: 'Restrições ou lesões?',
      subtitle:
          'Selecione as regiões que precisam de atenção. '
          'O app vai evitar exercícios de risco para essas áreas.\n'
          'Se não tiver nenhuma, pode avançar!',
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _restrictions.map((r) {
          final isSelected = selected.contains(r.value);
          return GestureDetector(
            onTap: () => ref
                .read(onboardingDraftProvider.notifier)
                .toggleRestriction(r.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.navy : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected
                      ? AppColors.navy
                      : AppColors.grey.withAlpha(60),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    r.icon,
                    size: 16,
                    color: isSelected ? AppColors.green : AppColors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    r.label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.navy,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
