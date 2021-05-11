import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/otlet_instance.dart';
import 'package:otlet/business_logic/utils/constants.dart';
import 'package:otlet/ui/screens/charts_screen/create_chart_screen.dart';
import 'package:provider/provider.dart';

class ViewChartsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<OtletInstance>(builder: (context, instance, _) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No Charts Here', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            ElevatedButton(
                style: ElevatedButton.styleFrom(primary: primaryColor),
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CreateChartScreen(instance)));
                },
                child:
                    Text('Create New Chart', style: TextStyle(fontSize: 17))),
          ],
        ),
      );
    });
  }
}
