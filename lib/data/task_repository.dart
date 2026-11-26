import 'package:drift/drift.dart';

import '../domain/task.dart' as domain;
import 'app_database.dart';

class TaskRepository {
  TaskRepository(this.database);

  final AppDatabase database;

  Stream<List<domain.ActTask>> watchTasks() {
    return database.select(database.tasks).watch().map(
          (rows) => rows.map(_toDomain).toList(),
        );
  }

  Future<int> createTask({
    required String title,
    required String notes,
    required domain.TaskType type,
    required domain.TaskPriority priority,
    required DateTime dueAt,
  }) {
    return database.into(database.tasks).insert(
          TasksCompanion.insert(
            title: title,
            notes: Value(notes),
            type: _toDatabaseType(type),
            priority: _toDatabasePriority(priority),
            dueAt: dueAt,
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<bool> updateTask(domain.ActTask task) {
    return database.update(database.tasks).replace(
          TasksCompanion(
            id: Value(task.id),
            title: Value(task.title),
            notes: Value(task.notes),
            type: Value(_toDatabaseType(task.type)),
            priority: Value(_toDatabasePriority(task.priority)),
            dueAt: Value(task.dueAt),
            completed: Value(task.completed),
            completedAt: Value(task.completedAt),
            createdAt: Value(task.createdAt),
          ),
        );
  }

  Future<int> deleteTask(int id) {
    return (database.delete(database.tasks)..where((row) => row.id.equals(id))).go();
  }

  Future<void> setCompleted(domain.ActTask task, bool completed) async {
    await updateTask(task.copyWith(
      completed: completed,
      completedAt: completed ? DateTime.now() : null,
    ));
  }

  domain.ActTask _toDomain(Task row) {
    return domain.ActTask(
      id: row.id,
      title: row.title,
      notes: row.notes,
      type: _fromDatabaseType(row.type),
      priority: _fromDatabasePriority(row.priority),
      dueAt: row.dueAt,
      completed: row.completed,
      createdAt: row.createdAt,
      completedAt: row.completedAt,
    );
  }

  TaskType _toDatabaseType(domain.TaskType type) => TaskType.values[type.index];
  domain.TaskType _fromDatabaseType(TaskType type) => domain.TaskType.values[type.index];

  TaskPriority _toDatabasePriority(domain.TaskPriority priority) =>
      TaskPriority.values[priority.index];
  domain.TaskPriority _fromDatabasePriority(TaskPriority priority) =>
      domain.TaskPriority.values[priority.index];
}
