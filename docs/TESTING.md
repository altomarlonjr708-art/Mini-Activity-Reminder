# ActMind Phone Testing

## Notification basics
1. Reconnect the phone and run `flutter run`.
2. Open Settings and tap **Test scheduled notification**.
3. Allow notification permission.
4. Put ActMind in the background and wait 10 seconds.
5. Confirm the notification appears and tapping it opens ActMind.

## Tasks
1. Add a past-deadline task and confirm the warning.
2. Complete and undo a task.
3. Edit and delete tasks.
4. Close and reopen the app to confirm SQLite persistence.

## Calendar and stats
1. Add tasks on different dates and confirm calendar markers.
2. Select a marked date and confirm the task list changes.
3. Confirm Done on time, Done late, and overdue counts.

## Escalation
1. Create deadlines across 3 days, 36 hours, 12 hours, 30 minutes, and past.
2. Confirm High priority escalates earlier.
3. Confirm quiet-hour nudges move outside 23:00-07:00.

## Reboot and battery optimization
1. Reboot the phone and reopen ActMind.
2. Disable battery optimization for ActMind when guided in settings.
