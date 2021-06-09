import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/chart_helpers.dart';
import 'package:otlet/business_logic/models/otlet_chart.dart';
import 'package:otlet/business_logic/models/otlet_instance.dart';
import 'package:otlet/business_logic/models/tool.dart';
import 'package:otlet/business_logic/utils/constants.dart';
import 'package:otlet/ui/widgets/alerts/error_dialog.dart';
import 'package:otlet/ui/widgets/alerts/id_simple_selector.dart';
import 'package:otlet/ui/widgets/charts/chart_filter_card.dart';

class CreateFiltersScreen extends StatefulWidget {
  final OtletInstance instance;
  final OtletChart chart;
  final Function(int) updateCreateChartIndex;
  CreateFiltersScreen(this.instance, this.chart,
      {@required this.updateCreateChartIndex});
  @override
  _CreateFiltersScreenState createState() => _CreateFiltersScreenState();
}

class _CreateFiltersScreenState extends State<CreateFiltersScreen> {
  OtletInstance instance;
  OtletChart chart;

  bool isEditing = false;
  bool isCreating = false;
  ChartFilter editingFilter;

  TextEditingController pseudoToolController;
  TextEditingController comparatorController;
  TextEditingController valueLimitController;

  final _formKey = GlobalKey<FormState>();

  // FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    instance = widget.instance;
    chart = widget.chart;
    pseudoToolController = TextEditingController();
    comparatorController = TextEditingController();
    valueLimitController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        widget.updateCreateChartIndex(0);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: backButton(),
              onPressed: () => widget.updateCreateChartIndex(0)),
          centerTitle: true,
          title: Text('Manage Filters'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                    SizedBox(height: 10),
                    Center(
                      child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              if (!isEditing) {
                                // starting a new filter build
                                editingFilter = ChartFilter.basic();
                              } else {
                                // save edits / add new filter
                                if (pseudoToolController.text.trim().isNotEmpty ||
                                    comparatorController.text
                                        .trim()
                                        .isNotEmpty ||
                                    valueLimitController.text
                                        .trim()
                                        .isNotEmpty) {
                                  if (!_formKey.currentState.validate()) return;
                                  if (valueLimitController.text
                                      .trim()
                                      .isEmpty) {
                                    showErrorDialog(
                                        context, 'Filter limit required');
                                    return;
                                  }
                                  chart.addOrModifyFilter(editingFilter);
                                  for (TextEditingController controller in [
                                    pseudoToolController,
                                    comparatorController,
                                    valueLimitController
                                  ]) {
                                    controller.clear();
                                  }
                                }
                              }
                              isEditing = !isEditing;
                              isCreating = isEditing;
                            });
                          },
                          child: Text(
                              isEditing
                                  ? '${editingFilter.filterSaveable() ? 'Save' : 'Cancel'}'
                                  : 'Add Filter',
                              style: TextStyle(
                                  fontSize: 16, color: primaryColor))),
                    ),
                    if (isEditing)
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                                'Filter for ${chart.scope == ChartScope.books ? 'books' : 'sessions'} where:',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w400)),
                            SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              textCapitalization: TextCapitalization.words,
                              controller: pseudoToolController,
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
                                  relevantTools
                                      .sort((a, b) => a.name.compareTo(b.name));
                                  Map<String, String> options =
                                      Map<String, String>.fromIterable(
                                          relevantTools,
                                          key: (tool) => (tool as Tool).id,
                                          value: (tool) => (tool as Tool).name);

                                  MapEntry toolInfo =
                                      await showIdSelectorDialog(context,
                                          'Select a filter var.', options);
                                  if (toolInfo == null) return;
                                  setState(() {
                                    pseudoToolController.text = toolInfo.value;
                                    // assign the tool that is the correct tool id
                                    editingFilter.pseudoTool = Tool.fromTool(
                                        relevantTools.firstWhere((element) =>
                                            element.id == toolInfo.key));
                                    valueLimitController.clear();
                                    editingFilter.pseudoTool.value = null;
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                  labelText: 'Filter Variable',
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
                            TextFormField(
                              controller: comparatorController,
                              readOnly: true,
                              onTap: () async {
                                MapEntry comparatorEntry =
                                    await showIdSelectorDialog(
                                        context,
                                        'Select a comparator',
                                        Map.fromIterables(
                                            FilterComparator.values,
                                            FilterComparator.values
                                                .map((e) => editingFilter
                                                    .comparatorToString(
                                                        comparator: e))
                                                .toList()));
                                if (comparatorEntry == null) return;
                                FilterComparator comparator =
                                    comparatorEntry.key;
                                setState(() {
                                  editingFilter.filterComparator = comparator;
                                  comparatorController.text =
                                      editingFilter.comparatorToString();
                                });
                              },
                              decoration: InputDecoration(
                                  labelText: 'Comparator',
                                  suffixIcon: Icon(Icons.arrow_drop_down),
                                  border: OutlineInputBorder()),
                              validator: (value) {
                                if (value.trim().isEmpty)
                                  return 'Comparator required';
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            if (editingFilter.pseudoTool != null)
                              editingFilter.pseudoTool.generateValueInput(
                                  context, valueLimitController, FocusNode(),
                                  labelText: 'Filter Limit',
                                  onValueChange: (value) {
                                setState(() {
                                  editingFilter.pseudoTool.value = value;
                                  if (editingFilter
                                      .pseudoTool.useFixedOptions) {
                                    valueLimitController.text =
                                        editingFilter.pseudoTool.displayValue();
                                  }
                                  // editingFilter.valueLimit = value;
                                  // valueLimitController.text =
                                  //     editingFilter.pseudoTool.displayValue();
                                });
                              })
                          ],
                        ),
                      ),
                  ] +
                  [
                    SizedBox(height: 15),
                    if (chart.filters.isNotEmpty && !isEditing)
                      Text('Filters',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500))
                  ] +
                  [
                    if (!isEditing)
                      Column(
                        children: chart.filters.map((e) {
                          return ChartFilterCard(
                            e,
                            editFilter: () {
                              if (isEditing) return;
                              // edit a filter
                              setState(() {
                                isEditing = true;
                                editingFilter = e;
                                pseudoToolController.text = e.pseudoTool.name;
                                comparatorController.text =
                                    e.comparatorToString();
                                valueLimitController.text =
                                    e.pseudoTool.displayValue();
                              });
                            },
                            deleteFilter: () {
                              setState(() {
                                chart.filters.removeWhere(
                                    (element) => element.id == e.id);
                              });
                            },
                          );
                        }).toList(),
                      )
                  ],
            ),
          ),
        ),
      ),
    );
  }
}
