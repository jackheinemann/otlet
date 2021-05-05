import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/tool.dart';
import 'package:otlet/business_logic/utils/functions.dart';

import '../../../business_logic/utils/constants.dart';

class ToolCard extends StatelessWidget {
  final Tool tool;
  final Function(Tool) updateTool;

  ToolCard(this.tool, {@required this.updateTool});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        Tool temp = await editTool(context, tool);
        if (temp == null) return;
        updateTool(temp);
      },
      title: Text(tool.name, style: TextStyle(fontSize: 18)),
      subtitle: Text(tool.toolType),
      trailing: Checkbox(
        activeColor: accentColor,
        value: tool.setActiveForAll,
        onChanged: (value) {
          tool.setActiveForAll = value;
          updateTool(tool);
        },
      ),
    );
  }
}
