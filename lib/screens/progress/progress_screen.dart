import 'package:flutter/material.dart';
import '../../models/session_model.dart';
import '../../services/session_service.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionService = SessionService();

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Progreso')),
      body: StreamBuilder<List<Session>>(
        stream: sessionService.getSessions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final sessions = snapshot.data ?? [];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resumen
                Row(
                  children: [
                    _StatCard(
                      icon: Icons.calendar_today,
                      label: 'Total sesiones',
                      value: '${sessions.length}',
                      color: const Color(0xFF6C63FF),
                    ),
                    const SizedBox(width: 16),
                    _StatCard(
                      icon: Icons.timer,
                      label: 'Tiempo total',
                      value: '${sessions.fold(0, (a, b) => a + b.durationMinutes)} min',
                      color: Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Text('Historial',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // Lista de sesiones
                Expanded(
                  child: sessions.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.bar_chart, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('Aún no has entrenado',
                                  style: TextStyle(color: Colors.grey)),
                              SizedBox(height: 8),
                              Text('¡Empieza tu primera sesión!',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: sessions.length,
                          itemBuilder: (context, index) {
                            final session = sessions[index];
                            return _SessionCard(
                              session: session,
                              sessionService: sessionService,
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final Session session;
  final SessionService sessionService;

  const _SessionCard({required this.session, required this.sessionService});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.check_circle, color: Colors.green),
        ),
        title: Text(session.routineName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          '${session.date.day}/${session.date.month}/${session.date.year}  •  ${session.durationMinutes} min  •  ${session.exercises.length} ejercicios',
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => sessionService.deleteSession(session.id),
        ),
      ),
    );
  }
}