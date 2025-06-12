import 'dart:convert';
import 'package:sound_mind/src/views/home_screen/components/recording_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sound_mind/constants/color_list.dart';
import 'package:sound_mind/src/models/auth_provider.dart';
import 'package:sound_mind/src/models/track_provider.dart';
import 'package:sound_mind/src/views/home_screen/components/user_navbar.dart';
import 'package:sound_mind/src/views/home_screen/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../generated_playlist_screen/generated_playlist.dart';
import 'components/wheel.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userXp;
  bool _isLoading = false;
  final baseUrl = dotenv.env['BASE_URL']!;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserXp();
    });
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

    final String apiUrl = "$baseUrl/users/$username";

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
    const String backgroundColorHex = SPACE_CADET;
    final Color backgroundColor = Color(int.parse('0xFF$backgroundColorHex'));

    const String buttonHex = JORDY_BLUE;
    final Color buttonColor = Color(int.parse('0xFF$buttonHex'));

    const String textColorHex = GHOST_WHITE;
    final Color textColor = Color(int.parse('0xFF$textColorHex'));

    const String secondaryColorHex = OXFORD_BLUE;
    final Color secondaryColor = Color(int.parse('0xFF$secondaryColorHex'));

    final trackProvider = Provider.of<TrackProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Home"),
        titleTextStyle: TextStyle(
          fontSize: 25,
          fontFamily: 'Moderustic',
          color: textColor,
        ),
        centerTitle: true,
        backgroundColor: backgroundColor,
      ),
      backgroundColor: backgroundColor,
      bottomNavigationBar: const UserNavbar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Center(
                child: Text(
                  "Welcome to the Home Screen!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ✅ Pass XP to Wheel widget
              Container(
                child: _isLoading
                    ? Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : Wheel(userXp: userXp ?? "0"), // Pass XP here
              ),

              const SizedBox(height: 10),
              // ✅ "Generate New Playlist" Button
              Padding(
                padding: EdgeInsets.all(1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        print('Generate New Playlist pressed');
                        try {
                          final prefs = await SharedPreferencesService.instance;
                          final slider1 = prefs.getDouble('slider1')?.toInt() ??
                              2; // Default to 2 (NEUTRAL)
                          final favoriteArtist =
                              prefs.getString('favoriteArtist') ??
                                  'Unknown Artist';
                          final selectedActivity =
                              prefs.getString('selectedActivity') ??
                                  'Unknown Activity';

                          // Log the retrieved values for debugging
                          print(
                              'Slider1: $slider1, Artist: $favoriteArtist, Activity: $selectedActivity');

                          String mood;
                          switch (slider1) {
                            case 0:
                              mood = 'ANGRY';
                              break;
                            case 1:
                              mood = 'SAD';
                              break;
                            case 2:
                              mood = 'NEUTRAL';
                              break;
                            case 3:
                              mood = 'HAPPY';
                              break;
                            case 4:
                              mood = 'EXCITED';
                              break;
                            default:
                              mood = 'NEUTRAL';
                          }

                          // Create a JSON object
                          final Map<String, dynamic> jsonData = {
                            'mood': mood,
                            'artist': favoriteArtist,
                            'activity': selectedActivity,
                          };
                          final String jsonString = jsonEncode(jsonData);
                          print('JSON Data: $jsonString');

                          try {
                            final response = await http.post(
                              Uri.parse("$baseUrl/mood/suggest_songs"),
                              headers: {
                                "Content-Type": "application/json",
                              },
                              body: jsonString,
                            );

                            if (response.statusCode == 200) {
                              final Map<String, dynamic> responseData =
                                  jsonDecode(response.body);

                              // Extract playlists from the "playlists" key
                              if (responseData.containsKey("songs") &&
                                  responseData["songs"] is List) {
                                final List<dynamic> playlistsData =
                                    responseData["songs"];

                                // Save the response to the provider
                                final trackProvider =
                                    Provider.of<TrackProvider>(context,
                                        listen: false);
                                trackProvider.setTracks(
                                    playlistsData.cast<Map<String, dynamic>>());

                                debugPrint("Tracks saved successfully");
                              } else {
                                throw Exception(
                                    "Invalid response format: 'playlists' key not found");
                              }
                            } else {
                              throw Exception("Failed to send data");
                            }
                          } catch (error) {
                            debugPrint("Error submitting data: $error");
                          }

                          if (!context.mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GeneratedPlaylist()),
                          );
                        } catch (e) {
                          print('Error accessing SharedPreferences: $e');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor: buttonColor,
                      ),
                      child: Text(
                        'Generate New Playlist',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    //const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => RecordingDialog(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        // padding:
                        //     EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        padding: EdgeInsets.all(15),
                        shape: CircleBorder(),
                        backgroundColor: buttonColor,
                      ),
                      child: Icon(
                        Icons.mic, // Use the microphone icon
                        size: 27,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
