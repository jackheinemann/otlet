import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/book.dart';
import 'package:otlet/business_logic/models/otlet_instance.dart';
import 'package:otlet/ui/widgets/books/otlet_card.dart';
import 'package:provider/provider.dart';

import '../../business_logic/models/book.dart';
import '../../business_logic/utils/constants.dart';

class ViewBooksScreen extends StatelessWidget {
  final Function(int) updateScreenIndex;

  ViewBooksScreen({@required this.updateScreenIndex});
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
                        Text('No Books Here', style: TextStyle(fontSize: 18)),
                        SizedBox(height: 10),
                        ElevatedButton(
                            style:
                                ElevatedButton.styleFrom(primary: primaryColor),
                            onPressed: () =>
                                updateScreenIndex(ScreenIndex.addBookScreen),
                            child: Text('Add New Book',
                                style: TextStyle(fontSize: 17))),
                      ],
                    ),
                  )),
      );
    });
  }
}
