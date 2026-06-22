import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/trainup_logo.dart';
import '../../workout_engine/domain/workout_plan.dart';
import '../../workout_engine/presentation/workout_engine_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(activePlanProvider);
    final generateState = ref.watch(generatePlanProvider);
    final user = Supabase.instance.client.auth.currentUser;
    final firstName = (user?.userMetadata?['full_name'] as String?)
            ?.split(' ')
            .first ??
        'Atleta';

    ref.listen<GeneratePlanState>(generatePlanProvider, (_, next) {
      if (next is GeneratePlanError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Colors.red.shade700,
          ),
        );
        ref.read(generatePlanProvider.notifier).reset();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        title: const TrainUpLogo(
            variant: TrainUpLogoVariant.horizontal, height: 28),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            tooltip: 'Sair',
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
            },
          ),
        ],
      ),
      body: planAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.green),
        ),
        error: (e, _) => _ErrorView(message: e.toString()),
        data: (plan) {
          if (plan == null) {
            return _EmptyPlanView(
              firstName: firstName,
              isGenerating: generateState is GeneratePlanLoading,
              onGenerate: () =>
                  ref.read(generatePlanProvider.notifier).generate(),
            );
          }
          return _PlanView(plan: plan, firstName: firstName);
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sem plano gerado ainda
// ---------------------------------------------------------------------------
class _EmptyPlanView extends StatelessWidget {
  const _EmptyPlanView({
    required this.firstName,
    required this.isGenerating,
    required this.onGenerate,
  });

  final String firstName;
  final bool isGenerating;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.fitness_center, size: 72, color: AppColors.green),
            const SizedBox(height: 20),
            Text(
              'Olá, $firstName!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.navy,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vamos gerar o seu plano de treino personalizado agora.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.grey),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: isGenerating ? null : onGenerate,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(220, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: isGenerating
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(
                isGenerating ? 'Gerando...' : 'Gerar meu treino',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Plano gerado — exibe divisão de treino completa
// ---------------------------------------------------------------------------
class _PlanView extends StatelessWidget {
  const _PlanView({required this.plan, required this.firstName});

  final WorkoutPlan plan;
  final String firstName;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
            child: _PlanHeader(plan: plan, firstName: firstName)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          sliver: SliverList.separated(
            itemCount: plan.days.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 12),
            itemBuilder: (_, i) =>
                _DayCard(day: plan.days[i], planId: plan.id),
          ),
        ),
      ],
    );
  }
}

class _PlanHeader extends StatelessWidget {
  const _PlanHeader({required this.plan, required this.firstName});

  final WorkoutPlan plan;
  final String firstName;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navy,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Olá, $firstName!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            plan.splitTemplateName,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatChip(
                icon: Icons.calendar_today,
                label: '${plan.days.length} dias/semana',
              ),
              const SizedBox(width: 10),
              _StatChip(
                icon: Icons.loop,
                label: 'Semana ${plan.cycleWeek} de 4',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.green, size: 14),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({required this.day, required this.planId});

  final WorkoutDay day;
  final String planId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        '/session',
        extra: (day: day, planId: planId),
      ),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.navy,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${day.dayIndex + 1}',
                        style: const TextStyle(
                          color: AppColors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    day.label,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        '${day.exercises.length} exercícios',
                        style: const TextStyle(
                            color: AppColors.grey, fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right,
                          color: AppColors.grey, size: 18),
                    ],
                  ),
                ],
              ),
              if (day.exercises.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                ...day.exercises.map((e) => _ExerciseRow(exercise: e)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({required this.exercise});

  final PlannedExercise exercise;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.fitness_center,
                color: AppColors.green, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  exercise.primaryMuscle,
                  style:
                      const TextStyle(color: AppColors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${exercise.sets}×${exercise.repsMin}-${exercise.repsMax}',
                style: const TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                'RIR ${exercise.rir} · ${exercise.restSeconds}s',
                style:
                    const TextStyle(color: AppColors.grey, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.grey)),
          ],
        ),
      ),
    );
  }
}
