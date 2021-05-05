import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/book.dart';
import 'package:otlet/business_logic/models/otlet_instance.dart';
import 'package:otlet/ui/widgets/books/otlet_card.dart';
import 'package:provider/provider.dart';

class ViewBooksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<OtletInstance>(builder: (context, instance, _) {
      List<Book> books = instance.books;
      return Scaffold(
        body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: books.length > 0
                ? ListView.builder(
                    itemCount: books.length,
                    itemBuilder: (context, i) {
                      Book book = books[i];
                      return OtletCard(book);
                    })
                : Center(
                    child: Text('No Books Here',
                        style: TextStyle(
                            fontSize: 19, fontWeight: FontWeight.w400)),
                  )),
      );
    });
    // return Selector<OtletInstance, List<Book>>(
    //   selector: (context, instance) => instance.books,
    //   builder: (context, books, _) => Scaffold(
    //     body: Padding(
    //         padding: const EdgeInsets.all(8.0),
    //         child: books.length > 0
    //             ? ListView.builder(
    //                 itemCount: books.length,
    //                 itemBuilder: (context, i) {
    //                   Book book = books[i];
    //                   return OtletCard(book);
    //                 })
    //             : Center(
    //                 child: Text('No Books Here',
    //                     style: TextStyle(
    //                         fontSize: 19, fontWeight: FontWeight.w400)),
    //               )),
    //   ),
    // );
  }
}
