class WorkoutPlan {
  const WorkoutPlan({
    required this.id,
    required this.userId,
    required this.source,
    required this.cycleWeek,
    required this.splitTemplateName,
    required this.days,
  });

  final String id;
  final String userId;
  final String source; // 'auto' | 'personal'
  final int cycleWeek;
  final String splitTemplateName;
  final List<WorkoutDay> days;
}

class WorkoutDay {
  const WorkoutDay({
    required this.dayIndex,
    required this.label,
    required this.exercises,
  });

  final int dayIndex;
  final String label;
  final List<PlannedExercise> exercises;
}

class PlannedExercise {
  const PlannedExercise({
    required this.exerciseId,
    required this.name,
    required this.primaryMuscle,
    required this.sets,
    required this.repsMin,
    required this.repsMax,
    required this.rir,
    required this.restSeconds,
    this.videoUrl,
  });

  final String exerciseId;
  final String name;
  final String primaryMuscle;
  final int sets;
  final int repsMin;
  final int repsMax;
  final int rir;
  final int restSeconds;
  final String? videoUrl;
}
