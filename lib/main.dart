import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/app_database.dart';
import 'data/task_provider.dart';
import 'data/task_repository.dart';
import 'ui/app_shell.dart';
import 'ui/app_theme.dart';
import 'ui/theme_controller.dart';

void main() {
  final database = AppDatabase();
  final taskRepository = TaskRepository(database);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => TaskProvider(taskRepository)),
      ],
      child: const ActMindApp(),
    ),
  );
}

class ActMindApp extends StatelessWidget {
  const ActMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, _) {
        return MaterialApp(
          title: 'ActMind',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeController.themeMode,
          home: const AppShell(),
        );
      },
    );
  }
}

