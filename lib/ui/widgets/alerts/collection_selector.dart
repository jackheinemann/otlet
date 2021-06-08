import 'package:flutter/material.dart';
import 'package:otlet/business_logic/utils/constants.dart';

Future<List<String>> showCollectionSelectorDialog(BuildContext context,
    String title, List<String> options, List<String> currentSelection) async {
  List<String> selected = currentSelection ?? [];
  await showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text(options.isEmpty ? 'No Collections' : title),
            content: options.isEmpty
                ? Text('Create one in the settings menu')
                : StatefulBuilder(builder: (context, setState) {
                    return SingleChildScrollView(
                      child: Column(
                        children: options
                            .map((e) => ListTile(
                                  onTap: () {
                                    if (selected.contains(e))
                                      setState(() => selected.remove(e));
                                    else
                                      setState(() => selected.add(e));
                                  },
                                  title: Text(e.toString()),
                                  trailing: Icon(Icons.check,
                                      color: selected.contains(e)
                                          ? Colors.black
                                          : Colors.transparent),
                                ))
                            .toList(),
                      ),
                    );
                  }),
            actions: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: primaryColor),
                        onPressed: () => Navigator.pop(context),
                        child: Text('OK', style: TextStyle(fontSize: 17))),
                  ),
                ),
              )
            ],
          ));
  return selected;
}
