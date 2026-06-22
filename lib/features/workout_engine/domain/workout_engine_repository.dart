import 'workout_plan.dart';

abstract interface class WorkoutEngineRepository {
  /// Gera e persiste um plano automático (RF-002).
  /// Retorna o plano gerado.
  Future<WorkoutPlan> generatePlan({required String userId});

  /// Busca o plano ativo do usuário (já gerado).
  Future<WorkoutPlan?> fetchActivePlan({required String userId});
}
