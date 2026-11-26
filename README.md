# ActMind

ActMind is an offline Android task reminder for unfinished school projects and activities. It uses Drift SQLite for local storage and Provider for state management.

## Features

- Add, edit, delete, complete, and undo tasks
- School project, activity, and other task types
- Low, medium, and high priorities
- Overdue, Today, Upcoming, and Done task groups
- Search and type/priority filters
- Calendar markers and daily task lists
- Material 3 light, dark, and system themes
- SQLite persistence with optional subtask schema
- Timezone-aware notifications and escalation channels
- Stats for on-time, late, and overdue work

## Setup

```powershell
flutter doctor
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Android testing

1. Enable Developer Options and USB debugging.
2. Connect the Android phone.
3. Run `flutter devices`.
4. Run `flutter run`.
5. Allow notification permission when prompted.

See `docs/TESTING.md` for the manual phone checklist and `docs/ARCHITECTURE.md` for project structure.

## Build release APK

```powershell
flutter build apk --release
```

The APK is generated under `build/app/outputs/flutter-apk/app-release.apk`.
