import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/tool.dart';
import 'package:otlet/business_logic/utils/functions.dart';
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
            : ListView.builder(
                itemCount: instance.tools.length,
                itemBuilder: (context, i) {
                  Tool tool = instance.tools[i];
                  return ListTile(
                    title: Text(tool.name),
                  );
                });
      },
    );
  }
}
