import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../utils/app_logger.dart';

class TaskRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _userId {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      AppLogger.w("Intento de acceso a userId sin usuario autenticado");
    }
    return uid ?? '';
  }

  // 1. LEER TAREAS (Stream en tiempo real)
  Stream<List<Task>> getTasks() {
    AppLogger.i("Iniciando Stream de tareas para el usuario: $_userId");

    return _db
        .collection('tasks')
        .where('userId', isEqualTo: _userId)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) {
          AppLogger.i(
            "Firestore: Recibidos ${snapshot.docs.length} documentos",
          );
          return snapshot.docs.map((doc) => Task.fromSnapshot(doc)).toList();
        });
  }

  // 2. GUARDAR TAREA (Create)
  Future<void> saveTask({
    required String title,
    required String description,
    required TaskPriority priority,
    required Color color,
    required DateTime date,
    int? reminderMinutes,
  }) async {
    try {
      if (_userId.isEmpty) {
        throw Exception("Operación cancelada: Usuario no identificado");
      }

      AppLogger.i("Intentando guardar nueva tarea: '$title'");

      final newTask = Task(
        id: '',
        title: title,
        description: description,
        date: date,
        priority: priority,
        color: color,
        userId: _userId,
        reminderMinutes: reminderMinutes,
      );

      final docRef = await _db.collection('tasks').add(newTask.toMap());
      AppLogger.i("✅ Tarea guardada con éxito. ID generado: ${docRef.id}");
    } catch (e, stackTrace) {
      AppLogger.e("❌ Error al guardar tarea '$title'", e, stackTrace);
      rethrow;
    }
  }

  // 3. ACTUALIZAR TAREA COMPLETA (Update)
  Future<void> updateTask(Task task) async {
    try {
      AppLogger.i("Actualizando tarea completa: ${task.id} (${task.title})");

      await _db.collection('tasks').doc(task.id).update(task.toMap());
      AppLogger.i("✅ Tarea ${task.id} sincronizada con Firestore");
    } catch (e, stackTrace) {
      AppLogger.e(
        "❌ Error crítico al actualizar tarea ${task.id}",
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  // 4. CAMBIAR SOLO ESTADO (Toggle)
  Future<void> toggleTaskStatus(String taskId, bool currentStatus) async {
    try {
      final newStatus = !currentStatus;
      AppLogger.i(
        "Cambiando estado de tarea $taskId a: ${newStatus ? 'Completada' : 'Pendiente'}",
      );

      await _db.collection('tasks').doc(taskId).update({
        'isCompleted': newStatus,
      });
      AppLogger.i("✅ Cambio de estado reflejado en el servidor");
    } catch (e, stackTrace) {
      AppLogger.e("❌ Error al hacer toggle en tarea $taskId", e, stackTrace);
    }
  }

  // 5. BORRAR TAREA (Delete)
  Future<void> deleteTask(String taskId) async {
    try {
      AppLogger.w(
        "Eliminando tarea ID: $taskId...",
      ); // Usamos Warning porque es una acción destructiva

      await _db.collection('tasks').doc(taskId).delete();
      AppLogger.i("✅ Tarea $taskId eliminada permanentemente");
    } catch (e, stackTrace) {
      AppLogger.e("❌ Fallo al eliminar tarea $taskId", e, stackTrace);
      rethrow;
    }
  }
}
