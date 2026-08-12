import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../data/services/mqtt_service.dart';
import '../../domain/entities/emotion_log.dart';

class EmotionProvider extends ChangeNotifier {
  final List<EmotionLog> _logs = [];
  EmotionLog? _currentLiveStream;
  StreamSubscription? _emotionSub;

  List<EmotionLog> get logs => List.unmodifiable(_logs);
  EmotionLog? get currentLiveStream => _currentLiveStream;

  void init(MqttService mqttService) {
    _loadSampleLogs();
    _emotionSub?.cancel();
    _emotionSub = mqttService.emotionStream.listen((data) {
      final moodStr = data['mood'] as String? ?? 'happy';
      final confidence = (data['confidence'] as num?)?.toDouble() ?? 0.92;
      final rawMsg = data['rawMessage'] as String? ?? 'Robot camera stream active';

      UserMood mood;
      switch (moodStr.toLowerCase()) {
        case 'happy':
          mood = UserMood.happy;
          break;
        case 'sad':
          mood = UserMood.sad;
          break;
        case 'depressed':
          mood = UserMood.depressed;
          break;
        case 'angry':
          mood = UserMood.angry;
          break;
        default:
          mood = UserMood.happy;
      }

      final newLog = EmotionLog(
        id: const Uuid().v4(),
        mood: mood,
        confidence: confidence,
        timestamp: DateTime.now(),
        rawMessage: rawMsg,
      );

      _currentLiveStream = newLog;
      _logs.insert(0, newLog);
      if (_logs.length > 50) {
        _logs.removeLast();
      }
      notifyListeners();
    });
  }

  void _loadSampleLogs() {
    final now = DateTime.now();
    _currentLiveStream = EmotionLog(
      id: const Uuid().v4(),
      mood: UserMood.happy,
      confidence: 0.95,
      timestamp: now,
      rawMessage: 'Robot AI Camera: User detected in Happy mood state.',
    );

    _logs.addAll([
      EmotionLog(
        id: const Uuid().v4(),
        mood: UserMood.happy,
        confidence: 0.96,
        timestamp: now.subtract(const Duration(minutes: 15)),
        rawMessage: 'Confirmed intake receipt: Aspirin Cardio 100 mg taken.',
        isIntakeReceipt: true,
        associatedMedicineName: 'Aspirin Cardio',
      ),
      EmotionLog(
        id: const Uuid().v4(),
        mood: UserMood.sad,
        confidence: 0.89,
        timestamp: now.subtract(const Duration(hours: 1, minutes: 20)),
        rawMessage: 'Robot AI Telemetry: Facial scan interpreted user as Sad.',
      ),
      EmotionLog(
        id: const Uuid().v4(),
        mood: UserMood.depressed,
        confidence: 0.92,
        timestamp: now.subtract(const Duration(hours: 3, minutes: 45)),
        rawMessage: 'Robot AI Telemetry: Expression analysis flags Depressed state.',
      ),
      EmotionLog(
        id: const Uuid().v4(),
        mood: UserMood.happy,
        confidence: 0.94,
        timestamp: now.subtract(const Duration(hours: 6)),
        rawMessage: 'Intake verification scan: Omega 3 Fish Oil ready.',
        isIntakeReceipt: true,
        associatedMedicineName: 'Omega 3 Fish Oil',
      ),
      EmotionLog(
        id: const Uuid().v4(),
        mood: UserMood.angry,
        confidence: 0.87,
        timestamp: now.subtract(const Duration(hours: 8)),
        rawMessage: 'Robot AI Telemetry: Camera detected elevated frustration/Angry state.',
      ),
    ]);
  }

  void addIntakeReceipt(String medicineName) {
    final receipt = EmotionLog(
      id: const Uuid().v4(),
      mood: UserMood.happy,
      confidence: 0.98,
      timestamp: DateTime.now(),
      rawMessage: 'Robot AI Camera verified intake receipt for $medicineName.',
      isIntakeReceipt: true,
      associatedMedicineName: medicineName,
    );

    _logs.insert(0, receipt);
    notifyListeners();
  }

  void updateLog({
    required String id,
    required UserMood mood,
    String? symptoms,
  }) {
    final index = _logs.indexWhere((l) => l.id == id);
    if (index != -1) {
      _logs[index] = _logs[index].copyWith(
        mood: mood,
        symptoms: symptoms,
      );
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _emotionSub?.cancel();
    super.dispose();
  }
}
