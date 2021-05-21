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

List<String> chartColorCodes = [
  '3366cc',
  'dc3912',
  'ff9900',
  '109618',
  '990099',
  '0099c6',
  'dd4477',
  '66aa00',
  'b82e2e',
  '316395',
  '994499',
  '22aa99',
  'aaaa11',
  '6633cc',
  'e67300',
  '8b0707',
  '651067',
  '329262',
  '5574a6',
  '3b3eac',
  'b77322',
  '16d620',
  'b91383',
  'f4359e',
  '9c5935',
  'a9c413',
  '2a778d',
  '668d1c',
  'bea413',
  '0c5922',
  '743411',
].map((e) => '#$e').toList();

DateFormat monthDayYearFormat = DateFormat('MMMM d, y');

Map<Unit, String> unitDisplays = Map.fromIterables(Unit.values,
    Unit.values.map((e) => e.toString().replaceAll('Unit.', '')).toList());
