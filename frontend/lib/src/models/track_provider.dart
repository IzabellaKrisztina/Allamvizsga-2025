import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrackProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _tracks = [];

  List<Map<String, dynamic>> get tracks => _tracks;

  Future<void> setTracks(List<Map<String, dynamic>> newTracks) async {
    _tracks = newTracks;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_tracks', jsonEncode(newTracks));
  }

  Future<void> loadTracks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString('saved_tracks');

    if (savedData != null) {
      try {
        final List<dynamic> data = jsonDecode(savedData);
        _tracks = data.cast<Map<String, dynamic>>();
        notifyListeners();
      } catch (e) {
        debugPrint("Error loading saved tracks: $e");
      }
    }
  }
}
