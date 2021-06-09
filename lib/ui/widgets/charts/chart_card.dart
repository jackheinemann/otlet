import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/otlet_chart.dart';
import 'package:otlet/business_logic/models/otlet_instance.dart';
import 'package:otlet/business_logic/utils/constants.dart';

class ChartCard extends StatelessWidget {
  final OtletChart chart;
  final OtletInstance instance;
  final Function(int, {OtletChart chart}) updateScreenIndex;

  ChartCard(this.chart, this.instance, {@required this.updateScreenIndex});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => updateScreenIndex(ScreenIndex.viewChart, chart: chart),
      title: Text(chart.name ?? 'no name', style: TextStyle(fontSize: 18)),
      leading: chart.chartIcon(),
      trailing: IconButton(
          onPressed: () {
            updateScreenIndex(ScreenIndex.addEditChart, chart: chart);
          },
          icon: Icon(Icons.edit)),
    );
  }
}
