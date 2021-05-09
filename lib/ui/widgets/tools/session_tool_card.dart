import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/tool.dart';

class SessionToolCard extends StatefulWidget {
  final Tool tool;
  final ListTile valueEditor;

  SessionToolCard(this.tool, this.valueEditor);
  @override
  _SessionToolCardState createState() => _SessionToolCardState();
}

class _SessionToolCardState extends State<SessionToolCard> {
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
    );
    return Column(
      children: [toolTile, valueEditor],
    );
  }
}
