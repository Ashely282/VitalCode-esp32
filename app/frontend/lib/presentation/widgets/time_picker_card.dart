import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'animated_scale_button.dart';

class TimePickerCard extends StatelessWidget {
  final String timeText;
  final VoidCallback onTap;

  const TimePickerCard({
    super.key,
    required this.timeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Pick Daily Dosage Time',
      child: ScaleTap(
        child: Material(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.accentLime),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_filled_rounded,
                        color: AppColors.accentLime,
                      ),
                      const SizedBox(width: 12),
                      Text('Daily Dosage Time', style: AppTypography.bodyLarge),
                    ],
                  ),
                  Text(
                    timeText,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.accentLime,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
