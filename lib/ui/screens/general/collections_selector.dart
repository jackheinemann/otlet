import 'dart:io';

import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/otlet_instance.dart';
import 'package:otlet/business_logic/utils/constants.dart';
import 'package:otlet/ui/widgets/alerts/confirm_dialog.dart';

class CollectionsSelector extends StatefulWidget {
  final Map<String, bool> options;
  final OtletInstance instance;
  final String title;
  final Function(int, {Map<String, bool> options}) updateAddIndex;

  CollectionsSelector(
      {@required this.options,
      @required this.instance,
      @required this.title,
      @required this.updateAddIndex});

  @override
  _CollectionsSelectorState createState() => _CollectionsSelectorState();
}

class _CollectionsSelectorState extends State<CollectionsSelector> {
  String title;
  Map<String, bool> options;

  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    options = widget.options;
    title = widget.title;
    controller.addListener(() {
      String value = controller.text;
      if (value.contains(',')) {
        String payload =
            capitalizeFirst(value.substring(0, value.length - 1).trim());
        setState(() {
          options.putIfAbsent(payload, () => true);
          controller.clear();
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool shouldPop =
            await showConfirmDialog('Discard changes to Collections?', context);
        if (shouldPop) widget.updateAddIndex(0);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(
                  Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios),
              onPressed: () async {
                bool shouldPop = await showConfirmDialog(
                    'Discard changes to Collections?', context);
                if (shouldPop) widget.updateAddIndex(0);
                return Future.value(false);
              }),
          title: Text(title),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                controller: controller,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                onEditingComplete: () {
                  FocusScope.of(context).unfocus();
                  String lastInput = controller.text.trim();
                  if (lastInput.isEmpty) return;
                  setState(() {
                    options.putIfAbsent(lastInput, () => true);
                    controller.clear();
                  });
                },
                decoration: InputDecoration(
                    labelText: 'Add new collections',
                    hintText: 'Separate values with commas',
                    border: OutlineInputBorder()),
              ),
              Wrap(
                spacing: 10,
                children: options.keys
                    .map((e) => InputChip(
                          onPressed: () {
                            setState(() {
                              options[e] = !options[e];
                            });
                          },
                          selected: options[e],
                          selectedColor: primaryColor,
                          checkmarkColor:
                              options[e] ? Colors.white : Colors.black,
                          labelStyle: TextStyle(
                              color: options[e] ? Colors.white : Colors.black),
                          label: Text(e, style: TextStyle(fontSize: 18)),
                          onDeleted: () {
                            setState(() {
                              options.remove(e);
                            });
                          },
                          deleteIcon: Icon(Icons.cancel_outlined,
                              color: options[e] ? Colors.white : Colors.black),
                        ))
                    .toList(),
              ),
              Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(primary: primaryColor),
                onPressed: () {
                  widget.instance.updateCollections(options.keys.toList());
                  widget.updateAddIndex(0, options: options);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Save',
                    // style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              )
            ],
          ),
        ),
      ),
    );
  }
}

String capitalizeFirst(String string) {
  return '${string[0].toUpperCase()}${string.substring(1).toLowerCase()}';
}
