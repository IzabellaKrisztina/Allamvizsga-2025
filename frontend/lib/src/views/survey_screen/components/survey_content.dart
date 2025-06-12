import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sound_mind/constants/color_list.dart';
import 'package:sound_mind/src/controllers/survey_controller.dart';

class SurveyContent extends StatefulWidget {
  final String question;

  const SurveyContent({Key? key, required this.question}) : super(key: key);

  @override
  State<SurveyContent> createState() => _SurveyContentState();
}

class _SurveyContentState extends State<SurveyContent> {
  late FocusNode _focusNode;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surveyController = Provider.of<SurveyController>(context);

    const String buttonHex = JORDY_BLUE;
    final Color buttonColor = Color(int.parse('0xFF$buttonHex'));

    const String textHex = GHOST_WHITE;
    final Color textColor = Color(int.parse('0xFF$textHex'));

    const String secondaryColorHex = OXFORD_BLUE;
    final Color secondaryColor = Color(int.parse('0xFF$secondaryColorHex'));

    _textController.text = surveyController.getAnswer(widget.question) ?? '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          widget.question,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: textColor, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: 300,
          child: TextFormField(
            controller: _textController,
            focusNode: _focusNode,
            keyboardType: TextInputType.text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: textColor,
            ),
            decoration: InputDecoration(
              labelText: 'Enter your answer...',
              labelStyle: TextStyle(
                color: buttonColor,
                fontSize: 18,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: buttonColor,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: buttonColor,
                  width: 2,
                ),
              ),
            ),
            onChanged: (value) {
              surveyController.saveAnswer(widget.question, value);
            },
          ),
        ),
      ],
    );
  }
}
