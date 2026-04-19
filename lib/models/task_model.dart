import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final int? reminderMinutes; // <--- NUEVO: Minutos antes para el aviso (puede ser nulo)

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.priority,
    required this.color,
    this.isCompleted = false,
    required this.userId,
    this.reminderMinutes, // <--- NUEVO
  });

  // --- Método copyWith actualizado para incluir recordatorios ---
  Task copyWith({
    String? title,
    String? description,
    DateTime? date,
    TaskPriority? priority,
    Color? color,
    bool? isCompleted,
    int? reminderMinutes, // <--- NUEVO
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
      reminderMinutes: reminderMinutes ?? this.reminderMinutes, // <--- NUEVO
    );
  }

  // 1. De "Task" a "Mapa" (Para guardar en Firestore)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': date,
      'priority': priority.name,
      'color': color.value,
      'isCompleted': isCompleted,
      'userId': userId,
      'reminderMinutes': reminderMinutes, // <--- NUEVO
    };
  }

  // 2. De "Snapshot de Firebase" a "Task" (Para leer de Firestore)
  factory Task.fromSnapshot(DocumentSnapshot snap) {
    var data = snap.data() as Map<String, dynamic>;
    
    return Task(
      id: snap.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      priority: TaskPriority.values.byName(data['priority'] ?? 'media'),
      color: Color(data['color'] ?? 0xFF42A5F5),
      isCompleted: data['isCompleted'] ?? false,
      userId: data['userId'] ?? '',
      reminderMinutes: data['reminderMinutes'], // <--- NUEVO
    );
  }
}