import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Añadido para el nombre real
import '../models/task_model.dart';
import '../repositories/task_repository.dart';
import '../ui/widgets/task_item.dart';
import '../utils/app_logger.dart'; // Añadido para debuguear el error de carga
import 'add_task_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bg = isDark ? const Color(0xFF121212) : const Color(0xFFF9F9F7);
    
    // Obtenemos el repositorio y el usuario actual
    final taskRepo = TaskRepository();
    final user = FirebaseAuth.instance.currentUser;
    final String name = user?.displayName ?? "Usuario";

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            backgroundColor: bg,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined, size: 22),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
              ),
              IconButton(
                icon: const Icon(Icons.person_outline, size: 22),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
              ),
              const SizedBox(width: 10),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 25, bottom: 15),
              title: Text(
                "TaskFlow",
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1C1C1C),
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                  letterSpacing: -1,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // SALUDO PERSONALIZADO (Cambio 1)
                  Text(
                    "Hola, $name. Tienes tareas para hoy.",
                    style: TextStyle(
                      fontSize: 16, 
                      color: isDark ? Colors.white54 : Colors.black45,
                      letterSpacing: 0.2
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    "MIS TAREAS REALES",
                    style: TextStyle(
                      fontSize: 11, 
                      fontWeight: FontWeight.bold, 
                      letterSpacing: 2, 
                      color: isDark ? Colors.white30 : Colors.black26
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  StreamBuilder<List<Task>>(
                    stream: taskRepo.getTasks(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        // LOGGING PARA DIAGNÓSTICO (Cambio 2)
                        AppLogger.e("Error cargando tareas en Home", snapshot.error);
                        return const Center(child: Text("Error al cargar datos"));
                      }
                      
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final tasks = snapshot.data ?? [];

                      if (tasks.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Text("No hay tareas pendientes ✨", 
                              style: TextStyle(color: isDark ? Colors.white30 : Colors.black26)),
                          ),
                        );
                      }

                      return Column(
                        // CONEXIÓN DE ACCIONES (Cambio 3)
                        children: tasks.map((task) => TaskItem(
                          task: task,
                          onTap: () => taskRepo.toggleTaskStatus(task.id, task.isCompleted),
                          onLongPress: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddTaskScreen(taskToEdit: task),
                              ),
                            );
                          },
                        )).toList(),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTaskScreen())),
        backgroundColor: isDark ? Colors.white : const Color(0xFF1C1C1C),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        label: Text(
          "Añadir", 
          style: TextStyle(color: isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold)
        ),
        icon: Icon(Icons.add, color: isDark ? Colors.black : Colors.white),
      ),
    );
  }
}