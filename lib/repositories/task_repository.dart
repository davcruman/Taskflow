import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // Necesario para el tipo Color
import '../models/task_model.dart';

class TaskRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Obtenemos el ID del usuario actual de Firebase Auth
  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  // 1. LEER TAREAS (Stream en tiempo real)
  Stream<List<Task>> getTasks() {
    return _db
        .collection('tasks')
        .where('userId', isEqualTo: _userId)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Task.fromSnapshot(doc))
            .toList());
  }

  // 2. GUARDAR TAREA (Create)
  Future<void> saveTask({
    required String title,
    required String description,
    required TaskPriority priority,
    required Color color,
    required DateTime date,
  }) async {
    if (_userId.isEmpty) return;

    final newTask = Task(
      id: '', // Firestore generará el ID automáticamente
      title: title,
      description: description,
      date: date,
      priority: priority,
      color: color,
      userId: _userId,
    );

    await _db.collection('tasks').add(newTask.toMap());
  }

  // 3. MARCAR COMPLETADA (Update)
  Future<void> toggleTaskStatus(String taskId, bool currentStatus) async {
    await _db.collection('tasks').doc(taskId).update({
      'isCompleted': !currentStatus,
    });
  }

  // 4. BORRAR TAREA (Delete)
  Future<void> deleteTask(String taskId) async {
    await _db.collection('tasks').doc(taskId).delete();
  }
}