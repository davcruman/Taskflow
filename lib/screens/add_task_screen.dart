import 'package:flutter/material.dart';
import '../models/task_model.dart';

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
              // Título de la tarea
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Título de la tarea", border: OutlineInputBorder()),
                validator: (value) => (value == null || value.isEmpty) ? "Por favor, escribe un título" : null,
              ),
              const SizedBox(height: 20),
              
              // Descripción
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: "Descripción (opcional)", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),

              // Selector de Prioridad
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

              // Selector de Fecha
              ListTile(
                title: Text("Fecha: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}"),
                trailing: const Icon(Icons.calendar_month),
                onTap: _presentDatePicker,
                tileColor: Colors.grey[200],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(height: 40),

              // Botón Guardar
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Aquí es donde en el futuro Persona B guardará en Firebase
                    Navigator.pop(context);
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