import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/book.dart';
import 'package:otlet/business_logic/models/otlet_instance.dart';
import 'package:otlet/business_logic/models/reading_session.dart';
import 'package:provider/provider.dart';

class ActiveBookCard extends StatelessWidget {
  final Book book;

  ActiveBookCard(this.book);
  @override
  Widget build(BuildContext context) {
    double bookImageWidth = MediaQuery.of(context).size.width * .3;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () async {},
      child: Card(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: bookImageWidth * 1.6,
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  book.coverUrl != null
                      // ? CachedNetworkImage(
                      //     imageUrl: book.coverUrl,
                      //     width: bookImageWidth,
                      //   )
                      ? book.coverImage(bookImageWidth, bookImageWidth * 1.5)
                      : Container(
                          color: Colors.grey,
                          width: bookImageWidth,
                          height: bookImageWidth * 1.5,
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
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 19, fontWeight: FontWeight.w400)),
                        // if (book.published != null)
                        //   Text(DateFormat('y').format(book.published),
                        //       style: TextStyle(
                        //           fontSize: 19, fontWeight: FontWeight.w400)),
                        if (book.trackProgress &&
                            book.readingProgress() != null)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              children: [
                                Spacer(),
                                Container(
                                  width: MediaQuery.of(context).size.width * .4,
                                  child: LinearProgressIndicator(
                                    value: book.readingProgress(),
                                    backgroundColor:
                                        Theme.of(context).backgroundColor,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context).accentColor),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                    '${(book.readingProgress() * 100).round()}%'),
                              ],
                            ),
                          ),
                        Consumer<OtletInstance>(
                            builder: (context, instance, _) {
                          List<ReadingSession> sessions =
                              instance.sessionsForBook(book: book);
                          return Text(
                              '${sessions?.length ?? 0} session${(sessions?.length ?? 0) == 1 ? '' : 's'} logged',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w400));
                        }),
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
