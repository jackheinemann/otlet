import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/book.dart';
import 'package:otlet/business_logic/services/open_library_service.dart';
import 'package:otlet/ui/widgets/alerts/error_dialog.dart';
import 'package:otlet/ui/widgets/books/book_edition_result_card.dart';

class ViewBookEditionsScreen extends StatefulWidget {
  final Book book;
  final Function(Book) selectEdition;

  ViewBookEditionsScreen(this.book, {@required this.selectEdition});
  @override
  _ViewBookEditionsScreenState createState() => _ViewBookEditionsScreenState();
}

class _ViewBookEditionsScreenState extends State<ViewBookEditionsScreen> {
  Book book;

  OpenLibraryService libraryService;
  List<Book> editions = [];
  AsyncMemoizer memoizer;

  @override
  void initState() {
    super.initState();
    book = widget.book;
    libraryService = OpenLibraryService();
    memoizer = AsyncMemoizer();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<dynamic>(
      stream: libraryService.getEditionsForBook(book, memoizer),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          showErrorDialog(
              context, 'Error retrieving editions, please try again.');
          return Scaffold(
            body: Center(
              child: ElevatedButton(
                  onPressed: () {
                    setState(() {});
                  },
                  child: Text('Reload')),
            ),
          );
        }
        if (snapshot.hasData) {
          editions = List<Book>.from(snapshot.data);
          return Scaffold(
            appBar: AppBar(centerTitle: true, title: Text('Editions')),
            body: ListView.builder(
                itemCount: editions.length,
                itemBuilder: (context, i) => BookEditionResultCard(
                      editions[i],
                      selectBook: () {
                        widget.selectEdition(editions[i]);
                      },
                    )),
          );
        }
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
