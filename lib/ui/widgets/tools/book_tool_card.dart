import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/tool.dart';

import '../../../business_logic/utils/constants.dart';

class BookToolCard extends StatelessWidget {
  final Tool tool;
  final Function(Tool) updateBookTool;

  BookToolCard(this.tool, {@required this.updateBookTool});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(tool.name, style: TextStyle(fontSize: 18)),
      subtitle: Text(tool.toolType),
      trailing: Switch(
        activeColor: accentColor,
        value: tool.isActive,
        onChanged: (value) {
          tool.isActive = value;
          updateBookTool(tool);
        },
      ),
    );
  }
}
