import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  const LoginButton(
      {required this.colour,
      required this.textColor,
      required this.title,
      required this.onPress});

  final Color colour;
  final Color textColor;
  final String title;
  final void Function() onPress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        color: colour,
        borderRadius: BorderRadius.circular(30.0),
        elevation: 5.0,
        child: MaterialButton(
          onPressed: () {
            onPress();
          },
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            title,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
