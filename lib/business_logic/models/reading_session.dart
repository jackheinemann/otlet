import 'dart:convert';

import 'package:otlet/business_logic/models/tool.dart';
import 'package:uuid/uuid.dart';

import 'book.dart';
import 'chart_helpers.dart';
import 'otlet_chart.dart';

class ReadingSession {
  String id;
  DateTime started;
  DateTime lastPaused;
  Duration timeSpentPaused = Duration(seconds: 0);
  DateTime ended;
  bool isReading = false;
  Duration timePassed;
  int pagesRead;
  // Book book;
  String bookId;
  String bookTitle;

  List<Tool> tools = [];
  List<Tool> otletTools = [];

  ReadingSession({
    this.started,
    this.ended,
    this.isReading = false,
    this.timePassed,
  }) {
    id = Uuid().v1();
  }

  ReadingSession.fromSession(ReadingSession session) {
    id = session.id;
    started = session.started;
    ended = session.ended;
    isReading = session.isReading;
    timePassed = session.timePassed;
    pagesRead = session.pagesRead;
    tools = session.tools.map((e) => Tool.fromTool(e)).toList();
    otletTools = session.otletTools.map((e) => Tool.fromTool(e)).toList();
    bookId = session.bookId;
    bookTitle = session.bookTitle;
  }

  ReadingSession.basic([Book book]) {
    id = Uuid().v1();
    timePassed = Duration(seconds: 0);
    bookId = book?.id;
    bookTitle = book?.title;
  }

  ReadingSession.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    started = DateTime.parse(json['started']);
    ended = DateTime.parse(json['ended']);
    isReading = json['isReading'];
    timePassed = Duration(seconds: json['timePassed']);
    pagesRead = json['pagesRead'];
    if (json['tools'] != null) {
      List<dynamic> toolsJson = List<dynamic>.from(jsonDecode(json['tools']));
      for (Map<String, dynamic> json in toolsJson) {
        tools.add(Tool.fromJson(json));
      }
    }
    if (json['otletTools'] != null) {
      List<dynamic> otletToolsJson =
          List<dynamic>.from(jsonDecode(json['otletTools']));
      for (Map<String, dynamic> json in otletToolsJson) {
        otletTools.add(Tool.fromJson(json));
      }
    }
    bookId = json['bookId'];
    bookTitle = json['bookTitle'];
  }

  void importSessionToolSingular(Tool tool, bool isOtletTool) {
    if (tool.isBookTool) return;
    if (isOtletTool) {
      for (int i = 0; i < otletTools.length; i++) {
        if (otletTools[i].id == tool.id) {
          if (otletTools[i].toolType == tool.toolType) {
            dynamic value = otletTools[i].value;
            tool.value = value;
            otletTools[i] = tool;
          } else {
            otletTools[i] = tool;
          }
          return;
        }
      }
      // if it wasn't found, add it to the otlettools
      otletTools.add(tool);
    } else {
      for (int i = 0; i < tools.length; i++) {
        if (tools[i].id == tool.id) {
          if (tools[i].toolType == tool.toolType) {
            dynamic value = tools[i].value;
            tool.value = value;
            tools[i] = tool;
          } else {
            tools[i] = tool;
          }
          return;
        }
      }
      // if it wasn't found, add it as new
      tools.add(tool); //TODO right here is the problem point
    }
  }

  void importSessionTools(Book book) {
    tools = book.tools
        .where((element) => !element.isBookTool && element.isActive)
        .map((e) => Tool.fromTool(e))
        .toList();
    otletTools = book.otletTools
        .where((element) => !element.isBookTool && element.isActive)
        .map((e) => Tool.fromTool(e))
        .toList();
    print(tools);
  }

  void updateTimePassed() {
    timePassed = DateTime.now().difference(started);
    otletTools[0].value = timePassed.inSeconds;
  }

  String displayTimePassed() {
    int hours = timePassed.inHours;
    int minutes = timePassed.inMinutes - (60 * hours);
    int seconds = timePassed.inSeconds - (60 * timePassed.inMinutes);

    if (hours >= 1) {
      return '$hours:${minutes >= 10 ? minutes : '0' + minutes.toString()}:${seconds >= 10 ? seconds : '0' + seconds.toString()}';
    } else
      return '${minutes >= 10 ? minutes : '0' + minutes.toString()}:${seconds >= 10 ? seconds : '0' + seconds.toString()}';
  }

  bool doesPassChartFilters(OtletChart chart) {
    for (ChartFilter filter in chart.filters) {
      Tool pseudoTool = filter.pseudoTool;
      Tool sessionTool =
          tools.firstWhere((element) => element.compareToolId(pseudoTool));
      print(sessionTool.name);
      if (!sessionTool.isActive) return false;
      if (sessionTool.value == null) return false;
      if (!filter.compareFilterValue(sessionTool)) return false;
    }
    return true;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'started': started.toString(),
      'ended': ended.toString(),
      'isReading': isReading,
      'timePassed': timePassed.inSeconds,
      'pagesRead': pagesRead,
      if (tools != null)
        'tools': jsonEncode(tools.map((e) => e.toJson()).toList()),
      if (otletTools != null)
        'otletTools': jsonEncode(otletTools.map((e) => e.toJson()).toList()),
      'bookId': bookId,
      'bookTitle': bookTitle
    };
  }
}
