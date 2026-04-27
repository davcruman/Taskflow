import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_logger.dart'; // <--- Importamos tu utilidad

enum TaskPriority { alta, media, baja }

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final TaskPriority priority;
  final Color color;
  bool isCompleted;
  final String userId;
  final int? reminderMinutes;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.priority,
    required this.color,
    this.isCompleted = false,
    required this.userId,
    this.reminderMinutes,
  });

  Task copyWith({
    String? title,
    String? description,
    DateTime? date,
    TaskPriority? priority,
    Color? color,
    bool? isCompleted,
    int? reminderMinutes,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      priority: priority ?? this.priority,
      color: color ?? this.color,
      isCompleted: isCompleted ?? this.isCompleted,
      userId: userId,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
    );
  }

  // --- Map para Firestore ---
  Map<String, dynamic> toMap() {
    // Logueamos cuando una tarea se está preparando para enviarse
    AppLogger.i("Convertiendo Tarea '$title' a Map para Firestore");

    return {
      'title': title,
      'description': description,
      'date': date,
      'priority': priority.name,
      'color': color.toARGB32(),
      'isCompleted': isCompleted,
      'userId': userId,
      'reminderMinutes': reminderMinutes,
    };
  }

  // --- Factory para leer de Firestore ---
  factory Task.fromSnapshot(DocumentSnapshot snap) {
    try {
      var data = snap.data() as Map<String, dynamic>;

      // Log informativo para saber qué ID de documento estamos leyendo
      AppLogger.i("Procesando documento de Firebase ID: ${snap.id}");

      return Task(
        id: snap.id,
        title: data['title'] ?? '',
        description: data['description'] ?? '',
        date: (data['date'] as Timestamp).toDate(),
        priority: TaskPriority.values.byName(data['priority'] ?? 'media'),
        color: Color(data['color'] ?? 0xFF42A5F5),
        isCompleted: data['isCompleted'] ?? false,
        userId: data['userId'] ?? '',
        reminderMinutes: data['reminderMinutes'],
      );
    } catch (e, stackTrace) {
      // Si falla la conversión (ej: un campo viene con tipo equivocado), el Logger nos dirá dónde
      AppLogger.e(
        "Error fatal al convertir Snapshot a Task. ID: ${snap.id}",
        e,
        stackTrace,
      );
      rethrow; // Lanzamos el error para que el servicio también se entere
    }
  }
}
