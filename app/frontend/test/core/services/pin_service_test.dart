import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alt1/core/services/pin_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Pure Dart SHA-256 PinService Tests', () {
    late PinService pinService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      pinService = PinService();
    });

    test('hasPin returns false when no PIN hash is set', () async {
      expect(await pinService.hasPin(), isFalse);
      expect(await pinService.getPinHash(), isNull);
    });

    test('setPin hashes 4-digit PIN with SHA-256 and stores under user_pin_hash', () async {
      await pinService.setPin('1234');
      final expectedHash = sha256.convert(utf8.encode('1234')).toString();
      expect(await pinService.getPinHash(), equals(expectedHash));
      expect(await pinService.hasPin(), isTrue);
    });

    test('verifyPin hashes input and compares against stored hash', () async {
      await pinService.setPin('5678');
      expect(await pinService.verifyPin('5678'), isTrue);
      expect(await pinService.verifyPin('0000'), isFalse);
    });

    test('clearPin removes user_pin_hash', () async {
      await pinService.setPin('9999');
      expect(await pinService.hasPin(), isTrue);
      await pinService.clearPin();
      expect(await pinService.hasPin(), isFalse);
    });
  });
}
