import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/otlet_instance.dart';
import 'package:otlet/business_logic/models/reading_session.dart';
import 'package:provider/provider.dart';

import '../../../../business_logic/models/book.dart';
import '../../../widgets/sessions/session_record.dart';

class BookSessionsTab extends StatelessWidget {
  final Book book;
  BookSessionsTab(this.book);
  @override
  Widget build(BuildContext context) {
    return Consumer<OtletInstance>(builder: (context, instance, _) {
      List<ReadingSession> sessions = instance.sessionsForBook(book: book);
      return sessions.length > 0
          ? ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, i) => SessionRecordCard(sessions[i]))
          : Center(
              child: Text('No Sessions Yet', style: TextStyle(fontSize: 18)),
            );
    });
  }
}
