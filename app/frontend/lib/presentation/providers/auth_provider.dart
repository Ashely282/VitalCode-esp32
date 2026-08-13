import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String _username = '';
  String _email = '';
  String _caregiverContact = '';

  bool get isAuthenticated => _isAuthenticated;
  String get username => _username;
  String get email => _email;
  String get caregiverContact => _caregiverContact;

  Future<bool> login({required String identifier, required String password}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));
    _isAuthenticated = true;
    _username = identifier.contains('@') ? identifier.split('@').first : identifier;
    _email = identifier.contains('@') ? identifier : '$identifier@healthcare.companion';
    _caregiverContact = '+1 (555) 019-2831';
    notifyListeners();
    return true;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String caregiverPhone,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _isAuthenticated = true;
    _username = name;
    _email = email;
    _caregiverContact = caregiverPhone.isNotEmpty ? caregiverPhone : '+1 (555) 019-2831';
    notifyListeners();
    return true;
  }

  void guestLogin() {
    _isAuthenticated = true;
    _username = 'Guest';
    _email = 'guest@healthcare.companion';
    _caregiverContact = 'Not Set';
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _username = '';
    _email = '';
    _caregiverContact = '';
    notifyListeners();
  }
}

