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
  final String userId; // Añadimos esto para que cada usuario vea lo suyo

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.priority,
    required this.color,
    this.isCompleted = false,
    required this.userId,
  });

  // 1. De "Task" a "Mapa" (Para guardar en Firestore)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': date, // Firestore acepta DateTime directamente
      'priority': priority.name, // Guardamos "alta", "media" o "baja" como texto
      'color': color.value,      // Guardamos el color como un número (int)
      'isCompleted': isCompleted,
      'userId': userId,
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
      // Convertimos el texto de nuevo a Enum
      priority: TaskPriority.values.byName(data['priority'] ?? 'media'),
      // Convertimos el número de nuevo a Color
      color: Color(data['color'] ?? 0xFF42A5F5),
      isCompleted: data['isCompleted'] ?? false,
      userId: data['userId'] ?? '',
    );
  }
}