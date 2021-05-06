import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/tool.dart';
import 'package:otlet/ui/widgets/tools/otlet_tool_card.dart';
import 'package:otlet/ui/widgets/tools/tool_card.dart';
import 'package:provider/provider.dart';

import '../../business_logic/models/otlet_instance.dart';
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
        // List<Tool> bookTargetTools =
        //     instance.tools.where((element) => element.isBookTool).toList();
        // List<Tool> sessionTargetTools =
        //     instance.tools.where((element) => !element.isBookTool).toList();
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Otlet Tools',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  Text('Active for All',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600))
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
                  itemCount: instance.otletTools.length,
                  itemBuilder: (context, i) {
                    Tool otletTool = instance.otletTools[i];
                    return OtletToolCard(otletTool,
                        updateActivity: (masterTool) {
                      setState(() {
                        instance.setGlobalOtletToolActivity(masterTool);
                      });
                    });
                  }),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Custom Tools',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  // Text('Active for All',
                  //     style:
                  //         TextStyle(fontSize: 18, fontWeight: FontWeight.w600))
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
                  itemCount: instance.tools.length,
                  itemBuilder: (context, i) {
                    Tool tool = instance.tools[i];
                    return ToolCard(
                      tool,
                      updateTool: (modifiedTool) {
                        setState(() {
                          modifiedTool.isMarkedForDeletion()
                              ? instance.deleteTool(modifiedTool)
                              : instance.modifyTool(modifiedTool);
                        });
                      },
                      updateActivity: (modifiedTool) {
                        setState(() {
                          instance.setGlobalToolActivity(modifiedTool);
                        });
                      },
                    );
                  }),
            ),
            // Padding(
            //   padding: const EdgeInsets.all(15.0),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Text('Session Tools',
            //           style:
            //               TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            //       Text('Active for All',
            //           style:
            //               TextStyle(fontSize: 18, fontWeight: FontWeight.w600))
            //     ],
            //   ),
            // ),
            // Container(
            //   height: 1,
            //   width: MediaQuery.of(context).size.width,
            //   color: primaryColor,
            // ),
            // Expanded(
            //   child: ListView.builder(
            //       itemCount: sessionTargetTools.length,
            //       itemBuilder: (context, i) {
            //         Tool tool = sessionTargetTools[i];
            //         return ToolCard(
            //           tool,
            //           updateTool: (modifiedTool) {
            //             setState(() {
            //               modifiedTool.isMarkedForDeletion()
            //                   ? instance.deleteTool(modifiedTool)
            //                   : instance.modifyTool(modifiedTool);
            //             });
            //           },
            //           updateActivity: (modifiedTool) {
            //             setState(() {
            //               instance.setGlobalActivity(modifiedTool);
            //             });
            //           },
            //         );
            //       }),
            // ),
          ],
        );
      },
    );
  }
}
