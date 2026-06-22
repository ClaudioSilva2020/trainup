import 'workout_session.dart';

abstract interface class SessionRepository {
  Future<String> createSession({
    required String userId,
    required String planId,
    required int dayIndex,
  });

  Future<void> saveSet({
    required String sessionId,
    required SessionSet set,
  });

  Future<void> finishSession({
    required String sessionId,
    required int durationSeconds,
  });
}
