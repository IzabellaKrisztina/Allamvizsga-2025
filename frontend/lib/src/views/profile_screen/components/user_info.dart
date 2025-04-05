import 'package:flutter/material.dart';
import 'package:sound_mind/constants/color_list.dart';

class UserInfo extends StatelessWidget {
  final String name;

  const UserInfo({required this.name});

  @override
  Widget build(BuildContext context) {
    const String textHex = COLOR_CHARCOAL;
    final Color textColor = Color(int.parse('0xFF$textHex'));
    return Column(
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
