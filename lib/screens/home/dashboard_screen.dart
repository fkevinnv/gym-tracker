import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/session_model.dart';
import '../../services/auth_service.dart';
import '../../services/session_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  int _calcularRacha(List<Session> sessions) {
    if (sessions.isEmpty) return 0;
    int racha = 0;
    DateTime dia = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final entreno = sessions.any((s) =>
          s.date.year == dia.year &&
          s.date.month == dia.month &&
          s.date.day == dia.day);
      if (entreno) {
        racha++;
        dia = dia.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return racha;
  }

  int _sesionesEstaSemana(List<Session> sessions) {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return sessions.where((s) => s.date.isAfter(weekAgo)).length;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final authService = AuthService();
    final sessionService = SessionService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gym Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async => await authService.logout(),
          ),
        ],
      ),
      body: StreamBuilder<List<Session>>(
        stream: sessionService.getSessions(),
        builder: (context, snapshot) {
          final sessions = snapshot.data ?? [];
          final racha = _calcularRacha(sessions);
          final estaSemana = _sesionesEstaSemana(sessions);
          final totalMinutos =
              sessions.fold(0, (a, b) => a + b.durationMinutes);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Saludo
                Text(
                  '¡Hola! 💪',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // Tarjetas de estadísticas
                Row(
                  children: [
                    _StatCard(
                      icon: Icons.local_fire_department,
                      label: 'Racha',
                      value: '$racha días',
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      icon: Icons.calendar_today,
                      label: 'Esta semana',
                      value: '$estaSemana sesiones',
                      color: const Color(0xFF6C63FF),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _StatCard(
                      icon: Icons.timer,
                      label: 'Tiempo total',
                      value: '$totalMinutos min',
                      color: Colors.teal,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      icon: Icons.fitness_center,
                      label: 'Total sesiones',
                      value: '${sessions.length}',
                      color: Colors.pink,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Última sesión
                if (sessions.isNotEmpty) ...[
                  Text(
                    'Último entrenamiento',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _LastSessionCard(session: sessions.first),
                  const SizedBox(height: 32),
                ],

                // Acceso rápido
                Text(
                  'Acceso rápido',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _QuickAction(
                  icon: Icons.fitness_center,
                  label: 'Ir a mis rutinas',
                  subtitle: 'Gestiona tus entrenamientos',
                  color: const Color(0xFF6C63FF),
                  onTap: () {},
                ),
                const SizedBox(height: 10),
                _QuickAction(
                  icon: Icons.bar_chart,
                  label: 'Ver progreso',
                  subtitle: 'Historial de sesiones',
                  color: Colors.teal,
                  onTap: () {},
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
                    fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _LastSessionCard extends StatelessWidget {
  final Session session;
  const _LastSessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.routineName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                  '${session.date.day}/${session.date.month}/${session.date.year}  •  ${session.durationMinutes} min  •  ${session.exercises.length} ejercicios',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: Theme.of(context).colorScheme.surfaceVariant,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
    );
  }
}