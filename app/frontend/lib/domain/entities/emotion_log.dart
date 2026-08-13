import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum UserMood { happy, sad, depressed, angry }

extension UserMoodExtension on UserMood {
  String get label {
    switch (this) {
      case UserMood.happy:
        return 'Happy';
      case UserMood.sad:
        return 'Sad';
      case UserMood.depressed:
        return 'Depressed';
      case UserMood.angry:
        return 'Angry';
    }
  }

  String get emoji {
    switch (this) {
      case UserMood.happy:
        return '😊';
      case UserMood.sad:
        return '😢';
      case UserMood.depressed:
        return '😔';
      case UserMood.angry:
        return '😠';
    }
  }

  IconData get icon {
    switch (this) {
      case UserMood.happy:
        return Icons.sentiment_very_satisfied_rounded;
      case UserMood.sad:
        return Icons.sentiment_dissatisfied_rounded;
      case UserMood.depressed:
        return Icons.sentiment_very_dissatisfied_rounded;
      case UserMood.angry:
        return Icons.mood_bad_rounded;
    }
  }

  Color get color {
    switch (this) {
      case UserMood.happy:
        return AppColors.successEmerald;
      case UserMood.sad:
        return AppColors.accent;
      case UserMood.depressed:
        return AppColors.textSecondaryDark;
      case UserMood.angry:
        return AppColors.vitalRed;
    }
  }
}

class EmotionLog {
  final String id;
  final UserMood mood;
  final double confidence; // e.g. 0.94
  final DateTime timestamp;
  final String rawMessage;
  final bool isIntakeReceipt;
  final String? associatedMedicineName;
  final String? symptoms;

  EmotionLog({
    required this.id,
    required this.mood,
    required this.confidence,
    required this.timestamp,
    required this.rawMessage,
    this.isIntakeReceipt = false,
    this.associatedMedicineName,
    this.symptoms,
  });

  EmotionLog copyWith({
    String? id,
    UserMood? mood,
    double? confidence,
    DateTime? timestamp,
    String? rawMessage,
    bool? isIntakeReceipt,
    String? associatedMedicineName,
    String? symptoms,
  }) {
    return EmotionLog(
      id: id ?? this.id,
      mood: mood ?? this.mood,
      confidence: confidence ?? this.confidence,
      timestamp: timestamp ?? this.timestamp,
      rawMessage: rawMessage ?? this.rawMessage,
      isIntakeReceipt: isIntakeReceipt ?? this.isIntakeReceipt,
      associatedMedicineName: associatedMedicineName ?? this.associatedMedicineName,
      symptoms: symptoms ?? this.symptoms,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mood': mood.name,
      'confidence': confidence,
      'timestamp': timestamp.toIso8601String(),
      'rawMessage': rawMessage,
      'isIntakeReceipt': isIntakeReceipt,
      'associatedMedicineName': associatedMedicineName,
      'symptoms': symptoms,
    };
  }

  factory EmotionLog.fromJson(Map<String, dynamic> json) {
    return EmotionLog(
      id: json['id'] as String,
      mood: UserMood.values.firstWhere(
        (m) => m.name == json['mood'],
        orElse: () => UserMood.happy,
      ),
      confidence: (json['confidence'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      rawMessage: json['rawMessage'] as String,
      isIntakeReceipt: json['isIntakeReceipt'] as bool? ?? false,
      associatedMedicineName: json['associatedMedicineName'] as String?,
      symptoms: json['symptoms'] as String?,
    );
  }
}
