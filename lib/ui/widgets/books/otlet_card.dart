import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:otlet/business_logic/models/book.dart';
import 'package:otlet/ui/screens/view_book_screen.dart';

import '../../../business_logic/models/otlet_instance.dart';

class OtletCard extends StatelessWidget {
  final Book book;
  final OtletInstance instance;

  OtletCard(this.book, this.instance);
  @override
  Widget build(BuildContext context) {
    double bookImageWidth = MediaQuery.of(context).size.width * .25;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () async {
        if (book.compareIds(instance.activeBook()))
          book.isActive = true;
        else
          book.isActive = false;
        print(book.isActive);
        Book temp = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ViewBookScreen(Book.fromBook(book))));
        if (temp == null) return;
        if (temp.compareToBook(book)) return;
        instance.modifyBook(temp);
        instance.saveInstance();
      },
      child: Card(
        elevation: 5,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: bookImageWidth * 1.6,
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  book.coverUrl != null
                      ? CachedNetworkImage(
                          imageUrl: book.coverUrl,
                          width: bookImageWidth,
                        )
                      : Container(
                          color: Colors.grey,
                          width: bookImageWidth,
                          height: bookImageWidth * 1.4,
                          child: Center(
                              child: Text(book.relevantFirstChar(),
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white))),
                        ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(book.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 23, fontWeight: FontWeight.bold)),
                        if (book.author != null)
                          Text(book.author,
                              style: TextStyle(
                                  fontSize: 19, fontWeight: FontWeight.w400)),
                        if (book.published != null)
                          Text(DateFormat('y').format(book.published),
                              style: TextStyle(
                                  fontSize: 19, fontWeight: FontWeight.w400)),
                        if (book.trackProgress &&
                            book.readingProgress() != null)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              children: [
                                Spacer(),
                                Container(
                                  width: MediaQuery.of(context).size.width * .5,
                                  child: LinearProgressIndicator(
                                    value: book.readingProgress(),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                    '${(book.readingProgress() * 100).round()}%'),
                              ],
                            ),
                          )
                      ],
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
