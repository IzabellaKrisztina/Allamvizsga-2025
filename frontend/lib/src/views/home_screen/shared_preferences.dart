import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get instance async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }
}
