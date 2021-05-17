import 'package:flutter/material.dart';

Future<dynamic> showSimpleSelectorDialog(
    BuildContext context, String title, List<dynamic> options) async {
  String target = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: Column(
                children: options
                    .map((e) => ListTile(
                          onTap: () => Navigator.pop(context, e),
                          title: Text(e.toString()),
                        ))
                    .toList(),
              ),
            ),
          ));
  return target;
}
