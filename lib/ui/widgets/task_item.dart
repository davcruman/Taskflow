import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../repositories/task_repository.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TaskItem({
    super.key,
    required this.task,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key(task.id),
      // Permitimos ambas direcciones
      direction: DismissDirection.horizontal,
      
      // Fondo al deslizar a la DERECHA (Completar)
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 30),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Icon(Icons.check_circle_outline, color: Colors.white, size: 28),
      ),

      // Fondo al deslizar a la IZQUIERDA (Borrar)
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 30),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),

      // Lógica según la dirección
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Si desliza a la derecha, completamos y NO borramos el widget
          TaskRepository().toggleTaskStatus(task.id, task.isCompleted);
          return false; // Retornamos false para que la tarjeta vuelva a su sitio
        } else {
          // Si desliza a la izquierda, borramos
          return true; 
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          TaskRepository().deleteTask(task.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Tarea '${task.title}' eliminada"), behavior: SnackBarBehavior.floating),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: ListTile(
            onTap: onTap, // Ahora esto llevará a editar (se configura en HomeScreen)
            onLongPress: onLongPress,
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
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(
                  task.isCompleted 
                      ? Icons.check_circle 
                      : (task.priority == TaskPriority.alta ? Icons.circle : Icons.circle_outlined),
                  color: task.color,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  "${task.date.day}/${task.date.month}",
                  style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.black38),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}