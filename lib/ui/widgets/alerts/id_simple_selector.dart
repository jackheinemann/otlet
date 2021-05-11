import 'package:flutter/material.dart';

Future<String> showIdSelectorDialog(
    BuildContext context, String title, Map<String, dynamic> options) async {
  String target = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: Column(
                children: options.entries.map((e) {
                  String id = e.key;
                  dynamic value = e.value;
                  return ListTile(
                    onTap: () => Navigator.pop(context, id),
                    title: Text(value.toString()),
                  );
                }).toList(),
              ),
            ),
          ));
  return target;
}
