import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/tool.dart';
import 'package:otlet/business_logic/utils/functions.dart';
import 'package:otlet/ui/widgets/tools/tool_card.dart';
import 'package:provider/provider.dart';

import '../../business_logic/models/otlet_instance.dart';
import '../../business_logic/utils/constants.dart';
import '../../business_logic/utils/constants.dart';

class ViewToolsScreen extends StatefulWidget {
  @override
  _ViewToolsScreenState createState() => _ViewToolsScreenState();
}

class _ViewToolsScreenState extends State<ViewToolsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<OtletInstance>(
      builder: (context, instance, _) {
        List<Tool> bookTargetTools =
            instance.tools.where((element) => element.isBookTool).toList();
        List<Tool> sessionTargetTools =
            instance.tools.where((element) => !element.isBookTool).toList();
        return instance.tools.length == 0
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('No Tools Here', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 10),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: primaryColor),
                        onPressed: () async {
                          Tool tool = await createNewTool(context);
                          if (tool == null) return;
                          setState(() {
                            instance.addNewTool(tool);
                          });
                        },
                        child: Text('Create New Tool',
                            style: TextStyle(fontSize: 17))),
                  ],
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Book Tools',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                        Text('Active for All',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600))
                      ],
                    ),
                  ),
                  Container(
                    height: 1,
                    width: MediaQuery.of(context).size.width,
                    color: primaryColor,
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: bookTargetTools.length,
                        itemBuilder: (context, i) {
                          Tool tool = bookTargetTools[i];
                          return ToolCard(
                            tool,
                            updateTool: (modifiedTool) {
                              setState(() {
                                modifiedTool.isMarkedForDeletion()
                                    ? instance.deleteTool(modifiedTool)
                                    : instance.modifyTool(modifiedTool);
                              });
                            },
                          );
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Session Tools',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                        Text('Active for All',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600))
                      ],
                    ),
                  ),
                  Container(
                    height: 1,
                    width: MediaQuery.of(context).size.width,
                    color: primaryColor,
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: sessionTargetTools.length,
                        itemBuilder: (context, i) {
                          Tool tool = sessionTargetTools[i];
                          return ToolCard(
                            tool,
                            updateTool: (modifiedTool) {
                              setState(() {
                                modifiedTool.isMarkedForDeletion()
                                    ? instance.deleteTool(modifiedTool)
                                    : instance.modifyTool(modifiedTool);
                              });
                            },
                          );
                        }),
                  ),
                ],
              );
      },
    );
  }
}
