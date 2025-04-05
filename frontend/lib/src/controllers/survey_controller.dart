import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sound_mind/src/models/playlist_provider.dart';
import 'package:sound_mind/src/models/survey_provider.dart';
import 'package:http/http.dart' as http;
import 'package:sound_mind/src/views/home_screen/home_screen.dart';
import 'package:sound_mind/src/views/login_screen/login_screen.dart';

class SurveyController with ChangeNotifier {
  int currentPage = 0;

  final int totalPage;
  final SurveyProvider surveyProvider;

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
    final Map<String, dynamic> answers = surveyProvider.getAllAnswers();
    final Map<String, dynamic> formattedData = {
      "question_answer": answers,
    };

    final String jsonString = jsonEncode(formattedData);

    try {
      final response = await http.post(
        Uri.parse(
            "https://2c67-217-73-170-83.ngrok-free.app/mood/analyze_mood"),
        headers: {
          "Content-Type": "application/json",
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
        builder: (context) => LoginScreen(),
      ),
    );
  }

  // void submitSurvey(BuildContext context) async {
  //   final Map<String, dynamic> answers = surveyProvider.getAllAnswers();
  //   final Map<String, dynamic> formattedData = {
  //     "question_answer": answers,
  //   };

  //   final String jsonString = jsonEncode(formattedData);

  //   try {
  //     final response = await http.post(
  //       Uri.parse(
  //           "https://2c67-217-73-170-83.ngrok-free.app/mood/analyze_mood"),
  //       headers: {
  //         "Content-Type": "application/json",
  //       },
  //       body: jsonString,
  //     );

  //     if (response.statusCode == 200) {
  //       // Successfully received a response

  //       showDialog(
  //         context: context,
  //         builder: (context) {
  //           return AlertDialog(
  //             title: const Text("Success"),
  //             actions: [
  //               TextButton(
  //                 onPressed: () => Navigator.pop(context),
  //                 child: const Text("OK"),
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     } else {
  //       throw Exception("Failed to submit survey: ${response.statusCode}");
  //     }
  //   } catch (error) {
  //     showDialog(
  //       context: context,
  //       builder: (context) {
  //         return AlertDialog(
  //           title: const Text("Error"),
  //           content: Text("Something went wrong: $error"),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.pop(context),
  //               child: const Text("OK"),
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   }

  //   // showDialog(
  //   //   context: context,
  //   //   builder: (context) {
  //   //     return AlertDialog(
  //   //       title: const Text("Survey Data"),
  //   //       content: SingleChildScrollView(child: Text(jsonString)),
  //   //       actions: [
  //   //         TextButton(
  //   //           onPressed: () {
  //   //             Navigator.pop(context);
  //   //           },
  //   //           child: const Text("OK"),
  //   //         ),
  //   //       ],
  //   //     );
  //   //   },
  //   // );
  // }
}
