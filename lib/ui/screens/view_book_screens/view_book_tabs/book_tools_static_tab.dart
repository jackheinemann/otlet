import 'package:flutter/material.dart';
import 'package:otlet/ui/widgets/tools/static_tool_card.dart';

import '../../../../business_logic/models/book.dart';

class BookToolsStaticTab extends StatelessWidget {
  final Book book;
  final VoidCallback editTools;
  BookToolsStaticTab(this.book, {@required this.editTools});
  @override
  Widget build(BuildContext context) {
    return Column(
        children: book.tools
            .where((element) => element.isActive)
            .toList()
            .map((e) => StaticToolCard(e))
            .toList());
  }
}
