import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/session_model.dart';

class SessionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  CollectionReference get _sessionsRef =>
      _db.collection('users').doc(_uid).collection('sessions');

  // Obtener todas las sesiones
  Stream<List<Session>> getSessions() {
    return _sessionsRef
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Session.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Guardar sesión completada
  Future<void> saveSession(Session session) async {
    await _sessionsRef.doc(session.id).set(session.toMap());
  }

  // Eliminar sesión
  Future<void> deleteSession(String id) async {
    await _sessionsRef.doc(id).delete();
  }

  // Sesiones de la última semana
  Future<List<Session>> getLastWeekSessions() async {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final snap = await _sessionsRef
        .where('date', isGreaterThan: weekAgo.toIso8601String())
        .get();
    return snap.docs
        .map((doc) => Session.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }
}