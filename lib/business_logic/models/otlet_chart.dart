import 'package:otlet/business_logic/models/chart_helpers.dart';
import 'package:uuid/uuid.dart';

class OtletChart {
  String id;
  String name;
  String type;
  String scope;

  List<ChartFilter> filters = [];

  OtletChart({this.id, this.name, this.type, this.scope, this.filters}) {
    if (id == null) id = Uuid().v1();
    if (filters == null) filters = [];
  }

  OtletChart.basic() {
    id = Uuid().v1();
  }

  void addOrModifyFilter(ChartFilter filter) {
    for (int i = 0; i < filters.length; i++) {
      ChartFilter existingFilter = filters[i];
      if (existingFilter.id == filter.id) {
        filters[i] = filter;
        return;
      }
    }
    // didnt find it, must be a new filter
    filters.add(filter);
  }
}
