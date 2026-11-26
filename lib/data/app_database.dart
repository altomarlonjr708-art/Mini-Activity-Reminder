import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get notes => text().withDefault(const Constant(''))();
  IntColumn get type => intEnum<TaskType>()();
  IntColumn get priority => intEnum<TaskPriority>()();
  DateTimeColumn get dueAt => dateTime()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

class Subtasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get taskId => integer().references(Tasks, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
}

enum TaskType { schoolProject, activity, other }

enum TaskPriority { low, medium, high }

@DriftDatabase(tables: [Tasks, Subtasks])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'actmind'));

  @override
  int get schemaVersion => 1;
}
