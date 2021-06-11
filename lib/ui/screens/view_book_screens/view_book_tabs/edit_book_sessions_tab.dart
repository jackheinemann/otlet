import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/book.dart';
import 'package:otlet/business_logic/models/otlet_instance.dart';
import 'package:otlet/business_logic/models/reading_session.dart';

import 'package:otlet/business_logic/utils/constants.dart';
import 'package:otlet/ui/widgets/sessions/session_record.dart';
import 'package:provider/provider.dart';

class EditBookSessionsTab extends StatelessWidget {
  final Book book;
  final Function(int, {ReadingSession session}) updateSessionBuilderIndex;
  EditBookSessionsTab(this.book, {@required this.updateSessionBuilderIndex});
  @override
  Widget build(BuildContext context) {
    return Consumer<OtletInstance>(builder: (context, instance, _) {
      List<ReadingSession> sessions = instance.sessionsForBook(book: book);
      return Column(
        mainAxisAlignment: sessions.length > 0
            ? MainAxisAlignment.start
            : MainAxisAlignment.center,
        children: [
          OutlinedButton(
              onPressed: () => updateSessionBuilderIndex(1),
              child: Text('Create Custom Session',
                  style: TextStyle(fontSize: 16, color: primaryColor))),
          sessions.length > 0
              ? Expanded(
                  child: ListView.builder(
                      itemCount: sessions.length,
                      itemBuilder: (context, i) => GestureDetector(
                          onTap: () => updateSessionBuilderIndex(1,
                              session: sessions[i]),
                          child: SessionRecordCard(sessions[i]))),
                )
              : Center(
                  child:
                      Text('No Sessions Yet', style: TextStyle(fontSize: 18)),
                ),
        ],
      );
    });
  }
}
