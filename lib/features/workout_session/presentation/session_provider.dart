import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/session_repository_impl.dart';
import '../domain/session_repository.dart';
import '../domain/workout_session.dart';
import '../../workout_engine/domain/workout_plan.dart';

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepositoryImpl(Supabase.instance.client);
});

// Estado da sessão em andamento
class SessionState {
  const SessionState({
    required this.day,
    required this.planId,
    this.sessionId,
    this.currentExerciseIndex = 0,
    this.currentSetIndex = 0,
    this.loggedSets = const [],
    this.startedAt,
    this.isFinished = false,
    this.isSaving = false,
    this.error,
  });

  final WorkoutDay day;
  final String planId;
  final String? sessionId;
  final int currentExerciseIndex;
  final int currentSetIndex;
  final List<SessionSet> loggedSets;
  final DateTime? startedAt;
  final bool isFinished;
  final bool isSaving;
  final String? error;

  PlannedExercise get currentExercise =>
      day.exercises[currentExerciseIndex];

  int get totalExercises => day.exercises.length;
  bool get isLastExercise =>
      currentExerciseIndex == totalExercises - 1;
  bool get isLastSet =>
      currentSetIndex == currentExercise.sets - 1;

  int get elapsedSeconds =>
      startedAt == null
          ? 0
          : DateTime.now().difference(startedAt!).inSeconds;

  SessionState copyWith({
    String? sessionId,
    int? currentExerciseIndex,
    int? currentSetIndex,
    List<SessionSet>? loggedSets,
    DateTime? startedAt,
    bool? isFinished,
    bool? isSaving,
    String? error,
  }) =>
      SessionState(
        day: day,
        planId: planId,
        sessionId: sessionId ?? this.sessionId,
        currentExerciseIndex:
            currentExerciseIndex ?? this.currentExerciseIndex,
        currentSetIndex: currentSetIndex ?? this.currentSetIndex,
        loggedSets: loggedSets ?? this.loggedSets,
        startedAt: startedAt ?? this.startedAt,
        isFinished: isFinished ?? this.isFinished,
        isSaving: isSaving ?? this.isSaving,
        error: error,
      );
}

class SessionNotifier extends FamilyNotifier<SessionState, ({WorkoutDay day, String planId})> {
  @override
  SessionState build(({WorkoutDay day, String planId}) arg) {
    return SessionState(day: arg.day, planId: arg.planId);
  }

  Future<void> start() async {
    if (state.sessionId != null) return;

    final userId = Supabase.instance.client.auth.currentUser!.id;
    try {
      final sessionId = await ref.read(sessionRepositoryProvider).createSession(
            userId: userId,
            planId: state.planId,
            dayIndex: state.day.dayIndex,
          );
      state = state.copyWith(
        sessionId: sessionId,
        startedAt: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(error: 'Erro ao iniciar sessão: $e');
    }
  }

  Future<void> logSet({
    required int? repsDone,
    required double? weightKg,
    required int? rirReported,
  }) async {
    final sessionId = state.sessionId;
    if (sessionId == null) return;

    final exercise = state.currentExercise;
    final set = SessionSet(
      exerciseId: exercise.exerciseId,
      exerciseName: exercise.name,
      setNumber: state.currentSetIndex + 1,
      repsDone: repsDone,
      weightKg: weightKg,
      rirReported: rirReported,
    );

    // Persiste imediatamente (online-first; drift como próximo passo)
    try {
      await ref
          .read(sessionRepositoryProvider)
          .saveSet(sessionId: sessionId, set: set);
    } catch (_) {
      // Segue mesmo se falhar (pode sincronizar depois)
    }

    final newSets = [...state.loggedSets, set];

    // Avança para próxima série ou exercício
    if (state.isLastSet) {
      if (state.isLastExercise) {
        // Treino concluído — finaliza
        await _finish(newSets);
      } else {
        state = state.copyWith(
          loggedSets: newSets,
          currentExerciseIndex: state.currentExerciseIndex + 1,
          currentSetIndex: 0,
        );
      }
    } else {
      state = state.copyWith(
        loggedSets: newSets,
        currentSetIndex: state.currentSetIndex + 1,
      );
    }
  }

  Future<void> _finish(List<SessionSet> finalSets) async {
    state = state.copyWith(isSaving: true, loggedSets: finalSets);
    try {
      await ref.read(sessionRepositoryProvider).finishSession(
            sessionId: state.sessionId!,
            durationSeconds: state.elapsedSeconds,
          );
      state = state.copyWith(isFinished: true, isSaving: false);
    } catch (e) {
      state = state.copyWith(
          isSaving: false, isFinished: true, error: 'Erro ao finalizar: $e');
    }
  }

  void skipSet() {
    if (state.isLastSet) {
      if (state.isLastExercise) {
        _finish([...state.loggedSets]);
      } else {
        state = state.copyWith(
          currentExerciseIndex: state.currentExerciseIndex + 1,
          currentSetIndex: 0,
        );
      }
    } else {
      state = state.copyWith(currentSetIndex: state.currentSetIndex + 1);
    }
  }
}

final sessionProvider = NotifierProviderFamily<SessionNotifier, SessionState,
    ({WorkoutDay day, String planId})>(SessionNotifier.new);
