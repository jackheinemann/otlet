import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/otlet_instance.dart';
import 'package:otlet/business_logic/models/reading_session.dart';
import 'package:otlet/ui/widgets/books/active_book_card.dart';
import 'package:otlet/ui/widgets/sessions/session_record.dart';
import 'package:otlet/ui/widgets/sessions/session_tracker_card.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<OtletInstance>(
      builder: (context, instance, _) => Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              instance.hasActiveBook()
                  ? ActiveBookCard(instance.activeBook())
                  : Card(
                      elevation: 5,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width * .25 * 1.6,
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                'No Active Book',
                                style: TextStyle(fontSize: 18),
                              ),
                            )),
                      ),
                    ),
              if (instance.hasActiveBook())
                Expanded(
                  child: ListView.builder(
                      itemCount: instance.activeBook().sessions.length,
                      itemBuilder: (context, i) {
                        ReadingSession session =
                            instance.activeBook().sessions.toList()[i];
                        return SessionRecordCard(session);
                      }),
                ),
              if (instance.hasActiveBook()) SessionTrackerCard(instance)
            ],
          ),
        ),
      ),
    );
  }
}
