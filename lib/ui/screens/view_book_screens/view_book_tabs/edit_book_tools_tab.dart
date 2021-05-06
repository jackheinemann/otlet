import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/tool.dart';
import 'package:otlet/ui/widgets/tools/book_tool_card.dart';

import '../../../../business_logic/models/book.dart';
import '../../../../business_logic/utils/constants.dart';

class EditBookToolsTab extends StatefulWidget {
  final Book book;
  final VoidCallback stopEditing;

  EditBookToolsTab(this.book, {@required this.stopEditing});
  @override
  _EditBookToolsTabState createState() => _EditBookToolsTabState();
}

class _EditBookToolsTabState extends State<EditBookToolsTab> {
  Book book;
  @override
  void initState() {
    super.initState();
    book = widget.book;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OutlinedButton(
            onPressed: () => widget.stopEditing(),
            child: Text('Stop Editing',
                style: TextStyle(fontSize: 16, color: primaryColor))),
        Expanded(
          child: ListView.builder(
              itemCount: book.tools.length,
              itemBuilder: (context, i) {
                Tool tool = book.tools[i];
                ListTile valueEditor = tool.generateValueInput(context,
                    onValueChange: (_) {}, editingChanges: (_) {});
                return BookToolCard(tool, valueEditor, updateBookTool: (_) {});
              }),
        ),
      ],
    );
  }
}
