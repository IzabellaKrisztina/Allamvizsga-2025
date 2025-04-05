import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlaylistProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _playlists = [];

  List<Map<String, dynamic>> get playlists => _playlists;

  // Set playlists and save to SharedPreferences
  Future<void> setPlaylists(List<Map<String, dynamic>> newPlaylists) async {
    _playlists = newPlaylists;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_playlists', jsonEncode(newPlaylists));
  }

  // Load playlists from SharedPreferences (used on app startup/login)
  Future<void> loadPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString('saved_playlists');

    if (savedData != null) {
      try {
        final List<dynamic> data = jsonDecode(savedData);
        _playlists = data.cast<Map<String, dynamic>>();
        notifyListeners();
      } catch (e) {
        debugPrint("Error loading saved playlists: $e");
      }
    }
  }
}
