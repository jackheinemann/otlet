import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:otlet/business_logic/models/goal.dart';

const List<String> litGenres = [
  'Drama',
  'Fable',
  'Fairy Tale',
  'Fantasy',
  'Fiction',
  'Fiction in Verse',
  'Folklore',
  'Historical Fiction',
  'Horror',
  'Humor',
  'Legend',
  'Mystery',
  'Mythology',
  'Poetry',
  'Realistic Fiction',
  'Science Fiction',
  'Short Story',
  'Tall Tale',
  'Biography',
  'Autobiography',
  'Essay',
  'Narrative Nonfiction',
  'History',
  'Nonfiction',
  'Speech'
];

Color primaryColor = Color(0xFF373F51);
Color secondaryColor = Color(0xFF58A4B0);
Color accentColor = Color(0xFFDAA49A);

DateFormat monthDayYearFormat = DateFormat('MMMM d, y');

Map<Unit, String> unitDisplays = Map.fromIterables(Unit.values,
    Unit.values.map((e) => e.toString().replaceAll('Unit.', '')).toList());
