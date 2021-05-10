import 'package:flutter/material.dart';
import 'package:otlet/business_logic/utils/constants.dart';
import 'package:otlet/ui/delegates/nav_manager.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
            primaryColor: primaryColor,
            backgroundColor: Colors.grey[200],
            accentColor: secondaryColor),
        home: NavManager());
  }
}
