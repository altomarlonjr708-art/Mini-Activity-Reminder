import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/task.dart';
import 'task_repository.dart';

class TaskProvider extends ChangeNotifier {
  TaskProvider(this.repository) {
    _subscription = repository.watchTasks().listen((tasks) {
      _tasks = tasks;
      notifyListeners();
    });
  }

  final TaskRepository repository;
  late final StreamSubscription<List<ActTask>> _subscription;
  List<ActTask> _tasks = const [];

  List<ActTask> get tasks => List.unmodifiable(_tasks);

  Future<void> createTask({
    required String title,
    required String notes,
    required TaskType type,
    required TaskPriority priority,
    required DateTime dueAt,
  }) {
    return repository.createTask(
      title: title,
      notes: notes,
      type: type,
      priority: priority,
      dueAt: dueAt,
    );
  }

  Future<void> updateTask(ActTask task) => repository.updateTask(task);
  Future<void> deleteTask(int id) => repository.deleteTask(id);
  Future<void> setCompleted(ActTask task, bool completed) =>
      repository.setCompleted(task, completed);

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
