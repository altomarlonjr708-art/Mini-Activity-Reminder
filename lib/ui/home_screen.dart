import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/task_provider.dart';
import '../domain/task.dart';
import 'task_form_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  bool _sameDay(DateTime first, DateTime second) {
    return first.year == second.year && first.month == second.month && first.day == second.day;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        final now = DateTime.now();
        final tasks = [...provider.tasks]..sort((a, b) => a.dueAt.compareTo(b.dueAt));
        final overdue = tasks.where((task) => !task.completed && task.dueAt.isBefore(now) && !_sameDay(task.dueAt, now)).toList();
        final today = tasks.where((task) => !task.completed && _sameDay(task.dueAt, now)).toList();
        final upcoming = tasks.where((task) => !task.completed && task.dueAt.isAfter(now) && !_sameDay(task.dueAt, now)).toList();
        final done = tasks.where((task) => task.completed).toList();

        if (tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.assignment_outlined, size: 56, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 12),
                Text('No tasks yet', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                const Text('Tap + to add your first task'),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.only(bottom: 88),
          children: [
            if (overdue.isNotEmpty) _TaskSection(title: 'Overdue', tasks: overdue),
            if (today.isNotEmpty) _TaskSection(title: 'Today', tasks: today),
            if (upcoming.isNotEmpty) _TaskSection(title: 'Upcoming', tasks: upcoming),
            if (done.isNotEmpty) _TaskSection(title: 'Done', tasks: done),
          ],
        );
      },
    );
  }
}

class _TaskSection extends StatelessWidget {
  const _TaskSection({required this.title, required this.tasks});

  final String title;
  final List<ActTask> tasks;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...tasks.map((task) => _TaskCard(task: task)),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task});

  final ActTask task;

  Color _priorityColor(BuildContext context) {
    return switch (task.priority) {
      TaskPriority.high => Theme.of(context).colorScheme.error,
      TaskPriority.medium => Colors.orange,
      TaskPriority.low => Colors.green,
    };
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('Delete "${task.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<TaskProvider>().deleteTask(task.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat('MMM d, y').add_jm().format(task.dueAt);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TaskFormScreen(task: task))),
        leading: Checkbox(
          value: task.completed,
          onChanged: (value) => context.read<TaskProvider>().setCompleted(task, value ?? false),
        ),
        title: Text(task.title, style: TextStyle(decoration: task.completed ? TextDecoration.lineThrough : null)),
        subtitle: Text('$dateText · ${task.priority.name.toUpperCase()}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 32, decoration: BoxDecoration(color: _priorityColor(context), borderRadius: BorderRadius.circular(4))),
            IconButton(icon: const Icon(Icons.delete_outline), tooltip: 'Delete task', onPressed: () => _confirmDelete(context)),
          ],
        ),
      ),
    );
  }
}
