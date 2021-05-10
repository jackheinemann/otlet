import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:otlet/business_logic/models/goal.dart';
import 'package:otlet/business_logic/utils/constants.dart';
import 'package:otlet/ui/widgets/alerts/simple_selector.dart';

class CreateGoalScreen extends StatefulWidget {
  final Goal goal;

  CreateGoalScreen({this.goal});
  @override
  _CreateGoalScreenState createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends State<CreateGoalScreen> {
  Goal goal;
  bool isEdit;

  TextEditingController unitController = TextEditingController();
  TextEditingController unitCountController = TextEditingController();
  TextEditingController goalStartedController = TextEditingController();
  TextEditingController goalDateController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    goal = widget.goal ?? Goal.basic();
    isEdit = widget.goal != null;
    unitController.text = unitDisplays[goal.unit];
    if (goal.goalUnitCount != null)
      unitController.text = goal.goalUnitCount.toString();
    if (goal.goalStarted != null)
      goalStartedController.text = monthDayYearFormat.format(goal.goalStarted);
    if (goal.goalDate != null)
      goalDateController.text = monthDayYearFormat.format(goal.goalDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(isEdit ? 'Edit Goal' : 'Create Goal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  Text('I want to finish', style: TextStyle(fontSize: 19)),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width * .2,
                      child: TextFormField(
                        validator: (value) {
                          if (value.isEmpty) return 'This field is required';
                          int count = int.tryParse(value);
                          if (count == null)
                            return 'Invalid value';
                          else
                            goal.goalUnitCount = count;
                          return null;
                        },
                        keyboardType:
                            TextInputType.numberWithOptions(signed: true),
                        decoration: InputDecoration(
                            hintText: '#', border: OutlineInputBorder()),
                      )),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextFormField(
                      validator: (value) {
                        if (value.isEmpty) return 'This field is required';
                        return null;
                      },
                      controller: unitController,
                      readOnly: true,
                      onTap: () async {
                        String selected = await showSimpleSelectorDialog(
                            context,
                            'Select unit type',
                            unitDisplays.values.toList());
                        if (selected == null) return;
                        setState(() {
                          goal.unit = unitDisplays.keys.firstWhere(
                              (element) => unitDisplays[element] == selected);
                          unitController.text = selected;
                        });
                      },
                      decoration: InputDecoration(
                          suffixIcon: Icon(Icons.arrow_drop_down),
                          border: OutlineInputBorder()),
                    ),
                  )
                ],
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('by', style: TextStyle(fontSize: 19)),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width * .6,
                      child: TextFormField(
                        validator: (value) {
                          if (value.isEmpty) return 'This field is required';
                          return null;
                        },
                        readOnly: true,
                        onTap: () async {
                          DateTime dateTime = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1950),
                              lastDate: DateTime(2150));
                          if (dateTime == null) return;
                          setState(() {
                            goal.goalDate = dateTime;
                            goalDateController.text =
                                monthDayYearFormat.format(goal.goalDate);
                          });
                        },
                        controller: goalDateController,
                        decoration: InputDecoration(
                            suffixIcon: Icon(Icons.arrow_drop_down),
                            hintText: monthDayYearFormat
                                .format(DateTime(DateTime.now().year, 12, 31)),
                            border: OutlineInputBorder()),
                      ))
                ],
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('starting', style: TextStyle(fontSize: 19)),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width * .6,
                      child: TextFormField(
                        validator: (value) {
                          if (value.isEmpty) return 'This field is required';
                          return null;
                        },
                        readOnly: true,
                        onTap: () async {
                          DateTime dateTime = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1950),
                              lastDate: DateTime(2150));
                          if (dateTime == null) return;
                          setState(() {
                            goal.goalStarted = dateTime;
                            goalStartedController.text =
                                monthDayYearFormat.format(goal.goalStarted);
                          });
                        },
                        controller: goalStartedController,
                        decoration: InputDecoration(
                            suffixIcon: Icon(Icons.arrow_drop_down),
                            hintText: monthDayYearFormat
                                .format(DateTime(DateTime.now().year, 1, 1)),
                            border: OutlineInputBorder()),
                      ))
                ],
              ),
              Spacer(),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: primaryColor),
                  onPressed: () {
                    if (!_formKey.currentState.validate()) return;
                    Navigator.pop(context, goal);
                  },
                  child: Text('Save Goal')),
              SizedBox(height: 30)
            ],
          ),
        ),
      ),
    );
  }
}
