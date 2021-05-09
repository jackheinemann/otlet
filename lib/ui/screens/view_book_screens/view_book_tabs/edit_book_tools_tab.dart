import 'package:flutter/material.dart';
import 'package:otlet/ui/widgets/tools/book_tool_card.dart';

import '../../../../business_logic/models/book.dart';
import '../../../../business_logic/utils/constants.dart';

class EditBookToolsTab extends StatefulWidget {
  final Book book;
  final VoidCallback stopEditing;
  final Function(Book) onValueChange;

  EditBookToolsTab(this.book,
      {@required this.stopEditing, @required this.onValueChange});
  @override
  _EditBookToolsTabState createState() => _EditBookToolsTabState();
}

class _EditBookToolsTabState extends State<EditBookToolsTab> {
  Book book;
  List<TextEditingController> valueControllers = [];
  @override
  void initState() {
    super.initState();
    book = widget.book;
    valueControllers = book.tools.map((e) => TextEditingController()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return book.tools.length == 0
        ? Center(
            child: Text('No Tools Created', style: TextStyle(fontSize: 18)),
          )
        : ListView.builder(
            itemCount: book.tools.length,
            itemBuilder: (context, i) {
              ListTile valueEditor = book.tools[i].generateValueInput(
                  context, valueControllers[i], onValueChange: (value) {
                setState(() {
                  book.tools[i].value = value;
                  valueControllers[i].text = book.tools[i].displayValue();
                });
                widget.onValueChange(book);
              });
              return BookToolCard(book.tools[i], valueEditor);
            });
  }
}
