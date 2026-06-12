import 'exercise_model.dart';

class Routine {
  final String id;
  final String name;
  final String description;
  final List<Exercise> exercises;
  final DateTime createdAt;

  Routine({
    required this.id,
    required this.name,
    this.description = '',
    this.exercises = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'exercises': exercises.map((e) => e.toMap()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory Routine.fromMap(Map<String, dynamic> map) => Routine(
    id: map['id'],
    name: map['name'],
    description: map['description'] ?? '',
    exercises: (map['exercises'] as List<dynamic>? ?? [])
        .map((e) => Exercise.fromMap(e))
        .toList(),
    createdAt: DateTime.parse(map['createdAt']),
  );
}