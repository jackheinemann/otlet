import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/otlet_chart.dart';
import 'package:otlet/business_logic/models/otlet_instance.dart';
import 'package:otlet/business_logic/utils/constants.dart';
import 'package:otlet/ui/screens/charts_screen/create_chart_screen.dart';
import 'package:provider/provider.dart';

class ViewChartsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<OtletInstance>(builder: (context, instance, _) {
      return instance.charts.isNotEmpty
          ? ListView.builder(
              itemCount: instance.charts.length,
              itemBuilder: (context, i) => ListTile(
                    onTap: () {
                      OtletChart chart = instance.charts[i];
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
                                            child: chart.generateChart(
                                                context, instance)),
                                      ),
                                    ),
                                  )));
                    },
                    title: Text(instance.charts[i].name ?? 'No Name'),
                  ))
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No Charts Here', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: primaryColor),
                      onPressed: () async {
                        OtletChart temp = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    CreateChartScreen(instance)));
                        if (temp == null) return;
                        instance.addNewChart(temp);
                      },
                      child: Text('Create New Chart',
                          style: TextStyle(fontSize: 17))),
                ],
              ),
            );
    });
  }
}
