import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/tool.dart';
import 'package:otlet/ui/widgets/tools/static_tool_card.dart';

import '../../../../business_logic/models/book.dart';

class BookToolsStaticTab extends StatelessWidget {
  final Book book;
  final VoidCallback editTools;
  BookToolsStaticTab(this.book, {@required this.editTools});
  @override
  Widget build(BuildContext context) {
    List<Tool> activeTools =
        book.tools.where((element) => element.isActive).toList();
    return activeTools.isEmpty
        ? Center(
            child: Text('No Active Tools', style: TextStyle(fontSize: 18)),
          )
        : Column(children: activeTools.map((e) => StaticToolCard(e)).toList());
  }
}
