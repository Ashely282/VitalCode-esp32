import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class QrScannerPlaceholder extends StatefulWidget {
  final Function(String brokerIp, int port)? onScanned;

  const QrScannerPlaceholder({super.key, this.onScanned});

  @override
  State<QrScannerPlaceholder> createState() => _QrScannerPlaceholderState();
}

class _QrScannerPlaceholderState extends State<QrScannerPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _triggerSimulatedScan() {
    setState(() => _isScanning = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        content: Text(
          'Robot QR Code Scanned! Broker settings configured.',
          style: TextStyle(color: AppColors.vitalRed),
        ),
      ),
    );
    widget.onScanned?.call('192.168.1.100', 1883);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isScanning = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 135,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.7)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background camera view
            Positioned.fill(
              child: Container(
                color: Theme.of(context).colorScheme.surface,
                child: Center(
                  child: Icon(
                    Icons.qr_code_2_rounded,
                    size: 80,
                    color: AppColors.textMutedDark.withValues(alpha: 0.25),
                  ),
                ),
              ),
            ),

            // Viewfinder frame
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.accent, width: 2.0),
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            // Vital Red Laser scanner animation
            if (_isScanning)
              Positioned(
                top: 22,
                child: AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _animController.value * 70),
                      child: child,
                    );
                  },
                  child: Container(
                    width: 80,
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: AppColors.vitalRed,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.vitalRed.withValues(alpha: 0.9),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Compact Overlay Action Button
            Positioned(
              bottom: 8,
              child: SizedBox(
                height: 32,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    foregroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.accent, width: 1),
                    ),
                    elevation: 2,
                  ),
                  onPressed: _triggerSimulatedScan,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.qr_code_scanner_rounded, size: 15),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _isScanning ? 'Tap to Scan Robot QR' : 'QR Scanned',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
