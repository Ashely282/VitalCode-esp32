import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class VitalCodeLogoWidget extends StatelessWidget {
  final double scale;
  final bool showCircuitTraces;

  const VitalCodeLogoWidget({
    super.key,
    this.scale = 1.0,
    this.showCircuitTraces = true,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary, width: 3),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // VITAL Wordmark
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Text background V-TAL
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'V  TAL',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: Theme.of(context).colorScheme.onSurface,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Red Medical Cross (+) Overlay
                    Positioned(
                      left: 20,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.vitalRed.withValues(alpha: 0.6),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: AppColors.vitalRed,
                          size: 34,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 8),

                // CODE Badge with Rounded Container
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.darkBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                  child: const Text(
                    '[CODE]',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimaryDark,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),

                if (showCircuitTraces) ...[
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 70,
                    height: 50,
                    child: CustomPaint(
                      painter: CircuitTracePainter(
                        lineColor: AppColors.circuitLine,
                        nodeColor: AppColors.deepTeal,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            // Horizontal White ECG Heartbeat Line running across
            Positioned(
              left: 0,
              right: showCircuitTraces ? 70 : 0,
              child: SizedBox(
                height: 24,
                child: CustomPaint(painter: EcgHeartbeatPainter()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EcgHeartbeatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.ecgLineWhite.withValues(alpha: 0.95)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final midY = size.height / 2;

    path.moveTo(0, midY);
    path.lineTo(size.width * 0.15, midY);
    // Pulse spike 1
    path.lineTo(size.width * 0.22, midY - 6);
    path.lineTo(size.width * 0.28, midY + 8);
    path.lineTo(size.width * 0.35, midY - 14);
    path.lineTo(size.width * 0.42, midY + 12);
    path.lineTo(size.width * 0.48, midY);

    path.lineTo(size.width * 0.65, midY);
    // Pulse spike 2
    path.lineTo(size.width * 0.72, midY - 10);
    path.lineTo(size.width * 0.78, midY + 10);
    path.lineTo(size.width * 0.85, midY);
    path.lineTo(size.width, midY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CircuitTracePainter extends CustomPainter {
  final Color lineColor;
  final Color nodeColor;

  static final Path _path1 = Path()
    ..moveTo(0, 10)
    ..lineTo(20, 10)
    ..lineTo(35, 25)
    ..lineTo(55, 25);

  static final Path _path2 = Path()
    ..moveTo(0, 25)
    ..lineTo(25, 25)
    ..lineTo(40, 10)
    ..lineTo(60, 10);

  static final Path _path3 = Path()
    ..moveTo(0, 40)
    ..lineTo(15, 40)
    ..lineTo(30, 48)
    ..lineTo(50, 48);

  const CircuitTracePainter({
    this.lineColor = AppColors.circuitLine,
    this.nodeColor = AppColors.deepTeal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final nodePaint = Paint()
      ..color = nodeColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(_path1, linePaint);
    canvas.drawCircle(const Offset(55, 25), 3.5, nodePaint);

    canvas.drawPath(_path2, linePaint);
    canvas.drawCircle(const Offset(60, 10), 3.5, nodePaint);

    canvas.drawPath(_path3, linePaint);
    canvas.drawCircle(const Offset(50, 48), 3.5, nodePaint);
  }

  @override
  bool shouldRepaint(covariant CircuitTracePainter oldDelegate) =>
      oldDelegate.lineColor != lineColor || oldDelegate.nodeColor != nodeColor;
}
