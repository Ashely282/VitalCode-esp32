import 'package:flutter_test/flutter_test.dart';
import 'package:alt1/domain/entities/medicine.dart';

void main() {
  group('Medicine Status & Time Calculations', () {
    final now = DateTime(2026, 8, 6, 8, 0, 0); // 8:00 AM today

    test('getStatus returns upcoming when within 90 minutes of scheduled time', () {
      final medicine = Medicine(
        id: '1',
        name: 'Aspirin',
        dosage: '100 mg',
        startDate: now.subtract(const Duration(days: 1)),
        endDate: now.add(const Duration(days: 10)),
        expirationDate: now.add(const Duration(days: 100)),
        scheduleTime: '09:00 AM', // Scheduled at 9:00 AM (1 hour from 8:00 AM)
        isTaken: false,
      );

      expect(medicine.getStatus(now), equals(MedicineStatus.upcoming));
    });

    test('getStatus returns upcoming exactly 90 minutes before next scheduled dose', () {
      final curTime = DateTime(2026, 8, 6, 7, 30, 0); // 7:30 AM
      final medicine = Medicine(
        id: '1',
        name: 'Aspirin',
        dosage: '100 mg',
        startDate: curTime.subtract(const Duration(days: 1)),
        endDate: curTime.add(const Duration(days: 10)),
        expirationDate: curTime.add(const Duration(days: 100)),
        scheduleTime: '09:00 AM', // 90 mins away
        isTaken: false,
      );

      expect(medicine.getStatus(curTime), equals(MedicineStatus.upcoming));
    });

    test('getStatus returns taken after user marks as taken outside 90-minute window', () {
      final intakeTime = DateTime(2026, 8, 6, 9, 0, 0); // 9:00 AM intake
      final checkTime = DateTime(2026, 8, 6, 12, 0, 0); // 12:00 PM check (21 hours until next dose tomorrow 9:00 AM)

      final medicine = Medicine(
        id: '1',
        name: 'Aspirin',
        dosage: '100 mg',
        startDate: intakeTime.subtract(const Duration(days: 1)),
        endDate: intakeTime.add(const Duration(days: 10)),
        expirationDate: intakeTime.add(const Duration(days: 100)),
        scheduleTime: '09:00 AM',
        isTaken: true,
        takenAt: intakeTime,
      );

      expect(medicine.getStatus(checkTime), equals(MedicineStatus.taken));
    });

    test('getStatus automatically transitions from taken to upcoming 90 minutes before next scheduled dose', () {
      // Dose taken on Aug 6 at 9:00 AM
      final intakeTime = DateTime(2026, 8, 6, 9, 0, 0);
      final medicine = Medicine(
        id: '1',
        name: 'Aspirin',
        dosage: '100 mg',
        startDate: intakeTime.subtract(const Duration(days: 1)),
        endDate: intakeTime.add(const Duration(days: 10)),
        expirationDate: intakeTime.add(const Duration(days: 100)),
        scheduleTime: '09:00 AM',
        isTaken: true,
        takenAt: intakeTime,
      );

      // On Aug 7 at 7:30 AM (90 minutes before Aug 7 9:00 AM next dose)
      final upcomingWindowTime = DateTime(2026, 8, 7, 7, 30, 0);

      // Should evaluate to upcoming, resetting the status visually from taken
      expect(medicine.getStatus(upcomingWindowTime), equals(MedicineStatus.upcoming));
    });

    test('getStatus returns overdue when scheduled time passes without intake', () {
      final checkTime = DateTime(2026, 8, 6, 10, 0, 0); // 10:00 AM check
      final medicine = Medicine(
        id: '1',
        name: 'Aspirin',
        dosage: '100 mg',
        startDate: checkTime.subtract(const Duration(days: 1)),
        endDate: checkTime.add(const Duration(days: 10)),
        expirationDate: checkTime.add(const Duration(days: 100)),
        scheduleTime: '09:00 AM', // 9:00 AM passed
        isTaken: false,
        takenAt: null,
      );

      expect(medicine.getStatus(checkTime), equals(MedicineStatus.overdue));
    });
  });
}
