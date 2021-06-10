import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:otlet/ui/widgets/alerts/error_dialog.dart';
import 'package:otlet/ui/widgets/alerts/simple_selector.dart';
import 'package:uuid/uuid.dart';

class Tool {
  String id;
  String name;
  String toolType;
  DateTime created = DateTime.now();

  TextEditingController dynamicToolController = TextEditingController();

  bool isBookTool;

  bool isActive = false;
  bool setActiveForAll = false;

  static String booleanTool = 'True/False';
  static String integerTool = 'Integer';
  static String doubleTool = 'Decimal';
  static String textTool = 'Text';
  static String dateTool = 'Date Only';
  static String timeTool = 'Time Only';
  static String dateTimeTool = 'Date and Time';
  static List<String> toolTypes = [
    textTool,
    integerTool,
    doubleTool,
    dateTool,
    // timeTool,
    dateTimeTool,
    booleanTool,
  ];

  Type valueType;
  dynamic value;
  bool useFixedOptions = false;
  List<dynamic> fixedOptions = [];

  Tool(
      {String customId,
      this.name,
      this.toolType,
      this.created,
      this.isBookTool,
      this.isActive,
      this.setActiveForAll,
      this.valueType,
      this.value,
      this.useFixedOptions,
      this.fixedOptions}) {
    id = customId ?? Uuid().v1();
  }

  Tool.empty() {
    id = Uuid().v1();
  }

  Tool.fromTool(Tool tool) {
    id = tool.id;
    name = tool.name;
    toolType = tool.toolType;
    isBookTool = tool.isBookTool;
    valueType = tool.valueType;
    value = tool.value;
    useFixedOptions = tool.useFixedOptions;
    if (useFixedOptions) fixedOptions = List<dynamic>.from(tool.fixedOptions);
    created = tool.created;
    isActive = tool.isActive;
    setActiveForAll = tool.setActiveForAll;
  }

  Tool.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    toolType = json['toolType'];
    isBookTool = json['isBookTool'];
    if (json['value'] != null && json['value'] != 'null') {
      if (isDateTime()) {
        if (toolType == Tool.timeTool) {
          value = TimeOfDay.fromDateTime(
              DateFormat('h:mm aa').parse(json['value']));
        } else
          try {
            value = DateTime.parse(json['value']);
          } catch (e) {
            print('Error parsing date: $e. Trying new style');
            try {
              value = DateFormat('MMMM d, y m:ss aa').parse(json['value']);
            } catch (e) {
              print('Error on second date parse: $e. Trying once more');
              try {
                value = DateFormat('MMMM d, y').parse(json['value']);
              } catch (e) {
                print('giving up on date, assigning DateTime.now()');
                value = DateTime.now();
              }
            }
          }
      } else
        value = json['value'];
    }
    useFixedOptions = json['useFixedOptions'];
    if (useFixedOptions && json['fixedOptions'] != null)
      fixedOptions = List<dynamic>.from(jsonDecode(json['fixedOptions']));
    if (json['created'] != null) created = DateTime.parse(json['created']);
    isActive = json['isActive'];
    setActiveForAll = json['setActiveForAll'];
  }

  void assignValueFromString(String stringVal) {
    if (toolType == Tool.integerTool) {
      value = int.tryParse(stringVal);
    } else if (toolType == Tool.doubleTool) {
      value = double.tryParse(stringVal);
    } else if (toolType == Tool.textTool) {
      value = stringVal;
    } else if (toolType == Tool.dateTimeTool) {
      value = DateFormat('MMMM d, y h:mm aa').parse(stringVal);
    } else if (toolType == Tool.dateTool) {
      value = DateFormat('MMMM d').parse(stringVal);
    } else {
      // toolType == Tool.timeTool
      DateTime timeOfDayDT = DateFormat('h:mm aa').parse(value);
      value = TimeOfDay.fromDateTime(timeOfDayDT);
    }
  }

  bool compareToolId(Tool tool) {
    if (tool == null) return false;
    return tool.id == id;
  }

  bool compareToTool(Tool tool) {
    if (id == tool.id || this == tool) return true;
    if (name != tool.name) return false;
    if (toolType != tool.toolType) return false;
    if (isBookTool != tool.isBookTool) return false;
    if (value != tool.value) return false;
    if (useFixedOptions != tool.useFixedOptions) return false;
    if ((fixedOptions ?? ['placeholder'][0]) !=
            (tool.fixedOptions ?? ['placeholder'][0]) ||
        fixedOptions.length != tool.fixedOptions.length) return false;

    return true;
  }

  String displayValue() {
    if (value == null) return '';
    if (isSpecialGrade()) {
      if (isDateTime()) {
        if (isOnlyDate()) {
          return DateFormat('MMMM d, y${includesTime() ? ' h:mm aa' : ''}')
              .format(value);
        } else {
          TimeOfDay timeOfDay = value as TimeOfDay;
          return DateFormat('h:mm aa')
              .format(DateTime(1, 1, 1, timeOfDay.hour, timeOfDay.minute));
        }
      } else {
        return value.toString();
      }
    } else
      return value.toString();
  }

  Tool generalize() {
    Tool generalized = Tool.fromTool(this);
    generalized.value = null;
    return generalized;
  }

  Widget generateValueInput(BuildContext context,
      TextEditingController valueController, FocusNode focusNode,
      {@required Function(dynamic) onValueChange, String labelText}) {
    TextFormField textFormField;
    if (value != null && isSpecialGrade())
      valueController.text = displayValue();
    if (labelText == null) labelText = 'Value';

    if (useFixedOptions) {
      // just show a simple selector
      textFormField = TextFormField(
        controller: valueController,
        decoration:
            InputDecoration(labelText: labelText, border: OutlineInputBorder()),
        readOnly: true,
        onTap: () async {
          dynamic result = await showSimpleSelectorDialog(
              context, 'Select a value for $name', fixedOptions);
          if (result == null) return;
          value = result;
          onValueChange(value);
        },
      );
    } else {
      if (isSpecialGrade()) {
        // gonna need some special stuff
        textFormField = TextFormField(
          controller: valueController,
          decoration: InputDecoration(
              labelText: labelText, border: OutlineInputBorder()),
          readOnly: true,
          onTap: () async {
            if (isDateTime()) {
              if (isOnlyDate()) {
                DateTime dateTime = await showDatePicker(
                    context: context,
                    initialDate: value == null ? DateTime.now() : value,
                    firstDate:
                        DateTime.now().subtract(Duration(days: 365) * 50),
                    lastDate: DateTime.now().add(Duration(days: 365) * 50));
                if (dateTime == null) return;
                if (toolType == Tool.dateTimeTool) {
                  TimeOfDay timeOfDay = await showTimePicker(
                      context: context, initialTime: TimeOfDay.now());
                  if (timeOfDay == null) return;
                  dateTime = DateTime(dateTime.year, dateTime.month,
                      dateTime.day, timeOfDay.hour, timeOfDay.minute);
                }
                onValueChange(dateTime);
              } else {
                // is just TimeOfDay
                TimeOfDay timeOfDay = await showTimePicker(
                    context: context, initialTime: TimeOfDay.now());
                if (timeOfDay == null) return;
                onValueChange(timeOfDay);
              }
            } else {
              bool val = await showSimpleSelectorDialog(
                  context, 'Select a value', [true, false]);
              onValueChange(val);
            }
          },
        );
      } else {
        // either decimal, integer, or text
        textFormField = TextFormField(
          focusNode: focusNode,
          textCapitalization: TextCapitalization.words,
          keyboardType: toolType == Tool.textTool
              ? TextInputType.text
              : TextInputType.numberWithOptions(signed: true),
          controller: valueController,
          decoration: InputDecoration(
              labelText: labelText, border: OutlineInputBorder()),
          onEditingComplete: () {
            FocusScope.of(context).unfocus();
            String input = valueController.text.trim();
            if (input.isEmpty) return;
            if (toolType == Tool.textTool)
              onValueChange(input);
            else if (toolType == Tool.doubleTool) {
              double val = double.tryParse(input);
              if (val == null)
                showErrorDialog(
                    context, '$input is not a valid decimal value.');
              else
                onValueChange(val);
            } else {
              int val = int.tryParse(input);
              if (val == null)
                showErrorDialog(
                    context, '$input is not a valid integer value.');
              else
                onValueChange(val);
            }
          },
        );
      }
    }
    return textFormField;
  }

  bool isOnlyDate() =>
      toolType == Tool.dateTimeTool || toolType == Tool.dateTool;

  bool includesTime() {
    return toolType == Tool.timeTool || toolType == Tool.dateTimeTool;
  }

  bool isDateTime() {
    return (toolType == Tool.dateTimeTool) ||
        (toolType == Tool.dateTool || toolType == Tool.timeTool);
  }

  bool isInitialized() {
    return toolType != null && isBookTool != null;
  }

  bool isMarkedForDeletion() => name == null;

  bool isNumeric() {
    return (toolType == integerTool || toolType == doubleTool);
  }

  bool isPlottable() => isNumeric() || isDateTime();

  bool isSpecialGrade() {
    if ((toolType == Tool.booleanTool || toolType == Tool.dateTimeTool) ||
        (toolType == Tool.dateTool || toolType == Tool.timeTool)) return true;
    return false;
  }

  void setToolType(String toolType) {
    if (toolType == Tool.booleanTool)
      valueType = bool;
    else if (toolType == Tool.integerTool)
      valueType = int;
    else if (toolType == Tool.doubleTool)
      valueType = double;
    else if (toolType == Tool.textTool)
      valueType = String;
    else if (toolType == Tool.timeTool) {
      valueType = TimeOfDay;
    } else
      valueType = DateTime;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'toolType': toolType,
      'isBookTool': isBookTool,
      if (value != null)
        'value': isDateTime()
            ? (toolType == Tool.timeTool
                ? DateFormat('h:mm aa')
                    .format(DateTime(1, 1, 1, value.hour, value.minute))
                : value.toString())
            : value,
      'useFixedOptions': useFixedOptions,
      if (useFixedOptions) 'fixedOptions': jsonEncode(fixedOptions),
      if (created != null) 'created': created.toString(),
      'isActive': isActive,
      'setActiveForAll': setActiveForAll
    };
  }
}
