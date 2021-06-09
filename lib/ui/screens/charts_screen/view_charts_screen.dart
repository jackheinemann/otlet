import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/otlet_chart.dart';
import 'package:otlet/business_logic/models/otlet_instance.dart';
import 'package:otlet/business_logic/utils/constants.dart';
import 'package:otlet/ui/widgets/charts/chart_card.dart';
import 'package:provider/provider.dart';

class ViewChartsScreen extends StatelessWidget {
  final Function(int, {OtletChart chart}) updateScreenIndex;

  ViewChartsScreen({@required this.updateScreenIndex});
  @override
  Widget build(BuildContext context) {
    return Consumer<OtletInstance>(builder: (context, instance, _) {
      return instance.charts.isNotEmpty
          ? ListView.builder(
              itemCount: instance.charts.length,
              itemBuilder: (context, i) => ChartCard(
                    instance.charts[i],
                    instance,
                    updateScreenIndex: (index, {chart}) =>
                        updateScreenIndex(index, chart: chart),
                  ))
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No Charts Here', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: primaryColor),
                      onPressed: () {
                        updateScreenIndex(ScreenIndex.addEditChart);
                      },
                      child: Text('Create New Chart',
                          style: TextStyle(fontSize: 17))),
                ],
              ),
            );
    });
  }
}
