import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import '../models/task_model.dart';
import '../repositories/task_repository.dart';
import '../ui/widgets/task_item.dart';
import '../utils/app_logger.dart'; 
import 'add_task_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';
import '../ui/screens/calendar_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = ""; 
  String filterType = "Todas"; 

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bg = isDark ? const Color(0xFF121212) : const Color(0xFFF9F9F7);
    
    final taskRepo = TaskRepository();
    final user = FirebaseAuth.instance.currentUser;
    final String name = user?.displayName ?? "Usuario";

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: bg,
            elevation: 0,
            actions: [
              // --- BOTÓN DE CALENDARIO AÑADIDO ---
              IconButton(
                icon: const Icon(Icons.calendar_month_outlined, size: 22),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarScreen())),
              ),
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
                  fontSize: 26,
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
                  Text(
                    "Hola, $name. Tienes tareas para hoy.",
                    style: TextStyle(fontSize: 15, color: isDark ? Colors.white54 : Colors.black45),
                  ),
                  const SizedBox(height: 20),

                  // --- BUSCADOR ---
                  TextField(
                    onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: "Buscar tareas...",
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // --- FILTROS RÁPIDOS ---
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ["Todas", "Pendientes", "Completadas"].map((filter) {
                        bool isSelected = filterType == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(filter),
                            selected: isSelected,
                            onSelected: (val) => setState(() => filterType = filter),
                            selectedColor: isDark ? Colors.white : Colors.black,
                            labelStyle: TextStyle(color: isSelected ? (isDark ? Colors.black : Colors.white) : (isDark ? Colors.white : Colors.black)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 30),

                  Text(
                    "MIS TAREAS",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2, color: isDark ? Colors.white30 : Colors.black26),
                  ),
                  const SizedBox(height: 15),
                  
                  StreamBuilder<List<Task>>(
                    stream: taskRepo.getTasks(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return const Center(child: Text("Error al cargar datos"));
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                      final allTasks = snapshot.data ?? [];
                      
                      final filteredTasks = allTasks.where((task) {
                        final matchesSearch = task.title.toLowerCase().contains(searchQuery);
                        bool matchesStatus = true;
                        if (filterType == "Pendientes") matchesStatus = !task.isCompleted;
                        if (filterType == "Completadas") matchesStatus = task.isCompleted;

                        return matchesSearch && matchesStatus;
                      }).toList();

                      if (filteredTasks.isEmpty) {
                        return Center(child: Text("\nNo se encontraron tareas", style: TextStyle(color: isDark ? Colors.white30 : Colors.black26)));
                      }

                      return Column(
                        children: filteredTasks.map((task) => TaskItem(
                          task: task,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddTaskScreen(taskToEdit: task))),
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
        label: Text("Añadir", style: TextStyle(color: isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
        icon: Icon(Icons.add, color: isDark ? Colors.black : Colors.white),
      ),
    );
  }
}