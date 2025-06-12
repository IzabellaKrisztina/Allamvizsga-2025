import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sound_mind/src/views/login_screen/login_screen.dart';

Row RegisterFooter(BuildContext context, Color buttonColor, Color textColor) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        'Already have an account?',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
      SizedBox(
        width: 10,
      ),
      GestureDetector(
        onTap: () async {
          await Future.delayed(Duration(seconds: 2));
          if (!context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        },
        child: Text(
          'Try to log in!',
          style: TextStyle(
            color: buttonColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  );
}
