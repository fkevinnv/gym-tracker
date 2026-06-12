import 'package:flutter/material.dart';
import '../../models/routine_model.dart';
import '../../services/routine_service.dart';
import 'routine_detail_screen.dart';

class RoutinesScreen extends StatelessWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final routineService = RoutineService();

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Rutinas')),
      body: StreamBuilder<List<Routine>>(
        stream: routineService.getRoutines(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fitness_center, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No tienes rutinas todavía',
                      style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('Pulsa + para crear una',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final routines = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: routines.length,
            itemBuilder: (context, index) {
              final routine = routines[index];
              return _RoutineCard(
                routine: routine,
                routineService: routineService,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context, routineService),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateDialog(BuildContext context, RoutineService service) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva rutina'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await service.createRoutine(
                  nameController.text.trim(),
                  descController.text.trim(),
                );
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  final Routine routine;
  final RoutineService routineService;

  const _RoutineCard({
    required this.routine,
    required this.routineService,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.fitness_center, color: Color(0xFF6C63FF)),
        ),
        title: Text(routine.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          routine.description.isEmpty
              ? '${routine.exercises.length} ejercicios'
              : routine.description,
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: PopupMenuButton(
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('✏️ Editar')),
            const PopupMenuItem(value: 'delete', child: Text('🗑️ Eliminar')),
          ],
          onSelected: (value) async {
            if (value == 'delete') {
              await routineService.deleteRoutine(routine.id);
            } else if (value == 'edit') {
              _showEditDialog(context);
            }
          },
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RoutineDetailScreen(routine: routine),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final nameController = TextEditingController(text: routine.name);
    final descController = TextEditingController(text: routine.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar rutina'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await routineService.updateRoutine(
                Routine(
                  id: routine.id,
                  name: nameController.text.trim(),
                  description: descController.text.trim(),
                  exercises: routine.exercises,
                  createdAt: routine.createdAt,
                ),
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}