import 'package:flutter/material.dart';

import '../../../business_logic/utils/constants.dart';

class GenreChip extends StatelessWidget {
  final String genre;
  GenreChip(this.genre);
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: primaryColor, width: 1.5)),
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Text(genre,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
        ));
  }
}
