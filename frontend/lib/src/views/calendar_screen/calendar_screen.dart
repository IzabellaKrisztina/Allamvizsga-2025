import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sound_mind/src/models/auth_provider.dart';
import 'package:sound_mind/src/models/registProvider.dart';
import 'package:sound_mind/src/views/home_screen/components/user_navbar.dart';
import 'package:sound_mind/src/views/login_screen/login_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../constants/color_list.dart';
import 'components/xp_bar_chart.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? userXp;
  bool _isLoading = false;
  final baseUrl = dotenv.env['BASE_URL']!;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserXp();
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }

  /// ✅ Extract username from JWT token
  String? _extractUsername(String? token) {
    if (token == null) return null;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload =
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final Map<String, dynamic> decoded = jsonDecode(payload);
      return decoded['sub']; // Extract "sub" field (username)
    } catch (e) {
      print("Error decoding JWT: $e");
      return null;
    }
  }

  /// ✅ Fetch user XP from the API
  Future<void> _fetchUserXp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) return;

    final String? token = authProvider.token;
    final String? username = _extractUsername(token);

    if (username == null) {
      print("Username extraction failed.");
      return;
    }

    final String apiUrl =
        "$baseUrl/users/$username";

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userXp = data['xp'].toString(); // Assuming XP is a number
        });
      } else {
        print("Failed to fetch user XP: ${response.body}");
      }
    } catch (e) {
      print("Error fetching user XP: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final registProvider = Provider.of<RegistProvider>(context);

    const String backgroundColorHex = COLOR_OLIVINE;
    final Color backgroundColor = Color(int.parse('0xFF$backgroundColorHex'));

    const String currentDayHex = COLOR_CHARCOAL;
    final Color currentDayColor = Color(int.parse('0xFF$currentDayHex'));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        title: Text(
          'Calendar Screen',
          style: TextStyle(color: currentDayColor),
        ),
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 25,
          fontFamily: 'Moderustic',
          color: currentDayColor,
        ),
      ),
      backgroundColor: backgroundColor,
      bottomNavigationBar: const UserNavbar(),
      body: authProvider.isAuthenticated || registProvider.isRegistered
          ? _buildCalendar() // ✅ Show calendar if logged in
          : _buildGuestMode(context), // ✅ Show guest message if not logged in
    );
  }

  /// ✅ Calendar UI for authenticated users
  Widget _buildCalendar() {
    const String selectedDayHex = COLOR_DARK_PURPLE;
    final Color selectedDayColor = Color(int.parse('0xFF$selectedDayHex'));

    const String currentDayHex = COLOR_CHARCOAL;
    final Color currentDayColor = Color(int.parse('0xFF$currentDayHex'));

    const String calendarHex = COLOR_ASH_GRAY;
    final Color calendarColor = Color(int.parse('0xFF$calendarHex'));

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: calendarColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: TableCalendar(
              startingDayOfWeek: StartingDayOfWeek.monday,
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              onDaySelected: _onDaySelected,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: selectedDayColor,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: currentDayColor,
                  shape: BoxShape.circle,
                ),
                weekendTextStyle: const TextStyle(color: Colors.red),
                outsideDaysVisible: false,
                defaultTextStyle: TextStyle(color: currentDayColor),
              ),
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: TextStyle(
                  color: currentDayColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                leftChevronIcon:
                    Icon(Icons.chevron_left, color: currentDayColor),
                rightChevronIcon:
                    Icon(Icons.chevron_right, color: currentDayColor),
              ),
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              pageAnimationEnabled: true,
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: _isLoading
                      ? Center(
                          // Ensures it stays centered
                          child: SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : Text(
                          "User's XP for the day: ${userXp ?? 'No XP data'}",
                          style: TextStyle(
                            color: currentDayColor,
                            fontSize: 20,
                          ),
                        ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: calendarColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 2,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: XpBarChart(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// ✅ Guest mode UI when user is not logged in
  Widget _buildGuestMode(BuildContext context) {
    const String textHex = COLOR_CHARCOAL;
    final Color textColor = Color(int.parse('0xFF$textHex'));

    const String backgroundColorHex = COLOR_ASH_GRAY;
    final Color backgroundColor = Color(int.parse('0xFF$backgroundColorHex'));

    return Center(
      child: SizedBox(
        width: double.infinity, // Make the column take full width
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center vertically
          crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
          mainAxisSize: MainAxisSize.min, // Prevent unnecessary space
          children: [
            Text(
              "You're not logged in.\nPlease log in to access your profile.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: textColor, // Button color
                foregroundColor: backgroundColor, // Text color
                elevation: 6, // Shadow effect
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14), // Padding inside button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                ),
                shadowColor: Colors.black45, // Shadow color
              ),
              child: const Text(
                'Go to login screen',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
