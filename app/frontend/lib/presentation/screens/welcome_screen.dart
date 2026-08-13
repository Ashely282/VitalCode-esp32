import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../../core/theme/app_typography.dart';
import '../widgets/custom_button.dart';
import '../widgets/vital_code_logo_widget.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const Spacer(),

              // Exact VITAL CODE Brand Logo Header from Source Image
              Flexible(
                flex: 2,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: const VitalCodeLogoWidget(scale: 0.95),
                ),
              ),

              const SizedBox(height: 32),

                      // Hero Title
                      Text(
                        'Healthcare Companion AI',
                        style: AppTypography.displayLarge.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 26,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      // Tagline
                      Text(
                        'Next-Gen Robot Telemetry & Vital Medication Sync.\nIntelligent. Vigilant. Connected.',
                        style: AppTypography.bodyLarge.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 28),

                      // Feature cards with VITAL CODE brand accent styling
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildFeatureRow(
                              icon: Icons.medication_rounded,
                              color: AppColors.accent,
                              title: 'VITAL Medication Engine',
                              subtitle:
                                  'Automated live countdowns & dose logs.',
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Divider(),
                            ),
                            _buildFeatureRow(
                              icon: Icons.videocam_rounded,
                              color: AppColors.vitalRed,
                              title: 'Vision & ECG Emotion Telemetry',
                              subtitle:
                                  'Robot camera streams mood & vital states.',
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Divider(),
                            ),
                            _buildFeatureRow(
                              icon: Icons.contact_emergency_rounded,
                              color: AppColors.vitalRed,
                              title: 'Caregiver Emergency Broadcast',
                              subtitle:
                                  'Instant alert link to your primary caregiver.',
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),
                      const SizedBox(height: 20),

                      // Primary Clear Action
                      CustomButton(
                        label: 'Get Started',
                        icon: Icons.arrow_forward_rounded,
                        onPressed: () => context.go('/auth-choice'),
                      ),
                      const SizedBox(height: 10),

                      TextButton(
                        onPressed: () {
                          context.read<AuthProvider>().guestLogin();
                          context.go('/pair');
                        },
                        child: Text(
                          'Skip to Robot Pairing',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.titleMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTypography.caption),
            ],
          ),
        ),
      ],
    );
  }
}
