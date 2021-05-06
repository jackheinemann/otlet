import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/tool.dart';

import '../../../business_logic/utils/constants.dart';

class BookToolCard extends StatelessWidget {
  final Tool tool;
  final Function(Tool) updateBookTool;
  final Function(bool) toolIsEditing;

  BookToolCard(this.tool,
      {@required this.updateBookTool, @required this.toolIsEditing});
  @override
  Widget build(BuildContext context) {
    ListTile toolTile = ListTile(
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
    return tool.isActive
        ? Column(
            children: [
              toolTile,
              tool.generateValueInput(context,
                  onValueChange: (value) {
                    tool.value = value;
                    updateBookTool(tool);
                  },
                  editingChanges: (isEditing) => toolIsEditing(isEditing))
            ],
          )
        : toolTile;
  }
}
