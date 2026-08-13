import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class BatteryIndicatorWidget extends StatelessWidget {
  final int? batteryLevel;

  const BatteryIndicatorWidget({
    super.key,
    this.batteryLevel,
  });

  IconData _getBatteryIcon(int level) {
    if (level >= 90) return Icons.battery_full_rounded;
    if (level >= 60) return Icons.battery_6_bar_rounded;
    if (level >= 30) return Icons.battery_3_bar_rounded;
    return Icons.battery_1_bar_rounded;
  }

  Color _getBatteryColor(int level) {
    if (level >= 50) return AppColors.successEmerald;
    if (level >= 20) return AppColors.warningAmber;
    return AppColors.emergencyRed;
  }

  @override
  Widget build(BuildContext context) {
    final battery = batteryLevel ?? 0;
    final color = _getBatteryColor(battery);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getBatteryIcon(battery),
            color: color,
            size: 18,
          ),
          const SizedBox(width: 4),
          Text(
            '$battery%',
            style: AppTypography.caption.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
