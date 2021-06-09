import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/chart_set.dart';
import 'package:otlet/business_logic/models/chart_helpers.dart';
import 'package:otlet/business_logic/models/otlet_chart.dart';
import 'package:otlet/business_logic/models/otlet_instance.dart';
import 'package:otlet/business_logic/models/reading_session.dart';
import 'package:otlet/business_logic/models/tool.dart';
import 'package:otlet/business_logic/utils/constants.dart';
import 'package:otlet/ui/screens/charts_screen/create_filters_screen.dart';
import 'package:otlet/ui/widgets/alerts/confirm_dialog.dart';
import 'package:otlet/ui/widgets/alerts/error_dialog.dart';
import 'package:otlet/ui/widgets/alerts/id_simple_selector.dart';
import 'package:otlet/ui/widgets/alerts/simple_selector.dart';

class CreateChartScreen extends StatefulWidget {
  final OtletChart chart;
  final OtletInstance instance;
  final Function(int) updateScreenIndex;
  CreateChartScreen(
      {this.chart, @required this.instance, @required this.updateScreenIndex});
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

  bool isEditing;

  int _editChartIndex = 0; // for local navigation within the hierarchy

  @override
  initState() {
    super.initState();
    instance = widget.instance;
    chart = widget.chart ?? OtletChart.basic();
    isEditing = widget.chart != null;
    if (chart.name != null) nameController.text = chart.name;
    typeController.text = chart.type;
    scopeController.text = chart.scope;
    if (instance.books
        .map((e) => e.id)
        .toList()
        .contains(chart.selectedBookId ?? 'no id'))
      singleBookController.text = instance.books
          .firstWhere((element) => element.id == chart.selectedBookId)
          .title;
    else
      chart.selectedBookId = null; // handle missing book
    if ((instance.tools + instance.otletTools)
        .map((e) => e.id)
        .toList()
        .contains(chart.xToolId ?? 'no id'))
      xAxisController.text = (instance.tools + instance.otletTools)
          .firstWhere((element) => element.id == chart.xToolId)
          .name;
    else
      chart.xToolId = null;
    if ((instance.tools + instance.otletTools)
        .map((e) => e.id)
        .toList()
        .contains(chart.yToolId ?? 'no id'))
      yAxisController.text = (instance.tools + instance.otletTools)
          .firstWhere((element) => element.id == chart.yToolId)
          .name;
    else
      chart.yToolId = null;
    filterController.text =
        chart.filters.map((e) => e.filterLabel()).toList().join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return _editChartIndex == 0
        ? WillPopScope(
            onWillPop: () async {
              bool shouldPop =
                  await showConfirmDialog('Discard changes?', context);
              if (shouldPop) widget.updateScreenIndex(ScreenIndex.mainTabs);
              return Future.value(false);
            },
            child: Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: Text('Create New Chart'),
                leading: IconButton(
                    icon: backButton(),
                    onPressed: () async {
                      bool shouldPop =
                          await showConfirmDialog('Discard changes?', context);
                      if (shouldPop)
                        widget.updateScreenIndex(ScreenIndex.mainTabs);
                    }),
                actions: [
                  if (isEditing)
                    IconButton(
                        onPressed: () async {
                          bool shouldDelete = await showConfirmDialog(
                              'Delete chart ${chart.name}?', context);
                          if (!shouldDelete) return;
                          instance.deleteChart(chart);
                          widget.updateScreenIndex(ScreenIndex.mainTabs);
                        },
                        icon: Icon(Icons.delete))
                ],
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
                                  key: (book) => book.id,
                                  value: (book) => book.title));
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
                    if (chart.scope == ChartScope.singleBook)
                      SizedBox(height: 15),
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

                                  MapEntry toolInfo =
                                      await showIdSelectorDialog(
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
                                if (value.trim().isEmpty)
                                  return 'Variable required';
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
                                    textCapitalization:
                                        TextCapitalization.words,
                                    controller: yAxisController,
                                    readOnly: true,
                                    onTap: () async {
                                      List<Tool> relevantTools =
                                          (instance.tools + instance.otletTools)
                                              .where((element) =>
                                                  (chart.scope ==
                                                          ChartScope.books
                                                      ? element.isBookTool
                                                      : !element.isBookTool))
                                              .toList();
                                      if (relevantTools.isEmpty) {
                                        showErrorDialog(context,
                                            'No Valid Tools Available');
                                      } else {
                                        if (chart.requiresNumeric())
                                          relevantTools.removeWhere(
                                              (tool) => !tool.isNumeric());
                                        relevantTools.sort(
                                            (a, b) => a.name.compareTo(b.name));
                                        Map<String, String> options =
                                            Map<String, String>.fromIterable(
                                                relevantTools,
                                                key: (tool) =>
                                                    (tool as Tool).id,
                                                value: (tool) =>
                                                    (tool as Tool).name);

                                        MapEntry toolInfo =
                                            await showIdSelectorDialog(context,
                                                'Select an y var', options);
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
                                setState(() {
                                  _editChartIndex = 1;
                                });
                              },
                              decoration: InputDecoration(
                                  labelText: 'Filters',
                                  suffixIcon: Icon(Icons.filter_list),
                                  border: OutlineInputBorder()),
                            ),
                            Spacer(),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: primaryColor),
                                onPressed: () {
                                  List<ChartSet> dataSet = [];
                                  // var series;
                                  List<ReadingSession> sessionsToPull;
                                  if (chart.scope != ChartScope.books)
                                    sessionsToPull = chart.scope ==
                                            ChartScope.singleBook
                                        ? instance.books
                                            .firstWhere((book) =>
                                                book.id == chart.selectedBookId)
                                            .sessions
                                        : instance.sessionHistory;
                                  int loopIndex = -1;
                                  for (dynamic bookOrSession
                                      in chart.scope == ChartScope.books
                                          ? instance.books
                                          : sessionsToPull) {
                                    if (!bookOrSession
                                        .doesPassChartFilters(chart)) continue;
                                    loopIndex += 1;
                                    print(chartColorCodes.length);
                                    if (loopIndex >= chartColorCodes.length)
                                      loopIndex = 0;
                                    // if we make it here, the book or tool passes all the filters
                                    Tool xTool = (bookOrSession.tools +
                                            bookOrSession.otletTools)
                                        .firstWhere(
                                            (t) => t.id == chart.xToolId);
                                    // print('${xTool.value}: ${xTool.value.runtimeType}');
                                    Tool yTool;
                                    if (chart.requiresNumeric())
                                      yTool = (bookOrSession.tools +
                                              bookOrSession.otletTools)
                                          .firstWhere(
                                              (t) => t.id == chart.yToolId);
                                    if (xTool.isActive && xTool.value != null) {
                                      String xToolString = xTool.displayValue();
                                      if (yTool == null) {
                                        // simple frequency graph, yVal will always be an int
                                        if (!dataSet
                                            .map((e) => e.xVal)
                                            .toList()
                                            .contains(xToolString)) {
                                          // dataSet does not contain this xVal, so add it
                                          dataSet.add(ChartSet(
                                              xToolString, 1, loopIndex));
                                        } else {
                                          for (int i = 0;
                                              i < dataSet.length;
                                              i++) {
                                            ChartSet chartSet = dataSet[i];
                                            if (chartSet.xVal == xToolString) {
                                              dataSet[i].yVal +=
                                                  1; // increment by 1 if it exists and is found
                                            }
                                          }
                                        }
                                      } else {
                                        // gonna be a numeric, have to do special stuff
                                        if (yTool.isActive &&
                                            yTool.value != null) {
                                          print(
                                              '${yTool.value} is ${yTool.value.runtimeType}');
                                          dataSet.add(ChartSet(xTool.value,
                                              yTool.value, loopIndex));
                                        }
                                      }
                                    }
                                  }
                                  if (dataSet.isEmpty) {
                                    showErrorDialog(
                                        context, 'No chartable data found.');
                                    return;
                                  }
                                  if (nameController.text.isNotEmpty)
                                    chart.name = nameController.text.trim();
                                  else
                                    chart.name =
                                        'Chart ${instance.charts.length + 1}';
                                  // dataset filled and ready

                                  isEditing
                                      ? instance.modifyChart(chart)
                                      : instance.addNewChart(chart);
                                  widget
                                      .updateScreenIndex(ScreenIndex.mainTabs);
                                },
                                child: Text(isEditing
                                    ? 'Save Chart'
                                    : 'Generate Chart')),
                            SizedBox(height: 30)
                          ],
                        ),
                      )
                  ],
                ),
              ),
            ),
          )
        : CreateFiltersScreen(instance, chart, updateCreateChartIndex: (index) {
            print('hellooo');
            setState(() {
              _editChartIndex = index;
              print(_editChartIndex);
              if (chart.filters.isNotEmpty)
                filterController.text = chart.filters
                    .map((e) => e.filterLabel())
                    .toList()
                    .join(', ');
              else
                filterController.clear();
            });
          });
  }
}
