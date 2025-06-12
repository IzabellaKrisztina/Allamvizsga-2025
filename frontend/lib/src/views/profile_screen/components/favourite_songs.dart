import 'package:flutter/material.dart';

import '../../../../constants/color_list.dart';

class FavouriteSongs extends StatelessWidget {
  final List<String> songs = [
    //TODO: ADD FAVE SONGS FROM DB
    "Song 1",
    "Song 2",
    "Song 3",
    "Song 4",
  ];

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

    const String accentColorHex = ROSY_BROWN;
    final Color accentColor = Color(int.parse('0xFF$accentColorHex'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Favourite Songs",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: buttonColor),
        ),
        const SizedBox(height: 10),
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.transparent.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: secondaryColor.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 2,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Column(
                children: songs
                    .map(
                      (song) => ListTile(
                        leading: Icon(
                          Icons.music_note,
                          color: buttonColor,
                        ),
                        title: Text(
                          song,
                          style: TextStyle(color: textColor),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
