import 'package:flutter/material.dart';
import 'package:otlet/ui/widgets/tools/book_tool_card.dart';

import '../../../business_logic/models/book.dart';

class BookToolsTab extends StatelessWidget {
  final Book book;
  final Function(Book) updateBook;
  BookToolsTab(this.book, {@required this.updateBook});
  @override
  Widget build(BuildContext context) {
    return book.tools.length > 0
        ? ListView.builder(
            itemCount: book.tools.length,
            itemBuilder: (context, i) =>
                BookToolCard(book.tools[i], updateBookTool: (modifiedTool) {
                  book.tools[i] = modifiedTool;
                  updateBook(book);
                }))
        : Center(
            child: Text('No Tools Yet', style: TextStyle(fontSize: 18)),
          );
  }
}
