import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/tool.dart';

import '../../../business_logic/utils/constants.dart';

class BookToolCard extends StatefulWidget {
  final Tool tool;
  final ListTile valueEditor;
  final Function(Tool) updateBookTool;

  BookToolCard(this.tool, this.valueEditor, {@required this.updateBookTool});
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
      trailing: Switch(
        activeColor: accentColor,
        value: tool.isActive,
        onChanged: (value) {
          setState(() {
            tool.isActive = value;
          });
          // widget.updateBookTool(tool);
        },
      ),
    );
    return tool.isActive
        ? Column(
            children: [toolTile, valueEditor],
          )
        : toolTile;
  }
}

// class BookToolCard extends StatelessWidget {
//   final Tool tool;
//   final ListTile valueEditor;
//   final Function(Tool) updateBookTool;

//   BookToolCard(this.tool, this.valueEditor, {@required this.updateBookTool});
//   @override
//   Widget build(BuildContext context) {}
// }
