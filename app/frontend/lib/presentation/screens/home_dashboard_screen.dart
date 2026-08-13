import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/medicine.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../providers/auth_provider.dart';
import '../providers/medicine_provider.dart';
import '../widgets/animated_scale_button.dart';
import '../widgets/battery_indicator_widget.dart';
import '../widgets/medicine_schedule_card.dart';
import '../widgets/upcoming_timer_card.dart';
import '../../services/mqtt_service.dart' as new_mqtt;
import '../../models/robot_telemetry.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userName = auth.username.isNotEmpty ? auth.username : 'Eleanor';
    final mqttService = Provider.of<new_mqtt.MqttService>(
      context,
      listen: false,
    );

    return StreamBuilder<String>(
      stream: mqttService.telemetryStream,
      builder: (context, snapshot) {
        RobotTelemetry? telemetry;

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          try {
            final Map<String, dynamic> data = jsonDecode(snapshot.data!);
            telemetry = RobotTelemetry.fromJson(data);
          } catch (e) {
            debugPrint('Error parsing telemetry JSON: $e');
          }
        }

        final robotStatus = telemetry?.status ?? 'Robot Telemetry Active';
        final batteryLevel = telemetry?.batteryPercentage;

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final headerColor = isDark ? AppColors.accentLime : Theme.of(context).scaffoldBackgroundColor;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'CARE COMPANION',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: headerColor,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.favorite_rounded,
                      color: AppColors.vitalRed,
                      size: 16,
                    ),
                  ],
                ),
                Text(
                  'Hello $userName • $robotStatus',
                  style: AppTypography.caption.copyWith(
                    color: headerColor,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.settings_rounded,
                  color: headerColor,
                ),
                tooltip: 'App Settings',
                onPressed: () => context.push('/settings'),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: BatteryIndicatorWidget(batteryLevel: batteryLevel),
              ),
            ],
          ),
          floatingActionButton: ScaleTap(
            child: FloatingActionButton(
              onPressed: () => context.push('/add-medicine'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              elevation: 6,
              shape: const CircleBorder(),
              tooltip: 'Add Medicine',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_rounded,
                    size: 20,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  const SizedBox(width: 1),
                  Icon(
                    Icons.medication_rounded,
                    size: 18,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ],
              ),
            ),
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(24),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // ==========================================
                          // MAIN FOCUS: UPCOMING COUNTDOWN TIMER
                          // ==========================================
                          const UpcomingTimerCard(),

                          const SizedBox(height: 32),

                          // Today's Medication Schedule Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Today's Schedule",
                                style: AppTypography.titleLarge.copyWith(
                                  fontSize: 20,
                                ),
                              ),
                              Selector<MedicineProvider, int>(
                                selector: (_, provider) =>
                                    provider.medicines.length,
                                builder: (context, count, child) {
                                  return Text(
                                    '$count Medicines',
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),
                        ]),
                      ),
                    ),

                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                      ).copyWith(bottom: 24),
                      sliver: Selector<MedicineProvider, int>(
                        selector: (_, provider) => provider.medicines.length,
                        builder: (context, count, child) {
                          if (count == 0) {
                            return SliverToBoxAdapter(
                              child: Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    'No medicines scheduled. Tap "Add Medicine" to create one.',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            );
                          }

                          return SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              return Selector<MedicineProvider, Medicine>(
                                selector: (_, provider) =>
                                    provider.medicines[index],
                                builder: (context, med, child) {
                                  return MedicineScheduleCard(medicine: med);
                                },
                              );
                            }, childCount: count),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
