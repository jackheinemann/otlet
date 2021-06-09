import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/tool.dart';

import '../../../business_logic/utils/constants.dart';

class ToolCard extends StatelessWidget {
  final Tool tool;
  final Function(int) updateScreenIndex;
  final Function(Tool) updateActivity;

  ToolCard(this.tool,
      {@required this.updateScreenIndex, @required this.updateActivity});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => updateScreenIndex(ScreenIndex.addEditTool),
      leading: tool.isBookTool ? Icon(Icons.menu_book) : Icon(Icons.history),
      title: Text(tool.name, style: TextStyle(fontSize: 18)),
      subtitle: Text(tool.toolType),
      trailing: Switch(
        activeColor: accentColor,
        value: tool.setActiveForAll,
        onChanged: (value) {
          tool.setActiveForAll = value;
          updateActivity(tool);
        },
      ),
    );
  }
}
