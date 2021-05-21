import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/chart_set.dart';
import 'package:otlet/business_logic/models/book.dart';
import 'package:otlet/business_logic/models/chart_helpers.dart';
import 'package:otlet/business_logic/models/otlet_chart.dart';
import 'package:otlet/business_logic/models/otlet_instance.dart';
import 'package:otlet/business_logic/models/reading_session.dart';
import 'package:otlet/business_logic/models/tool.dart';
import 'package:otlet/business_logic/utils/constants.dart';
import 'package:otlet/ui/screens/charts_screen/create_filters_screen.dart';
import 'package:otlet/ui/widgets/alerts/error_dialog.dart';
import 'package:otlet/ui/widgets/alerts/id_simple_selector.dart';
import 'package:otlet/ui/widgets/alerts/simple_selector.dart';
import 'package:uuid/uuid.dart';

class CreateChartScreen extends StatefulWidget {
  final OtletInstance instance;
  CreateChartScreen(this.instance);
  @override
  _CreateChartScreenState createState() => _CreateChartScreenState();
}

class _CreateChartScreenState extends State<CreateChartScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  TextEditingController scopeController = TextEditingController();
  TextEditingController singleBookController = TextEditingController();
  TextEditingController xAxisController = TextEditingController();
  TextEditingController yAxisController = TextEditingController();
  TextEditingController filterController = TextEditingController();
  OtletChart chart;
  OtletInstance instance;

  @override
  initState() {
    super.initState();
    instance = widget.instance;
    chart = OtletChart.basic();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Create New Chart'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(height: 10),
            TextFormField(
              textCapitalization: TextCapitalization.words,
              controller: nameController,
              decoration: InputDecoration(
                  labelText: 'Chart Title (required)',
                  border: OutlineInputBorder()),
              validator: (value) {
                if (value.trim().isEmpty) return 'Title required';
                return null;
              },
            ),
            SizedBox(height: 15),
            TextFormField(
              textCapitalization: TextCapitalization.words,
              controller: typeController,
              readOnly: true,
              onTap: () async {
                String type = await showSimpleSelectorDialog(
                    context, 'Select Chart Type', ChartType.types);
                if (type == null) return;
                setState(() {
                  chart.type = type;
                  typeController.text = type;
                  // chart.xToolInfo = null;
                  // chart.yToolInfo = null;
                  chart.xToolId = null;
                  chart.yToolId = null;
                  xAxisController.clear();
                  yAxisController.clear();
                });
              },
              decoration: InputDecoration(
                  labelText: 'Chart Type',
                  suffixIcon: Icon(Icons.arrow_drop_down),
                  border: OutlineInputBorder()),
              validator: (value) {
                if (value.trim().isEmpty) return 'Type required';
                return null;
              },
            ),
            SizedBox(height: 15),
            TextFormField(
              textCapitalization: TextCapitalization.words,
              controller: scopeController,
              readOnly: true,
              onTap: () async {
                String scope = await showSimpleSelectorDialog(
                    context, 'Select Chart Scope', ChartScope.scopes);
                if (scope == null) return;
                setState(() {
                  chart.scope = scope;
                  scopeController.text = scope;
                  // chart.xToolInfo = null;
                  // chart.yToolInfo = null;
                  xAxisController.clear();
                  yAxisController.clear();
                  singleBookController.clear();
                  chart.xToolId = null;
                  chart.yToolId = null;
                  chart.selectedBookId = null;
                });
              },
              decoration: InputDecoration(
                  labelText: 'Scope',
                  suffixIcon: Icon(Icons.arrow_drop_down),
                  border: OutlineInputBorder()),
              validator: (value) {
                if (value.trim().isEmpty) return 'Scope required';
                return null;
              },
            ),
            SizedBox(height: 15),
            if (chart.scope == ChartScope.singleBook)
              TextFormField(
                textCapitalization: TextCapitalization.words,
                controller: singleBookController,
                readOnly: true,
                onTap: () async {
                  MapEntry selectedBook = await showIdSelectorDialog(
                      context,
                      'Select a book',
                      Map<String, String>.fromIterable(instance.books,
                          key: (book) => book.id, value: (book) => book.title));
                  if (selectedBook == null) return;
                  setState(() {
                    chart.selectedBookId = selectedBook.key;
                    singleBookController.text = selectedBook.value;
                  });
                },
                decoration: InputDecoration(
                    labelText: 'Book',
                    suffixIcon: Icon(Icons.arrow_drop_down),
                    border: OutlineInputBorder()),
                validator: (value) {
                  if (value.trim().isEmpty) return 'Book required';
                  return null;
                },
              ),
            if (chart.scope == ChartScope.singleBook) SizedBox(height: 15),
            if (chart.scope != null &&
                chart.type != null &&
                (chart.scope == ChartScope.singleBook
                    ? chart.selectedBookId != null
                    : true))
              Expanded(
                child: Column(
                  children: [
                    TextFormField(
                      textCapitalization: TextCapitalization.words,
                      controller: xAxisController,
                      readOnly: true,
                      onTap: () async {
                        List<Tool> relevantTools = (instance.tools +
                                instance.otletTools)
                            .where((element) => (chart.scope == ChartScope.books
                                ? element.isBookTool
                                : !element.isBookTool))
                            .toList();
                        if (relevantTools.isEmpty) {
                          showErrorDialog(context, 'No Valid Tools Available');
                        } else {
                          if (chart.requiresNumeric())
                            relevantTools
                                .removeWhere((tool) => !tool.isPlottable());
                          relevantTools
                              .sort((a, b) => a.name.compareTo(b.name));
                          Map<String, String> options =
                              Map<String, String>.fromIterable(relevantTools,
                                  key: (tool) => (tool as Tool).id,
                                  value: (tool) => (tool as Tool).name);

                          MapEntry toolInfo = await showIdSelectorDialog(
                              context, 'Select an x var', options);
                          if (toolInfo == null) return;
                          setState(() {
                            chart.xToolId = toolInfo.key;
                            xAxisController.text = toolInfo.value;
                          });
                        }
                      },
                      decoration: InputDecoration(
                          labelText: 'X Axis Variable',
                          suffixIcon: Icon(Icons.arrow_drop_down),
                          border: OutlineInputBorder()),
                      validator: (value) {
                        if (value.trim().isEmpty) return 'Variable required';
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    if (chart.requiresNumeric())
                      Column(
                        children: [
                          TextFormField(
                            textCapitalization: TextCapitalization.words,
                            controller: yAxisController,
                            readOnly: true,
                            onTap: () async {
                              List<Tool> relevantTools =
                                  (instance.tools + instance.otletTools)
                                      .where((element) =>
                                          (chart.scope == ChartScope.books
                                              ? element.isBookTool
                                              : !element.isBookTool))
                                      .toList();
                              if (relevantTools.isEmpty) {
                                showErrorDialog(
                                    context, 'No Valid Tools Available');
                              } else {
                                if (chart.requiresNumeric())
                                  relevantTools.removeWhere(
                                      (tool) => !tool.isPlottable());
                                relevantTools
                                    .sort((a, b) => a.name.compareTo(b.name));
                                Map<String, String> options =
                                    Map<String, String>.fromIterable(
                                        relevantTools,
                                        key: (tool) => (tool as Tool).id,
                                        value: (tool) => (tool as Tool).name);

                                MapEntry toolInfo = await showIdSelectorDialog(
                                    context, 'Select an y var', options);
                                if (toolInfo == null) return;
                                setState(() {
                                  chart.yToolId = toolInfo.key;
                                  yAxisController.text = toolInfo.value;
                                });
                              }
                            },
                            decoration: InputDecoration(
                                labelText: 'Y Axis Variable',
                                suffixIcon: Icon(Icons.arrow_drop_down),
                                border: OutlineInputBorder()),
                            validator: (value) {
                              if (value.trim().isEmpty)
                                return 'Variable required';
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 15,
                          ),
                        ],
                      ),
                    TextFormField(
                      controller: filterController,
                      readOnly: true,
                      onTap: () async {
                        OtletChart temp = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    CreateFiltersScreen(instance, chart)));
                        setState(() {
                          chart = temp;
                          if (chart.filters.isNotEmpty)
                            filterController.text = chart.filters
                                .map((e) => e.filterLabel())
                                .toList()
                                .join(', ');
                          else
                            filterController.clear();
                        });
                      },
                      decoration: InputDecoration(
                          labelText: 'Filters',
                          suffixIcon: Icon(Icons.filter_list),
                          border: OutlineInputBorder()),
                    ),
                    Spacer(),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: primaryColor),
                        onPressed: () {
                          List<ChartSet> dataSet = [];
                          var series;
                          List<ReadingSession> sessionsToPull;
                          if (chart.scope != ChartScope.books)
                            sessionsToPull =
                                chart.scope == ChartScope.singleBook
                                    ? instance.books
                                        .firstWhere((book) =>
                                            book.id == chart.selectedBookId)
                                        .sessions
                                    : instance.sessionHistory;
                          for (dynamic bookOrSession
                              in chart.scope == ChartScope.books
                                  ? instance.books
                                  : sessionsToPull) {
                            if (!bookOrSession.doesPassChartFilters(chart))
                              continue;
                            // if we make it here, the book or tool passes all the filters
                            Tool xTool =
                                (bookOrSession.tools + bookOrSession.otletTools)
                                    .firstWhere((t) => t.id == chart.xToolId);
                            // print('${xTool.value}: ${xTool.value.runtimeType}');
                            Tool yTool;
                            if (chart.requiresNumeric())
                              yTool = (bookOrSession.tools +
                                      bookOrSession.otletTools)
                                  .firstWhere((t) => t.id == chart.yToolId);
                            if (xTool.isActive && xTool.value != null) {
                              String xToolString = xTool.displayValue();
                              if (yTool == null) {
                                // simple frequency graph, yVal will always be an int
                                if (!dataSet
                                    .map((e) => e.xVal)
                                    .toList()
                                    .contains(xToolString)) {
                                  // dataSet does not contain this xVal, so add it
                                  dataSet.add(ChartSet(xToolString, 1));
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
                                  print(
                                      '${yTool.value} is ${yTool.value.runtimeType}');
                                  dataSet
                                      .add(ChartSet(xTool.value, yTool.value));
                                }
                              }
                            }
                          }
                          if (dataSet.isEmpty) {
                            showErrorDialog(
                                context, 'No chartable data found.');
                            return;
                          }

                          // dataset filled and ready
                          if (chart.type == ChartType.bar ||
                              chart.type == ChartType.pie) {
                            series = [
                              Series<ChartSet, String>(
                                  id: Uuid().v1(),
                                  data: dataSet,
                                  domainFn: (ChartSet data, _) => data.xVal,
                                  measureFn: (ChartSet data, _) => data.yVal,
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
                                    domainFn: (ChartSet chartSet, _) =>
                                        chartSet.xVal,
                                    measureFn: (ChartSet chartSet, _) =>
                                        chartSet.yVal)
                              ];
                            } else {
                              series = [
                                Series<ChartSet, int>(
                                    id: Uuid().v1(),
                                    data: dataSet,
                                    domainFn: (ChartSet chartSet, _) =>
                                        chartSet.xVal,
                                    measureFn: (ChartSet chartSet, _) =>
                                        chartSet.yVal)
                              ];
                            }
                          }
                          var finalChart;
                          if (chart.type == ChartType.pie) {
                            finalChart = PieChart(series,
                                animate: true,
                                defaultRenderer: ArcRendererConfig(
                                    arcRendererDecorators: [
                                      ArcLabelDecorator(
                                          labelPosition: ArcLabelPosition.auto)
                                    ]));
                          } else if (chart.type == ChartType.bar) {
                            finalChart = BarChart(
                              series,
                              animate: true,
                            );
                          } else if (dataSet.first.xVal.runtimeType ==
                              DateTime) {
                            print(dataSet
                                .map((e) => '${e.xVal} ${e.yVal}')
                                .toList());
                            finalChart = TimeSeriesChart(series,
                                animate: true,
                                defaultRenderer:
                                    LineRendererConfig(includePoints: true));
                          } else if (chart.type == ChartType.line) {
                            finalChart = LineChart(series,
                                animate: true,
                                defaultRenderer:
                                    LineRendererConfig(includePoints: true));
                          } else if (chart.type == ChartType.dot) {
                            finalChart =
                                ScatterPlotChart(series, animate: true);
                          }

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Scaffold(
                                        appBar: AppBar(
                                            centerTitle: true,
                                            title: Text(
                                                nameController.text.isEmpty
                                                    ? 'Untitled'
                                                    : nameController.text)),
                                        body: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Center(
                                            child: Container(
                                                height: 500, child: finalChart),
                                          ),
                                        ),
                                      )));
                        },
                        child: Text('Generate Chart')),
                    SizedBox(height: 30)
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
