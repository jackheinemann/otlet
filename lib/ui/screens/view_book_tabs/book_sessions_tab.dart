import 'package:flutter/material.dart';

import '../../../business_logic/models/book.dart';
import '../../widgets/sessions/session_record.dart';

class BookSessionsTab extends StatelessWidget {
  final Book book;
  BookSessionsTab(this.book);
  @override
  Widget build(BuildContext context) {
    return book.sessions.length > 0
        ? ListView.builder(
            itemCount: book.sessions.length,
            itemBuilder: (context, i) => SessionRecordCard(book.sessions[i]))
        : Center(
            child: Text('No Sessions Yet', style: TextStyle(fontSize: 18)),
          );
  }
}
