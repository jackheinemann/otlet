import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/chart_helpers.dart';
import 'package:otlet/business_logic/models/otlet_chart.dart';
import 'package:otlet/business_logic/models/otlet_instance.dart';
import 'package:otlet/business_logic/models/tool.dart';
import 'package:otlet/business_logic/utils/constants.dart';
import 'package:otlet/ui/widgets/alerts/error_dialog.dart';
import 'package:otlet/ui/widgets/alerts/id_simple_selector.dart';

class CreateFiltersScreen extends StatefulWidget {
  final OtletInstance instance;
  final OtletChart chart;
  CreateFiltersScreen(this.instance, this.chart);
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
    return Scaffold(
      appBar: AppBar(
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
                                  comparatorController.text.trim().isNotEmpty ||
                                  valueLimitController.text.trim().isNotEmpty) {
                                if (!_formKey.currentState.validate()) return;
                                if (valueLimitController.text.trim().isEmpty) {
                                  print('hey');
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
                            style:
                                TextStyle(fontSize: 16, color: primaryColor))),
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
                                Map<String, String> options =
                                    Map<String, String>.fromIterable(
                                        relevantTools,
                                        key: (tool) => (tool as Tool).id,
                                        value: (tool) => (tool as Tool).name);

                                MapEntry toolInfo = await showIdSelectorDialog(
                                    context, 'Select an filter var', options);
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
                                          FilterComparator
                                              .values
                                              .map((e) => editingFilter
                                                  .comparatorString(
                                                      comparator: e))
                                              .toList()));
                              if (comparatorEntry == null) return;
                              FilterComparator comparator = comparatorEntry.key;
                              setState(() {
                                editingFilter.filterComparator = comparator;
                                comparatorController.text =
                                    editingFilter.comparatorString();
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
                                context, valueLimitController,
                                labelText: 'Filter Limit',
                                onValueChange: (value) {
                              setState(() {
                                editingFilter.pseudoTool.value = value;
                                // editingFilter.valueLimit = value;
                                // valueLimitController.text =
                                //     editingFilter.pseudoTool.displayValue();
                              });
                            })
                        ],
                      ),
                    ),
                ] +
                chart.filters.map((e) {
                  return ListTile(title: Text(e.filterLabel()));
                }).toList(),
          ),
        ),
      ),
    );
  }
}
