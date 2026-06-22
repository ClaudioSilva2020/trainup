import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/progress_repository.dart';
import '../domain/progress_summary.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  ProgressRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<ProgressSummary> fetchSummary({required String userId}) async {
    // 1. Sessões do usuário (simples, sem joins complexos)
    final sessionsData = await _client
        .from('workout_sessions')
        .select('id, day_index, performed_at, duration_seconds, plan_id')
        .eq('user_id', userId)
        .order('performed_at', ascending: false)
        .limit(30);

    if ((sessionsData as List).isEmpty) {
      return const ProgressSummary(
        totalSessions: 0,
        totalMinutes: 0,
        currentStreak: 0,
        recentSessions: [],
        volumeByExercise: {},
      );
    }

    // 2. Busca labels dos splits para as sessions que têm plan_id
    final planIds = sessionsData
        .map((s) => s['plan_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();

    final Map<String, List<Map<String, dynamic>>> splitStructures = {};
    if (planIds.isNotEmpty) {
      final plansData = await _client
          .from('workout_plans')
          .select('id, split_template_id')
          .inFilter('id', planIds);

      final templateIds = (plansData as List)
          .map((p) => p['split_template_id'] as String?)
          .whereType<String>()
          .toSet()
          .toList();

      if (templateIds.isNotEmpty) {
        final templates = await _client
            .from('split_templates')
            .select('id, structure')
            .inFilter('id', templateIds);

        final templateMap = {
          for (final t in templates as List)
            t['id'] as String:
                (t['structure'] as List).cast<Map<String, dynamic>>()
        };

        final planTemplateMap = {
          for (final p in plansData)
            p['id'] as String: p['split_template_id'] as String?
        };

        for (final planId in planIds) {
          final templateId = planTemplateMap[planId];
          if (templateId != null && templateMap.containsKey(templateId)) {
            splitStructures[planId] = templateMap[templateId]!;
          }
        }
      }
    }

    // 3. Monta sessões
    final recentSessions = <SessionSummary>[];
    int totalSeconds = 0;

    for (final s in sessionsData) {
      final dayIndex = s['day_index'] as int;
      final duration = (s['duration_seconds'] as int?) ?? 0;
      totalSeconds += duration;
      final planId = s['plan_id'] as String?;

      String dayLabel = 'Dia ${dayIndex + 1}';
      try {
        final structure = planId != null ? splitStructures[planId] : null;
        if (structure != null && dayIndex < structure.length) {
          dayLabel = structure[dayIndex]['label'] as String? ?? dayLabel;
        }
      } catch (_) {}

      recentSessions.add(SessionSummary(
        sessionId: s['id'] as String,
        dayLabel: dayLabel,
        performedAt: DateTime.parse(s['performed_at'] as String),
        durationSeconds: duration,
        totalSets: 0,
      ));
    }

    // 4. Volume por exercício — queries separadas e simples
    final sessionIds = sessionsData.map((s) => s['id'] as String).toList();

    final setsData = await _client
        .from('session_sets')
        .select('exercise_id, weight_kg, reps_done, session_id')
        .inFilter('session_id', sessionIds)
        .not('weight_kg', 'is', null)
        .gt('weight_kg', 0);

    // Resolve nomes dos exercícios
    final exerciseIds = (setsData as List)
        .map((r) => r['exercise_id'] as String)
        .toSet()
        .toList();

    final Map<String, String> exerciseNames = {};
    if (exerciseIds.isNotEmpty) {
      final exData = await _client
          .from('exercises')
          .select('id, name')
          .inFilter('id', exerciseIds);
      for (final e in exData as List) {
        exerciseNames[e['id'] as String] = e['name'] as String;
      }
    }

    // Mapa session_id → performed_at
    final sessionDates = {
      for (final s in sessionsData)
        s['id'] as String: DateTime.parse(s['performed_at'] as String)
    };

    final Map<String, List<ExerciseVolume>> volumeByExercise = {};
    for (final row in setsData) {
      final exId = row['exercise_id'] as String;
      final name = exerciseNames[exId];
      if (name == null) continue;

      final sessionId = row['session_id'] as String;
      final date = sessionDates[sessionId];
      if (date == null) continue;

      final weight = (row['weight_kg'] as num).toDouble();
      final reps = (row['reps_done'] as int?) ?? 0;

      volumeByExercise.putIfAbsent(name, () => []).add(ExerciseVolume(
            exerciseName: name,
            date: date,
            maxWeightKg: weight,
            totalReps: reps,
          ));
    }

    return ProgressSummary(
      totalSessions: recentSessions.length,
      totalMinutes: totalSeconds ~/ 60,
      currentStreak: _computeStreak(recentSessions),
      recentSessions: recentSessions,
      volumeByExercise: volumeByExercise,
    );
  }

  int _computeStreak(List<SessionSummary> sessions) {
    if (sessions.isEmpty) return 0;
    final dates = sessions
        .map((s) =>
            DateTime(s.performedAt.year, s.performedAt.month, s.performedAt.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime expected =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    for (final d in dates) {
      if (d == expected || d == expected.subtract(const Duration(days: 1))) {
        streak++;
        expected = d.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }
}
