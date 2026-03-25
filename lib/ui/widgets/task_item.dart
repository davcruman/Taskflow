import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../repositories/task_repository.dart'; // Importamos tu repositorio

class TaskItem extends StatelessWidget {
  final Task task;
  const TaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 1. Envolvemos todo en un Dismissible para poder borrar deslizando
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart, // Solo deslizar de derecha a izquierda
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 30),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      // Misión de Persona B: Borrar de la base de datos real
      onDismissed: (direction) {
        TaskRepository().deleteTask(task.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: ListTile(
            onTap: () {
              // Misión de Persona B: Cambiar estado completado en Firebase
              TaskRepository().toggleTaskStatus(task.id, task.isCompleted);
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            leading: Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: task.color,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            title: Text(
              task.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark ? Colors.white : const Color(0xFF2D2D2D),
                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text(
              task.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
            ),
            trailing: Icon(
              task.isCompleted 
                  ? Icons.check_circle 
                  : (task.priority == TaskPriority.alta ? Icons.circle : Icons.circle_outlined),
              color: task.color,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}