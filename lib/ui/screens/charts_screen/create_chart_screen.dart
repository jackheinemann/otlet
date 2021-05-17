import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/bar_chart_set.dart';
import 'package:otlet/business_logic/models/chart_helpers.dart';
import 'package:otlet/business_logic/models/otlet_chart.dart';
import 'package:otlet/business_logic/models/otlet_instance.dart';
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
                    context, 'Select Chart Type', ChartTypes.types);
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
            if (chart.scope != null && chart.type != null)
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
                          Map<String, String> options =
                              Map<String, String>.fromIterable(relevantTools,
                                  key: (tool) => (tool as Tool).id,
                                  value: (tool) => (tool as Tool).name);

                          MapEntry toolInfo = await showIdSelectorDialog(
                              context, 'Select an x var', options);
                          if (toolInfo == null) return;
                          setState(() {
                            // chart.xToolInfo = toolInfo;
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
                        List<ChartFilter> filters = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    CreateFiltersScreen(instance, chart)));
                      },
                      decoration: InputDecoration(
                          labelText: 'Filters',
                          suffixIcon: Icon(Icons.filter_list),
                          border: OutlineInputBorder()),
                    ),
                    // SizedBox(
                    //   height: 15,
                    // ),
                    // TextFormField(
                    //   textCapitalization: TextCapitalization.words,
                    //   controller: yAxisController,
                    //   readOnly: true,
                    //   onTap: () async {
                    //     List<Tool> relevantTools = instance.tools
                    //         .where((element) => (chart.scope == ChartScope.books
                    //             ? element.isBookTool
                    //             : !element.isBookTool))
                    //         .where((element) => element.isNumeric())
                    //         .toList();

                    //     if (relevantTools.isEmpty) {
                    //       showErrorDialog(context, 'No Valid Tools Available');
                    //     } else {
                    //       Map<String, String> options =
                    //           Map<String, String>.fromIterable(relevantTools,
                    //               key: (tool) => (tool as Tool).id,
                    //               value: (tool) => (tool as Tool).name);

                    //       MapEntry toolInfo = await showIdSelectorDialog(
                    //           context, 'Select an y var', options);
                    //       if (toolInfo == null) return;
                    //       setState(() {
                    //         chart.yToolInfo = toolInfo;
                    //         yAxisController.text = toolInfo.value;
                    //       });
                    //     }
                    //   },
                    //   decoration: InputDecoration(
                    //       labelText: 'Y Axis Variable',
                    //       suffixIcon: Icon(Icons.arrow_drop_down),
                    //       border: OutlineInputBorder()),
                    //   validator: (value) {
                    //     if (value.trim().isEmpty) return 'Variable required';
                    //     return null;
                    //   },
                    // ),
                    Spacer(),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: primaryColor),
                        onPressed: () {
                          Map<String, dynamic> dataset = {};
                          // String toolId = chart.xToolInfo.key;
                          // for (Book book in instance.books) {
                          //   for (Tool tool in book.tools) {
                          //     if (tool.id == toolId) {
                          //       if (tool.isActive && tool.value != null) {
                          //         if (dataset.containsKey(tool.value))
                          //           dataset[tool.value] += 1;
                          //         else
                          //           dataset[tool.value] = 1;
                          //       }
                          //     }
                          //   }
                          // }
                          print(dataset);
                          var series = [
                            Series(
                                id: 'Source Counts',
                                data: dataset.entries
                                    .map((e) => BarChartSet(e.key, e.value))
                                    .toList(),
                                domainFn: (BarChartSet data, _) => data.label,
                                measureFn: (BarChartSet data, _) => data.value)
                          ];
                          var finalChart = BarChart(
                            series,
                            animate: true,
                          );

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Scaffold(
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
