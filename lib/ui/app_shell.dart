import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/notification_service.dart';
import 'theme_controller.dart';

import 'calendar_screen.dart';
import 'home_screen.dart';
import 'stats_screen.dart';
import 'task_form_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static const _destinations = <NavigationDestination>[
    NavigationDestination(icon: Icon(Icons.task_outlined), selectedIcon: Icon(Icons.task), label: 'Tasks'),
    NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Calendar'),
    NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Stats'),
    NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
  ];

  static const _screens = <Widget>[
    HomeScreen(),
    CalendarScreen(),
    StatsScreen(),
    _SettingsPlaceholder(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ActMind')),
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        destinations: _destinations,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TaskFormScreen()),
              ),
              tooltip: 'Add task',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _SettingsPlaceholder extends StatefulWidget {
  const _SettingsPlaceholder();

  @override
  State<_SettingsPlaceholder> createState() => _SettingsPlaceholderState();
}

class _SettingsPlaceholderState extends State<_SettingsPlaceholder> {

  Future<void> _requestAndTest(BuildContext context) async {
    final granted = await NotificationService.requestNotificationPermission();
    if (!context.mounted) return;

    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification permission is required for reminders')),
      );
      return;
    }

    await NotificationService.scheduleTestNotification();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Test reminder scheduled for 10 seconds')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(value: ThemeMode.system, label: Text('System')),
            ButtonSegment(value: ThemeMode.light, label: Text('Light')),
            ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
          ],
          selected: {themeController.themeMode},
          onSelectionChanged: (modes) => themeController.setThemeMode(modes.first),
        ),
        const SizedBox(height: 24),
        Text('Notifications', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: () => _requestAndTest(context),
          icon: const Icon(Icons.notifications_active),
          label: const Text('Test scheduled notification'),
        ),
        const SizedBox(height: 12),
        const ListTile(
          leading: Icon(Icons.battery_alert_outlined),
          title: Text('Battery optimization'),
          subtitle: Text('Allow unrestricted/background activity for reliable nudges.'),
        ),
      ],
    );
  }
}

