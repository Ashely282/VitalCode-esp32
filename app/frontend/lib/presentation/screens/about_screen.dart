import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/mqtt_constants.dart';
import '../providers/auth_provider.dart';
import '../providers/mqtt_provider.dart';
import '../widgets/custom_button.dart';
import 'edit_account_screen.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {

  void _triggerEmergencyAlert(BuildContext context) {
    context.read<MqttProvider>().sendEmergencySignal();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.error, size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'EMERGENCY ALERT',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Text(
            'Emergency pulse signal broadcasted over MQTT! Your primary caregiver and medical response team have been notified.',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Icon(Icons.logout_rounded, color: Theme.of(context).colorScheme.error, size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Sign Out',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to log out of CareCompanion AI? Your authentication session will be completely cleared.',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<AuthProvider>().logout();
                context.go('/auth-choice');
              },
              child: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Robot System Diagnostics'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_rounded, color: Theme.of(context).colorScheme.secondary),
            tooltip: 'App Settings & Theme',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Account Profile Info Box
                  const _UserProfileCard(),

              const SizedBox(height: 24),

              // Caregiver Support Emergency Contact Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.contact_emergency_rounded,
                            color: Theme.of(context).colorScheme.error,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'EMERGENCY CAREGIVER SUPPORT',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w800,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Dr. Sarah Connor (Primary)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Direct Line: +1 (555) 019-2831',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      label: 'BROADCAST EMERGENCY ALERT',
                      icon: Icons.notifications_active_rounded,
                      isEmergency: true,
                      onPressed: () => _triggerEmergencyAlert(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // MQTT Telemetry Details
              Text(
                'MQTT Broker Telemetry Details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Column(
                  children: [
                    Selector<MqttProvider, String>(
                      selector: (context, provider) => '${provider.telemetry.brokerIp}:${provider.telemetry.brokerPort}',
                      builder: (context, endpoint, child) => _TelemetryRow(
                        label: 'Broker Endpoint',
                        value: endpoint,
                        icon: Icons.dns_rounded,
                      ),
                    ),
                    const Divider(height: 24),
                    Selector<MqttProvider, int>(
                      selector: (context, provider) => provider.telemetry.latencyMs,
                      builder: (context, latency, child) => _TelemetryRow(
                        label: 'Broker Latency',
                        value: '$latency ms',
                        icon: Icons.speed_rounded,
                      ),
                    ),
                    const Divider(height: 24),
                    Selector<MqttProvider, String>(
                      selector: (context, provider) => '${provider.telemetry.packetsReceived} / ${provider.telemetry.packetsSent}',
                      builder: (context, packets, child) => _TelemetryRow(
                        label: 'Packets Received / Sent',
                        value: packets,
                        icon: Icons.swap_vert_rounded,
                      ),
                    ),
                    const Divider(height: 24),
                    _TelemetryRow(
                      label: 'Active Subscribed Topics',
                      value: '${MqttConstants.allTopics.length} Topics Active',
                      icon: Icons.topic_rounded,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Robot Firmware Info
              Text(
                'System & Firmware',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Column(
                  children: [
                    Selector<MqttProvider, String>(
                      selector: (context, provider) => provider.telemetry.firmwareVersion,
                      builder: (context, version, child) => _TelemetryRow(
                        label: 'Firmware Version',
                        value: 'v$version',
                        icon: Icons.memory_rounded,
                      ),
                    ),
                    const Divider(height: 24),
                    Selector<MqttProvider, String>(
                      selector: (context, provider) => provider.telemetry.serialNumber,
                      builder: (context, serial, child) => _TelemetryRow(
                        label: 'Hardware Serial Number',
                        value: serial,
                        icon: Icons.developer_board_rounded,
                      ),
                    ),
                    const Divider(height: 24),
                    const _TelemetryRow(
                      label: 'Platform Architecture',
                      value: 'iOS AI Engine v2.0',
                      icon: Icons.phone_iphone_rounded,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // COMPACT SIGN OUT BUTTON AT VERY BOTTOM OF ABOUT PAGE
              Center(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side: BorderSide(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.6), width: 1.2),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  onPressed: () => _handleLogout(context),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    ),
  ),
);
  }
}

class _UserProfileCard extends StatefulWidget {
  const _UserProfileCard();

  @override
  State<_UserProfileCard> createState() => _UserProfileCardState();
}

class _UserProfileCardState extends State<_UserProfileCard> {
  String userName = "Guest";
  String userEmail = "guest@example.com";

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditAccountScreen(
                initialName: userName,
                initialEmail: userEmail,
              ),
            ),
          );

          if (!context.mounted) return;

          if (result != null && result is Map<String, String>) {
            setState(() {
              userName = result['name'] ?? userName;
              userEmail = result['email'] ?? userEmail;
            });
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userEmail,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TelemetryRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _TelemetryRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.secondary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
