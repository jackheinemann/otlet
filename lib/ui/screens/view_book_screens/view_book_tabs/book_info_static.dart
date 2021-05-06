import 'package:flutter/material.dart';
import 'package:otlet/ui/widgets/books/genre_chip.dart';

import '../../../../business_logic/models/book.dart';
import '../../../../business_logic/utils/constants.dart';

class BookInfoStatic extends StatelessWidget {
  final Book book;
  final Function(bool) updateActive;

  BookInfoStatic(this.book, {@required this.updateActive});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        OutlinedButton(
            onPressed: () {},
            child: Text('Edit Info',
                style: TextStyle(fontSize: 16, color: primaryColor))),
        SizedBox(
          height: 10,
        ),
        ListTile(
          title: Text('Active Book',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              )),
          trailing: Switch(
              activeColor: accentColor,
              value: book.isActive,
              onChanged: (value) {
                updateActive(value);
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
        Text('Genres',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            )),
        SizedBox(
          height: 10,
        ),
        book.genres.isEmpty
            ? Text(
                'No Genres Assigned',
                style: TextStyle(fontSize: 18),
              )
            : Wrap(
                alignment: WrapAlignment.start,
                spacing: 10,
                children: book.genres.map((e) => GenreChip(e)).toList(),
              )
      ],
    );
  }
}
