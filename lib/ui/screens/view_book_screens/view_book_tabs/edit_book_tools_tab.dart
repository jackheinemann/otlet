import 'package:flutter/material.dart';
import 'package:otlet/ui/widgets/tools/book_tool_card.dart';

import '../../../../business_logic/models/book.dart';

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
  List<FocusNode> focusNodes = [];
  @override
  void initState() {
    super.initState();
    book = widget.book;
    valueControllers = book.tools.map((e) {
      TextEditingController controller = TextEditingController();
      controller.text = e.displayValue();
      return controller;
    }).toList();
    for (int i = 0; i < book.tools.length; i++) {
      FocusNode focusNode = FocusNode();
      focusNode.addListener(() {
        if (!focusNode.hasFocus) {
          // means we just lost focus, keep checking
          if (book.tools[i].displayValue() != valueControllers[i].text.trim()) {
            // means the value in the tool and its formfield are different
            setState(() {
              book.tools[i]
                  .assignValueFromString(valueControllers[i].text.trim());
            });
            widget.onValueChange(book);
          }
        }
      });
      focusNodes.add(focusNode);
    }
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
              ListTile valueEditor = ListTile(
                  title: book.tools[i].generateValueInput(
                      context, valueControllers[i], focusNodes[i],
                      onValueChange: (value) {
                print('value $value is a ${value.runtimeType}');
                setState(() {
                  book.tools[i].value = value;
                  valueControllers[i].text = book.tools[i].displayValue();
                });
                widget.onValueChange(book);
              }));
              return BookToolCard(book.tools[i], valueEditor);
            });
  }
}
