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
    this.onLongPress
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
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
      onDismissed: (direction) {
        TaskRepository().deleteTask(task.id);
        
        // Feedback inmediato al usuario
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Tarea '${task.title}' eliminada"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: "OK",
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
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
            onTap: onTap, 
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
                  style: TextStyle(
                    fontSize: 10, 
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}