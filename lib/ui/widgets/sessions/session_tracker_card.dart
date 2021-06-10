import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/otlet_instance.dart';
import 'package:otlet/business_logic/models/reading_session.dart';
import 'package:otlet/business_logic/utils/constants.dart';
import 'package:otlet/ui/widgets/alerts/input_dialog.dart';

class SessionTrackerCard extends StatelessWidget {
  final OtletInstance instance;
  SessionTrackerCard(this.instance);
  @override
  Widget build(BuildContext context) {
    ReadingSession session = instance.activeSession;
    return Card(
      elevation: 2,
      child: Container(
        height: MediaQuery.of(context).size.height * .1,
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: instance.hasActiveSession()
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 20,
                      ),
                      Text(session.displayTimePassed(),
                          style: TextStyle(fontSize: 16)),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          instance.updateSession(!session.isReading);
                        },
                        child: CircleAvatar(
                          backgroundColor: primaryColor,
                          child: Icon(
                              session.isReading
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.white),
                        ),
                      ),
                      SizedBox(
                        width: 40,
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (session.timePassed.inSeconds >= 1) {
                            instance.updateSession(false);
                            String currentPageString = await showInputDialog(
                                    context, 'Enter current page?',
                                    initialValue: instance
                                        .activeBook()
                                        .currentPage
                                        ?.toString(),
                                    labelText: 'Enter a number',
                                    submitText: 'Save') ??
                                'null';
                            int currentPage = int.tryParse(currentPageString);
                            if (currentPage != null) {
                              session.pagesRead = currentPage -
                                      instance.activeBook()?.currentPage ??
                                  0;
                              instance.books[instance.activeBookIndex]
                                  .currentPage = currentPage;
                            }
                          }
                          instance.endSession();
                          instance.saveInstance();
                        },
                        child: CircleAvatar(
                          backgroundColor: primaryColor,
                          child: Icon(
                              session.timePassed.inSeconds >= 1
                                  ? Icons.save
                                  : Icons.close,
                              color: Colors.white),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  )
                : GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      instance.startSession();
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * .1,
                      child: Center(
                        child:
                            Text('New Session', style: TextStyle(fontSize: 19)),
                      ),
                    ),
                  )),
      ),
    );
  }
}
