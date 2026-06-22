import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/session_repository.dart';
import '../domain/workout_session.dart';

class SessionRepositoryImpl implements SessionRepository {
  SessionRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<String> createSession({
    required String userId,
    required String planId,
    required int dayIndex,
  }) async {
    final row = await _client
        .from('workout_sessions')
        .insert({
          'user_id': userId,
          'plan_id': planId,
          'day_index': dayIndex,
          'performed_at': DateTime.now().toIso8601String(),
        })
        .select('id')
        .single();
    return row['id'] as String;
  }

  @override
  Future<void> saveSet({
    required String sessionId,
    required SessionSet set,
  }) async {
    await _client.from('session_sets').insert({
      'session_id': sessionId,
      'exercise_id': set.exerciseId,
      'set_number': set.setNumber,
      'reps_done': set.repsDone,
      'weight_kg': set.weightKg,
      'rir_reported': set.rirReported,
    });
  }

  @override
  Future<void> finishSession({
    required String sessionId,
    required int durationSeconds,
  }) async {
    await _client
        .from('workout_sessions')
        .update({'duration_seconds': durationSeconds})
        .eq('id', sessionId);
  }
}
