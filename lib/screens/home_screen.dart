import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../ui/widgets/task_item.dart';
import 'add_task_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Color "hueso" para el modo claro, mucho más premium que el blanco puro
    final Color bg = isDark ? const Color(0xFF121212) : const Color(0xFFF9F9F7);

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [ // <--- CORREGIDO: Tenía una 'i' menos
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            backgroundColor: bg,
            elevation: 0,
            // Botones de acción minimalistas
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
                  Text(
                    "Hola. Tienes tareas para hoy.",
                    style: TextStyle(
                      fontSize: 16, 
                      color: isDark ? Colors.white54 : Colors.black45,
                      letterSpacing: 0.2
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    "PRIORITARIAS",
                    style: TextStyle(
                      fontSize: 11, 
                      fontWeight: FontWeight.bold, 
                      letterSpacing: 2, 
                      color: isDark ? Colors.white30 : Colors.black26
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Mapeamos las tareas directamente aquí
                  ..._getMockTasks().map((task) => TaskItem(task: task)).toList(),
                  
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
        elevation: 0, // Sin sombra para un look más "flat" y moderno
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        label: Text(
          "Añadir", 
          style: TextStyle(color: isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold)
        ),
        icon: Icon(Icons.add, color: isDark ? Colors.black : Colors.white),
      ),
    );
  }

  // Datos de prueba dentro del mismo archivo para que no falle nada
  List<Task> _getMockTasks() {
    return [
      Task(
        id: '1', 
        title: "Rúbrica de PMDM", 
        description: "Comprobar puntos de nivel GRAVE.", 
        date: DateTime.now(), 
        priority: TaskPriority.alta, 
        color: const Color(0xFFE57373)
      ),
      Task(
        id: '2', 
        title: "UI de Calendario", 
        description: "Usar el paquete table_calendar.", 
        date: DateTime.now(), 
        priority: TaskPriority.media, 
        color: const Color(0xFF81C784),
        isCompleted: true
      ),
    ];
  }
}