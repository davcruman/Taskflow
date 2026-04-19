import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/task_model.dart';
import '../../repositories/task_repository.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final TaskRepository _repository = TaskRepository();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Task> _allTasks = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<Task> _getTasksForDay(DateTime day) {
    return _allTasks.where((task) => isSameDay(task.date, day)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendario de Tareas')),
      body: StreamBuilder<List<Task>>(
        stream: _repository.getTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          _allTasks = snapshot.data ?? [];

          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                
                // --- CONFIGURACIÓN PARA QUITAR EL "2 WEEKS" ---
                calendarFormat: CalendarFormat.month, 
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false, // Oculta el botón que cambia a "2 weeks"
                  titleCentered: true,
                ),
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Mes', // Bloquea el formato solo a mes
                },
                // ----------------------------------------------

                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                eventLoader: _getTasksForDay,
                calendarStyle: CalendarStyle(
                  markersAlignment: Alignment.bottomCenter,
                  markerDecoration: const BoxDecoration(
                    color: Colors.deepPurple,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.5), 
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Colors.deepPurple,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const Divider(),
              Expanded(
                child: _buildTaskList(_getTasksForDay(_selectedDay!)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return const Center(child: Text('No hay tareas para este día'));
    }

    return ListView.builder(
      itemCount: tasks.length, 
      itemBuilder: (context, index) {
        final task = tasks[index];
        return ListTile(
          leading: CircleAvatar(backgroundColor: task.color),
          title: Text(task.title),
          subtitle: Text(task.description),
          trailing: Icon(
            task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: task.isCompleted ? Colors.green : null,
          ),
          onTap: () => _showTaskDetails(task),
        );
      },
    );
  }

  void _showTaskDetails(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Descripción: ${task.description}"),
            const SizedBox(height: 10),
            Text("Prioridad: ${task.priority.name}"),
            Text("Fecha: ${task.date.toString().split(' ')[0]}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}