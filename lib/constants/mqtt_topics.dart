class MqttTopics {
  static String status(String robotId) => "vitalcode/robots/$robotId/status";
  static String command(String robotId) => "vitalcode/robots/$robotId/command";
  static String medicine(String robotId) => "vitalcode/robots/$robotId/medicine";
  static String emergency(String robotId) => "vitalcode/robots/$robotId/emergency";
  static String heartbeat(String robotId) => "vitalcode/robots/$robotId/heartbeat";
  static String telemetry(String robotId) => "vitalcode/robots/$robotId/telemetry";
  static String response(String robotId) => "vitalcode/robots/$robotId/response";
}
