import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/reading_session.dart';
import 'package:otlet/business_logic/models/tool.dart';
import 'package:provider/provider.dart';

import '../../../business_logic/models/otlet_instance.dart';

class EditSessionTools extends StatefulWidget {
  final ReadingSession session;

  EditSessionTools({this.session});
  @override
  _EditSessionToolsState createState() => _EditSessionToolsState();
}

class _EditSessionToolsState extends State<EditSessionTools> {
  List<TextEditingController> valueControllers = [];
  List<Tool> activeSessionTools = [];
  List<FocusNode> focusNodes = [];

  ReadingSession session;
  bool isEdit;

  @override
  void initState() {
    super.initState();
    session = widget.session;
    isEdit = widget.session != null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OtletInstance>(builder: (context, instance, _) {
      if (session == null) session = instance.activeSession;
      activeSessionTools = session.tools;
      if (valueControllers.isEmpty) {
        valueControllers = activeSessionTools.map((e) {
          TextEditingController controller = TextEditingController();
          if (widget.session != null) {
            // means we have to put the value in, as it is an existing session being edited
            controller.text = e.displayValue();
          }
          return controller;
        }).toList();
      }

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
                  if (!isEdit)
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
                            print(
                                'building value input with tool ${tool.toJson()}');
                            return ListTile(
                                title: tool.generateValueInput(
                                    context, valueControllers[i], focusNodes[i],
                                    labelText: tool.name,
                                    onValueChange: (value) {
                              setState(() {
                                tool.value = value;
                                valueControllers[i].text = tool.displayValue();
                                if (!isEdit) instance.updateSessionTool(tool);
                              });
                            }));
                          })),
                ],
              ),
      );
    });
  }
}
