import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/mqtt_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/robot_telemetry.dart';
import '../providers/mqtt_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/qr_scanner_placeholder.dart';

class RobotPairingScreen extends StatefulWidget {
  const RobotPairingScreen({super.key});

  @override
  State<RobotPairingScreen> createState() => _RobotPairingScreenState();
}

class _RobotPairingScreenState extends State<RobotPairingScreen> {
  final _brokerIpController = TextEditingController(text: MqttConstants.defaultBrokerIp);
  final _brokerPortController = TextEditingController(text: MqttConstants.defaultBrokerPort.toString());
  bool _isTesting = false;

  @override
  void dispose() {
    _brokerIpController.dispose();
    _brokerPortController.dispose();
    super.dispose();
  }

  Future<void> _handleTestConnection() async {
    setState(() => _isTesting = true);
    final mqttProvider = context.read<MqttProvider>();
    final port = int.tryParse(_brokerPortController.text.trim()) ?? 1883;

    final success = await mqttProvider.testAndConnect(
      ip: _brokerIpController.text.trim(),
      port: port,
    );

    if (mounted) {
      setState(() => _isTesting = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            content: Row(
              children: [
                Icon(Icons.wifi_rounded, color: AppColors.successEmerald),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Robot Companion Connected via MQTT Broker!',
                    style: TextStyle(color: AppColors.textPrimaryDark),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
        context.go('/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Robot Connection & Pairing'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/auth-choice'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
            bottom: 40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pair Companion Device',
                style: AppTypography.displayLarge.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 6),
              Text(
                'Scan the robot QR code or specify your local MQTT broker telemetry IP & port.',
                style: AppTypography.bodyMedium,
              ),

              const SizedBox(height: 16),

              // Compacted Interactive QR Scanner Viewport Placeholder
              QrScannerPlaceholder(
                onScanned: (brokerIp, port) {
                  setState(() {
                    _brokerIpController.text = brokerIp;
                    _brokerPortController.text = port.toString();
                  });
                },
              ),

              const SizedBox(height: 16),

              // Connection Status Badge
              Consumer<MqttProvider>(
                builder: (context, mqttProvider, child) {
                  final state = mqttProvider.connectionState;
                  Color badgeColor;
                  String stateLabel;

                  switch (state) {
                    case RobotConnectionState.connected:
                      badgeColor = AppColors.successEmerald;
                      stateLabel = 'MQTT BROKER ACTIVE & CONNECTED';
                      break;
                    case RobotConnectionState.connecting:
                      badgeColor = AppColors.warningAmber;
                      stateLabel = 'CONNECTING TO BROKER...';
                      break;
                    case RobotConnectionState.error:
                      badgeColor = AppColors.emergencyRed;
                      stateLabel = 'CONNECTION ERROR';
                      break;
                    case RobotConnectionState.disconnected:
                      badgeColor = AppColors.textMutedDark;
                      stateLabel = 'ROBOT DISCONNECTED';
                      break;
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: badgeColor.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: badgeColor,
                            boxShadow: [
                              BoxShadow(color: badgeColor, blurRadius: 6),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            stateLabel,
                            style: AppTypography.labelLarge.copyWith(
                              fontSize: 12,
                              color: badgeColor,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 14),

              // MQTT Broker Settings Form
              CustomTextField(
                label: 'MQTT BROKER IP / HOSTNAME',
                hint: 'e.g. broker.emqx.io or 192.168.1.100',
                controller: _brokerIpController,
                prefixIcon: Icons.router_rounded,
              ),

              const SizedBox(height: 12),

              CustomTextField(
                label: 'MQTT PORT',
                hint: 'e.g. 1883',
                controller: _brokerPortController,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.settings_ethernet_rounded,
              ),

              const SizedBox(height: 20),

              CustomButton(
                label: 'Test Connection & Pair',
                icon: Icons.electrical_services_rounded,
                isLoading: _isTesting,
                onPressed: _handleTestConnection,
              ),

              const SizedBox(height: 10),

              CustomButton(
                label: 'Proceed to Dashboard',
                isPrimary: false,
                onPressed: () => context.go('/dashboard'),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
