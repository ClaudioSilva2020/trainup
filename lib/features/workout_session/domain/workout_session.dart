class WorkoutSession {
  const WorkoutSession({
    required this.id,
    required this.userId,
    required this.planId,
    required this.dayIndex,
    required this.performedAt,
    this.durationSeconds,
    this.sets = const [],
  });

  final String id;
  final String userId;
  final String planId;
  final int dayIndex;
  final DateTime performedAt;
  final int? durationSeconds;
  final List<SessionSet> sets;
}

class SessionSet {
  const SessionSet({
    required this.exerciseId,
    required this.exerciseName,
    required this.setNumber,
    this.repsDone,
    this.weightKg,
    this.rirReported,
  });

  final String exerciseId;
  final String exerciseName;
  final int setNumber;
  final int? repsDone;
  final double? weightKg;
  final int? rirReported;

  SessionSet copyWith({
    int? repsDone,
    double? weightKg,
    int? rirReported,
  }) =>
      SessionSet(
        exerciseId: exerciseId,
        exerciseName: exerciseName,
        setNumber: setNumber,
        repsDone: repsDone ?? this.repsDone,
        weightKg: weightKg ?? this.weightKg,
        rirReported: rirReported ?? this.rirReported,
      );
}
