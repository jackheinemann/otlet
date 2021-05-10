import 'package:uuid/uuid.dart';

class Goal {
  String id;
  String name;
  Unit unit;
  DateTime goalDate;
  DateTime goalStarted = DateTime.now();
  int goalUnitCount;
  int currentUnitCount;
  bool completed = false;

  Goal(
      {this.id,
      this.name,
      this.unit,
      this.goalDate,
      this.goalStarted,
      this.goalUnitCount,
      this.currentUnitCount,
      this.completed = false}) {
    if (id == null) id = Uuid().v1();
  }

  Goal.basic() {
    id = Uuid().v1();
    currentUnitCount = 0;
    unit = Unit.books;
  }

  Goal.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    unit = json['unit'] == 'pages' ? Unit.pages : Unit.books;
    if (json['goalDate'] != null) goalDate = DateTime.parse(json['goalDate']);
    if (json['goalStarted'] != null)
      goalStarted = DateTime.parse(json['goalStarted']);
    goalUnitCount = json['goalUnitCount'];
    currentUnitCount = json['currentUnitCount'];
    completed = json['completed'] ?? false;
  }

  Goal.fromGoal(Goal goal) {
    id = goal.id;
    name = goal.name;
    unit = goal.unit;
    goalDate = goal.goalDate;
    goalStarted = goal.goalStarted;
    goalUnitCount = goal.goalUnitCount;
    currentUnitCount = goal.currentUnitCount;
    completed = goal.completed;
  }

  bool isEmpty() {
    if (name != null) return false;
    if (unit != null) return false;
    if (goalDate != null) return false;
    if (goalStarted != null) return false;
    if (goalUnitCount != null) return false;
    return true;
  }

  int daysLeft() {
    if (goalDate == null) return -1;
    return DateTime.now().difference(goalDate).inDays.abs();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'unit': unit == Unit.pages ? 'pages' : 'books',
      if (goalDate != null) 'goalDate': goalDate.toString(),
      if (goalStarted != null) 'goalStarted': goalStarted.toString(),
      'goalUnitCount': goalUnitCount,
      'currentUnitCount': currentUnitCount,
      'completed': completed
    };
  }

  double progressPercentage() {
    if (goalUnitCount <= 0) return -1;
    return currentUnitCount / goalUnitCount;
  }

  double requiredRate() {
    int left = daysLeft();
    if (left == -1) return null;
    int remainingUnits = goalUnitCount - currentUnitCount;
    double rate = remainingUnits / (left > 0 ? left : 0.01);
    if (unit == Unit.pages)
      return rate;
    else {
      double multiplier = 1 /
          rate; // this will give us the multiplier to bring 0.11 books / day to 1 book / x days kinda thing
      return multiplier;
    }
  }
}

enum Unit { books, pages }
