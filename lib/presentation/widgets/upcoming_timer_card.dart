import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_typography.dart';
import '../providers/medicine_provider.dart';
import '../providers/emotion_provider.dart';

class UpcomingTimerCard extends StatelessWidget {
  const UpcomingTimerCard({super.key});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicineProvider>(
      builder: (context, medProvider, child) {
        final upcoming = medProvider.nextUpcomingMedicine;
        final timeStr = _formatDuration(medProvider.timeUntilNextDose);

        final Color cardBg = Theme.of(context).colorScheme.primary;
        final Color cardBorder = Theme.of(context).colorScheme.outlineVariant;

        final Color textPrimaryOnCard = Theme.of(context).colorScheme.onPrimary;
        final Color textSecondaryOnCard = Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.85);
        final Color timerChipBg = Colors.black.withValues(alpha: 0.25);
        final Color timerText = Theme.of(context).colorScheme.onPrimary;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: AppRadii.dialog, // Equivalent to circular(24)
            border: Border.all(color: cardBorder, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.vitalRed.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            color: AppColors.vitalRed,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'UPCOMING MEDICATION',
                            style: AppTypography.overline.copyWith(
                              color: AppColors.vitalRed,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warningAmber.withValues(alpha: 0.22),
                      borderRadius: AppRadii.card,
                      border: Border.all(
                        color: AppColors.warningAmber.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.schedule,
                          color: Colors.black,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          upcoming != null ? upcoming.scheduleTime : '01:30 PM',
                          style: AppTypography.caption.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          upcoming != null ? upcoming.name : 'Omega 3 Fish Oil',
                          style: AppTypography.titleMedium.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            // Background is medium-light teal → dark slate for contrast
                            color: textPrimaryOnCard,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          upcoming != null
                              ? upcoming.dosage
                              : '1000 mg (1 Softgel)',
                          style: AppTypography.bodyMedium.copyWith(
                            // Slightly lighter slate for secondary hierarchy
                            color: textSecondaryOnCard,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: timerChipBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Text(
                      timeStr,
                      style: AppTypography.timerDisplay.copyWith(
                        color: timerText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.successEmerald,
                        foregroundColor: Theme.of(context).colorScheme.onError,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadii.button,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      onPressed: upcoming != null
                          ? () {
                              medProvider.markAsTaken(upcoming.id);
                              context.read<EmotionProvider>().addIntakeReceipt(
                                upcoming.name,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                                  content: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: AppColors.successEmerald,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Logged receipt for ${upcoming.name}',
                                          style: AppTypography.bodyMedium
                                              .copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.check_circle_outline, size: 20),
                      label: const Text(
                        'Mark as Taken',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
