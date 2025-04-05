import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sound_mind/src/controllers/survey_controller.dart';
import 'package:sound_mind/src/models/survey_provider.dart';
import 'package:sound_mind/src/views/survey_screen/components/survey_template.dart';
import 'package:sound_mind/src/views/survey_screen/components/survey_content.dart';

class SurveyScreen extends StatefulWidget {
  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  @override
  Widget build(BuildContext context) {
    final surveyProvider = Provider.of<SurveyProvider>(context, listen: false);

    return ChangeNotifierProvider(
      create: (context) => SurveyController(10, surveyProvider),
      child: Consumer<SurveyController>(
        builder: (context, controller, child) {
          final List<String> questions = [
            "What's your go-to genre when you're feeling happy?",
            "What type of music do you listen to when you're feeling down or stressed?",
            "Which song or artist do you never get tired of?",
            "Do you prefer lyrics or instrumentals?",
            "Do you enjoy upbeat, energetic music or more chill, relaxed tunes?",
            "Is there a specific song or album that perfectly matches your current mood?",
            "Do your music preferences change depending on the time of day? (e.g., morning vs. night)",
            "Do you associate certain songs with specific memories or emotions?",
            "How often do you discover new music versus sticking to your favorites?",
            "Would you say your music taste leans more mainstream or alternative/indie?",
          ];

          return SurveyTemplate(
            title: questions[controller.currentPage],
            content: SurveyContent(question: questions[controller.currentPage]),
            currentPage: controller.currentPage,
            totalPage: questions.length,
            controller: controller,
          );
        },
      ),
    );
  }
}
