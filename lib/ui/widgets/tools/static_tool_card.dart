import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/tool.dart';

class StaticToolCard extends StatelessWidget {
  final Tool tool;

  StaticToolCard(this.tool);
  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(tool.name, style: TextStyle(fontSize: 18)),
        subtitle: Text(tool.toolType),
        trailing: tool.isBookTool
            ? (tool.value != null)
                ? Text(tool.displayValue(), style: TextStyle(fontSize: 17))
                : Text('Empty', style: TextStyle(fontSize: 17))
            : Icon(Icons.history));
  }
}
