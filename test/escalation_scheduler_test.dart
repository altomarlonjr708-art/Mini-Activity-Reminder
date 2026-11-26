import 'package:actmind/services/escalation_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const scheduler = EscalationScheduler();
  const quiet = QuietHours(startHour: 23, startMinute: 0, endHour: 7, endMinute: 0);

  test('exactly 2 days uses gentle schedule', () {
    final now = DateTime(2026, 1, 1, 8);
    final result = scheduler.schedule(now: now, deadline: now.add(const Duration(days: 2)), priority: NudgePriority.low, quietHours: quiet);
    expect(result.first.tone, NudgeTone.gentle);
  });

  test('exactly 1 hour uses very urgent tone', () {
    final now = DateTime(2026, 1, 1, 8);
    final result = scheduler.schedule(now: now, deadline: now.add(const Duration(hours: 1)), priority: NudgePriority.low, quietHours: quiet);
    expect(result.every((item) => item.tone == NudgeTone.veryUrgent), isTrue);
  });

  test('past deadline uses overdue frequency', () {
    final now = DateTime(2026, 1, 1, 8);
    final result = scheduler.schedule(now: now, deadline: now.subtract(const Duration(hours: 1)), priority: NudgePriority.low, quietHours: quiet);
    expect(result, isNotEmpty);
    expect(result.every((item) => item.tone == NudgeTone.overdue), isTrue);
  });

  test('high priority escalates earlier', () {
    final now = DateTime(2026, 1, 1, 8);
    final deadline = now.add(const Duration(hours: 12));
    final high = scheduler.schedule(now: now, deadline: deadline, priority: NudgePriority.high, quietHours: quiet);
    expect(high.first.tone, NudgeTone.urgent);
  });

  test('quiet hours move nudges outside the window', () {
    final now = DateTime(2026, 1, 1, 22);
    final deadline = now.add(const Duration(hours: 10));
    final result = scheduler.schedule(now: now, deadline: deadline, priority: NudgePriority.low, quietHours: quiet);
    expect(result.every((item) => !quiet.contains(item.time)), isTrue);
  });
}
