import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/otlet_instance.dart';
import 'package:otlet/business_logic/services/local_storage_manager.dart';
import 'package:otlet/business_logic/utils/constants.dart';
import 'package:otlet/ui/delegates/tab_manager.dart';

class NavManager extends StatelessWidget {
  final LocalStorageManager localStorageManager = LocalStorageManager();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Object>(
        future: localStorageManager.getLocalInstance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            OtletInstance otletInstance = snapshot.data;
            return TabManager(otletInstance);
          }
          return Scaffold(
            // appBar: AppBar(centerTitle: true),
            // body: Center(
            //   child: Container(
            //     width: MediaQuery.of(context).size.width * .5,
            //     child: LinearProgressIndicator(
            //       backgroundColor: Theme.of(context).backgroundColor,
            //       valueColor: AlwaysStoppedAnimation<Color>(
            //           Theme.of(context).accentColor),
            //     ),
            //   ),
            // ),
            backgroundColor: primaryColor,
            body: Center(
              // color: primaryColor,
              child: Image.asset('assets/launcher/book_logo_launcher.png'),
            ),
          );
        });
  }
}
