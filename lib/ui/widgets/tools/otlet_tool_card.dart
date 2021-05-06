import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/tool.dart';

import '../../../business_logic/utils/constants.dart';

class OtletToolCard extends StatelessWidget {
  final Tool tool;
  final Function(Tool) updateActivity;

  OtletToolCard(this.tool, {@required this.updateActivity});
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
          updateActivity(tool);
        },
      ),
    );
  }
}
