import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../data/task_provider.dart';
import '../domain/task.dart';
import 'task_form_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final selected = _selectedDay ?? _focusedDay;
    final dayTasks = provider.tasks.where((task) => _sameDay(task.dueAt, selected)).toList();

    return ListView(
      children: [
        TableCalendar<ActTask>(
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365 * 5)),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => _sameDay(day, selected),
          eventLoader: (day) => provider.tasks.where((task) => _sameDay(task.dueAt, day)).toList(),
          onDaySelected: (selectedDay, focusedDay) => setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          }),
          calendarStyle: const CalendarStyle(markerDecoration: BoxDecoration(color: Colors.teal, shape: BoxShape.circle)),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Tasks for ${selected.day}/${selected.month}/${selected.year}', style: Theme.of(context).textTheme.titleMedium),
        ),
        if (dayTasks.isEmpty)
          const Padding(padding: EdgeInsets.all(16), child: Text('No tasks on this day'))
        else
          ...dayTasks.map((task) => Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  title: Text(task.title),
                  subtitle: Text(task.priority.name),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TaskFormScreen(task: task))),
                ),
              )),
      ],
    );
  }
}
