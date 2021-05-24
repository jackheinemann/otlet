import 'dart:convert';

import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/chart_helpers.dart';
import 'package:otlet/business_logic/models/otlet_instance.dart';
import 'package:otlet/business_logic/models/reading_session.dart';
import 'package:otlet/business_logic/models/tool.dart';
import 'package:otlet/business_logic/utils/constants.dart';
import 'package:otlet/ui/widgets/alerts/error_dialog.dart';
import 'package:uuid/uuid.dart';

import 'chart_set.dart';

class OtletChart {
  String id;
  String name;
  String type;
  String scope;
  String xToolId;
  String yToolId;
  String selectedBookId; // only for Sessions (Single Book) scope

  List<ChartFilter> filters = [];

  OtletChart({this.id, this.name, this.type, this.scope, this.filters}) {
    if (id == null) id = Uuid().v1();
    if (filters == null) filters = [];
  }

  OtletChart.basic() {
    id = Uuid().v1();
  }

  OtletChart.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    type = json['type'];
    scope = json['scope'];
    xToolId = json['xToolId'];
    yToolId = json['yToolId'];
    selectedBookId = json['selectedBookId'];
    filters = List<String>.from(json['filters'])
        .map((e) => ChartFilter.fromJson(jsonDecode(e)))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'scope': scope,
      'xToolId': xToolId,
      'yToolId': yToolId,
      'selectedBookId': selectedBookId,
      'filters': filters.map((e) => e.toJson()).toList(),
    };
  }

  void addOrModifyFilter(ChartFilter filter) {
    for (int i = 0; i < filters.length; i++) {
      ChartFilter existingFilter = filters[i];
      if (existingFilter.id == filter.id) {
        filters[i] = filter;
        return;
      }
    }
    // didnt find it, must be a new filter
    filters.add(filter);
  }

  bool requiresNumeric() => type == ChartType.dot || type == ChartType.line;

  dynamic generateChart(BuildContext context, OtletInstance instance) {
    List<ChartSet> dataSet = [];
    var series;
    List<ReadingSession> sessionsToPull;
    if (scope != ChartScope.books)
      sessionsToPull = scope == ChartScope.singleBook
          ? instance.books
              .firstWhere((book) => book.id == selectedBookId)
              .sessions
          : instance.sessionHistory;
    int loopIndex = -1;
    for (dynamic bookOrSession
        in scope == ChartScope.books ? instance.books : sessionsToPull) {
      if (!bookOrSession.doesPassChartFilters(this)) continue;
      loopIndex += 1;
      print(chartColorCodes.length);
      if (loopIndex >= chartColorCodes.length) loopIndex = 0;
      // if we make it here, the book or tool passes all the filters
      Tool xTool = (bookOrSession.tools + bookOrSession.otletTools)
          .firstWhere((t) => t.id == xToolId);
      // print('${xTool.value}: ${xTool.value.runtimeType}');
      Tool yTool;
      if (requiresNumeric())
        yTool = (bookOrSession.tools + bookOrSession.otletTools)
            .firstWhere((t) => t.id == yToolId);
      if (xTool.isActive && xTool.value != null) {
        String xToolString = xTool.displayValue();
        if (yTool == null) {
          // simple frequency graph, yVal will always be an int
          if (!dataSet.map((e) => e.xVal).toList().contains(xToolString)) {
            // dataSet does not contain this xVal, so add it
            dataSet.add(ChartSet(xToolString, 1, loopIndex));
          } else {
            for (int i = 0; i < dataSet.length; i++) {
              ChartSet chartSet = dataSet[i];
              if (chartSet.xVal == xToolString) {
                dataSet[i].yVal +=
                    1; // increment by 1 if it exists and is found
              }
            }
          }
        } else {
          // gonna be a numeric, have to do special stuff
          if (yTool.isActive && yTool.value != null) {
            print('${yTool.value} is ${yTool.value.runtimeType}');
            dataSet.add(ChartSet(xTool.value, yTool.value, loopIndex));
          }
        }
      }
    }
    if (dataSet.isEmpty) {
      showErrorDialog(context, 'No chartable data found.');
      return;
    }

    // dataset filled and ready
    if (type == ChartType.bar || type == ChartType.pie) {
      series = [
        Series<ChartSet, String>(
            id: Uuid().v1(),
            data: dataSet,
            domainFn: (ChartSet data, _) => data.xVal,
            measureFn: (ChartSet data, _) => data.yVal,
            colorFn: (ChartSet chartSet, _) =>
                Color.fromHex(code: chartColorCodes[chartSet.index]),
            labelAccessorFn: (ChartSet data, _) {
              return '${data.xVal}: ${data.yVal}';
            }),
      ];
    } else {
      if (dataSet.first.xVal.runtimeType == DateTime) {
        dataSet.sort((a, b) => a.xVal.compareTo(b.xVal));
        series = [
          Series<ChartSet, DateTime>(
              id: Uuid().v1(),
              data: dataSet,
              domainFn: (ChartSet chartSet, _) => chartSet.xVal,
              measureFn: (ChartSet chartSet, _) => chartSet.yVal,
              colorFn: (ChartSet chartSet, _) => type == ChartType.dot
                  ? Color.fromHex(code: chartColorCodes[chartSet.index])
                  : Color.fromHex(code: chartColorCodes[0])),
        ];
      } else {
        if (dataSet.first.xVal.runtimeType == int)
          series = [
            Series<ChartSet, int>(
                id: Uuid().v1(),
                data: dataSet,
                domainFn: (ChartSet chartSet, _) => chartSet.xVal,
                measureFn: (ChartSet chartSet, _) => chartSet.yVal,
                colorFn: (ChartSet chartSet, _) => type == ChartType.dot
                    ? Color.fromHex(code: chartColorCodes[chartSet.index])
                    : Color.fromHex(code: chartColorCodes[0]))
          ];
        else
          series = [
            Series<ChartSet, double>(
                id: Uuid().v1(),
                data: dataSet,
                domainFn: (ChartSet chartSet, _) => chartSet.xVal,
                measureFn: (ChartSet chartSet, _) => chartSet.yVal,
                colorFn: (ChartSet chartSet, _) => type == ChartType.dot
                    ? Color.fromHex(code: chartColorCodes[chartSet.index])
                    : Color.fromHex(code: chartColorCodes[0]))
          ];
      }
    }
    var finalChart;
    if (type == ChartType.pie) {
      finalChart = PieChart(series,
          animate: true,
          defaultRenderer: ArcRendererConfig(arcRendererDecorators: [
            ArcLabelDecorator(labelPosition: ArcLabelPosition.auto)
          ]));
    } else if (type == ChartType.bar) {
      finalChart = BarChart(
        series,
        animate: true,
      );
    } else if (dataSet.first.xVal.runtimeType == DateTime) {
      print(dataSet.map((e) => '${e.xVal} ${e.yVal}').toList());
      finalChart = TimeSeriesChart(series,
          animate: true,
          domainAxis: DateTimeAxisSpec(),
          defaultRenderer: LineRendererConfig(
              includePoints: true, includeLine: type == ChartType.line));
    } else if (type == ChartType.line) {
      finalChart = LineChart(series,
          animate: true,
          defaultRenderer: LineRendererConfig(includePoints: true));
    } else if (type == ChartType.dot) {
      finalChart = ScatterPlotChart(series, animate: true);
    }

    return finalChart;
  }
}
