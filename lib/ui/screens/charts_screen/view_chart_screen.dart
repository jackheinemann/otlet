import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/otlet_chart.dart';
import 'package:otlet/business_logic/models/otlet_instance.dart';
import 'package:otlet/business_logic/utils/constants.dart';
import 'package:provider/provider.dart';

class ViewChartScreen extends StatelessWidget {
  final OtletChart chart;
  final Function(int) updateScreenIndex;

  ViewChartScreen(this.chart, {@required this.updateScreenIndex});
  @override
  Widget build(BuildContext context) {
    return Consumer<OtletInstance>(
      builder: (context, instance, _) => WillPopScope(
        onWillPop: () {
          updateScreenIndex(ScreenIndex.mainTabs);
          return Future.value(false);
        },
        child: Scaffold(
          appBar: AppBar(
              leading: IconButton(
                  icon: backButton(),
                  onPressed: () => updateScreenIndex(ScreenIndex.mainTabs)),
              centerTitle: true,
              title: Text(chart.name ?? 'No name')),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Container(
                  height: 500, child: chart.generateChart(context, instance)),
            ),
          ),
        ),
      ),
    );
  }
}
