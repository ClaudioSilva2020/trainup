class UserTrainingProfile {
  const UserTrainingProfile({
    required this.userId,
    required this.objective,
    required this.level,
    required this.daysPerWeek,
    required this.equipment,
    required this.restrictions,
  });

  final String userId;
  final String objective;   // hipertrofia | perda_gordura | condicionamento
  final String level;       // iniciante | intermediario | avancado
  final int daysPerWeek;    // 2–6
  final String equipment;   // academia | halteres | peso_corporal
  final List<String> restrictions; // joelho, lombar, ombro, etc.

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'objective': objective,
        'level': level,
        'days_per_week': daysPerWeek,
        'equipment': equipment,
        'restrictions': restrictions,
        'updated_at': DateTime.now().toIso8601String(),
      };
}
