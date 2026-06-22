class SessionSummary {
  const SessionSummary({
    required this.sessionId,
    required this.dayLabel,
    required this.performedAt,
    required this.durationSeconds,
    required this.totalSets,
  });

  final String sessionId;
  final String dayLabel;
  final DateTime performedAt;
  final int durationSeconds;
  final int totalSets;

  String get durationFormatted {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    return m > 0 ? '${m}min ${s}s' : '${s}s';
  }
}

class ExerciseVolume {
  const ExerciseVolume({
    required this.exerciseName,
    required this.date,
    required this.maxWeightKg,
    required this.totalReps,
  });

  final String exerciseName;
  final DateTime date;
  final double maxWeightKg;
  final int totalReps;
}

class ProgressSummary {
  const ProgressSummary({
    required this.totalSessions,
    required this.totalMinutes,
    required this.currentStreak,
    required this.recentSessions,
    required this.volumeByExercise,
  });

  final int totalSessions;
  final int totalMinutes;
  final int currentStreak;
  final List<SessionSummary> recentSessions;
  final Map<String, List<ExerciseVolume>> volumeByExercise;
}
