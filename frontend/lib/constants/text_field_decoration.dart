import 'package:flutter/material.dart';

import 'color_list.dart';

const String borderHex = COLOR_DARK_PURPLE;
final Color border = Color(int.parse('0xFF$borderHex'));

InputDecoration kTextFieldDecoration({String hintText = 'Enter a value'}) {
  return InputDecoration(
    hintText: hintText,
    contentPadding:
        const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(32.0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: border, width: 1.0),
      borderRadius: const BorderRadius.all(Radius.circular(32.0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: border, width: 2.0),
      borderRadius: const BorderRadius.all(Radius.circular(32.0)),
    ),
  );
}
