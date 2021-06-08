import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/tool.dart';
import 'package:otlet/ui/screens/view_tools_screens/create_custom_tool_screen.dart';

Future<Tool> createNewTool(BuildContext context) async {
  return await Navigator.push(context,
      MaterialPageRoute(builder: (context) => CreateCustomToolScreen()));
}

Future<Tool> editTool(BuildContext context, Tool tool) async {
  return await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CreateCustomToolScreen(
                isEdit: true,
                tool: tool,
              )));
}

String generateCoverUrl(String coverKey, {String size = 'M'}) =>
    'https://covers.openlibrary.org/b/id/$coverKey-$size.jpg';
