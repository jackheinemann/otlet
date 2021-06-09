import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:otlet/business_logic/models/otlet_instance.dart';
import 'package:otlet/business_logic/models/tool.dart';
import 'package:otlet/ui/widgets/alerts/confirm_dialog.dart';
import 'package:otlet/ui/widgets/alerts/error_dialog.dart';
import 'package:otlet/ui/widgets/alerts/simple_selector.dart';
import 'package:provider/provider.dart';

import '../../../business_logic/utils/constants.dart';
import 'create_fixed_options_screen.dart';

class CreateCustomToolScreen extends StatefulWidget {
  final bool isEdit;
  final Tool tool;
  final Function(int) updateScreenIndex;

  CreateCustomToolScreen(
      {this.isEdit = false, this.tool, @required this.updateScreenIndex});
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
      tool = Tool.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OtletInstance>(
      builder: (context, instance, _) => WillPopScope(
        onWillPop: () async {
          bool shouldPop = await showConfirmDialog('Discard changes?', context);
          if (shouldPop) widget.updateScreenIndex(ScreenIndex.mainTabs);
          return Future.value(false);
        },
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            leading: IconButton(
                icon: backButton(),
                onPressed: () async {
                  bool shouldPop =
                      await showConfirmDialog('Discard changes?', context);
                  if (shouldPop) widget.updateScreenIndex(ScreenIndex.mainTabs);
                  return Future.value(false);
                }),
            title: Text(isEdit ? 'Edit ${tool.name}' : 'Create Custom Tool'),
            actions: [
              if (isEdit)
                IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      bool shouldDelete = await showConfirmDialog(
                          'Delete tool ${tool.name}?', context);
                      if (!shouldDelete) return;
                      instance.deleteTool(tool);
                      widget.updateScreenIndex(ScreenIndex.mainTabs);
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 7.0),
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
                                if (tool.fixedOptions != null)
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
                                    List<dynamic> fixedOptions =
                                        await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CreateFixedOptionsScreen(
                                                        tool)));
                                    if (fixedOptions == null) return;

                                    setState(() {
                                      tool.fixedOptions =
                                          List<dynamic>.from(fixedOptions);
                                      fixedOptionsController.text = tool
                                          .fixedOptions
                                          .map((e) => e.toString())
                                          .toList()
                                          .join(', ');
                                    });
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
                          showErrorDialog(
                              context, 'You must select a tool type.');
                          return;
                        }

                        if (isEdit) {
                          instance.modifyTool(tool);
                        } else {
                          instance.addNewTool(tool);
                        }
                        widget.updateScreenIndex(ScreenIndex.mainTabs);
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
        ),
      ),
    );
  }
}
