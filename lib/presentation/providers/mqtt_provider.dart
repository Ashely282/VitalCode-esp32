import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/constants/mqtt_constants.dart';
import '../../data/services/mqtt_service.dart';
import '../../domain/entities/robot_telemetry.dart';

class MqttProvider extends ChangeNotifier {
  final MqttService _mqttService = MqttService();

  RobotTelemetry _telemetry = RobotTelemetry(
    brokerIp: MqttConstants.defaultBrokerIp,
    brokerPort: MqttConstants.defaultBrokerPort,
    connectionState: RobotConnectionState.disconnected,
    batteryLevel: 92,
  );

  StreamSubscription<int>? _batterySub;
  StreamSubscription<String>? _statusSub;

  RobotTelemetry get telemetry => _telemetry;
  RobotConnectionState get connectionState => _telemetry.connectionState;
  int get batteryLevel => _telemetry.batteryLevel;
  MqttService get mqttService => _mqttService;

  MqttProvider() {
    _initListeners();
  }

  void _initListeners() {
    _batterySub = _mqttService.batteryStream.listen((battery) {
      _telemetry = _telemetry.copyWith(batteryLevel: battery);
      notifyListeners();
    });

    _statusSub = _mqttService.statusStream.listen((status) {
      _telemetry = _telemetry.copyWith(
        packetsReceived: _telemetry.packetsReceived + 1,
      );
      notifyListeners();
    });
  }

  Future<bool> testAndConnect({required String ip, required int port}) async {
    _telemetry = _telemetry.copyWith(
      brokerIp: ip,
      brokerPort: port,
      connectionState: RobotConnectionState.connecting,
    );
    notifyListeners();

    final success = await _mqttService.connect(brokerIp: ip, brokerPort: port);
    if (success) {
      _telemetry = _telemetry.copyWith(
        connectionState: RobotConnectionState.connected,
      );
    } else {
      _telemetry = _telemetry.copyWith(
        connectionState: RobotConnectionState.error,
      );
    }
    notifyListeners();
    return success;
  }

  void sendEmergencySignal() {
    _mqttService.publishMessage(
      MqttConstants.topicStatus,
      'EMERGENCY_ALERT_TRIGGERED: Caregiver support requested immediately.',
    );
    _telemetry = _telemetry.copyWith(
      packetsSent: _telemetry.packetsSent + 1,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _batterySub?.cancel();
    _statusSub?.cancel();
    _mqttService.dispose();
    super.dispose();
  }
}
