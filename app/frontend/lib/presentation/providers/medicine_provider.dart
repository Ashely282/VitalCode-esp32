import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/medicine.dart';

class MedicineProvider extends ChangeNotifier {
  final List<Medicine> _medicines = [];
  Timer? _countdownTimer;
  Duration _timeUntilNextDose = Duration.zero;
  Medicine? _nextUpcomingMedicine;
  DateTime? _targetScheduledTime;

  List<Medicine> get medicines => List.unmodifiable(_medicines);
  Duration get timeUntilNextDose => _timeUntilNextDose;
  Medicine? get nextUpcomingMedicine => _nextUpcomingMedicine;

  MedicineProvider() {
    _loadSampleData();
  }

  void _loadSampleData() {
    final now = DateTime.now();

    _medicines.addAll([
      Medicine(
        id: const Uuid().v4(),
        name: 'Aspirin Cardio',
        dosage: '100 mg (1 Tablet)',
        startDate: now.subtract(const Duration(days: 5)),
        endDate: now.add(const Duration(days: 25)),
        expirationDate: now.add(const Duration(days: 365)),
        scheduleTime: '09:00 AM',
        instructions: 'Take with warm water after breakfast',
        isTaken: true,
        takenAt: now.subtract(const Duration(hours: 3)),
      ),
      Medicine(
        id: const Uuid().v4(),
        name: 'Omega 3 Fish Oil',
        dosage: '1000 mg (1 Softgel)',
        startDate: now.subtract(const Duration(days: 10)),
        endDate: now.add(const Duration(days: 50)),
        expirationDate: now.add(const Duration(days: 500)),
        scheduleTime: '01:30 PM',
        instructions: 'Take during lunch',
        isTaken: false,
      ),
      Medicine(
        id: const Uuid().v4(),
        name: 'Vitamin D3 + K2',
        dosage: '5000 IU (1 Capsule)',
        startDate: now,
        endDate: now.add(const Duration(days: 90)),
        expirationDate: now.add(const Duration(days: 700)),
        scheduleTime: '08:00 PM',
        instructions: 'Take before dinner',
        isTaken: false,
      ),
    ]);

    _updateNextUpcomingMedicine();
  }

  void _updateNextUpcomingMedicine() {
    final now = DateTime.now();
    final pending = _medicines.where((m) => m.getStatus(now) != MedicineStatus.taken).toList();

    if (pending.isNotEmpty) {
      pending.sort((a, b) {
        final timeA = a.getNextScheduledDoseTime(now);
        final timeB = b.getNextScheduledDoseTime(now);
        return timeA.compareTo(timeB);
      });
      _nextUpcomingMedicine = pending.first;
    } else if (_medicines.isNotEmpty) {
      final sorted = List<Medicine>.from(_medicines)
        ..sort((a, b) => a.getNextScheduledDoseTime(now).compareTo(b.getNextScheduledDoseTime(now)));
      _nextUpcomingMedicine = sorted.first;
    } else {
      _nextUpcomingMedicine = null;
    }

    if (_nextUpcomingMedicine != null) {
      _targetScheduledTime = _nextUpcomingMedicine!.getNextScheduledDoseTime(now);
      final remaining = _targetScheduledTime!.difference(now);
      _timeUntilNextDose = remaining.isNegative ? Duration.zero : remaining;
    } else {
      _targetScheduledTime = null;
      _timeUntilNextDose = Duration.zero;
    }

    _startCountdownTimer();
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      if (_nextUpcomingMedicine != null) {
        _targetScheduledTime = _nextUpcomingMedicine!.getNextScheduledDoseTime(now);
        final remaining = _targetScheduledTime!.difference(now);
        _timeUntilNextDose = remaining.isNegative ? Duration.zero : remaining;
      }
      _updateNextUpcomingMedicineStateOnly();
      notifyListeners();
    });
  }

  void _updateNextUpcomingMedicineStateOnly() {
    final now = DateTime.now();
    final pending = _medicines.where((m) => m.getStatus(now) != MedicineStatus.taken).toList();

    if (pending.isNotEmpty) {
      pending.sort((a, b) {
        final timeA = a.getNextScheduledDoseTime(now);
        final timeB = b.getNextScheduledDoseTime(now);
        return timeA.compareTo(timeB);
      });
      _nextUpcomingMedicine = pending.first;
    } else if (_medicines.isNotEmpty) {
      final sorted = List<Medicine>.from(_medicines)
        ..sort((a, b) => a.getNextScheduledDoseTime(now).compareTo(b.getNextScheduledDoseTime(now)));
      _nextUpcomingMedicine = sorted.first;
    } else {
      _nextUpcomingMedicine = null;
    }

    if (_nextUpcomingMedicine != null) {
      _targetScheduledTime = _nextUpcomingMedicine!.getNextScheduledDoseTime(now);
      final remaining = _targetScheduledTime!.difference(now);
      _timeUntilNextDose = remaining.isNegative ? Duration.zero : remaining;
    } else {
      _targetScheduledTime = null;
      _timeUntilNextDose = Duration.zero;
    }
  }

  void addMedicine({
    required String name,
    required String dosage,
    required DateTime startDate,
    required DateTime endDate,
    required DateTime expirationDate,
    required String scheduleTime,
    String instructions = '',
  }) {
    final newMed = Medicine(
      id: const Uuid().v4(),
      name: name,
      dosage: dosage,
      startDate: startDate,
      endDate: endDate,
      expirationDate: expirationDate,
      scheduleTime: scheduleTime,
      instructions: instructions,
      isTaken: false,
    );

    _medicines.insert(0, newMed);
    _updateNextUpcomingMedicine();
    notifyListeners();
  }

  void updateMedicine({
    required String id,
    required String name,
    required String dosage,
    required DateTime startDate,
    required DateTime endDate,
    required DateTime expirationDate,
    required String scheduleTime,
    String instructions = '',
  }) {
    final index = _medicines.indexWhere((m) => m.id == id);
    if (index != -1) {
      _medicines[index] = _medicines[index].copyWith(
        name: name,
        dosage: dosage,
        startDate: startDate,
        endDate: endDate,
        expirationDate: expirationDate,
        scheduleTime: scheduleTime,
        instructions: instructions,
      );
      _updateNextUpcomingMedicine();
      notifyListeners();
    }
  }

  void deleteMedicine(String id) {
    _medicines.removeWhere((m) => m.id == id);
    _updateNextUpcomingMedicine();
    notifyListeners();
  }

  void markAsTaken(String id) {
    final index = _medicines.indexWhere((m) => m.id == id);
    if (index != -1) {
      _medicines[index] = _medicines[index].copyWith(
        isTaken: true,
        takenAt: DateTime.now(),
      );
      _updateNextUpcomingMedicine();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
