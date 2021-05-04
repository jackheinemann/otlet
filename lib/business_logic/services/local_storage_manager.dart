import 'dart:convert';

import 'package:otlet/business_logic/models/otlet_instance.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageManager {
  Future<OtletInstance> getLocalInstance() async {
    OtletInstance otletInstance;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String instanceString = preferences.getString('otlet_instance');
    if (instanceString == null) {
      otletInstance = OtletInstance.empty();
    } else {
      otletInstance = OtletInstance.fromJson(jsonDecode(instanceString));
      print(otletInstance.books);
    }

    otletInstance.preferences = preferences;
    return otletInstance;
  }
}
