import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/goal.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;

  GoalCard(this.goal);
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * .2,
        child: Column(
          children: [Text('goal! ${goal.currentUnitCount}')],
        ),
      ),
    );
  }
}
