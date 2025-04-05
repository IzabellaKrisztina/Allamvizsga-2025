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
    const String boxHex = COLOR_ASH_GRAY;
    final Color boxColor = Color(int.parse('0xFF$boxHex'));

    const String textHex = COLOR_CHARCOAL;
    final Color textColor = Color(int.parse('0xFF$textHex'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Favourite Songs",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 10),
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: boxColor,
            borderRadius: BorderRadius.circular(15),
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
                          color: textColor,
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
