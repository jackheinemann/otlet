import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/otlet_instance.dart';
import 'package:otlet/business_logic/models/reading_session.dart';
import 'package:otlet/business_logic/utils/constants.dart';
import 'package:otlet/ui/widgets/sessions/session_record.dart';

class ViewSessionsScreen extends StatelessWidget {
  final OtletInstance instance;
  final Function(int, {ReadingSession session}) updateScreenIndex;

  ViewSessionsScreen(this.instance, {@required this.updateScreenIndex});
  @override
  Widget build(BuildContext context) {
    return instance.sessionHistory.length > 0
        ? ListView.builder(
            itemCount: instance.sessionHistory.length,
            itemBuilder: (context, i) => GestureDetector(
                onTap: () => updateScreenIndex(ScreenIndex.addEditSessionScreen,
                    session: instance.sessionHistory[i]),
                child: SessionRecordCard(instance.sessionHistory[i])))
        : Center(
            child: Text('No Sessions Yet', style: TextStyle(fontSize: 18)),
          );
  }
}
