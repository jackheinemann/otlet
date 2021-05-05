import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/book.dart';
import 'package:otlet/business_logic/models/otlet_instance.dart';
import 'package:otlet/business_logic/utils/functions.dart';
import 'package:otlet/ui/widgets/books/otlet_card.dart';
import 'package:provider/provider.dart';

import '../../business_logic/models/book.dart';
import '../../business_logic/utils/constants.dart';

class ViewBooksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<OtletInstance>(builder: (context, instance, _) {
      List<Book> books = List<Book>.from(instance.books);
      books.sort((a, b) => a.title.compareTo(b.title));
      return Scaffold(
        body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: books.length > 0
                ? ListView.builder(
                    itemCount: books.length,
                    itemBuilder: (context, i) {
                      Book book = books[i];
                      return OtletCard(book, instance);
                    })
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('No Tools Here', style: TextStyle(fontSize: 18)),
                        SizedBox(height: 10),
                        ElevatedButton(
                            style:
                                ElevatedButton.styleFrom(primary: primaryColor),
                            onPressed: () async {
                              Book temp = await createNewBook(context);
                              if (temp == null) return;
                              instance.addNewBook(temp);
                            },
                            child: Text('Create New Tool',
                                style: TextStyle(fontSize: 17))),
                      ],
                    ),
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
