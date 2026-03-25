import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart'; // Importamos tu motor

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  TaskPriority _selectedPriority = TaskPriority.media;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // Función para abrir el selector de fecha nativo
  void _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  // Lógica de Backend: Asignamos un color según la prioridad para la UI de tu colega
  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.alta: return const Color(0xFFE57373); // Rojo
      case TaskPriority.media: return const Color(0xFF81C784); // Verde
      case TaskPriority.baja: return const Color(0xFF64B5F6); // Azul
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nueva Tarea")),
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

              ListTile(
                title: Text("Fecha: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}"),
                trailing: const Icon(Icons.calendar_month),
                onTap: _presentDatePicker,
                tileColor: Colors.grey[200],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(height: 40),

              // BOTÓN CONECTADO A FIREBASE
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Llamada al Repositorio para guardar en Firestore
                    await TaskRepository().saveTask(
                      title: _titleController.text,
                      description: _descController.text,
                      priority: _selectedPriority,
                      color: _getPriorityColor(_selectedPriority),
                      date: _selectedDate,
                    );
                    
                    if (mounted) Navigator.pop(context);
                  }
                },
                child: const Text("Guardar Tarea"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}