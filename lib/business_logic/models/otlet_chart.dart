import 'package:uuid/uuid.dart';

class OtletChart {
  String id;
  String name;
  String type;
  String scope;

  OtletChart({this.id, this.name, this.type, this.scope}) {
    if (id == null) id = Uuid().v1();
  }

  OtletChart.basic() {
    id = Uuid().v1();
  }
}
