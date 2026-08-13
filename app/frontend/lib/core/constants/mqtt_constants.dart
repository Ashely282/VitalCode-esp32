class MqttConstants {
  MqttConstants._();

  static const String defaultBrokerIp = 'broker.emqx.io';
  static const int defaultBrokerPort = 1883;

  // Topics
  static const String topicStatus = 'robot/status';
  static const String topicBattery = 'robot/battery';
  static const String topicCameraEmotion = 'robot/camera/emotion';
  static const String topicScheduleUpdate = 'robot/schedule_update';

  static const List<String> allTopics = [
    topicStatus,
    topicBattery,
    topicCameraEmotion,
    topicScheduleUpdate,
  ];
}
