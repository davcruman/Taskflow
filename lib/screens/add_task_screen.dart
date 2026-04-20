import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';
import '../services/notification_service.dart';

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
  late TimeOfDay _selectedTime;
  late TaskPriority _selectedPriority;
  late bool isEditing;
  int? _selectedReminder;

  List<Map<String, dynamic>> get _reminderOptions => [
    {'label': 'sin_recordatorio'.tr(), 'value': null},
    {'label': 'min_5_antes'.tr(), 'value': 5},
    {'label': 'min_30_antes'.tr(), 'value': 30},
    {'label': 'h_1_antes'.tr(), 'value': 60},
    {'label': 'dia_1_antes'.tr(), 'value': 1440},
  ];

  @override
  void initState() {
    super.initState();
    isEditing = widget.taskToEdit != null;
    _titleController = TextEditingController(text: widget.taskToEdit?.title ?? '');
    _descController = TextEditingController(text: widget.taskToEdit?.description ?? '');
    _selectedDate = widget.taskToEdit?.date ?? DateTime.now();
    _selectedTime = widget.taskToEdit != null ? TimeOfDay.fromDateTime(widget.taskToEdit!.date) : TimeOfDay.now();
    _selectedPriority = widget.taskToEdit?.priority ?? TaskPriority.media;
    _selectedReminder = widget.taskToEdit?.reminderMinutes;
  }

  String _getPriorityTranslation(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.alta: return "prio_alta".tr();
      case TaskPriority.media: return "prio_media".tr();
      case TaskPriority.baja: return "prio_baja".tr();
    }
  }

  void _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) setState(() => _selectedDate = pickedDate);
  }

  void _presentTimePicker() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null) setState(() => _selectedTime = pickedTime);
  }

  DateTime _getCombinedDateTime() {
    return DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedTime.hour, _selectedTime.minute);
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
      appBar: AppBar(title: Text(isEditing ? "editar_tarea".tr() : "nueva_tarea".tr())),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: "titulo_task".tr(), border: const OutlineInputBorder()),
                validator: (value) => (value == null || value.isEmpty) ? "error_titulo".tr() : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: InputDecoration(labelText: "descripcion_task".tr(), border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              Text("prioridad".tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<TaskPriority>(
                value: _selectedPriority,
                isExpanded: true,
                items: TaskPriority.values.map((p) => DropdownMenuItem(
                  value: p, 
                  child: Text(_getPriorityTranslation(p))
                )).toList(),
                onChanged: (val) => setState(() => _selectedPriority = val!),
              ),
              const SizedBox(height: 20),
              Text("recordatorio".tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<int?>(
                initialValue: _selectedReminder,
                isExpanded: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark ? Colors.white.withValues(alpha : 0.05) : Colors.grey[200],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
                items: _reminderOptions.map((opt) => DropdownMenuItem<int?>(value: opt['value'], child: Text(opt['label']))).toList(),
                onChanged: (val) => setState(() => _selectedReminder = val),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text("fecha".tr(), style: const TextStyle(fontSize: 12)),
                      subtitle: Text("${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}"),
                      tileColor: isDark ? Colors.white.withValues(alpha : 0.05) : Colors.grey[200],
                      onTap: _presentDatePicker,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ListTile(
                      title: Text("hora".tr(), style: const TextStyle(fontSize: 12)),
                      subtitle: Text(_selectedTime.format(context)),
                      tileColor: isDark ? Colors.white.withValues(alpha : 0.05) : Colors.grey[200],
                      onTap: _presentTimePicker,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: isDark ? Colors.white : Colors.black),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final DateTime fullTaskDate = _getCombinedDateTime();

                    // 1. Lógica de Firebase
                    if (isEditing) {
                      final updatedTask = widget.taskToEdit!.copyWith(
                        title: _titleController.text,
                        description: _descController.text,
                        priority: _selectedPriority,
                        color: _getPriorityColor(_selectedPriority),
                        date: fullTaskDate,
                        reminderMinutes: _selectedReminder,
                      );
                      await TaskRepository().updateTask(updatedTask);
                    } else {
                      await TaskRepository().saveTask(
                        title: _titleController.text,
                        description: _descController.text,
                        priority: _selectedPriority,
                        color: _getPriorityColor(_selectedPriority),
                        date: fullTaskDate,
                        reminderMinutes: _selectedReminder,
                      );
                    }

                    // 2. Lógica de Notificación Programada
                    if (_selectedReminder != null) {
                      final DateTime reminderTime = fullTaskDate.subtract(Duration(minutes: _selectedReminder!));
                      
                      if (reminderTime.isAfter(DateTime.now())) {
                        // ID único para la notificación
                        final int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

                        await NotificationService.scheduleNotification(
                          id: notificationId,
                          title: '⏰ Recordatorio: ${_titleController.text}',
                          body: 'Faltan $_selectedReminder minutos para tu tarea.',
                          scheduledDate: reminderTime,
                        );
                      }
                    }

                    if (mounted) Navigator.pop(context);
                  }
                },
                child: Text(
                  isEditing ? "guardar_cambios".tr() : "crear_tarea".tr(),
                  style: TextStyle(color: isDark ? Colors.black : Colors.white)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}