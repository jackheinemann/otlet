import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/tool.dart';

import '../../../business_logic/utils/constants.dart';

class BookToolCard extends StatefulWidget {
  final Tool tool;
  final ListTile valueEditor;

  BookToolCard(this.tool, this.valueEditor);
  @override
  _BookToolCardState createState() => _BookToolCardState();
}

class _BookToolCardState extends State<BookToolCard> {
  Tool tool;
  ListTile valueEditor;

  initState() {
    super.initState();
    tool = widget.tool;
    valueEditor = widget.valueEditor;
  }

  @override
  Widget build(BuildContext context) {
    ListTile toolTile = ListTile(
      title: Text(tool.name, style: TextStyle(fontSize: 18)),
      subtitle: Text(tool.toolType),
      leading: Icon(tool.isBookTool ? Icons.menu_book : Icons.history),
      trailing: Switch(
        activeColor: accentColor,
        value: tool.isActive,
        onChanged: (isActive) {
          setState(() {
            tool.isActive = isActive;
          });
        },
      ),
    );
    return tool.isActive && tool.isBookTool
        ? Column(
            children: [toolTile, valueEditor],
          )
        : toolTile;
  }
}
