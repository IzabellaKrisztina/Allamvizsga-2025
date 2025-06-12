import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sound_mind/constants/color_list.dart';
import 'package:sound_mind/src/models/auth_provider.dart';
import 'package:sound_mind/src/models/registProvider.dart';
import 'package:sound_mind/src/views/home_screen/components/user_navbar.dart';
import 'package:sound_mind/src/views/login_screen/components/login_button.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:sound_mind/src/views/login_screen/login_screen.dart';
import 'package:sound_mind/src/views/survey_screen/survey_screen.dart';
import 'components/favourite_songs.dart';
import 'components/playlists.dart';
import 'components/profile_picture.dart';
import 'components/user_info.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context); // Access
    final registProvider = Provider.of<RegistProvider>(context);
    final username = _extractUsername(authProvider.token);

    const String backgroundColorHex = SPACE_CADET;
    final Color backgroundColor = Color(int.parse('0xFF$backgroundColorHex'));

    const String buttonHex = JORDY_BLUE;
    final Color buttonColor = Color(int.parse('0xFF$buttonHex'));

    const String textColorHex = GHOST_WHITE;
    final Color textColor = Color(int.parse('0xFF$textColorHex'));

    const String secondaryColorHex = OXFORD_BLUE;
    final Color secondaryColor = Color(int.parse('0xFF$secondaryColorHex'));

    const String accentColorHex = ROSY_BROWN;
    final Color accentColor = Color(int.parse('0xFF$accentColorHex'));

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Profile",
          style: TextStyle(color: textColor),
        ),
        titleTextStyle: TextStyle(
          fontSize: 25,
          fontFamily: 'Moderustic',
          color: textColor,
        ),
        centerTitle: true,
        backgroundColor: backgroundColor,
        actions: authProvider.isAuthenticated || registProvider.isRegistered
            ? [
                // Show exit button only if logged in
                IconButton(
                  icon: Icon(Icons.exit_to_app, color: accentColor, size: 30),
                  onPressed: () {
                    authProvider.logout();
                    registProvider.setRegistered(false);
                    // Navigate back to login screen after logout
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                ),
              ]
            : [],
      ),

      bottomNavigationBar: const UserNavbar(),
      body: authProvider.isAuthenticated || registProvider.isRegistered
          ? _buildUserProfile(username) // ✅ Show profile if logged in
          : _buildGuestMode(context), // ✅ Show guest message if not logged in
    );
  }

  /// ✅ Profile UI for authenticated users
  Widget _buildUserProfile(String? username) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ProfilePicture(
              name:
                  username ?? "Unknown User"), // Profile image with edit option
          const SizedBox(height: 20),
          UserInfo(name: username ?? "Unknown User"), // User info
          const SizedBox(height: 40),
          FavouriteSongs(), // Favorite songs list
          const SizedBox(height: 20),
          Playlists(), // User playlists
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// ✅ Guest mode UI when user is not logged in
  Widget _buildGuestMode(BuildContext context) {
    const String backgroundColorHex = SPACE_CADET;
    final Color backgroundColor = Color(int.parse('0xFF$backgroundColorHex'));

    const String buttonHex = JORDY_BLUE;
    final Color buttonColor = Color(int.parse('0xFF$buttonHex'));

    const String textColorHex = GHOST_WHITE;
    final Color textColor = Color(int.parse('0xFF$textColorHex'));

    const String secondaryColorHex = OXFORD_BLUE;
    final Color secondaryColor = Color(int.parse('0xFF$secondaryColorHex'));

    const String accentColorHex = ROSY_BROWN;
    final Color accentColor = Color(int.parse('0xFF$accentColorHex'));

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
                backgroundColor: buttonColor, // Button color
                foregroundColor: buttonColor, // Text color
                elevation: 6, // Shadow effect
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14), // Padding inside button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                ),
                shadowColor: Colors.black45, // Shadow color
              ),
              child: Text(
                'Go to login screen',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
