import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/tool.dart';
import 'package:provider/provider.dart';

import '../../../business_logic/models/otlet_instance.dart';

class EditSessionTools extends StatefulWidget {
  @override
  _EditSessionToolsState createState() => _EditSessionToolsState();
}

class _EditSessionToolsState extends State<EditSessionTools> {
  List<TextEditingController> valueControllers = [];
  List<Tool> activeSessionTools = [];
  List<FocusNode> focusNodes = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<OtletInstance>(builder: (context, instance, _) {
      activeSessionTools = instance.activeSession.tools;
      if (valueControllers.isEmpty)
        valueControllers =
            activeSessionTools.map((e) => TextEditingController()).toList();
      if (focusNodes.isEmpty) {
        for (int i = 0; i < activeSessionTools.length; i++) {
          FocusNode focusNode = FocusNode();
          focusNode.addListener(() {
            if (!focusNode.hasFocus) {
              // means we just lost focus, keep checking
              if (activeSessionTools[i].displayValue() !=
                  valueControllers[i].text.trim()) {
                // means the value in the tool and its formfield are different
                setState(() {
                  activeSessionTools[i]
                      .assignValueFromString(valueControllers[i].text.trim());
                  instance.updateSessionTool(activeSessionTools[i]);
                });
              }
            }
          });
          focusNodes.add(focusNode);
        }
      }
      // focusNodes = activeSessionTools.map((e) => FocusNode()).toList();
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
                            return ListTile(
                                title: tool.generateValueInput(
                                    context, valueControllers[i], focusNodes[i],
                                    labelText: tool.name,
                                    onValueChange: (value) {
                              setState(() {
                                tool.value = value;
                                valueControllers[i].text = tool.displayValue();
                                instance.updateSessionTool(tool);
                              });
                            }));
                          })),
                ],
              ),
      );
    });
  }
}
