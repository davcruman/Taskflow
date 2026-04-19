import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? taskToEdit; 

  const AddTaskScreen({super.key, this.taskToEdit});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime; // <--- NUEVO: Para la hora
  late TaskPriority _selectedPriority;
  late bool isEditing;

  int? _selectedReminder; 
  final List<Map<String, dynamic>> _reminderOptions = [
    {'label': 'Sin recordatorio', 'value': null},
    {'label': '5 minutos antes', 'value': 5},
    {'label': '30 minutos antes', 'value': 30},
    {'label': '1 hora antes', 'value': 60},
    {'label': '1 día antes', 'value': 1440},
  ];

  @override
  void initState() {
    super.initState();
    isEditing = widget.taskToEdit != null;

    _titleController = TextEditingController(text: widget.taskToEdit?.title ?? '');
    _descController = TextEditingController(text: widget.taskToEdit?.description ?? '');
    
    // Si editamos, extraemos fecha y hora de la tarea. Si no, usamos el "ahora".
    _selectedDate = widget.taskToEdit?.date ?? DateTime.now();
    _selectedTime = widget.taskToEdit != null 
        ? TimeOfDay.fromDateTime(widget.taskToEdit!.date) 
        : TimeOfDay.now();
    
    _selectedPriority = widget.taskToEdit?.priority ?? TaskPriority.media;
    _selectedReminder = widget.taskToEdit?.reminderMinutes;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE SELECCIÓN ---

  void _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  void _presentTimePicker() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null) {
      setState(() => _selectedTime = pickedTime);
    }
  }

  // FUNCIÓN CLAVE: Fusiona el día elegido con la hora elegida
  DateTime _getCombinedDateTime() {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.alta: return const Color(0xFFE57373);
      case TaskPriority.media: return const Color(0xFF81C784);
      case TaskPriority.baja: return const Color(0xFF64B5F6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? "Editar Tarea" : "Nueva Tarea")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Título de la tarea", border: OutlineInputBorder()),
                validator: (value) => (value == null || value.isEmpty) ? "Por favor, escribe un título" : null,
              ),
              const SizedBox(height: 20),
              
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: "Descripción (opcional)", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),

              const Text("Prioridad:", style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<TaskPriority>(
                value: _selectedPriority,
                isExpanded: true,
                items: TaskPriority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority.toString().split('.').last.toUpperCase()),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedPriority = val!),
              ),
              const SizedBox(height: 20),

              const Text("Recordatorio:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              DropdownButtonFormField<int?>(
                value: _selectedReminder,
                isExpanded: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
                items: _reminderOptions.map((opt) {
                  return DropdownMenuItem<int?>(
                    value: opt['value'],
                    child: Text(opt['label']),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedReminder = val),
              ),
              const SizedBox(height: 20),

              // --- SELECTORES DE FECHA Y HORA ---
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text("Fecha", style: TextStyle(fontSize: 12)),
                      subtitle: Text("${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}"),
                      trailing: const Icon(Icons.calendar_month, size: 20),
                      onTap: _presentDatePicker,
                      tileColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ListTile(
                      title: const Text("Hora", style: TextStyle(fontSize: 12)),
                      subtitle: Text(_selectedTime.format(context)),
                      trailing: const Icon(Icons.access_time, size: 20),
                      onTap: _presentTimePicker,
                      tileColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: isDark ? Colors.white : Colors.black,
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Obtenemos el DateTime que incluye la HORA
                    final DateTime fullTaskDate = _getCombinedDateTime();

                    if (isEditing) {
                      final updatedTask = widget.taskToEdit!.copyWith(
                        title: _titleController.text,
                        description: _descController.text,
                        priority: _selectedPriority,
                        color: _getPriorityColor(_selectedPriority),
                        date: fullTaskDate, // <--- HORA INCLUIDA
                        reminderMinutes: _selectedReminder,
                      );
                      await TaskRepository().updateTask(updatedTask);
                    } else {
                      await TaskRepository().saveTask(
                        title: _titleController.text,
                        description: _descController.text,
                        priority: _selectedPriority,
                        color: _getPriorityColor(_selectedPriority),
                        date: fullTaskDate, // <--- HORA INCLUIDA
                        reminderMinutes: _selectedReminder,
                      );
                    }
                    
                    if (mounted) Navigator.pop(context);
                  }
                },
                child: Text(
                  isEditing ? "GUARDAR CAMBIOS" : "CREAR TAREA",
                  style: TextStyle(
                    color: isDark ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}