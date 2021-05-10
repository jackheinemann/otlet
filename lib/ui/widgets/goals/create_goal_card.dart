import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/goal.dart';
import 'package:otlet/business_logic/models/otlet_instance.dart';
import 'package:otlet/business_logic/utils/constants.dart';
import 'package:otlet/ui/screens/home_screen/create_goal_screen.dart';

class CreateGoalCard extends StatelessWidget {
  final Function(Goal) addGoal;
  final OtletInstance instance;

  CreateGoalCard(this.instance, {@required this.addGoal});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * .15,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('No Goal Set', style: TextStyle(fontSize: 18)),
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: primaryColor),
                  onPressed: () async {
                    Goal goal = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreateGoalScreen(instance)));
                    if (goal == null) return;
                    // addGoal(goal);
                    instance.addNewGoal(goal);
                  },
                  child: Text('Create Goal'))
            ],
          ),
        ),
      ),
    );
  }
}
