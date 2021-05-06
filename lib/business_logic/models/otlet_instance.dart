import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/reading_session.dart';
import 'package:otlet/business_logic/models/tool.dart';
import 'package:otlet/business_logic/services/session_stream.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'book.dart';
import 'book.dart';

class OtletInstance extends ChangeNotifier {
  String userFirstName;
  String userLastName;
  SharedPreferences preferences;

  List<Book> books = [];

  int activeBookIndex = -1;
  ReadingSession activeSession;
  Stream<int> _stream;
  StreamSubscription<int> timerSubscription;

  List<ReadingSession> sessionHistory = [];
  List<Tool> tools = [];
  List<Tool> otletTools = [
    Tool(
        name: 'Track Progress',
        toolType: Tool.doubleTool,
        useFixedOptions: false,
        setActiveForAll: false,
        isBookTool: true)
  ];

  OtletInstance.empty();

  OtletInstance.fromInstance(OtletInstance instance) {
    userFirstName = instance.userFirstName;
    userLastName = instance.userLastName;
    if (instance.books != null)
      books = instance.books.map((e) => Book.fromBook(e)).toList();
    activeBookIndex = instance.activeBookIndex;
    activeSession = ReadingSession.fromSession(instance.activeSession);
    if (instance.sessionHistory != null)
      sessionHistory = instance.sessionHistory
          .map((e) => ReadingSession.fromSession(e))
          .toList();
    if (instance.tools != null) {
      tools = instance.tools.map((e) => Tool.fromTool(e)).toList();
    }
    if (instance.otletTools != null) {
      otletTools = instance.otletTools.map((e) => Tool.fromTool(e)).toList();
    }
  }

  OtletInstance.fromJson(Map<String, dynamic> json) {
    userFirstName = json['userFirstName'];
    userLastName = json['userLastName'];
    print('got through names');
    if (json.containsKey('books')) {
      List<Book> booksBuilder = [];
      for (Map<String, dynamic> bookJson
          in List<Map<String, dynamic>>.from(jsonDecode(json['books']))) {
        booksBuilder.add(Book.fromJson(bookJson));
      }
      print(booksBuilder);
      books.addAll(booksBuilder);
    }
    print('got through active booksx');
    activeBookIndex = json['activeBookIndex'];
    print('got through active book index');
    if (json.containsKey('activeSession'))
      activeSession =
          ReadingSession.fromJson(jsonDecode(json['activeSession']));
    print('got through active session');
    if (json.containsKey('sessionHistory')) {
      List<ReadingSession> sessionHistoryBuilder = [];

      for (Map<String, dynamic> sessionJson in List<Map<String, dynamic>>.from(
          jsonDecode(json['sessionHistory']))) {
        sessionHistoryBuilder.add(ReadingSession.fromJson(sessionJson));
      }
      sessionHistory.addAll(sessionHistoryBuilder);
    }
    print('got through session history');
    if (json.containsKey('tools')) {
      List<Tool> toolsBuilder = [];

      for (Map<String, dynamic> toolJson
          in List<Map<String, dynamic>>.from(jsonDecode(json['tools']))) {
        toolsBuilder.add(Tool.fromJson(toolJson));
      }
      tools.addAll(toolsBuilder);
    }
    if (json.containsKey('otletTools')) {
      List<Tool> otletToolsBuilder = [];

      for (Map<String, dynamic> otletToolJson
          in List<Map<String, dynamic>>.from(jsonDecode(json['otletTools']))) {
        otletToolsBuilder.add(Tool.fromJson(otletToolJson));
      }
      otletTools = otletToolsBuilder;
    }
  }

  Book activeBook() {
    if (activeBookIndex < 0 || activeBookIndex >= books.length) return null;
    return books[activeBookIndex];
  }

  void addNewBook(Book book) {
    books.add(book);
    print('added book ${book.title}');
    notifyListeners();
  }

  void addNewTool(Tool tool) {
    tools.add(tool);
    for (int i = 0; i < books.length; i++) {
      books[i].tools.add(Tool.fromTool(tool));
    }
    saveInstance();
    notifyListeners();
  }

  void deleteBook(Book book) {
    int index;
    for (int i = 0; i < books.length; i++) {
      if (book.compareIds(books[i])) {
        index = i;
        break;
      }
    }
    if (index == null) return;
    if (activeBookIndex == index) activeBookIndex = -1;
    if (activeBookIndex > index) activeBookIndex -= 1;
    books.removeAt(index);
    saveInstance();
    notifyListeners();
  }

  void deleteTool(Tool tool) {
    int index;
    for (int i = 0; i < tools.length; i++) {
      if (tool.compareToolId(tools[i])) {
        index = i;
        break;
      }
    }
    if (index == null) return;
    tools.removeAt(index);
    for (int i = 0; i < books.length; i++) {
      books[i].tools.removeWhere((element) => element.compareToolId(tool));
    }
    saveInstance();
    notifyListeners();
  }

  void modifyBook(Book book) {
    print('modifying book ${book.title}');
    for (int i = 0; i < books.length; i++) {
      if (book.compareIds(books[i])) {
        if (!book.isActive) {
          if (activeBook().compareIds(book)) {
            print('hello');
            // means this book was deactivated
            activeBookIndex = -1;
          }
        } else
          activeBookIndex = i;
        book.isActive = null;
        books[i] = book;
        break;
      }
    }

    notifyListeners();
  }

  void modifyTool(Tool tool) {
    for (int i = 0; i < tools.length; i++) {
      if (tool.compareToolId(tools[i])) {
        tools[i] = tool;
        break;
      }
    }
    for (int i = 0; i < books.length; i++) {
      books[i].injectModifiedMasterTool(tool);
    }
    saveInstance();
    notifyListeners();
  }

  bool hasActiveBook() {
    if (activeBookIndex < 0 || activeBookIndex >= books.length) return false;
    return true;
  }

  void saveInstance() {
    preferences.setString('otlet_instance', jsonEncode(toJson()));
  }

  void setGlobalOtletToolActivity(Tool masterTool) {
    for (int i = 0; i < otletTools.length; i++) {
      // have to also make sure the master tool updates
      otletTools[i] = masterTool;
    }
    for (int i = 0; i < books.length; i++) {
      for (int j = 0; j < books[i].otletTools.length; j++) {
        Tool bookTool = books[i].otletTools[j];
        if (masterTool.compareToolId(bookTool)) {
          // found the corresponding tool, set its activity
          books[i].otletTools[j].isActive = masterTool.setActiveForAll;
          break;
        }
      }
    }
    saveInstance();
    notifyListeners();
  }

  void setGlobalToolActivity(Tool masterTool) {
    for (int i = 0; i < tools.length; i++) {
      // have to also make sure the master tool updates
      tools[i] = masterTool;
    }
    for (int i = 0; i < books.length; i++) {
      for (int j = 0; j < books[i].tools.length; j++) {
        Tool bookTool = books[i].tools[j];
        if (masterTool.compareToolId(bookTool)) {
          // found the corresponding tool, set its activity
          books[i].tools[j].isActive = masterTool.setActiveForAll;
          break;
        }
      }
    }
    saveInstance();
    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    return {
      'userFirstName': userFirstName,
      'userLastName': userLastName,
      if (books != null)
        'books': jsonEncode(books.map((e) => e.toJson()).toList()),
      'activeBookIndex': activeBookIndex,
      if (hasActiveSession()) 'activeSession': activeSession.toJson(),
      if (sessionHistory != null)
        'sessionHistory':
            jsonEncode(sessionHistory.map((e) => e.toJson()).toList()),
      if (tools != null)
        'tools': jsonEncode(tools.map((e) => e.toJson()).toList()),
      if (otletTools != null)
        'otletTools': jsonEncode(otletTools.map((e) => e.toJson()).toList())
    };
  }

  // SESSION CODE
  bool hasActiveSession() => activeSession != null;

  void startSession() {
    activeSession = ReadingSession.basic();
    activeSession.isReading = false;

    if (activeSession.started == null) activeSession.started = DateTime.now();
    _stream = sessionStream();

    notifyListeners();
  }

  void updateSession(bool reading) {
    if (!hasActiveSession()) return;
    activeSession.isReading = reading;
    if (reading) {
      if (activeSession.started == null) activeSession.started = DateTime.now();
      timerSubscription = _stream.listen((int newTick) {
        activeSession.timePassed += Duration(seconds: 1);
        notifyListeners();
      });
    } else {
      timerSubscription.pause();
    }
    notifyListeners();
  }

  void endSession() {
    Duration timePassed = activeSession.timePassed;

    timerSubscription.cancel();
    _stream = null;

    if (timePassed.inSeconds >= 1) {
      activeSession.ended = DateTime.now();
      activeSession.isReading = false;
      sessionHistory.add(activeSession);
      sessionHistory.sort((b, a) => a.ended.compareTo(b.ended));
      books[activeBookIndex]
          .sessions
          .add(ReadingSession.fromSession(activeSession));
      books[activeBookIndex]
          .sessions
          .sort((b, a) => a.ended.compareTo(b.ended));
    }
    activeSession = null;
    notifyListeners();
  }
}
