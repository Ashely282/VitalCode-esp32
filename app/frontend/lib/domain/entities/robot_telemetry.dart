enum RobotConnectionState {
  disconnected,
  connecting,
  connected,
  error,
}

class RobotTelemetry {
  final String brokerIp;
  final int brokerPort;
  final RobotConnectionState connectionState;
  final int batteryLevel; // Percentage 0 - 100
  final bool isCharging;
  final String firmwareVersion;
  final String serialNumber;
  final int latencyMs;
  final int packetsReceived;
  final int packetsSent;
  final String emergencyCaregiverName;
  final String emergencyCaregiverPhone;

  RobotTelemetry({
    required this.brokerIp,
    required this.brokerPort,
    required this.connectionState,
    required this.batteryLevel,
    this.isCharging = false,
    this.firmwareVersion = 'v2.4.1-companion-pro',
    this.serialNumber = 'BOT-iOS-9842-X',
    this.latencyMs = 18,
    this.packetsReceived = 1420,
    this.packetsSent = 380,
    this.emergencyCaregiverName = 'Dr. Sarah Connor (Primary Caregiver)',
    this.emergencyCaregiverPhone = '+1 (555) 019-2831',
  });

  RobotTelemetry copyWith({
    String? brokerIp,
    int? brokerPort,
    RobotConnectionState? connectionState,
    int? batteryLevel,
    bool? isCharging,
    String? firmwareVersion,
    String? serialNumber,
    int? latencyMs,
    int? packetsReceived,
    int? packetsSent,
    String? emergencyCaregiverName,
    String? emergencyCaregiverPhone,
  }) {
    return RobotTelemetry(
      brokerIp: brokerIp ?? this.brokerIp,
      brokerPort: brokerPort ?? this.brokerPort,
      connectionState: connectionState ?? this.connectionState,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      isCharging: isCharging ?? this.isCharging,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      serialNumber: serialNumber ?? this.serialNumber,
      latencyMs: latencyMs ?? this.latencyMs,
      packetsReceived: packetsReceived ?? this.packetsReceived,
      packetsSent: packetsSent ?? this.packetsSent,
      emergencyCaregiverName: emergencyCaregiverName ?? this.emergencyCaregiverName,
      emergencyCaregiverPhone: emergencyCaregiverPhone ?? this.emergencyCaregiverPhone,
    );
  }
}
