import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/book.dart';

class BookSearchResultCard extends StatelessWidget {
  final Book book;
  final Function(Book) selectWork;
  BookSearchResultCard(this.book, {@required this.selectWork});
  @override
  Widget build(BuildContext context) {
    double bookImageWidth = MediaQuery.of(context).size.width * .15;
    return GestureDetector(
      onTap: () => selectWork(book),
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
                          color: Colors.brown,
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
                        Text(book.title ?? 'title error',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 19, fontWeight: FontWeight.bold)),
                        if (book.author != null)
                          Text(book.author,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w400)),
                        // if (book.published != null)
                        //   Text(DateFormat('y').format(book.published),
                        //       style: TextStyle(
                        //           fontSize: 16, fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward)
                ],
              )),
        ),
      ),
    );
  }
}
