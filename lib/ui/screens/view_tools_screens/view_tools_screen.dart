import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/tool.dart';
import 'package:otlet/ui/widgets/tools/tool_card.dart';
import 'package:provider/provider.dart';

import '../../../business_logic/models/otlet_instance.dart';
import '../../../business_logic/utils/constants.dart';

class ViewToolsScreen extends StatefulWidget {
  final Function(int, {Tool tool}) updateScreenIndex;

  ViewToolsScreen({@required this.updateScreenIndex});
  @override
  _ViewToolsScreenState createState() => _ViewToolsScreenState();
}

class _ViewToolsScreenState extends State<ViewToolsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<OtletInstance>(
      builder: (context, instance, _) {
        return instance.tools.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('No Tools Here', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 10),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: primaryColor),
                        onPressed: () =>
                            widget.updateScreenIndex(ScreenIndex.addEditTool),
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
                        Text('Custom Tools',
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
                        itemCount: instance.tools.length,
                        itemBuilder: (context, i) {
                          Tool tool = instance.tools[i];
                          return ToolCard(
                            tool,
                            updateScreenIndex: (index) =>
                                widget.updateScreenIndex(index, tool: tool),
                            updateActivity: (modifiedTool) {
                              setState(() {
                                instance.setGlobalToolActivity(modifiedTool);
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
