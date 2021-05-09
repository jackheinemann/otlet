import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/tool.dart';
import 'package:otlet/ui/widgets/tools/session_tool_card.dart';
import 'package:provider/provider.dart';

import '../../../business_logic/models/otlet_instance.dart';

class EditSessionTools extends StatefulWidget {
  @override
  _EditSessionToolsState createState() => _EditSessionToolsState();
}

class _EditSessionToolsState extends State<EditSessionTools> {
  List<TextEditingController> valueControllers = [];
  List<Tool> activeSessionTools = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<OtletInstance>(builder: (context, instance, _) {
      activeSessionTools = instance.activeSession.tools;
      if (valueControllers.isEmpty)
        valueControllers =
            activeSessionTools.map((e) => TextEditingController()).toList();
      return Expanded(
        child: activeSessionTools.isEmpty
            ? Center(
                child: Text('No Active Session Tools',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Session Tools',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500)),
                  ),
                  Expanded(
                      child: ListView.builder(
                          itemCount: activeSessionTools.length,
                          itemBuilder: (context, i) {
                            Tool tool = activeSessionTools[i];
                            return tool.generateValueInput(
                                context, valueControllers[i],
                                labelText: tool.name, onValueChange: (value) {
                              setState(() {
                                tool.value = value;
                                valueControllers[i].text = tool.displayValue();
                                instance.updateSessionTool(tool);
                              });
                            });
                          })),
                ],
              ),
      );
    });
  }
}
