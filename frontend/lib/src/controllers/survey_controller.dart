import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sound_mind/src/models/playlist_provider.dart';
import 'package:sound_mind/src/models/survey_provider.dart';
import 'package:http/http.dart' as http;
import 'package:sound_mind/src/views/home_screen/home_screen.dart';
import 'package:sound_mind/src/views/login_screen/login_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sound_mind/src/models/auth_provider.dart';

class SurveyController with ChangeNotifier {
  int currentPage = 0;
  final int totalPage;
  final SurveyProvider surveyProvider;
  final baseUrl = dotenv.env['BASE_URL']!;
  SurveyController(this.totalPage, this.surveyProvider);

  void nextPage() {
    if (currentPage < totalPage - 1) {
      currentPage++;
      notifyListeners();
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      currentPage--;
      notifyListeners();
    }
  }

  void saveAnswer(String question, String answer) {
    surveyProvider.saveAnswer(question, answer);
    notifyListeners();
  }

  String? getAnswer(String question) => surveyProvider.getAnswer(question);

  void submitSurvey(BuildContext context) async {
    // final token = Provider.of<AuthProvider>(context, listen: false).token;

    final Map<String, dynamic> answers = surveyProvider.getAllAnswers();
    final Map<String, dynamic> formattedData = {
      "question_answer": answers,
    };

    final String jsonString = jsonEncode(formattedData);

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/mood/analyze_mood"),
        headers: {
          "Content-Type": "application/json",
          // "Authorization": "Bearer $token",
        },
        body: jsonString,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Extract playlists from the "playlists" key
        if (responseData.containsKey("playlists") &&
            responseData["playlists"] is List) {
          final List<dynamic> playlistsData = responseData["playlists"];

          // Save the response to the provider
          final playlistProvider =
              Provider.of<PlaylistProvider>(context, listen: false);
          playlistProvider
              .setPlaylists(playlistsData.cast<Map<String, dynamic>>());

          debugPrint("Playlists saved successfully");
        } else {
          throw Exception("Invalid response format: 'playlists' key not found");
        }
      } else {
        throw Exception("Failed to submit survey");
      }
    } catch (error) {
      debugPrint("Error submitting survey: $error");
    }

    // Navigate to home screen after submission
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HomeScreen(),
      ),
    );
  }
}
