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
      trailing: (tool.value != null)
          ? Text(tool.value.toString(), style: TextStyle(fontSize: 17))
          : null,
    );
  }
}
