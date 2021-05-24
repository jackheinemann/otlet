import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/otlet_chart.dart';
import 'package:otlet/business_logic/models/otlet_instance.dart';
import 'package:otlet/ui/screens/charts_screen/create_chart_screen.dart';

class ChartCard extends StatelessWidget {
  final OtletChart chart;
  final OtletInstance instance;

  ChartCard(this.chart, this.instance);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Scaffold(
                      appBar: AppBar(
                          centerTitle: true,
                          title: Text(chart.name ?? 'No name')),
                      body: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Container(
                              height: 500,
                              child: chart.generateChart(context, instance)),
                        ),
                      ),
                    )));
      },
      title: Text(chart.name ?? 'no name', style: TextStyle(fontSize: 18)),
      leading: chart.chartIcon(),
      trailing: IconButton(
          onPressed: () async {
            OtletChart temp = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CreateChartScreen(
                          instance,
                          chart: chart,
                        )));
            if (temp == null) return;
            if (temp.markedForDeletion()) {
              // delete
              instance.deleteChart(temp);
            } else {
              // modify probably?
              instance.modifyChart(temp);
            }
          },
          icon: Icon(Icons.edit)),
    );
  }
}
