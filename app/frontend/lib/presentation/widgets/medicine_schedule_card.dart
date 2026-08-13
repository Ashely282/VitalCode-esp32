import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/medicine.dart';
import 'animated_scale_button.dart';

class MedicineScheduleCard extends StatelessWidget {
  final Medicine medicine;

  const MedicineScheduleCard({
    super.key,
    required this.medicine,
  });

  @override
  Widget build(BuildContext context) {
    final status = medicine.getStatus(DateTime.now());
    final isTakenCurrent = status == MedicineStatus.taken;

    Color badgeBgColor;
    Color badgeTextColor;
    String badgeText;

    switch (status) {
      case MedicineStatus.taken:
        badgeBgColor = Color.lerp(Theme.of(context).colorScheme.surface, AppColors.successEmerald, 0.15)!;
        badgeTextColor = AppColors.successEmerald;
        badgeText = 'TAKEN';
        break;
      case MedicineStatus.overdue:
        badgeBgColor = AppColors.emergencyRed;
        badgeTextColor = Colors.white;
        badgeText = 'OVERDUE';
        break;
      case MedicineStatus.upcoming:
        badgeBgColor = Color.lerp(Theme.of(context).colorScheme.surface, AppColors.warningAmber, 0.15)!;
        badgeTextColor = AppColors.warningAmber;
        badgeText = 'UPCOMING';
        break;
    }

    return ScaleTap(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isTakenCurrent
                ? AppColors.successEmerald.withValues(alpha: 0.3)
                : Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isTakenCurrent
                    ? Color.lerp(Theme.of(context).colorScheme.surface, AppColors.successEmerald, 0.15)
                    : Color.lerp(Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.primary, 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isTakenCurrent
                    ? Icons.check_circle_rounded
                    : Icons.medication_rounded,
                color: isTakenCurrent
                    ? AppColors.successEmerald
                    : AppColors.accentLime,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine.name,
                    style: AppTypography.titleMedium.copyWith(
                      fontSize: 16,
                      decoration: isTakenCurrent
                          ? TextDecoration.lineThrough
                          : null,
                      color: isTakenCurrent
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${medicine.dosage} • ${medicine.scheduleTime}',
                    style: AppTypography.bodyMedium.copyWith(
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgeBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badgeText,
                style: AppTypography.caption.copyWith(
                  color: badgeTextColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                size: 20,
                color: AppColors.accentLime,
              ),
              tooltip: 'Edit Medicine',
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(6),
              onPressed: () => context.push('/add-medicine', extra: medicine),
            ),
          ],
        ),
      ),
    );
  }
}
