enum NudgeTone { gentle, reminder, urgent, veryUrgent, overdue }

enum NudgePriority { low, medium, high }

class QuietHours {
  const QuietHours({required this.startHour, required this.startMinute, required this.endHour, required this.endMinute});

  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  bool contains(DateTime time) {
    final start = startHour * 60 + startMinute;
    final end = endHour * 60 + endMinute;
    final minute = time.hour * 60 + time.minute;
    if (start == end) return false;
    if (start < end) return minute >= start && minute < end;
    return minute >= start || minute < end;
  }

  DateTime moveToEnd(DateTime time) {
    final end = DateTime(time.year, time.month, time.day, endHour, endMinute);
    if (end.isAfter(time)) return end;
    return end.add(const Duration(days: 1));
  }
}

class NudgeSchedule {
  const NudgeSchedule({required this.time, required this.tone});
  final DateTime time;
  final NudgeTone tone;
}

class EscalationScheduler {
  const EscalationScheduler();

  List<NudgeSchedule> schedule({
    required DateTime now,
    required DateTime deadline,
    required NudgePriority priority,
    required QuietHours quietHours,
    Duration leadTime = const Duration(days: 1),
    Duration window = const Duration(hours: 48),
  }) {
    if (!deadline.isAfter(now)) {
      final overdueTimes = <NudgeSchedule>[];
      var cursor = now.add(const Duration(minutes: 30));
      final firstAt = now.isBefore(deadline) ? deadline : now;
      cursor = firstAt.isAfter(cursor) ? cursor : now;
      for (var i = 0; i < 96 && cursor.isBefore(now.add(window)); i++) {
        overdueTimes.add(NudgeSchedule(time: _moveQuiet(cursor, quietHours), tone: NudgeTone.overdue));
        cursor = cursor.add(const Duration(minutes: 30));
      }
      return overdueTimes;
    }

    final result = <NudgeSchedule>[];
    var cursor = deadline.subtract(leadTime);
    if (cursor.isBefore(now)) cursor = now;

    for (var i = 0; i < 300 && cursor.isBefore(now.add(window)) && cursor.isBefore(deadline); i++) {
      final remaining = deadline.difference(cursor);
      final toneAndFrequency = _toneAndFrequency(remaining, priority);
      final moved = _moveQuiet(cursor, quietHours);
      result.add(NudgeSchedule(time: moved, tone: toneAndFrequency.$1));
      cursor = cursor.add(toneAndFrequency.$2);
    }
    return result;
  }

  (NudgeTone, Duration) _toneAndFrequency(Duration remaining, NudgePriority priority) {
    final high = priority == NudgePriority.high;
    if (remaining <= const Duration(hours: 1)) {
      return (NudgeTone.veryUrgent, const Duration(minutes: 15));
    }
    if (remaining <= Duration(hours: high ? 12 : 24)) {
      return (NudgeTone.urgent, const Duration(hours: 2));
    }
    if (remaining <= Duration(hours: high ? 36 : 48)) {
      return (NudgeTone.reminder, const Duration(hours: 6));
    }
    return (NudgeTone.gentle, const Duration(days: 1));
  }

  DateTime _moveQuiet(DateTime time, QuietHours quietHours) {
    return quietHours.contains(time) ? quietHours.moveToEnd(time) : time;
  }
}
