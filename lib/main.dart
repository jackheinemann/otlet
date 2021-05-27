import 'package:flutter/material.dart';
import 'package:otlet/business_logic/utils/constants.dart';
import 'package:otlet/ui/delegates/nav_manager.dart';

void main() {
  // if (defaultTargetPlatform == TargetPlatform.android) {
  //   InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
  // }
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
            backgroundColor: secondaryColor,
            accentColor: accentColor,
            appBarTheme: AppBarTheme(brightness: Brightness.dark),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
                selectedIconTheme: IconThemeData(color: primaryColor),
                selectedItemColor: primaryColor,
                selectedLabelStyle: TextStyle(color: primaryColor))),
        home: NavManager());
  }
}
