import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/tool.dart';

import '../../../business_logic/utils/constants.dart';

class CreateFixedOptionsScreen extends StatefulWidget {
  final Tool tool;

  CreateFixedOptionsScreen(this.tool);
  @override
  _CreateFixedOptionsScreenState createState() =>
      _CreateFixedOptionsScreenState();
}

class _CreateFixedOptionsScreenState extends State<CreateFixedOptionsScreen> {
  Tool tool;

  TextEditingController fixedOptionsController = TextEditingController();

  List<String> options = [];

  @override
  void initState() {
    super.initState();
    tool = widget.tool;
    if (tool.fixedOptions.isNotEmpty)
      options = tool.fixedOptions.map((e) => e.toString()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Set Fixed Options'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Input fixed options separated by commas.',
                  style: TextStyle(fontSize: 18)),
            ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7.0),
              child: TextFormField(
                keyboardType: tool.isNumeric()
                    ? TextInputType.numberWithOptions(signed: true)
                    : TextInputType.text,
                textCapitalization: TextCapitalization.words,
                controller: fixedOptionsController,
                onChanged: (value) {
                  if (value.contains(',')) {
                    String item = value.replaceAll(',', '').trim();
                    setState(() {
                      options.add(item);
                      fixedOptionsController.clear();
                    });
                  }
                },
                onEditingComplete: () {
                  FocusScope.of(context).unfocus();
                  String value = fixedOptionsController.text.trim();
                  if (value.isEmpty) {
                    fixedOptionsController.clear();
                    return;
                  }
                  setState(() {
                    options.add(value);
                    fixedOptionsController.clear();
                  });
                },
                decoration: InputDecoration(
                    labelText: 'Fixed Options',
                    hintText: tool.toolType == Tool.integerTool ||
                            tool.toolType == Tool.doubleTool
                        ? 'e.g. \'1, 2, 3, 10, 20, 90, 100\''
                        : 'e.g. \'Disagree, Neutral, Agree\'',
                    border: OutlineInputBorder()),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Wrap(
              spacing: 10,
              runSpacing: 2,
              children: options
                  .map((e) => Chip(
                        label: Text(
                          e.toString(),
                          style: TextStyle(fontSize: 17),
                        ),
                        deleteIcon: Icon(Icons.cancel),
                        onDeleted: () {
                          setState(() {
                            options.remove(e);
                          });
                        },
                      ))
                  .toList(),
            ),
            Spacer(),
            ElevatedButton(
                style: ElevatedButton.styleFrom(primary: primaryColor),
                onPressed: () {
                  if (options.isEmpty) {
                    Navigator.pop(context);
                    return;
                  } else if (tool.toolType == Tool.doubleTool) {
                    List<double> values = [];
                    for (String option in options) {
                      double val = double.tryParse(option);
                      if (val == null) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                'Error: $option is not a decimal figure.')));
                        return;
                      }
                      values.add(val);
                    }
                    Navigator.pop(context, values);
                  } else if (tool.toolType == Tool.integerTool) {
                    List<int> values = [];
                    for (String option in options) {
                      int val = int.tryParse(option);
                      if (val == null) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                'Error: $option is not an integer figure.')));
                        return;
                      }
                      values.add(val);
                    }
                    Navigator.pop(context, values);
                  } else {
                    Navigator.pop(context, options);
                  }
                },
                child: Text('Save Options', style: TextStyle(fontSize: 17))),
            SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}
