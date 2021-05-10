import 'package:uuid/uuid.dart';

class ReadingGoal {
  String id;
  String name;
  Unit unit;
  DateTime goalDate;
  int goalUnitCount;
  int currentUnitCount;
  bool completed = false;

  ReadingGoal(
      {this.id,
      this.name,
      this.unit,
      this.goalDate,
      this.goalUnitCount,
      this.currentUnitCount,
      this.completed = false}) {
    if (id == null) id = Uuid().v1();
  }

  ReadingGoal.basic() {
    id = Uuid().v1();
    currentUnitCount = 0;
  }

  ReadingGoal.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    unit = json['unit'] == 'pages' ? Unit.pages : Unit.books;
    if (json['goalDate'] != null) goalDate = DateTime.parse(json['goalDate']);
    goalUnitCount = json['goalUnitCount'];
    currentUnitCount = json['currentUnitCount'];
    completed = json['completed'] ?? false;
  }

  ReadingGoal.fromGoal(ReadingGoal goal) {
    id = goal.id;
    name = goal.name;
    unit = goal.unit;
    goalDate = goal.goalDate;
    goalUnitCount = goal.goalUnitCount;
    completed = goal.completed;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'unit': unit == Unit.pages ? 'pages' : 'books',
      if (goalDate != null) 'goalDate': goalDate.toString(),
      'goalUnitCount': goalUnitCount,
      'currentUnitCount': currentUnitCount,
      'completed': completed
    };
  }
}

enum Unit { books, pages }
