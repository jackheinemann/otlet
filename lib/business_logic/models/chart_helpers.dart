import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:otlet/business_logic/models/tool.dart';
import 'package:uuid/uuid.dart';

class ChartType {
  static String bar = 'Bar';
  static String line = 'Line';
  static String dot = 'Dot';
  static String pie = 'Pie';

  static List<String> types = [bar, pie, line, dot];
}

class ChartScope {
  static String books = 'Books';
  static String sessions = 'Sessions (All)';
  static String singleBook = 'Sessions (Single Book)';

  static List<String> scopes = [books, sessions, singleBook];
}

class ChartFilter {
  String id;
  FilterComparator filterComparator;
  Tool pseudoTool;
  dynamic valueLimit;

  String comparatorToString({FilterComparator comparator}) {
    if (comparator == null) comparator = filterComparator;
    if (comparator == FilterComparator.equals) return '=';
    if (comparator == FilterComparator.doesNotEqual) return '!=';
    if (comparator == FilterComparator.greaterThan) return '>';
    if (comparator == FilterComparator.lessThan) return '<';
    if (comparator == FilterComparator.greaterThanEQ) return '>=';
    if (comparator == FilterComparator.lessThanEQ) return '<=';
    return null;
  }

  FilterComparator comparatorFromString(String string) {
    if (string == '=') return FilterComparator.equals;
    if (string == '!=') return FilterComparator.doesNotEqual;
    if (string == '>') return FilterComparator.greaterThan;
    if (string == '<') return FilterComparator.lessThan;
    if (string == '>=') return FilterComparator.greaterThanEQ;
    if (string == '<=') return FilterComparator.lessThanEQ;
    return null;
  }

  ChartFilter.fromFilter(ChartFilter filter) {
    id = filter.id;
    filterComparator = filter.filterComparator;
    pseudoTool = Tool.fromTool(filter.pseudoTool);
    valueLimit = filter.valueLimit;
  }

  ChartFilter.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    filterComparator = comparatorFromString(json['filterComparator']);
    pseudoTool = json['pseudoTool'];
    if (pseudoTool.isDateTime()) {
      try {
        valueLimit = DateTime.parse(json['valueLimit']);
      } catch (e) {
        print('Error parsing date: $e. Trying new style');
        try {
          valueLimit =
              DateFormat('MMMM d, y m:ss aa').parse(json['valueLimit']);
        } catch (e) {
          print('Error on second date parse: $e. Trying once more');
          try {
            valueLimit = DateFormat('MMMM d, y').parse(json['valueLimit']);
          } catch (e) {
            print('giving up on date, assigning DateTime.now()');
            valueLimit = DateTime.now();
          }
        }
      }
    } else
      valueLimit = json['valueLimit'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filterComparator': comparatorToString(comparator: filterComparator),
      'pseudoTool': pseudoTool,
      'valueLimit': pseudoTool.isDateTime() ? valueLimit.toString() : valueLimit
    };
  }

  bool compareFilterValue(Tool tool) {
    // for each toolType and comparator enum value perform the proper check

    // to satisfy a true condition, comparingValue <COMPARATOR> filterValue
    dynamic filterValue = pseudoTool.value;
    dynamic comparingValue = tool.value;
    if (filterComparator == FilterComparator.equals) {
      // EQUAL TO
      if (filterValue != comparingValue) return false;
    } else if (filterComparator == FilterComparator.doesNotEqual) {
      // DOES NOT EQUAL
      if (filterValue == comparingValue) return false;
    } else if (filterComparator == FilterComparator.greaterThan) {
      // GREATER THAN
      print('going in with greater than');
      if (tool.isOnlyDate()) {
        DateTime filterDate = filterValue as DateTime;
        DateTime comparingDate = comparingValue as DateTime;
        if (!comparingDate.isAfter(filterDate)) return false;
      } else if (tool.toolType == Tool.timeTool) {
        TimeOfDay filterTime = filterValue as TimeOfDay;
        TimeOfDay comparingTime = comparingValue as TimeOfDay;
        if (!(comparingTime.hour > filterTime.hour)) return false;
        if (!(comparingTime.minute > filterTime.minute)) return false;
      } else if (!(comparingValue > filterValue)) return false;
    } else if (filterComparator == FilterComparator.lessThan) {
      // LESS THAN
      if (tool.isOnlyDate()) {
        DateTime filterDate = filterValue as DateTime;
        DateTime comparingDate = comparingValue as DateTime;
        if (!comparingDate.isBefore(filterDate)) return false;
      } else if (tool.toolType == Tool.timeTool) {
        TimeOfDay filterTime = filterValue as TimeOfDay;
        TimeOfDay comparingTime = comparingValue as TimeOfDay;
        if (!(comparingTime.hour < filterTime.hour)) return false;
        if (!(comparingTime.minute < filterTime.minute)) return false;
      } else if (!(comparingValue < filterValue)) return false;
    } else if (filterComparator == FilterComparator.greaterThanEQ) {
      // GREATER THAN OR EQUAL TO
      if (tool.isOnlyDate()) {
        DateTime filterDate = filterValue as DateTime;
        DateTime comparingDate = comparingValue as DateTime;
        if (!comparingDate.isAfter(filterDate) || comparingDate == filterDate)
          return false;
      } else if (tool.toolType == Tool.timeTool) {
        TimeOfDay filterTime = filterValue as TimeOfDay;
        TimeOfDay comparingTime = comparingValue as TimeOfDay;
        if (!(comparingTime.hour >= filterTime.hour)) return false;
        if (!(comparingTime.minute >= filterTime.minute)) return false;
      } else if (!(comparingValue >= filterValue)) return false;
    } else if (filterComparator == FilterComparator.lessThanEQ) {
      // LESS THAN OR EQUAL TO
      if (tool.isOnlyDate()) {
        DateTime filterDate = filterValue as DateTime;
        DateTime comparingDate = comparingValue as DateTime;
        if (!comparingDate.isBefore(filterDate) || comparingDate == filterDate)
          return false;
      } else if (tool.toolType == Tool.timeTool) {
        TimeOfDay filterTime = filterValue as TimeOfDay;
        TimeOfDay comparingTime = comparingValue as TimeOfDay;
        if (!(comparingTime.hour <= filterTime.hour)) return false;
        if (!(comparingTime.minute <= filterTime.minute)) return false;
      } else if (!(comparingValue <= filterValue)) return false;
    } else
      return false; // happens only when the filterComparator is not met, which should be never
    return true;
  }

  ChartFilter(this.id, this.filterComparator, this.pseudoTool);

  ChartFilter.basic() {
    id = Uuid().v1();
  }

  String filterToolType() {
    if (pseudoTool == null) return null;
    return pseudoTool.toolType;
  }

  String filterLabel() {
    return '${pseudoTool?.name} ${comparatorToString()} ${pseudoTool?.displayValue()}';
  }

  bool filterSaveable() {
    return filterComparator != null &&
        pseudoTool != null &&
        pseudoTool?.value != null;
  }
}

enum FilterComparator {
  equals,
  doesNotEqual,
  greaterThan,
  lessThan,
  greaterThanEQ,
  lessThanEQ
}
