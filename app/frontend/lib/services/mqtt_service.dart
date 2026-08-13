import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../constants/mqtt_topics.dart';

class MqttService {
  final String robotId;
  late MqttServerClient _client;
  
  // StreamController to broadcast telemetry data to the UI
  final StreamController<String> _telemetryController = StreamController<String>.broadcast();

  MqttService({required this.robotId});

  /// Connects to the MQTT broker and sets up auto-reconnect
  Future<void> connect(String brokerAddress, int port) async {
    final clientId = 'vital_ios_${DateTime.now().millisecondsSinceEpoch}';
    
    // We use MqttServerClient for mobile/desktop. Note: if you build for Web, you will need MqttBrowserClient.
    _client = MqttServerClient('test.mosquitto.org', clientId);
    _client.port = 1883;
    _client.logging(on: false);
    _client.keepAlivePeriod = 20;
    _client.onDisconnected = onDisconnected;
    _client.onConnected = onConnected;
    _client.onSubscribed = onSubscribed;
    
    // Auto reconnect setup
    _client.autoReconnect = true;

    // Setup a clean connection message
    final connMess = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .withWillTopic(MqttTopics.status(robotId))
        .withWillMessage('offline')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    
    _client.connectionMessage = connMess;

    try {
      await _client.connect();
    } catch (e) {
      debugPrint('Exception during MQTT connection: $e');
      _client.disconnect();
    }

    if (_client.connectionStatus!.state == MqttConnectionState.connected) {
      debugPrint('MQTT client connected successfully');
      _setupTelemetrySubscription();
    } else {
      debugPrint('ERROR: MQTT client connection failed - disconnecting, state is ${_client.connectionStatus!.state}');
      _client.disconnect();
    }
  }

  /// Sets up the subscription to the telemetry topic and pipes data into our StreamController
  void _setupTelemetrySubscription() {
    final telemetryTopic = MqttTopics.telemetry(robotId);
    _client.subscribe(telemetryTopic, MqttQos.atLeastOnce);

    _client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      if (c == null || c.isEmpty) return;

      final recMess = c[0].payload as MqttPublishMessage;
      final payloadData = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      
      // Aggressive Debug Logging as requested
      debugPrint('RAW MQTT MESSAGE RECEIVED: $payloadData');
      
      if (c[0].topic == telemetryTopic) {
        _telemetryController.add(payloadData);
      }
    });
  }

  /// The Stream that your UI (Dashboard) will listen to
  Stream<String> get telemetryStream => _telemetryController.stream;

  /// Publishes a command JSON string to the command topic
  void publishCommand(String commandJson) {
    if (_client.connectionStatus?.state != MqttConnectionState.connected) {
      print('Cannot publish, client is not connected.');
      return;
    }
    
    final builder = MqttClientPayloadBuilder();
    builder.addString(commandJson);
    
    final commandTopic = MqttTopics.command(robotId);
    _client.publishMessage(commandTopic, MqttQos.atLeastOnce, builder.payload!);
  }

  // --- Callbacks ---
  void onConnected() {
    debugPrint('Connected to MQTT Broker');
  }

  void onDisconnected() {
    debugPrint('MQTT DISCONNECTED!');
  }

  void onSubscribed(String topic) {
    debugPrint('Subscribed to topic: $topic');
  }

  /// Always remember to dispose resources when the service is no longer needed
  void dispose() {
    _client.disconnect();
    _telemetryController.close();
  }
}
