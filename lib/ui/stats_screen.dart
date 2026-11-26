import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/task_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>().tasks;
    final now = DateTime.now();
    final doneOnTime = tasks.where((task) => task.completed && task.completedAt != null && !task.completedAt!.isAfter(task.dueAt)).length;
    final doneLate = tasks.where((task) => task.completed && task.completedAt != null && task.completedAt!.isAfter(task.dueAt)).length;
    final overdue = tasks.where((task) => !task.completed && task.dueAt.isBefore(now)).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Progress', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        _StatCard(label: 'Done on time', value: doneOnTime, color: Colors.green),
        _StatCard(label: 'Done late', value: doneLate, color: Colors.orange),
        _StatCard(label: 'Currently overdue', value: overdue, color: Theme.of(context).colorScheme.error),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.color});

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color, child: Text('$value', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        title: Text(label),
      ),
    );
  }
}
