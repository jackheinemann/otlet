import 'package:otlet/business_logic/models/tool.dart';
import 'package:uuid/uuid.dart';

class ChartTypes {
  static String bar = 'Bar';
  static String line = 'Line';
  static String dot = 'Dot';
  static String pie = 'Pie';

  static List<String> types = [bar, line, dot, pie];
}

class ChartScope {
  static String books = 'Books';
  static String sessions = 'Sessions (All)';
  static String singleBook = 'Sessions (Single Book)';

  static List<String> scopes = [books, sessions, singleBook];
}

class ChartFilter {
  String id;
  FilterComparator filterComparator;
  Tool pseudoTool;
  dynamic valueLimit;

  String comparatorString({FilterComparator comparator}) {
    if (comparator == null) comparator = filterComparator;
    if (comparator == FilterComparator.equals) return '=';
    if (comparator == FilterComparator.doesNotEqual) return '!=';
    if (comparator == FilterComparator.greaterThan) return '>';
    if (comparator == FilterComparator.lessThan) return '<';
    if (comparator == FilterComparator.greaterThanEQ) return '>=';
    if (comparator == FilterComparator.lessThanEQ) return '<=';
    return null;
  }

  ChartFilter(this.id, this.filterComparator, this.pseudoTool);

  ChartFilter.basic() {
    id = Uuid().v1();
  }

  String filterToolType() {
    if (pseudoTool == null) return null;
    return pseudoTool.toolType;
  }

  String filterLabel() {
    return '${pseudoTool?.name} ${comparatorString()} ${pseudoTool?.displayValue()}';
  }

  bool filterSaveable() {
    return filterComparator != null &&
        pseudoTool != null &&
        pseudoTool?.value != null;
  }
}

enum FilterComparator {
  equals,
  doesNotEqual,
  greaterThan,
  lessThan,
  greaterThanEQ,
  lessThanEQ
}
