import 'package:flutter/material.dart';

enum TaskPriority { alta, media, baja }

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final TaskPriority priority;
  final Color color;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.priority,
    required this.color,
    this.isCompleted = false,
  });
}