import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider with ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? _token;

  String? get token => _token;

  bool get isAuthenticated => _token != null;

  AuthProvider() {
    _loadToken(); // Load token when AuthProvider is initialized
  }

  Future<void> _loadToken() async {
    _token = await _secureStorage.read(key: 'auth_token');
    notifyListeners(); // Update UI when token changes
  }

  Future<void> login(String token) async {
    _token = token;
    await _secureStorage.write(key: 'auth_token', value: token);
    notifyListeners(); // Notify UI about the change
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'auth_token');
    _token = null;
    notifyListeners();
  }
}

