import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:otlet/business_logic/models/reading_session.dart';
import 'package:otlet/business_logic/utils/constants.dart';

class SessionRecordCard extends StatelessWidget {
  final ReadingSession session;

  SessionRecordCard(this.session);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
          // session.tools
          //   .map((e) => e.name + ' ' + e.displayValue())
          //   .toList()
          //   .toString()
          session.pagesRead == null
              ? 'Session on ${monthDayYearFormat.format(session.started)}'
              : '${session.pagesRead} page session on ${monthDayYearFormat.format(session.started)}'),
      subtitle: Text(
          'From ${DateFormat(session.timePassed.inMinutes >= 1 ? 'h:mm aa' : 'h:mm:ss aa').format(session.started)} to ${DateFormat(session.timePassed.inMinutes >= 1 ? 'h:mm aa' : 'h:mm:ss aa').format(session.ended)}'),
      trailing: Text(session.displayTimePassed()),
    );
  }
}
