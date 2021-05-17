import 'package:flutter/material.dart';
import 'package:otlet/ui/widgets/books/genre_chip.dart';

import '../../../../business_logic/models/book.dart';
import '../../../../business_logic/utils/constants.dart';

class BookInfoStatic extends StatelessWidget {
  final Book book;
  final Function(bool) updateActive;
  final Function(bool) updateTrackProgress;

  BookInfoStatic(this.book,
      {@required this.updateActive, @required this.updateTrackProgress});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 10,
          ),
          ListTile(
            title: Text('Active Book',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                )),
            trailing: Checkbox(
                activeColor: accentColor,
                value: book.isActive,
                onChanged: (value) {
                  updateActive(value);
                }),
          ),
          ListTile(
            title: Text('Track Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                )),
            trailing: Checkbox(
                activeColor: accentColor,
                value: book.trackProgress,
                onChanged: (value) {
                  updateTrackProgress(value);
                }),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'Started',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text('Finished',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  )),
            ],
          ),
          SizedBox(
            height: 4,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                book.started == null
                    ? 'Not Started'
                    : monthDayYearFormat.format(book.started),
                style: TextStyle(fontSize: 18),
              ),
              Text(
                  book.finished == null
                      ? 'Not Finished'
                      : monthDayYearFormat.format(book.finished),
                  style: TextStyle(
                    fontSize: 18,
                  )),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Text('Genre',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              )),
          SizedBox(
            height: 10,
          ),
          book.genre == null
              ? Text(
                  'No Genre Assigned',
                  style: TextStyle(fontSize: 18),
                )
              : Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 10,
                  children: [GenreChip(book.genre)],
                )
        ],
      ),
    );
  }
}
