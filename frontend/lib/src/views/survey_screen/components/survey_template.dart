import 'package:flutter/material.dart';
import 'package:sound_mind/constants/color_list.dart';
import 'package:sound_mind/src/controllers/survey_controller.dart';
import 'package:sound_mind/src/views/home_screen/home_screen.dart';

class SurveyTemplate extends StatelessWidget {
  final String title;
  final Widget content;
  final int currentPage;
  final int totalPage;
  final SurveyController controller;

  const SurveyTemplate({
    Key? key,
    required this.title,
    required this.content,
    required this.currentPage,
    required this.totalPage,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const String backgroundColorHex = SPACE_CADET;
    final Color backgroundColor = Color(int.parse('0xFF$backgroundColorHex'));

    const String buttonHex = JORDY_BLUE;
    final Color buttonColor = Color(int.parse('0xFF$buttonHex'));

    const String textHex = GHOST_WHITE;
    final Color textColor = Color(int.parse('0xFF$textHex'));

    const String secondaryColorHex = OXFORD_BLUE;
    final Color secondaryColor = Color(int.parse('0xFF$secondaryColorHex'));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
              onPressed: () {
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              child: Row(
                children: [
                  Text(
                    "Skip",
                    style: TextStyle(
                        color: buttonColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.arrow_forward, color: buttonColor, size: 25),
                ],
              )),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: Center(child: content),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: currentPage > 0 ? controller.previousPage : null,
                  child: Text('Back',
                      style: TextStyle(color: textColor, fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                  ),
                ),
                ElevatedButton(
                  onPressed: currentPage < totalPage - 1
                      ? controller.nextPage
                      : () => controller.submitSurvey(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                  ),
                  child: Text(currentPage < totalPage - 1 ? 'Next' : 'Submit',
                      style: TextStyle(color: secondaryColor, fontSize: 20)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
