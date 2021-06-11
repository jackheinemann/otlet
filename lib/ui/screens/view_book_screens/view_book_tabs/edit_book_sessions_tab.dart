import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/book.dart';

import 'package:otlet/business_logic/utils/constants.dart';
import 'package:otlet/ui/widgets/sessions/session_record.dart';

class EditBookSessionsTab extends StatelessWidget {
  final Book book;
  final Function(int) updateSessionBuilderIndex;
  EditBookSessionsTab(this.book, {@required this.updateSessionBuilderIndex});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: book.sessions.length > 0
          ? MainAxisAlignment.start
          : MainAxisAlignment.center,
      children: [
        OutlinedButton(
            onPressed: () => updateSessionBuilderIndex(1),
            child: Text('Create Custom Session',
                style: TextStyle(fontSize: 16, color: primaryColor))),
        book.sessions.length > 0
            ? Expanded(
                child: ListView.builder(
                    itemCount: book.sessions.length,
                    itemBuilder: (context, i) =>
                        SessionRecordCard(book.sessions[i])),
              )
            : Center(
                child: Text('No Sessions Yet', style: TextStyle(fontSize: 18)),
              ),
      ],
    );
  }
}
