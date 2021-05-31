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
    List<Tool> bookTools = activeTools.where((e) => e.isBookTool).toList();
    List<Tool> sessionTools = activeTools.where((e) => !e.isBookTool).toList();
    return activeTools.isEmpty
        ? Center(
            child: Text(
                book.tools.isEmpty ? 'No Tools Created' : 'No Active Tools',
                style: TextStyle(fontSize: 18)),
          )
        : SingleChildScrollView(
            child: Column(
                children: <Widget>[
                      if (bookTools.isNotEmpty)
                        Text('Active Book Tools',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500))
                    ] +
                    bookTools.map((e) => StaticToolCard(e)).toList() +
                    [
                      if (sessionTools.isNotEmpty)
                        Text('Active Session Tools',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500))
                    ] +
                    sessionTools.map((e) => StaticToolCard(e)).toList()),
          );
  }
}
