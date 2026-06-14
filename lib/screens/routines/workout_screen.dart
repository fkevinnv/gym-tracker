import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/routine_model.dart';
import '../../models/session_model.dart';
import '../../services/session_service.dart';

class WorkoutScreen extends StatefulWidget {
  final Routine routine;
  const WorkoutScreen({super.key, required this.routine});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final SessionService _sessionService = SessionService();
  final List<bool> _completedSets = [];
  int _currentExerciseIndex = 0;
  int _restSeconds = 0;
  Timer? _restTimer;
  final DateTime _startTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initSets();
  }

  void _initSets() {
    _completedSets.clear();
    if (widget.routine.exercises.isNotEmpty) {
      final exercise = widget.routine.exercises[_currentExerciseIndex];
      for (int i = 0; i < exercise.sets; i++) {
        _completedSets.add(false);
      }
    }
  }

  void _startRestTimer(int seconds) {
    _restTimer?.cancel();
    setState(() => _restSeconds = seconds);
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSeconds <= 0) {
        timer.cancel();
      } else {
        setState(() => _restSeconds--);
      }
    });
  }

  void _nextExercise() {
    if (_currentExerciseIndex < widget.routine.exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _initSets();
        _restSeconds = 0;
        _restTimer?.cancel();
      });
    }
  }

  void _previousExercise() {
    if (_currentExerciseIndex > 0) {
      setState(() {
        _currentExerciseIndex--;
        _initSets();
        _restSeconds = 0;
        _restTimer?.cancel();
      });
    }
  }

  Future<void> _finishWorkout() async {
    final duration = DateTime.now().difference(_startTime).inMinutes;
    final session = Session(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      routineId: widget.routine.id,
      routineName: widget.routine.name,
      date: DateTime.now(),
      exercises: widget.routine.exercises,
      durationMinutes: duration,
    );
    await _sessionService.saveSession(session);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Entrenamiento completado! $duration min 💪'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercises = widget.routine.exercises;
    if (exercises.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Entrenamiento')),
        body: const Center(child: Text('Esta rutina no tiene ejercicios')),
      );
    }

    final exercise = exercises[_currentExerciseIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.routine.name),
        actions: [
          TextButton.icon(
            onPressed: () => _showFinishDialog(),
            icon: const Icon(Icons.check, color: Colors.green),
            label: const Text('Terminar', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Progreso de ejercicios
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                exercises.length,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _currentExerciseIndex
                        ? const Color(0xFF6C63FF)
                        : i < _currentExerciseIndex
                            ? Colors.green
                            : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ejercicio ${_currentExerciseIndex + 1} de ${exercises.length}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // Nombre del ejercicio
            Text(
              exercise.name,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${exercise.sets} series × ${exercise.reps} reps  •  ${exercise.weight} kg',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 32),

            // Series
            ...List.generate(exercise.sets, (i) {
              return CheckboxListTile(
                title: Text('Serie ${i + 1}'),
                subtitle: Text('${exercise.reps} reps  •  ${exercise.weight} kg'),
                value: _completedSets[i],
                activeColor: const Color(0xFF6C63FF),
                onChanged: (val) {
                  setState(() => _completedSets[i] = val ?? false);
                  if (val == true) {
                    _startRestTimer(exercise.restSeconds);
                  }
                },
              );
            }),

            const SizedBox(height: 24),

            // Temporizador de descanso
            if (_restSeconds > 0)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.timer, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      'Descanso: $_restSeconds s',
                      style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

            const Spacer(),

            // Navegación entre ejercicios
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _currentExerciseIndex > 0
                        ? _previousExercise
                        : null,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Anterior'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _currentExerciseIndex < exercises.length - 1
                        ? _nextExercise
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Siguiente'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFinishDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Terminar entrenamiento?'),
        content: const Text('Se guardará la sesión en tu historial.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _finishWorkout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Terminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}