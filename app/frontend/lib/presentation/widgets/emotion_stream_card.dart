import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/emotion_log.dart';
import '../providers/emotion_provider.dart';

class EmotionStreamCard extends StatefulWidget {
  const EmotionStreamCard({super.key});

  @override
  State<EmotionStreamCard> createState() => _EmotionStreamCardState();
}

class _EmotionStreamCardState extends State<EmotionStreamCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ecgAnimController;

  @override
  void initState() {
    super.initState();
    _ecgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _ecgAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EmotionProvider>(
      builder: (context, emotionProvider, child) {
        final live = emotionProvider.currentLiveStream;
        final mood = live?.mood ?? UserMood.happy;
        final confidencePercent = ((live?.confidence ?? 0.95) * 100).toInt();

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Camera Viewport Header
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Stack(
                  children: [
                    // Animated Live White ECG Waveform line background
                    AnimatedBuilder(
                      animation: _ecgAnimController,
                      builder: (context, child) {
                        return Positioned.fill(
                          child: CustomPaint(
                            painter: AnimatedEcgPainter(
                              progress: _ecgAnimController.value,
                            ),
                          ),
                        );
                      },
                    ),

                    // LIVE indicator badge
                    Positioned(
                      top: 14,
                      left: 14,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.vitalRed,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.vitalRed.withValues(alpha: 0.6),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.fiber_manual_record,
                                color: Theme.of(context).colorScheme.onPrimary, size: 10),
                            const SizedBox(width: 6),
                            Text(
                              'ROBOT VISION LIVE',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Topic Tag
                    Positioned(
                      top: 14,
                      right: 14,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          'topic: robot/camera/emotion',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.accent,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),

                    // Center Mood Avatar
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
                              border: Border.all(
                                color: AppColors.vitalRed,
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.vitalRed.withValues(alpha: 0.5),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: Text(
                              mood.emoji,
                              style: const TextStyle(fontSize: 42),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            mood.label,
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Telemetry Details
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Emotion Recognition Accuracy',
                          style: AppTypography.bodyMedium,
                        ),
                        Text(
                          '$confidencePercent%',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.successEmerald,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: live?.confidence ?? 0.95,
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.successEmerald,
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      live?.rawMessage ??
                          'Robot Telemetry: Monitoring user vitals & emotion in real time.',
                      style: AppTypography.caption.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AnimatedEcgPainter extends CustomPainter {
  final double progress;

  AnimatedEcgPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.ecgLineWhite.withValues(alpha: 0.25)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    final path = Path();
    final midY = size.height / 2;
    final offsetX = progress * size.width;

    path.moveTo(0, midY);
    for (double x = 0; x < size.width; x += 10) {
      final relativeX = (x + offsetX) % size.width;
      if ((relativeX - size.width * 0.4).abs() < 20) {
        path.lineTo(x, midY - 14);
      } else if ((relativeX - size.width * 0.45).abs() < 15) {
        path.lineTo(x, midY + 18);
      } else {
        path.lineTo(x, midY);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant AnimatedEcgPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
