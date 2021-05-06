import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    booleanTool,
    integerTool,
    doubleTool,
    textTool,
    dateTool,
    timeTool,
    dateTimeTool
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
    print('making a tool from $name');
    toolType = json['toolType'];
    isBookTool = json['isBookTool'];
    print('made it through isBookTool');
    if (json['value'] != null && json['value'] != 'null') {
      print('not null: ${json['value']}');
      print('${json['value']}');
      if (isDateTime()) {
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
      }
      // value = isDateTime() ? DateTime.parse(json['value']) : json['value'];
      // print(value);
      if (toolType == Tool.timeTool) value = TimeOfDay.fromDateTime(value);
    }
    print('made it through value');
    useFixedOptions = json['useFixedOptions'];
    if (useFixedOptions && json['fixedOptions'] != null)
      fixedOptions = List<dynamic>.from(jsonDecode(json['fixedOptions']));
    if (json['created'] != null) created = DateTime.parse(json['created']);
    print('made it through created');
    isActive = json['isActive'];
    print('made it through isActive');
    setActiveForAll = json['setActiveForAll'];
  }

  void assignValueFromString(String stringVal) {
    if (toolType == Tool.integerTool) {
      value = int.tryParse(stringVal);
    } else if (toolType == Tool.doubleTool) {
      value = double.tryParse(stringVal);
    } else if (toolType == Tool.textTool) {
      value = stringVal;
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

  Tool generalize() {
    Tool generalized = Tool.fromTool(this);
    generalized.value = null;
    return generalized;
  }

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
      'value': isDateTime() ? value.toString() : value,
      'useFixedOptions': useFixedOptions,
      if (useFixedOptions)
        'fixedOptions':
            jsonEncode(fixedOptions.map((e) => e.toString()).toList()),
      if (created != null) 'created': created.toString(),
      'isActive': isActive,
      'setActiveForAll': setActiveForAll
    };
  }
}
