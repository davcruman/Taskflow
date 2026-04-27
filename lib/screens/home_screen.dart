import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';
import '../ui/widgets/task_item.dart';
import 'add_task_screen.dart';
import 'settings_screen.dart';
import 'calendar_screen.dart';

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

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: bg,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_month_outlined, size: 22),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CalendarScreen()),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, size: 22),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
              const SizedBox(width: 10),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 25, bottom: 15),
              title: const Text(
                "TaskFlow",
                style: TextStyle(
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
                  // MENSAJE ELIMINADO AQUÍ
                  const SizedBox(
                    height: 10,
                  ), // Ajuste de margen superior para el buscador
                  TextField(
                    onChanged: (value) =>
                        setState(() => searchQuery = value.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: "buscar_tareas".tr(),
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ["Todas", "Pendientes", "Completadas"].map((
                        filter,
                      ) {
                        bool isSelected = filterType == filter;
                        String label = filter.toLowerCase().tr();
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(label),
                            selected: isSelected,
                            onSelected: (val) =>
                                setState(() => filterType = filter),
                            selectedColor: isDark ? Colors.white : Colors.black,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? (isDark ? Colors.black : Colors.white)
                                  : (isDark ? Colors.white : Colors.black),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "mis_tareas".tr(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: isDark ? Colors.white30 : Colors.black26,
                    ),
                  ),
                  const SizedBox(height: 15),
                  StreamBuilder<List<Task>>(
                    stream: taskRepo.getTasks(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return const Center(child: CircularProgressIndicator());
                      final allTasks = snapshot.data!;
                      final filteredTasks = allTasks.where((task) {
                        final matchesSearch = task.title.toLowerCase().contains(
                          searchQuery,
                        );
                        bool matchesStatus = true;
                        if (filterType == "Pendientes")
                          matchesStatus = !task.isCompleted;
                        if (filterType == "Completadas")
                          matchesStatus = task.isCompleted;
                        return matchesSearch && matchesStatus;
                      }).toList();

                      if (filteredTasks.isEmpty)
                        return Center(
                          child: Text(
                            "sin_tareas".tr(),
                            style: TextStyle(
                              color: isDark ? Colors.white30 : Colors.black26,
                            ),
                          ),
                        );

                      return Column(
                        children: filteredTasks
                            .map(
                              (t) => TaskItem(
                                task: t,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          AddTaskScreen(taskToEdit: t),
                                    ),
                                  );
                                },
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddTaskScreen()),
        ),
        label: Text(
          "anadir".tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
