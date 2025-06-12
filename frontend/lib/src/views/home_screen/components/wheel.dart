import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sound_mind/constants/color_list.dart';
import 'package:sound_mind/src/views/home_screen/components/activity_dropdown.dart';

class WheelController extends ChangeNotifier {
  SharedPreferences? _prefs;

  WheelController() {
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _loadPreferences();
    } catch (e) {
      print('Error initializing SharedPreferences: $e');
    }
  }

  Future<void> _loadPreferences() async {
    if (_prefs == null) return;

    try {
      _progress = _prefs!.getDouble('progress') ?? 0.1;
      _sliderValue1 = _prefs!.getDouble('slider1') ?? 2;
      _sliderValue2 = _prefs!.getDouble('slider2') ?? 50;
      _favoriteArtist = _prefs!.getString('favoriteArtist') ?? '';
      _selectedActivity = _prefs!.getString('selectedActivity');
      notifyListeners();
    } catch (e) {
      print('Error loading preferences: $e');
    }
  }

  double _progress = 0.1;
  double _sliderValue1 = 2;
  double _sliderValue2 = 50;
  List<bool> _checkboxValues = [false, false, false, false];
  String _favoriteArtist = '';
  String? _selectedActivity;

  double get progress => _progress;
  double get sliderValue1 => _sliderValue1;
  double get sliderValue2 => _sliderValue2;
  List<bool> get checkboxValues => _checkboxValues;
  String get favoriteArtist => _favoriteArtist;
  String? get selectedActivity => _selectedActivity;

  Future<void> updateProgress(double value) async {
    _progress = (value / 288).clamp(0.0, 1.0);
    await _saveToSharedPreferences('progress', _progress);
    notifyListeners();
  }

  Future<void> updateSlider1(double value) async {
    _sliderValue1 = value.clamp(0.0, 4.0);
    await _saveToSharedPreferences('slider1', _sliderValue1);
    notifyListeners();
  }

  Future<void> updateSlider2(double value) async {
    _sliderValue2 = value.clamp(0.0, 100.0);
    await _saveToSharedPreferences('slider2', _sliderValue2);
    notifyListeners();
  }

  Future<void> updateCheckbox(int index, bool value) async {
    _checkboxValues[index] = value;
    await _saveToSharedPreferences('checkbox_$index', value);
    notifyListeners();
  }

  Future<void> updateFavoriteArtist(String artist) async {
    _favoriteArtist = artist;
    await _saveToSharedPreferences('favoriteArtist', artist);
    notifyListeners();
  }

  Future<void> updateActivity(String? activity) async {
    _selectedActivity = activity;
    await _saveToSharedPreferences('selectedActivity', activity ?? '');
    notifyListeners();
  }

  // Helper function to save data to SharedPreferences
  Future<void> _saveToSharedPreferences(String key, dynamic value) async {
    if (_prefs == null) return;

    try {
      if (value is double) {
        await _prefs!.setDouble(key, value);
      } else if (value is String) {
        await _prefs!.setString(key, value);
      } else if (value is bool) {
        await _prefs!.setBool(key, value);
      }
    } catch (e) {
      print('Error saving to SharedPreferences: $e');
    }
  }
}

class Wheel extends StatefulWidget {
  final String userXp;

  const Wheel({Key? key, required this.userXp}) : super(key: key);

  @override
  State<Wheel> createState() => _WheelState();
}

class _WheelState extends State<Wheel> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wheelController =
          Provider.of<WheelController>(context, listen: false);
      double xpValue = double.tryParse(widget.userXp) ?? 0;
      double progress = xpValue.clamp(0, 288);
      wheelController.updateProgress(progress); // Set progress in controller
    });
  }

  @override
  Widget build(BuildContext context) {
    const String backgroundColorHex = SPACE_CADET;
    final Color backgroundColor = Color(int.parse('0xFF$backgroundColorHex'));

    const String buttonHex = JORDY_BLUE;
    final Color buttonColor = Color(int.parse('0xFF$buttonHex'));

    const String textColorHex = GHOST_WHITE;
    final Color textColor = Color(int.parse('0xFF$textColorHex'));

    const String secondaryColorHex = OXFORD_BLUE;
    final Color secondaryColor = Color(int.parse('0xFF$secondaryColorHex'));

    return Consumer<WheelController>(
      builder: (context, wheelController, child) {
        return Column(
          children: [
            CircularPercentIndicator(
              radius: 100.0,
              lineWidth: 15.0,
              percent: wheelController.progress,
              circularStrokeCap: CircularStrokeCap.round,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${(wheelController.progress * 288).toStringAsFixed(0)} XP',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              backgroundColor: textColor,
              progressColor: buttonColor,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                children: [
                  Text(
                    "Please select your current mood:",
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 20, color: textColor),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          'assets/images/very_sad.png',
                          width: 40,
                          height: 40,
                        ),
                        Image.asset(
                          'assets/images/little_sad.png',
                          width: 40,
                          height: 40,
                        ),
                        Image.asset(
                          'assets/images/neutral.png',
                          width: 40,
                          height: 40,
                        ),
                        Image.asset(
                          'assets/images/happy.png',
                          width: 40,
                          height: 40,
                        ),
                        Image.asset(
                          'assets/images/excited.png',
                          width: 40,
                          height: 40,
                        ),
                      ],
                    ),
                  ),
                  Slider(
                    value: wheelController.sliderValue1,
                    min: 0,
                    max: 4,
                    divisions: 4,
                    activeColor: buttonColor,
                    inactiveColor: textColor,
                    onChanged: (value) {
                      wheelController.updateSlider1(value.roundToDouble());
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Select Activity",
                    style: TextStyle(fontSize: 20, color: textColor),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      color: backgroundColor,
                      child: ActivitySelection(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // User input for favorite artist
                  Text(
                    "Who are your favorite artists?",
                    style: TextStyle(fontSize: 20, color: textColor),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      onChanged: (artist) {
                        wheelController.updateFavoriteArtist(artist);
                      },
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: "Enter artist's name...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: buttonColor, width: 4.0),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: buttonColor, width: 4.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: buttonColor, width: 4.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: buttonColor, width: 3.0),
                        ),
                        labelStyle: TextStyle(color: buttonColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
