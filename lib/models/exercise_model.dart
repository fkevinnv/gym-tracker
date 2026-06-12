class Exercise {
  final String id;
  final String name;
  final int sets;
  final int reps;
  final double weight;
  final int restSeconds;

  Exercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    this.weight = 0,
    this.restSeconds = 60,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'sets': sets,
    'reps': reps,
    'weight': weight,
    'restSeconds': restSeconds,
  };

  factory Exercise.fromMap(Map<String, dynamic> map) => Exercise(
    id: map['id'],
    name: map['name'],
    sets: map['sets'],
    reps: map['reps'],
    weight: (map['weight'] ?? 0).toDouble(),
    restSeconds: map['restSeconds'] ?? 60,
  );
}