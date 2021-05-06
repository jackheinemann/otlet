import 'package:flutter/material.dart';
import 'package:otlet/ui/widgets/tools/static_tool_card.dart';

import '../../../../business_logic/models/book.dart';
import '../../../../business_logic/utils/constants.dart';

class BookToolsStaticTab extends StatelessWidget {
  final Book book;
  final VoidCallback editTools;
  BookToolsStaticTab(this.book, {@required this.editTools});
  @override
  Widget build(BuildContext context) {
    return Column(
        children: <Widget>[
              OutlinedButton(
                  onPressed: () => editTools(),
                  child: Text('Edit Values',
                      style: TextStyle(fontSize: 16, color: primaryColor))),
            ] +
            book.tools
                .where((element) => element.isActive)
                .toList()
                .map((e) => StaticToolCard(e))
                .toList());
  }
}
