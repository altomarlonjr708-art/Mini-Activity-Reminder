import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/task_provider.dart';
import '../domain/task.dart';

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key, this.task});

  final ActTask? task;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  late DateTime _dueAt;
  late TaskType _type;
  late TaskPriority _priority;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title);
    _notesController = TextEditingController(text: task?.notes);
    _dueAt = task?.dueAt ?? DateTime.now().add(const Duration(days: 1));
    _type = task?.type ?? TaskType.schoolProject;
    _priority = task?.priority ?? TaskPriority.medium;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueAt,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _dueAt = DateTime(picked.year, picked.month, picked.day, _dueAt.hour, _dueAt.minute));
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_dueAt));
    if (picked != null) {
      setState(() => _dueAt = DateTime(_dueAt.year, _dueAt.month, _dueAt.day, picked.hour, picked.minute));
    }
  }

  Future<bool> _confirmPastDeadline() async {
    if (!_dueAt.isBefore(DateTime.now())) return true;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deadline is in the past'),
        content: const Text('This task is overdue immediately. Do you want to save it anyway?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save anyway')),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!await _confirmPastDeadline()) return;
    if (!mounted) return;

    final provider = context.read<TaskProvider>();
    if (widget.task == null) {
      await provider.createTask(
        title: _titleController.text.trim(),
        notes: _notesController.text.trim(),
        type: _type,
        priority: _priority,
        dueAt: _dueAt,
      );
    } else {
      await provider.updateTask(widget.task!.copyWith(
        title: _titleController.text.trim(),
        notes: _notesController.text.trim(),
        type: _type,
        priority: _priority,
        dueAt: _dueAt,
      ));
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.task == null ? 'Add task' : 'Edit task')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) => (value == null || value.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder()),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TaskType>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: TaskType.schoolProject, child: Text('School project')),
                DropdownMenuItem(value: TaskType.activity, child: Text('Activity')),
                DropdownMenuItem(value: TaskType.other, child: Text('Other')),
              ],
              onChanged: (value) => setState(() => _type = value ?? TaskType.other),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TaskPriority>(
              initialValue: _priority,
              decoration: const InputDecoration(labelText: 'Priority', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: TaskPriority.low, child: Text('Low')),
                DropdownMenuItem(value: TaskPriority.medium, child: Text('Medium')),
                DropdownMenuItem(value: TaskPriority.high, child: Text('High')),
              ],
              onChanged: (value) => setState(() => _priority = value ?? TaskPriority.medium),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Due date'),
              subtitle: Text('${_dueAt.day}/${_dueAt.month}/${_dueAt.year}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickDate,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule),
              title: const Text('Due time'),
              subtitle: Text(TimeOfDay.fromDateTime(_dueAt).format(context)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickTime,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(onPressed: _save, icon: const Icon(Icons.check), label: Text(widget.task == null ? 'Save task' : 'Update task')),
          ],
        ),
      ),
    );
  }
}
