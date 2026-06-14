import 'package:flutter/material.dart';
import '../../models/routine_model.dart';
import '../../models/exercise_model.dart';
import '../../services/routine_service.dart';
import 'workout_screen.dart';

class RoutineDetailScreen extends StatelessWidget {
  final Routine routine;
  const RoutineDetailScreen({super.key, required this.routine});

  @override
  Widget build(BuildContext context) {
    final routineService = RoutineService();

    return Scaffold(
      appBar: AppBar(
        title: Text(routine.name),
        actions: [
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WorkoutScreen(routine: routine),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Iniciar'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: routine.exercises.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No hay ejercicios todavía',
                      style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('Pulsa + para añadir uno',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: routine.exercises.length,
              itemBuilder: (context, index) {
                final exercise = routine.exercises[index];
                return _ExerciseCard(
                  exercise: exercise,
                  routine: routine,
                  routineService: routineService,
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExerciseDialog(context, routineService),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddExerciseDialog(
      BuildContext context, RoutineService routineService) {
    final nameController = TextEditingController();
    final setsController = TextEditingController(text: '3');
    final repsController = TextEditingController(text: '10');
    final weightController = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Añadir ejercicio'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del ejercicio',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: setsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Series',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: repsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Reps',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: weightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Kg',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final newExercise = Exercise(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text.trim(),
                  sets: int.tryParse(setsController.text) ?? 3,
                  reps: int.tryParse(repsController.text) ?? 10,
                  weight: double.tryParse(weightController.text) ?? 0,
                );
                final updatedRoutine = Routine(
                  id: routine.id,
                  name: routine.name,
                  description: routine.description,
                  exercises: [...routine.exercises, newExercise],
                  createdAt: routine.createdAt,
                );
                await routineService.updateRoutine(updatedRoutine);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final Routine routine;
  final RoutineService routineService;

  const _ExerciseCard({
    required this.exercise,
    required this.routine,
    required this.routineService,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF6C63FF).withOpacity(0.2),
          child: const Icon(Icons.sports_gymnastics, color: Color(0xFF6C63FF)),
        ),
        title: Text(exercise.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          '${exercise.sets} series × ${exercise.reps} reps  •  ${exercise.weight} kg',
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () async {
            final updatedExercises = routine.exercises
                .where((e) => e.id != exercise.id)
                .toList();
            await routineService.updateRoutine(Routine(
              id: routine.id,
              name: routine.name,
              description: routine.description,
              exercises: updatedExercises,
              createdAt: routine.createdAt,
            ));
          },
        ),
      ),
    );
  }
}