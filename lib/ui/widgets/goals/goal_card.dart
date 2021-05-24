import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/goal.dart';
import 'package:otlet/business_logic/utils/constants.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;

  GoalCard(this.goal);
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * .2,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Goal',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  Text('${goal.daysLeft()} days left',
                      style: TextStyle(fontSize: 18))
                ],
              ),
              SizedBox(height: 10),
              LinearProgressIndicator(
                value: goal.progressPercentage(),
                backgroundColor: Theme.of(context).backgroundColor,
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).accentColor),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                      '${goal.currentUnitCount}/${goal.goalUnitCount} ${unitDisplays[goal.unit]}',
                      style: TextStyle(fontSize: 16)),
                ],
              ),
              Spacer(),
              Text(
                  goal.unit == Unit.pages
                      ? 'Required rate: ${goal.requiredRate().toStringAsFixed(2)} ${unitDisplays[goal.unit]}/day'
                      : 'Required rate: 1 book per ${goal.requiredRate().toStringAsFixed(2)} days',
                  style: TextStyle(fontSize: 18)),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
