import 'package:intl/intl.dart';

enum MedicineStatus { taken, upcoming, overdue }

class Medicine {
  final String id;
  final String name;
  final String dosage;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime expirationDate;
  final String scheduleTime; // e.g. "08:00 AM" or "20:00"
  final String instructions;
  final bool isTaken;
  final DateTime? takenAt;

  Medicine({
    required this.id,
    required this.name,
    required this.dosage,
    required this.startDate,
    required this.endDate,
    required this.expirationDate,
    required this.scheduleTime,
    this.instructions = '',
    this.isTaken = false,
    this.takenAt,
  });

  (int, int) getScheduledHourMinute() {
    int hour = 9;
    int minute = 0;
    final trimmed = scheduleTime.trim();
    try {
      final parsedDate = DateFormat.jm().parse(trimmed);
      return (parsedDate.hour, parsedDate.minute);
    } catch (_) {
      final isPm = trimmed.toUpperCase().contains('PM');
      final isAm = trimmed.toUpperCase().contains('AM');
      final clean = trimmed.replaceAll(RegExp(r'[^\d:]'), '').trim();
      final parts = clean.split(':');
      if (parts.length >= 2) {
        hour = int.parse(parts[0]);
        minute = int.parse(parts[1]);
        if (isPm && hour < 12) hour += 12;
        if (isAm && hour == 12) hour = 0;
      }
    }
    return (hour, minute);
  }

  DateTime getNextScheduledDoseTime([DateTime? now]) {
    final currentTime = now ?? DateTime.now();
    final (hour, minute) = getScheduledHourMinute();

    final scheduledToday = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      hour,
      minute,
    );

    bool takenForToday = false;
    if (takenAt != null) {
      if (takenAt!.isAfter(scheduledToday.subtract(const Duration(hours: 12)))) {
        takenForToday = true;
      }
    } else if (isTaken && !currentTime.isBefore(scheduledToday)) {
      takenForToday = true;
    }

    if (takenForToday) {
      return scheduledToday.add(const Duration(days: 1));
    } else {
      if (currentTime.isBefore(scheduledToday)) {
        return scheduledToday;
      } else {
        return scheduledToday.add(const Duration(days: 1));
      }
    }
  }

  MedicineStatus getStatus([DateTime? now]) {
    final currentTime = now ?? DateTime.now();
    final (hour, minute) = getScheduledHourMinute();

    final scheduledToday = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      hour,
      minute,
    );

    final nextDoseTime = getNextScheduledDoseTime(currentTime);

    // Rule: If next scheduled dose is within 90 minutes in the future, status is upcoming.
    final diff = nextDoseTime.difference(currentTime);
    if (diff <= const Duration(minutes: 90) && nextDoseTime.isAfter(currentTime)) {
      return MedicineStatus.upcoming;
    }

    // Check if taken for current dose cycle
    bool takenForCurrentCycle = false;
    if (takenAt != null) {
      if (takenAt!.isAfter(scheduledToday.subtract(const Duration(hours: 12)))) {
        takenForCurrentCycle = true;
      }
    } else if (isTaken && !currentTime.isBefore(scheduledToday)) {
      takenForCurrentCycle = true;
    }

    if (takenForCurrentCycle) {
      return MedicineStatus.taken;
    }

    // Overdue check
    if (currentTime.isAfter(scheduledToday) && !startDate.isAfter(scheduledToday)) {
      return MedicineStatus.overdue;
    }

    return MedicineStatus.upcoming;
  }

  Medicine copyWith({
    String? id,
    String? name,
    String? dosage,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? expirationDate,
    String? scheduleTime,
    String? instructions,
    bool? isTaken,
    DateTime? takenAt,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      expirationDate: expirationDate ?? this.expirationDate,
      scheduleTime: scheduleTime ?? this.scheduleTime,
      instructions: instructions ?? this.instructions,
      isTaken: isTaken ?? this.isTaken,
      takenAt: takenAt ?? this.takenAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'expirationDate': expirationDate.toIso8601String(),
      'scheduleTime': scheduleTime,
      'instructions': instructions,
      'isTaken': isTaken,
      'takenAt': takenAt?.toIso8601String(),
    };
  }

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'] as String,
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      expirationDate: DateTime.parse(json['expirationDate'] as String),
      scheduleTime: json['scheduleTime'] as String,
      instructions: json['instructions'] as String? ?? '',
      isTaken: json['isTaken'] as bool? ?? false,
      takenAt: json['takenAt'] != null ? DateTime.parse(json['takenAt'] as String) : null,
    );
  }
}
