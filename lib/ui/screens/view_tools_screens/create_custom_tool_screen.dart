import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:otlet/business_logic/models/tool.dart';
import 'package:otlet/ui/widgets/alerts/confirm_dialog.dart';
import 'package:otlet/ui/widgets/alerts/error_dialog.dart';
import 'package:otlet/ui/widgets/alerts/simple_selector.dart';

import '../../../business_logic/utils/constants.dart';

class CreateCustomToolScreen extends StatefulWidget {
  final bool isEdit;
  final Tool tool;

  CreateCustomToolScreen({this.isEdit = false, this.tool});
  @override
  _CreateCustomToolScreenState createState() => _CreateCustomToolScreenState();
}

class _CreateCustomToolScreenState extends State<CreateCustomToolScreen> {
  Tool tool;
  TextEditingController toolNameController = TextEditingController();
  TextEditingController fixedOptionsController = TextEditingController();
  TextEditingController toolValueController = TextEditingController();
  bool isEdit;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    isEdit = widget.isEdit;
    if (isEdit) {
      tool = widget.tool;
      toolNameController.text = tool.name;
      fixedOptionsController.text =
          tool.fixedOptions.map((e) => e.toString()).toList().join(', ');
      if (tool.value != null) {
        if (tool.isDateTime()) {
          if (tool.toolType == Tool.timeTool) {
            TimeOfDay timeOfDay = tool.value as TimeOfDay;
            toolValueController.text =
                '${timeOfDay.hour}:${timeOfDay.minute < 10 ? '0' + timeOfDay.minute.toString() : timeOfDay.minute}';
          } else {
            DateTime dateVal = tool.value as DateTime;
            toolValueController.text =
                '${(tool.includesTime() ? DateFormat('MMMM dd, y h:mm aa') : DateFormat('MMMM dd y')).format(dateVal)}';
          }
        } else
          toolValueController.text = tool.value.toString();
      }
    } else {
      tool = Tool();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(isEdit ? 'Edit ${tool.name}' : 'Create Custom Tool'),
        actions: [
          if (isEdit)
            IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  bool shouldDelete = await showConfirmDialog(
                      'Are you sure you want to delete ${tool.name}?', context);
                  if (!shouldDelete) return;

                  Navigator.pop(context, Tool(customId: tool.id));
                })
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 7.0),
                        child: TextFormField(
                          textCapitalization: TextCapitalization.words,
                          controller: toolNameController,
                          decoration: InputDecoration(
                              labelText: 'Tool Name',
                              border: OutlineInputBorder()),
                          validator: (value) {
                            value = value.trim();
                            if (value.isEmpty) return 'Tool name required';
                            tool.name = value;
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      ListTile(
                        onTap: () async {
                          FocusScope.of(context).unfocus();
                          String target = await showSimpleSelectorDialog(
                              context,
                              'Measure per session or per book?',
                              ['Book', 'Session']);
                          if (target == null) return;
                          setState(() {
                            if (target == 'Session')
                              tool.isBookTool = false;
                            else
                              tool.isBookTool = true;
                          });
                        },
                        title: Text(
                            tool.isBookTool == null
                                ? 'Select Target'
                                : '${tool.isBookTool ? 'Book' : 'Session'} Tool',
                            style: TextStyle(fontSize: 16)),
                        trailing: Icon(Icons.arrow_drop_down),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      ListTile(
                        onTap: () async {
                          FocusScope.of(context).unfocus();
                          String toolType = await showSimpleSelectorDialog(
                              context,
                              'Select your tool\'s metric',
                              Tool.toolTypes);

                          if (toolType == null) return;

                          setState(() {
                            tool.toolType = toolType;
                            tool.value = null;
                            tool.fixedOptions.clear();
                            fixedOptionsController.clear();
                            toolValueController.clear();
                          });
                        },
                        title: Text(tool?.toolType ?? 'Select Type',
                            style: TextStyle(fontSize: 16)),
                        trailing: Icon(Icons.arrow_drop_down),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      if (tool.isInitialized())
                        if (!tool.isSpecialGrade())
                          ListTile(
                            title: Text('Set fixed options',
                                style: TextStyle(fontSize: 16)),
                            trailing: Switch(
                                value: tool.useFixedOptions,
                                onChanged: (val) {
                                  setState(() {
                                    tool.useFixedOptions = val;
                                  });
                                }),
                          ),
                      if (tool.isInitialized())
                        if (!tool.isSpecialGrade())
                          SizedBox(
                            height: 15,
                          ),
                      if (tool.toolType != null)
                        if (tool.useFixedOptions)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 7.0),
                            child: TextFormField(
                              onTap: () async {
                                // List<dynamic> fixedOptions =
                                //     await Navigator.push(
                                //         context,
                                //         MaterialPageRoute(
                                //             builder: (context) =>
                                //                 CreateFixedOptionsScreen(
                                //                     tool)));
                                // if (fixedOptions == null) return;
                                // setState(() {
                                //   tool.fixedOptions =
                                //       List<dynamic>.from(fixedOptions);
                                //   fixedOptionsController.text = tool
                                //       .fixedOptions
                                //       .map((e) => e.toString())
                                //       .toList()
                                //       .join(', ');
                                // });
                              },
                              textCapitalization: TextCapitalization.words,
                              readOnly: true,
                              controller: fixedOptionsController,
                              decoration: InputDecoration(
                                  labelText: 'Fixed Options',
                                  border: OutlineInputBorder()),
                            ),
                          ),
                      if (tool.toolType != null)
                        if (tool.useFixedOptions)
                          SizedBox(
                            height: 15,
                          ),
                      // if (tool.isInitialized())
                      //   if (tool.isBookTool)
                      //     tool.useFixedOptions
                      //         ? ListTile(
                      //             title: Text(
                      //                 tool.value == null
                      //                     ? 'Initial Value (optional)'
                      //                     : tool.value.toString(),
                      //                 style: TextStyle(fontSize: 16)),
                      //             trailing: Icon(Icons.arrow_drop_down),
                      //             onTap: () async {
                      //               if (tool.fixedOptions.isEmpty) {
                      //                 ScaffoldMessenger.of(context)
                      //                     .showSnackBar(SnackBar(
                      //                         content: Text(
                      //                             'Set fixed options first to select an initial value.')));
                      //                 return;
                      //               }
                      //               FocusScope.of(context).unfocus();
                      //               String initialValue =
                      //                   await showSimpleSelectorDialog(
                      //                       context,
                      //                       'Select an initial value${toolNameController.text.isNotEmpty ? ' for ' + toolNameController.text : ''}',
                      //                       tool.fixedOptions);

                      //               if (initialValue == null) return;
                      //               setState(() {
                      //                 tool.value = initialValue;
                      //                 toolValueController.text = initialValue;
                      //               });
                      //             },
                      //           )
                      //         : Padding(
                      //             padding: const EdgeInsets.symmetric(
                      //                 horizontal: 7.0),
                      //             child: TextFormField(
                      //               onTap: () async {
                      //                 if (!tool.isSpecialGrade()) return;

                      //                 if (tool.toolType == Tool.dateTimeTool ||
                      //                     tool.toolType == Tool.dateTool) {
                      //                   DateTime value = await showDatePicker(
                      //                       context: context,
                      //                       initialDate: DateTime.now(),
                      //                       firstDate: DateTime.now().subtract(
                      //                           Duration(days: 365 * 50)),
                      //                       lastDate: DateTime.now()
                      //                           .add(Duration(days: 365 * 50)));
                      //                   if (value == null) return;
                      //                   tool.value = value;
                      //                 }
                      //                 if (tool.toolType == Tool.dateTimeTool ||
                      //                     tool.toolType == Tool.timeTool) {
                      //                   TimeOfDay timeOfDay =
                      //                       await showTimePicker(
                      //                           context: context,
                      //                           initialTime: TimeOfDay.now());
                      //                   if (timeOfDay == null) return;
                      //                   if (tool.toolType ==
                      //                       Tool.dateTimeTool) {
                      //                     DateTime value =
                      //                         tool.value as DateTime;

                      //                     tool.value = DateTime(
                      //                         value.year,
                      //                         value.month,
                      //                         value.day,
                      //                         timeOfDay.hour,
                      //                         timeOfDay.minute);
                      //                   } else {
                      //                     tool.value = timeOfDay;
                      //                   }
                      //                 }
                      //                 if (tool.toolType == Tool.booleanTool) {
                      //                   bool value = await showDialog(
                      //                       context: context,
                      //                       builder: (context) => AlertDialog(
                      //                             title: Text('Select a value'),
                      //                             actions: [
                      //                               TextButton(
                      //                                   onPressed: () =>
                      //                                       Navigator.of(
                      //                                               context)
                      //                                           .pop(true),
                      //                                   child: Text('True')),
                      //                               TextButton(
                      //                                   onPressed: () =>
                      //                                       Navigator.of(
                      //                                               context)
                      //                                           .pop(false),
                      //                                   child: Text('False')),
                      //                             ],
                      //                           ));
                      //                   if (value == null) return;
                      //                   tool.value = value;
                      //                 }
                      //                 setState(() {
                      //                   if (tool.toolType == Tool.booleanTool)
                      //                     toolValueController.text =
                      //                         tool.value.toString();
                      //                   else {
                      //                     if (tool.toolType == Tool.dateTool)
                      //                       toolValueController.text =
                      //                           DateFormat('MMMM d y')
                      //                               .format(tool.value);
                      //                     else if (tool.toolType ==
                      //                         Tool.timeTool) {
                      //                       TimeOfDay time = tool.value;
                      //                       toolValueController.text =
                      //                           DateFormat(
                      //                                   DateFormat.HOUR_MINUTE)
                      //                               .format(DateTime(
                      //                                   1,
                      //                                   1,
                      //                                   1,
                      //                                   time.hour,
                      //                                   time.minute));
                      //                     } else {
                      //                       // datetime, need both
                      //                       toolValueController.text =
                      //                           DateFormat('MMMM d, y hh:mm aa')
                      //                               .format(tool.value);
                      //                     }
                      //                   }
                      //                 });
                      //               },
                      //               textCapitalization:
                      //                   TextCapitalization.words,
                      //               keyboardType: tool.isNumeric()
                      //                   ? TextInputType.numberWithOptions(
                      //                       signed: true)
                      //                   : TextInputType.text,
                      //               readOnly: tool.isSpecialGrade(),
                      //               controller: toolValueController,
                      //               decoration: InputDecoration(
                      //                   labelText: 'Initial Value (optional)',
                      //                   border: OutlineInputBorder()),
                      //               validator: (value) {
                      //                 value = value.trim();

                      //                 if (value.isEmpty) return null;
                      //                 if (tool.toolType == Tool.doubleTool) {
                      //                   double val = double.tryParse(value);
                      //                   if (val == null)
                      //                     return '$value is not a decimal figure';
                      //                   tool.value = val;
                      //                 } else if (tool.toolType ==
                      //                     Tool.integerTool) {
                      //                   int val = int.tryParse(value);
                      //                   if (val == null)
                      //                     return '$value is not an integer figure';
                      //                   tool.value = val;
                      //                 } else if (tool.toolType ==
                      //                     Tool.textTool) {
                      //                   tool.value = value;
                      //                 }
                      //                 return null;
                      //               },
                      //             ),
                      //           ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: primaryColor),
                  onPressed: () {
                    if (!_formKey.currentState.validate()) return;
                    if (tool?.isBookTool == null) {
                      showErrorDialog(context, 'You must select a target.');
                      return;
                    }
                    if (tool?.toolType == null) {
                      showErrorDialog(context, 'You must select a tool type.');
                      return;
                    }

                    Navigator.pop(context, tool);
                  },
                  child: Container(
                      width: MediaQuery.of(context).size.width * .5,
                      child: Center(
                          child: Text('Save Tool',
                              style: TextStyle(fontSize: 17))))),
              SizedBox(height: 20)
            ],
          ),
        ),
      ),
    );
  }
}
