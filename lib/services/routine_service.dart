import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/routine_model.dart';

class RoutineService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  CollectionReference get _routinesRef =>
      _db.collection('users').doc(_uid).collection('routines');

  // Obtener todas las rutinas en tiempo real
  Stream<List<Routine>> getRoutines() {
    return _routinesRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Routine.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Crear rutina
  Future<void> createRoutine(String name, String description) async {
    final id = _routinesRef.doc().id;
    final routine = Routine(
      id: id,
      name: name,
      description: description,
      exercises: [],
      createdAt: DateTime.now(),
    );
    await _routinesRef.doc(id).set(routine.toMap());
  }

  // Actualizar rutina
  Future<void> updateRoutine(Routine routine) async {
    await _routinesRef.doc(routine.id).update(routine.toMap());
  }

  // Eliminar rutina
  Future<void> deleteRoutine(String id) async {
    await _routinesRef.doc(id).delete();
  }
}