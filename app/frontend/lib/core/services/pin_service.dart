import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinService {
  static const String _pinHashKey = 'user_pin_hash';
  final SharedPreferences? prefs;

  PinService({this.prefs});

  Future<SharedPreferences> _getPrefs() async {
    return prefs ?? await SharedPreferences.getInstance();
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> setPin(String pin) async {
    final preferences = await _getPrefs();
    final hashed = _hashPin(pin);
    await preferences.setString(_pinHashKey, hashed);
  }

  Future<String?> getPinHash() async {
    final preferences = await _getPrefs();
    return preferences.getString(_pinHashKey);
  }

  Future<bool> hasPin() async {
    final hash = await getPinHash();
    return hash != null && hash.isNotEmpty;
  }

  Future<bool> verifyPin(String inputPin) async {
    final storedHash = await getPinHash();
    if (storedHash == null) return false;
    final inputHash = _hashPin(inputPin);
    return storedHash == inputHash;
  }

  Future<void> clearPin() async {
    final preferences = await _getPrefs();
    await preferences.remove(_pinHashKey);
  }
}
