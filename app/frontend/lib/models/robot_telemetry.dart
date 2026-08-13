class RobotTelemetry {
  final bool? wifiConnected;
  final int? batteryPercentage;
  final String? status;
  final String? firmwareVersion;
  final String? deviceName;
  final double? latitude;
  final double? longitude;
  final String? latestWaypoint;
  final String? waypointStatus;

  RobotTelemetry({
    this.wifiConnected,
    this.batteryPercentage,
    this.status,
    this.firmwareVersion,
    this.deviceName,
    this.latitude,
    this.longitude,
    this.latestWaypoint,
    this.waypointStatus,
  });

  factory RobotTelemetry.fromJson(Map<String, dynamic> json) {
    return RobotTelemetry(
      wifiConnected: json['wifi_connected'] as bool?,
      batteryPercentage: json['battery_percentage'] as int?,
      status: json['status'] as String?,
      firmwareVersion: json['firmware_version'] as String?,
      deviceName: json['device_name'] as String?,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      latestWaypoint: json['latest_waypoint'] as String?,
      waypointStatus: json['waypoint_status'] as String?,
    );
  }
}
