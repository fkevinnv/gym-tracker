import 'exercise_model.dart';

class Session {
  final String id;
  final String routineId;
  final String routineName;
  final DateTime date;
  final List<Exercise> exercises;
  final int durationMinutes;

  Session({
    required this.id,
    required this.routineId,
    required this.routineName,
    required this.date,
    required this.exercises,
    this.durationMinutes = 0,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'routineId': routineId,
    'routineName': routineName,
    'date': date.toIso8601String(),
    'exercises': exercises.map((e) => e.toMap()).toList(),
    'durationMinutes': durationMinutes,
  };

  factory Session.fromMap(Map<String, dynamic> map) => Session(
    id: map['id'],
    routineId: map['routineId'],
    routineName: map['routineName'],
    date: DateTime.parse(map['date']),
    exercises: (map['exercises'] as List<dynamic>? ?? [])
        .map((e) => Exercise.fromMap(e))
        .toList(),
    durationMinutes: map['durationMinutes'] ?? 0,
  );
}