import 'package:flutter/material.dart';

import '../services/notification_service.dart';

import 'home_screen.dart';
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
    _PlaceholderScreen(title: 'Calendar', icon: Icons.calendar_month),
    _PlaceholderScreen(title: 'Stats', icon: Icons.bar_chart),
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

class _SettingsPlaceholder extends StatelessWidget {
  const _SettingsPlaceholder();

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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_outlined, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text('Settings', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => _requestAndTest(context),
              icon: const Icon(Icons.notifications_active),
              label: const Text('Test scheduled notification'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          const Text('Ready for the next step'),
        ],
      ),
    );
  }
}
