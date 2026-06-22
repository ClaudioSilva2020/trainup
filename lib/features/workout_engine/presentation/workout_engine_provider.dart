import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/workout_engine_repository_impl.dart';
import '../domain/workout_engine_repository.dart';
import '../domain/workout_plan.dart';

final workoutEngineRepositoryProvider = Provider<WorkoutEngineRepository>((ref) {
  return WorkoutEngineRepositoryImpl(Supabase.instance.client);
});

// Busca o plano ativo ou retorna null (sem gerar)
final activePlanProvider = FutureProvider<WorkoutPlan?>((ref) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return null;
  return ref.read(workoutEngineRepositoryProvider).fetchActivePlan(userId: userId);
});

// Geração do plano (disparado manualmente após onboarding)
sealed class GeneratePlanState {
  const GeneratePlanState();
}

class GeneratePlanIdle extends GeneratePlanState {
  const GeneratePlanIdle();
}

class GeneratePlanLoading extends GeneratePlanState {
  const GeneratePlanLoading();
}

class GeneratePlanSuccess extends GeneratePlanState {
  const GeneratePlanSuccess(this.plan);
  final WorkoutPlan plan;
}

class GeneratePlanError extends GeneratePlanState {
  const GeneratePlanError(this.message);
  final String message;
}

class GeneratePlanNotifier extends Notifier<GeneratePlanState> {
  @override
  GeneratePlanState build() => const GeneratePlanIdle();

  Future<void> generate() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    state = const GeneratePlanLoading();
    try {
      final plan = await ref
          .read(workoutEngineRepositoryProvider)
          .generatePlan(userId: userId);
      ref.invalidate(activePlanProvider);
      state = GeneratePlanSuccess(plan);
    } catch (e) {
      state = GeneratePlanError('Erro ao gerar treino: $e');
    }
  }

  void reset() => state = const GeneratePlanIdle();
}

final generatePlanProvider =
    NotifierProvider<GeneratePlanNotifier, GeneratePlanState>(
        GeneratePlanNotifier.new);
