import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/tool.dart';

import '../../../business_logic/utils/constants.dart';

class ToolCard extends StatelessWidget {
  final Tool tool;
  final Function(Tool) updateActiveForAll;

  ToolCard(this.tool, {@required this.updateActiveForAll});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(tool.name, style: TextStyle(fontSize: 18)),
      subtitle: Text(tool.toolType),
      trailing: Checkbox(
        activeColor: accentColor,
        value: tool.setActiveForAll,
        onChanged: (value) {
          tool.setActiveForAll = value;
          updateActiveForAll(tool);
        },
      ),
    );
  }
}
