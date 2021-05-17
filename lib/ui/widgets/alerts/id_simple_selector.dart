import 'package:flutter/material.dart';

Future<MapEntry> showIdSelectorDialog(
    BuildContext context, String title, Map<dynamic, dynamic> options) async {
  MapEntry target = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: Column(
                children: options.entries.map((e) {
                  dynamic id = e.key;
                  dynamic value = e.value;
                  return ListTile(
                    onTap: () => Navigator.pop(context, MapEntry(id, value)),
                    title: Text(value.toString()),
                  );
                }).toList(),
              ),
            ),
          ));
  return target;
}
