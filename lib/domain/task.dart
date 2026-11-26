const _unsetCompletedAt = Object();

enum TaskType { schoolProject, activity, other }

enum TaskPriority { low, medium, high }

class ActTask {
  ActTask({
    required this.id,
    required this.title,
    required this.notes,
    required this.type,
    required this.priority,
    required this.dueAt,
    required this.completed,
    required this.createdAt,
    this.completedAt,
  });

  final int id;
  final String title;
  final String notes;
  final TaskType type;
  final TaskPriority priority;
  final DateTime dueAt;
  final bool completed;
  final DateTime createdAt;
  final DateTime? completedAt;

  ActTask copyWith({
    String? title,
    String? notes,
    TaskType? type,
    TaskPriority? priority,
    DateTime? dueAt,
    bool? completed,
    Object? completedAt = _unsetCompletedAt,
  }) {
    return ActTask(
      id: id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      dueAt: dueAt ?? this.dueAt,
      completed: completed ?? this.completed,
      createdAt: createdAt,
      completedAt: identical(completedAt, _unsetCompletedAt)
          ? this.completedAt
          : completedAt as DateTime?,
    );
  }
}
