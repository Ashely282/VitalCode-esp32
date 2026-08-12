import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isPrimary;
  final bool isEmergency;
  final bool isLoading;
  final double height;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isPrimary = true,
    this.isEmergency = false,
    this.isLoading = false,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    LinearGradient? gradient;
    Color? bgColor;
    
    if (isEmergency) {
      bgColor = Colors.red.shade700;
    } else if (isPrimary) {
      gradient = AppColors.primaryGradient;
    } else {
      gradient = const LinearGradient(
        colors: [AppColors.darkSurfaceCardElevated, AppColors.darkSurfaceCard],
      );
    }

    final glowColor = isEmergency
        ? AppColors.vitalRed
        : (isPrimary ? AppColors.accent : AppColors.darkSurfaceBorder);

    final foregroundColor = isEmergency 
        ? Colors.white 
        : Theme.of(context).colorScheme.onPrimary;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        gradient: gradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: isPrimary || isEmergency ? 0.35 : 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(18),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          color: foregroundColor,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                      ],
                      Flexible(
                        child: Text(
                          label,
                          style: AppTypography.labelLarge.copyWith(
                            color: foregroundColor,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
