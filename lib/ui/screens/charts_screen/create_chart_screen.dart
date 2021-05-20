import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/label_chart_set.dart';
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
                          Map<String, int> dataSet = {};
                          var series;
                          if (chart.scope == ChartScope.books) {
                            // book only
                            for (Book book in instance.books) {
                              if (!book.doesPassChartFilters(chart)) continue;
                              // if we make it here, the book passes all the filters
                              Tool bookTool = (book.tools + book.otletTools)
                                  .firstWhere((t) => t.id == chart.xToolId);
                              if (bookTool.isActive && bookTool.value != null) {
                                String bookToolString = bookTool.displayValue();
                                if (dataSet.containsKey(bookToolString))
                                  dataSet[bookToolString] += 1;
                                else
                                  dataSet[bookToolString] = 1;
                              }
                            }
                          } else {
                            List<ReadingSession> sessionsToPull =
                                chart.scope == ChartScope.singleBook
                                    ? instance.books
                                        .firstWhere((book) =>
                                            book.id == chart.selectedBookId)
                                        .sessions
                                    : instance.sessionHistory;
                            for (ReadingSession session in sessionsToPull) {
                              if (!session.doesPassChartFilters(chart))
                                continue;
                              // if we make it here, the session passes all the filters
                              Tool sessionTool =
                                  (session.tools + session.otletTools)
                                      .firstWhere((t) => t.id == chart.xToolId);
                              print(sessionTool.toJson());
                              if (sessionTool.isActive &&
                                  sessionTool.value != null) {
                                String sessionToolString =
                                    sessionTool.displayValue();
                                if (dataSet.containsKey(sessionToolString))
                                  dataSet[sessionToolString] += 1;
                                else
                                  dataSet[sessionToolString] = 1;
                              }
                            }
                          }
                          if (dataSet.isEmpty) {
                            showErrorDialog(
                                context, 'No chartable data found.');
                            return;
                          }

                          // dataset filled and ready
                          int total =
                              dataSet.values.toList().reduce((a, b) => a + b);
                          if (chart.type == ChartType.bar ||
                              chart.type == ChartType.pie) {
                            series = [
                              Series<LabelChartSet, String>(
                                  id: 'Sources Filtered',
                                  data: dataSet.entries
                                      .map((e) => LabelChartSet(e.key, e.value))
                                      .toList(),
                                  domainFn: (LabelChartSet data, _) {
                                    return data.label;
                                  },
                                  measureFn: (LabelChartSet data, _) =>
                                      data.value,
                                  labelAccessorFn: (LabelChartSet data, _) {
                                    return '${data.label}: ${data.value}';
                                    // return data.label +
                                    //     ': ' +
                                    //     ((data.value * 1.0 / total) * 100)
                                    //         .toStringAsFixed(2) +
                                    //     '%';
                                  }),
                            ];
                          } else {
                            series = [
                              Series<Map<int, int>, int>(
                                  id: 'id',
                                  data: [
                                    {1: 1},
                                    {2: 2},
                                    {14: 1},
                                    {15: 1},
                                    {50: 50}
                                  ],
                                  domainFn: (Map<int, int> map, _) =>
                                      map.keys.first,
                                  measureFn: (Map<int, int> map, _) =>
                                      map.values.first)
                            ];
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
                          } else if (chart.type == ChartType.line) {
                            finalChart = LineChart(series, animate: true);
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
