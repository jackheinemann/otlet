import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/chart_helpers.dart';
import 'package:otlet/business_logic/models/otlet_chart.dart';
import 'package:otlet/business_logic/models/otlet_instance.dart';
import 'package:otlet/business_logic/models/tool.dart';
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
              Column(
                children: [
                  if (chart.type == ChartTypes.bar ||
                      chart.type == ChartTypes.lineDot)
                    TextFormField(
                      textCapitalization: TextCapitalization.words,
                      controller: xAxisController,
                      readOnly: true,
                      onTap: () async {
                        List<Tool> relevantTools = instance.tools
                            .where((element) => (chart.scope == ChartScope.books
                                ? element.isBookTool
                                : !element.isBookTool))
                            .toList();
                        Map<String, String> options =
                            Map<String, String>.fromIterable(relevantTools,
                                key: (tool) => (tool as Tool).id,
                                value: (tool) => (tool as Tool).name);

                        String toolID = await showIdSelectorDialog(
                            context, 'Select an x', options);

                        Tool selected = relevantTools
                            .firstWhere((element) => element.id == toolID);
                        setState(() {
                          xAxisController.text = selected.name;
                        });
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
                ],
              )
          ],
        ),
      ),
    );
  }
}
