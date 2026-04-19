import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../utils/app_logger.dart';

class TaskRepository {
  // Usamos _db de forma consistente en todo el archivo
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
  // Actualizado para aceptar recordatorios
  Future<void> saveTask({
    required String title,
    required String description,
    required TaskPriority priority,
    required Color color,
    required DateTime date,
    int? reminderMinutes, // <--- AÑADIDO
  }) async {
    try {
      if (_userId.isEmpty) throw Exception("Usuario no autenticado");

      // Creamos la tarea con el ID temporal vacío, Firestore nos dará uno
      final newTask = Task(
        id: '', 
        title: title,
        description: description,
        date: date,
        priority: priority,
        color: color,
        userId: _userId,
        reminderMinutes: reminderMinutes, // <--- AÑADIDO
      );

      await _db.collection('tasks').add(newTask.toMap());
      AppLogger.i("Tarea guardada correctamente");
    } catch (e) {
      AppLogger.e("Error al guardar tarea", e);
      rethrow;
    }
  }

  // 3. ACTUALIZAR TAREA COMPLETA (Update)
  Future<void> updateTask(Task task) async {
    try {
      // Al usar task.toMap(), ya se incluye el reminderMinutes automáticamente
      await _db.collection('tasks').doc(task.id).update(task.toMap());
      AppLogger.i("Tarea ${task.id} actualizada con éxito");
    } catch (e) {
      AppLogger.e("Error crítico al actualizar tarea", e);
      rethrow;
    }
  }

  // 4. CAMBIAR SOLO ESTADO (Toggle)
  Future<void> toggleTaskStatus(String taskId, bool currentStatus) async {
    try {
      await _db.collection('tasks').doc(taskId).update({
        'isCompleted': !currentStatus,
      });
      AppLogger.i("Estado de tarea $taskId cambiado");
    } catch (e) {
      AppLogger.e("Error al cambiar estado de la tarea", e);
    }
  }

  // 5. BORRAR TAREA (Delete)
  Future<void> deleteTask(String taskId) async {
    try {
      await _db.collection('tasks').doc(taskId).delete();
      AppLogger.i("Tarea $taskId eliminada");
    } catch (e) {
      AppLogger.e("Error al eliminar tarea", e);
      rethrow;
    }
  }
}