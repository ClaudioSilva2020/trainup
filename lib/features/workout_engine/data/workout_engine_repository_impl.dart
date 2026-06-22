import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/workout_engine_repository.dart';
import '../domain/workout_plan.dart';

class WorkoutEngineRepositoryImpl implements WorkoutEngineRepository {
  WorkoutEngineRepositoryImpl(this._client);

  final SupabaseClient _client;

  // Ordem de dificuldade para filtrar "até o nível do usuário"
  static const _levelOrder = ['iniciante', 'intermediario', 'avancado'];

  @override
  Future<WorkoutPlan> generatePlan({required String userId}) async {
    // 1. Perfil do usuário
    final profileData = await _client
        .from('user_training_profile')
        .select()
        .eq('user_id', userId)
        .single();

    final objective = profileData['objective'] as String;
    final level = profileData['level'] as String;
    final daysPerWeek = profileData['days_per_week'] as int;
    final equipment = profileData['equipment'] as String;
    final userRestrictions =
        List<String>.from(profileData['restrictions'] as List);

    // 2. Parâmetros de objetivo
    final objParams = await _client
        .from('objective_parameters')
        .select()
        .eq('objective', objective)
        .single();

    final setsMin = objParams['sets_min'] as int;
    final setsMax = objParams['sets_max'] as int;
    final repsMin = objParams['reps_min'] as int;
    final repsMax = objParams['reps_max'] as int;
    final rirMin = objParams['rir_min'] as int;
    final rirMax = objParams['rir_max'] as int;
    final restSeconds = objParams['rest_seconds'] as int;

    // 3. Split template
    final splits = await _client
        .from('split_templates')
        .select()
        .eq('level', level)
        .eq('days_per_week', daysPerWeek);

    if (splits.isEmpty) {
      throw Exception(
          'Nenhum split template encontrado para nível=$level, dias=$daysPerWeek');
    }
    final split = splits.first;
    final splitId = split['id'] as String;
    final splitName = split['name'] as String;
    final structure = (split['structure'] as List)
        .cast<Map<String, dynamic>>();

    // 4. Exercícios elegíveis (equipment + até o nível do usuário)
    final levelIdx = _levelOrder.indexOf(level);
    final allowedLevels = _levelOrder.sublist(0, levelIdx + 1);

    final exercisesData = await _client
        .from('exercises')
        .select()
        .eq('equipment', equipment)
        .inFilter('difficulty_level', allowedLevels);

    // 5. Desativar plano anterior
    await _client
        .from('workout_plans')
        .update({'active': false})
        .eq('user_id', userId)
        .eq('active', true);

    // 6. Criar novo plano
    final planRow = await _client
        .from('workout_plans')
        .insert({
          'user_id': userId,
          'source': 'auto',
          'created_by': userId,
          'cycle_week': 1,
          'split_template_id': splitId,
          'active': true,
        })
        .select()
        .single();

    final planId = planRow['id'] as String;

    // 7. Montar dias e exercícios
    final days = <WorkoutDay>[];
    final allPlanExercises = <Map<String, dynamic>>[];

    for (var i = 0; i < structure.length; i++) {
      final dayStruct = structure[i];
      final dayLabel = dayStruct['label'] as String;
      final patterns = List<String>.from(dayStruct['patterns'] as List);

      final plannedExercises = <PlannedExercise>[];
      var orderIndex = 0;

      for (final pattern in patterns) {
        // Filtra por padrão de movimento, excluindo restrições do usuário
        final candidates = (exercisesData as List)
            .cast<Map<String, dynamic>>()
            .where((e) =>
                e['movement_pattern'] == pattern &&
                !_hasConflict(
                  List<String>.from(e['restrictions'] as List),
                  userRestrictions,
                ))
            .toList();

        if (candidates.isEmpty) continue;

        // Escolhe um exercício (composto tem prioridade)
        candidates.sort((a, b) {
          final aComp = a['exercise_type'] == 'composto' ? 0 : 1;
          final bComp = b['exercise_type'] == 'composto' ? 0 : 1;
          return aComp.compareTo(bComp);
        });
        final exercise = candidates.first;

        final sets = _midpoint(setsMin, setsMax);
        final rir = _midpoint(rirMin, rirMax);

        plannedExercises.add(PlannedExercise(
          exerciseId: exercise['id'] as String,
          name: exercise['name'] as String,
          primaryMuscle: exercise['primary_muscle'] as String,
          sets: sets,
          repsMin: repsMin,
          repsMax: repsMax,
          rir: rir,
          restSeconds: restSeconds,
          videoUrl: exercise['video_url'] as String?,
        ));

        allPlanExercises.add({
          'plan_id': planId,
          'day_index': i,
          'exercise_id': exercise['id'],
          'order_index': orderIndex++,
          'sets': sets,
          'reps_min': repsMin,
          'reps_max': repsMax,
          'rir': rir,
          'rest_seconds': restSeconds,
        });
      }

      days.add(WorkoutDay(
        dayIndex: i,
        label: dayLabel,
        exercises: plannedExercises,
      ));
    }

    // 8. Persistir exercícios do plano em lote
    if (allPlanExercises.isNotEmpty) {
      await _client.from('workout_plan_exercises').insert(allPlanExercises);
    }

    return WorkoutPlan(
      id: planId,
      userId: userId,
      source: 'auto',
      cycleWeek: 1,
      splitTemplateName: splitName,
      days: days,
    );
  }

  @override
  Future<WorkoutPlan?> fetchActivePlan({required String userId}) async {
    final planData = await _client
        .from('workout_plans')
        .select('*, split_templates(name)')
        .eq('user_id', userId)
        .eq('active', true)
        .maybeSingle();

    if (planData == null) return null;

    final planId = planData['id'] as String;
    final splitName =
        (planData['split_templates'] as Map<String, dynamic>?)?['name']
            as String? ??
            '';

    final exercisesData = await _client
        .from('workout_plan_exercises')
        .select('*, exercises(name, primary_muscle, video_url)')
        .eq('plan_id', planId)
        .order('day_index')
        .order('order_index');

    // Agrupa por dia
    final Map<int, List<PlannedExercise>> byDay = {};
    for (final row in exercisesData as List) {
      final dayIdx = row['day_index'] as int;
      final ex = row['exercises'] as Map<String, dynamic>;
      byDay.putIfAbsent(dayIdx, () => []).add(PlannedExercise(
            exerciseId: row['exercise_id'] as String,
            name: ex['name'] as String,
            primaryMuscle: ex['primary_muscle'] as String,
            sets: row['sets'] as int,
            repsMin: row['reps_min'] as int,
            repsMax: row['reps_max'] as int,
            rir: row['rir'] as int,
            restSeconds: row['rest_seconds'] as int,
            videoUrl: ex['video_url'] as String?,
          ));
    }

    // Busca labels do split template
    final splitData = await _client
        .from('split_templates')
        .select('structure')
        .eq('id', planData['split_template_id'] as String)
        .single();

    final structure =
        (splitData['structure'] as List).cast<Map<String, dynamic>>();

    final days = byDay.entries.map((e) {
      final label = e.key < structure.length
          ? structure[e.key]['label'] as String
          : 'Dia ${e.key + 1}';
      return WorkoutDay(dayIndex: e.key, label: label, exercises: e.value);
    }).toList()
      ..sort((a, b) => a.dayIndex.compareTo(b.dayIndex));

    return WorkoutPlan(
      id: planId,
      userId: userId,
      source: planData['source'] as String,
      cycleWeek: planData['cycle_week'] as int,
      splitTemplateName: splitName,
      days: days,
    );
  }

  bool _hasConflict(List<String> exerciseRestrictions, List<String> userRestrictions) {
    return exerciseRestrictions.any((r) => userRestrictions.contains(r));
  }

  int _midpoint(int min, int max) => min + ((max - min) / 2).round();
}
