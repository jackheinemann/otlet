import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/goal.dart';
import 'package:otlet/business_logic/models/otlet_chart.dart';
import 'package:otlet/business_logic/models/reading_session.dart';
import 'package:otlet/business_logic/models/tool.dart';
import 'package:otlet/business_logic/services/session_stream.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'book.dart';

class OtletInstance extends ChangeNotifier {
  String userFirstName;
  String userLastName;
  SharedPreferences preferences;

  List<Book> books = [];
  List<Goal> goals = [];
  List<String> collections = [];
  List<String> selectedCollections = [];

  int activeBookIndex = -1;
  ReadingSession activeSession;
  Stream<int> _stream;
  StreamSubscription<int> timerSubscription;

  List<ReadingSession> sessionHistory = [];
  List<Tool> tools = [];
  List<Tool> otletTools = [
    // page count, genre, author, publication year, started, finished
    Tool(
        customId: 'titleTool',
        name: 'Title',
        toolType: Tool.textTool,
        isBookTool: true,
        isActive: true,
        useFixedOptions: false),
    Tool(
        customId: 'authorTool',
        name: 'Author',
        toolType: Tool.textTool,
        isBookTool: true,
        isActive: true,
        useFixedOptions: false),
    Tool(
        customId: 'pageCountTool',
        name: 'Page Count',
        toolType: Tool.integerTool,
        isBookTool: true,
        isActive: true,
        useFixedOptions: false),
    Tool(
        customId: 'genreTool',
        name: 'Genre',
        toolType: Tool.textTool,
        isBookTool: true,
        isActive: true,
        useFixedOptions: false),
    Tool(
        customId: 'publicationTool',
        name: 'Publication Year',
        toolType: Tool.integerTool,
        isBookTool: true,
        isActive: true,
        useFixedOptions: false),
    Tool(
        customId: 'dateStartedTool',
        name: 'Date Started',
        toolType: Tool.dateTool,
        isBookTool: true,
        isActive: true,
        useFixedOptions: false),
    Tool(
        customId: 'dateFinishedTool',
        name: 'Date Finished',
        toolType: Tool.dateTool,
        isBookTool: true,
        isActive: true,
        useFixedOptions: false),
    // Tool(
    //     customId: 'bookCollectionTool',
    //     name: 'Collection',
    //     toolType: Tool.textTool,
    //     isBookTool: true,
    //     useFixedOptions: true,
    //     isActive: true,
    //     fixedOptions: []),
    Tool(
        customId: 'sessionLengthTool',
        name: 'Session Length',
        toolType: Tool.integerTool,
        isBookTool: false,
        isActive: true,
        useFixedOptions: false),
    Tool(
        customId: 'sessionStartedTool',
        name: 'Session Started',
        toolType: Tool.dateTimeTool,
        isBookTool: false,
        isActive: true,
        useFixedOptions: false),
    Tool(
        customId: 'sessionEndedTool',
        name: 'Session Ended',
        toolType: Tool.dateTimeTool,
        isBookTool: false,
        isActive: true,
        useFixedOptions: false),
    Tool(
        customId: 'sessionDateTool',
        name: 'Session Date',
        toolType: Tool.dateTool,
        isBookTool: false,
        isActive: true,
        useFixedOptions: false),
    Tool(
        customId: 'pagesReadTool',
        name: 'Pages Read',
        toolType: Tool.integerTool,
        isBookTool: false,
        isActive: true,
        useFixedOptions: false),
  ];

  List<OtletChart> charts = [];

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
    if (instance.goals != null) {
      goals = instance.goals.map((e) => Goal.fromGoal(e)).toList();
    }
    collections = List<String>.from(instance.collections);
    selectedCollections = List<String>.from(instance.selectedCollections);
  }

  OtletInstance.fromJson(Map<String, dynamic> json) {
    userFirstName = json['userFirstName'];
    userLastName = json['userLastName'];
    if (json.containsKey('books')) {
      List<Book> booksBuilder = [];
      for (Map<String, dynamic> bookJson
          in List<Map<String, dynamic>>.from(jsonDecode(json['books']))) {
        booksBuilder.add(Book.fromJson(bookJson));
      }
      books.addAll(booksBuilder);
    }
    activeBookIndex = json['activeBookIndex'];
    if (json.containsKey('activeSession'))
      activeSession =
          ReadingSession.fromJson(jsonDecode(json['activeSession']));
    if (json.containsKey('sessionHistory')) {
      List<ReadingSession> sessionHistoryBuilder = [];

      for (Map<String, dynamic> sessionJson in List<Map<String, dynamic>>.from(
          jsonDecode(json['sessionHistory']))) {
        sessionHistoryBuilder.add(ReadingSession.fromJson(sessionJson));
      }
      sessionHistory.addAll(sessionHistoryBuilder);
    }
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
    if (json.containsKey('goals')) {
      List<Goal> goalsBuilder = [];
      for (Map<String, dynamic> goalJson
          in List<Map<String, dynamic>>.from(jsonDecode(json['goals']))) {
        goalsBuilder.add(Goal.fromJson(goalJson));
      }
      goals = goalsBuilder;
    }
    if (json.containsKey('charts')) {
      List<OtletChart> chartsBuilder = [];
      for (Map<String, dynamic> chartJson
          in List<Map<String, dynamic>>.from(jsonDecode(json['charts']))) {
        chartsBuilder.add(OtletChart.fromJson(chartJson));
      }
      charts = chartsBuilder;
    }
    if (json.containsKey('collections')) {
      collections = List<String>.from(json['collections']);
    }
    if (json.containsKey('selectedCollections'))
      selectedCollections = List<String>.from(json['selectedCollections']);
  }

  Book activeBook() {
    if (activeBookIndex < 0 || activeBookIndex >= books.length) return null;
    return books[activeBookIndex];
  }

  void addNewBook(Book book) {
    book.tools = tools.map((e) {
      Tool tool = Tool.fromTool(e);
      if (e.setActiveForAll) tool.isActive = true;
      return tool;
    }).toList();
    book.otletTools = otletTools.map((e) {
      Tool tool = Tool.fromTool(e);
      if (tool.id == 'titleTool') tool.value = book.title;
      if (tool.id == 'authorTool') tool.value = book.author;
      if (tool.id == 'pageCountTool') tool.value = book.pageCount;
      if (tool.id == 'genreTool') tool.value = book.genre;
      if (book.published != null) if (tool.id == 'publicationTool')
        tool.value = book.published.year;
      if (book.started != null) if (tool.id == 'dateStartedTool')
        tool.value = book.started;
      if (book.finished != null) if (tool.id == 'dateFinishedTool')
        tool.value = book.finished;
      // if (book.collections != null) if (tool.id == 'bookCollectionTool') tool.value
      return tool;
    }).toList();
    books.add(book);
    saveInstance();
    notifyListeners();
  }

  void addNewChart(OtletChart chart) {
    charts.add(chart);
    saveInstance();
    notifyListeners();
  }

  void addNewGoal(Goal goal) {
    goals.add(goal);
    saveInstance();
    notifyListeners();
  }

  void addNewSession(ReadingSession session, Book book) {
    print('adding session');
    sessionHistory.add(session);
    sessionHistory.sort((b, a) => a.ended.compareTo(b.ended));
    for (int i = 0; i < books.length; i++) {
      if (books[i].compareToBook(book)) {
        books[i].sessions.add(ReadingSession.fromSession(session));
        books[i].sessions.sort((b, a) => a.ended.compareTo(b.ended));
        break;
      }
    }
    print('done adding session');
    saveInstance();
    notifyListeners();
  }

  void addNewTool(Tool tool) {
    tools.add(tool);
    for (int i = 0; i < books.length; i++) {
      books[i].tools.add(Tool.fromTool(tool));
      books[i].tools.sort((a, b) => a.name.compareTo(b.name));
    }
    saveInstance();
    notifyListeners();
  }

  calculateGoalProgress(Goal goal) {
    int total = 0;
    for (Book book in books) {
      if (book.finished == null || book.started == null) continue;
      if (book.finished.isBefore(goal.goalStarted) ||
          book.finished.isAfter(goal.goalDate)) continue;
      if (goal.unit == Unit.pages) {
        if (book.pageCount != null) total += book.pageCount;
      } else {
        // goal.unit == Unit.books
        total += 1;
      }
    }
    return total;
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

  void deleteChart(OtletChart chart) {
    int i = 0;
    for (; i < charts.length; i++) {
      if (chart.id == charts[i].id) break;
    }
    charts.removeAt(i);
    saveInstance();
    notifyListeners();
  }

  void deleteGoal(Goal goal) {
    int i = 0;
    for (; i < goals.length; i++) {
      if (goals[i].id == goal.id) break;
    }
    goals.removeAt(i);
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

  Map<String, bool> generateBookCollections([Book book]) {
    Map<String, bool> options = {};
    if (book == null) {
      book = Book();
      book.collections = [];
    }
    for (String collection in collections) {
      print(book.collections);
      if (book.collections.contains(collection))
        options.putIfAbsent(collection, () => true);
      else
        options.putIfAbsent(collection, () => false);
    }
    return options;
  }

  void modifyBook(Book book) {
    for (int i = 0; i < books.length; i++) {
      if (book.compareIds(books[i])) {
        if (!book.isActive && hasActiveBook()) {
          if (activeBook().compareIds(book)) {
            // means this book was deactivated
            activeBookIndex = -1;
          }
        } else
          activeBookIndex = i;
        book.isActive = null;
        for (Tool tool in book.otletTools) {
          if (tool.id == 'titleTool') tool.value = book.title;
          if (tool.id == 'authorTool') tool.value = book.author;
          if (tool.id == 'pageCountTool') tool.value = book.pageCount;
          if (tool.id == 'genreTool') tool.value = book.genre;
          if (tool.id == 'bookCollectionTool') tool.value = book.collections;
          if (book.published != null) if (tool.id == 'publicationTool')
            tool.value = book.published.year;
          if (book.started != null) if (tool.id == 'dateStartedTool')
            tool.value = book.started;
          if (book.finished != null) if (tool.id == 'dateFinishedTool')
            tool.value = book.finished;
        }
        books[i] = book;
        break;
      }
    }
    saveInstance();
    notifyListeners();
  }

  void modifyChart(OtletChart chart) {
    int i = 0;
    for (; i < charts.length; i++) {
      print(charts[i].name);
      if (charts[i].id == chart.id) break;
    }
    charts[i] = chart;
    print(charts[i].name);
    saveInstance();
    print('saved the chart');
    notifyListeners();
  }

  void modifyGoal(Goal goal) {
    int i = 0;
    for (; i < goals.length; i++) {
      if (goals[i].id == goal.id) break;
    }
    goals[i] = goal;
    saveInstance();
    notifyListeners();
  }

  void modifySession(ReadingSession session, Book book) {
    for (int i = 0; i < sessionHistory.length; i++) {
      if (sessionHistory[i].id == session.id) {
        sessionHistory[i] = session;
        sessionHistory.sort((b, a) => a.ended.compareTo(b.ended));
        break;
      }
    }
    for (int i = 0; i < books.length; i++) {
      if (books[i].compareIds(book)) {
        for (int j = 0; j < books[i].sessions.length; j++) {
          if (books[i].sessions[j].id == session.id) {
            books[i].sessions[j] = ReadingSession.fromSession(session);
            books[i].sessions.sort((b, a) => a.ended.compareTo(b.ended));
          }
        }
      }
    }
    saveInstance();
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

  void scorchEarth() {
    // wipe everything out
    preferences.clear();
    books.clear();
    tools.clear();
    sessionHistory.clear();
    activeBookIndex = -1;
    goals.clear();
    charts.clear();
    _stream = null;
    timerSubscription?.cancel();
    timerSubscription = null;
    collections.clear();
    selectedCollections.clear();
    notifyListeners();
  }

  void setGlobalOtletToolActivity(Tool masterTool) {
    for (int i = 0; i < otletTools.length; i++) {
      // have to also make sure the master tool updates
      if (otletTools[i].compareToolId(masterTool)) {
        otletTools[i] = masterTool;
        break;
      }
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
      if (tools[i].compareToolId(masterTool)) {
        tools[i] = masterTool;
        break;
      }
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

  List<Book> sortedBooks() {
    if (selectedCollections.isEmpty) return books;
    List<Book> sorted = [];
    for (Book book in books) {
      for (String collection in selectedCollections) {
        if (book.collections.contains(collection)) {
          // means at least one of the selected collections is present, so display the book
          sorted.add(book);
          break;
        }
      }
    }
    return sorted;
  }

  Map<String, dynamic> toJson() {
    print('instance on');
    Map<String, dynamic> json = {
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
        'otletTools': jsonEncode(otletTools.map((e) => e.toJson()).toList()),
      if (goals != null)
        'goals': jsonEncode(goals.map((e) => e.toJson()).toList()),
      if (charts != null)
        'charts': jsonEncode(charts.map((e) => e.toJson()).toList()),
      if (collections != null) 'collections': collections,
      if (selectedCollections != null)
        'selectedCollections': selectedCollections
    };
    print('instance off');
    return json;
  }

  void updateCollections(List<String> updated) {
    collections = List<String>.from(updated);
    // Tool tool;
    // int i = 0;
    // for (; i < otletTools.length; i++) {
    //   tool = otletTools[i];
    //   if (tool.id == 'bookCollectionTool') {
    //     tool.fixedOptions = List<String>.from(collections);
    //     break;
    //   }
    // }
    // otletTools[i] = tool;
    saveInstance();
    notifyListeners();
  }

  void updateSelectedCollection(List<String> updated) {
    selectedCollections = List<String>.from(updated);
    saveInstance();
    notifyListeners();
  }

  // SESSION CODE
  bool hasActiveSession() => activeSession != null;

  void startSession() {
    activeSession = ReadingSession.basic();
    activeSession.isReading = false;
    activeSession.importSessionTools(activeBook());

    // if (activeSession.started == null) activeSession.started = DateTime.now();
    _stream = sessionStream(counter: activeSession.timePassed?.inSeconds);

    notifyListeners();
  }

  void updateSessionTool(Tool tool) {
    for (int i = 0; i < activeSession.tools.length; i++) {
      if (tool.compareToolId(activeSession.tools[i])) {
        activeSession.tools[i] = tool;
        break;
      }
    }
    notifyListeners();
  }

  void updateSession(bool reading) {
    if (!hasActiveSession()) return;
    activeSession.isReading = reading;
    if (reading) {
      if (activeSession.started == null)
        activeSession.started = DateTime.now();
      else {
        // resuming from a paused stream
        if (activeSession.lastPaused != null)
          activeSession.timeSpentPaused +=
              DateTime.now().difference(activeSession.lastPaused);
        _stream = sessionStream(counter: activeSession.timePassed.inSeconds);
      }
      timerSubscription = _stream.listen((int newTick) {
        Duration timePassedRaw =
            DateTime.now().difference(activeSession.started) -
                (activeSession.timeSpentPaused ?? Duration(seconds: 0));

        if (timePassedRaw.inSeconds - activeSession.timePassed.inSeconds > 1)
          timePassedRaw -= Duration(
              seconds:
                  1); // this handles awkward second and a half stuff that rounds up to 2 seconds
        activeSession.timePassed = Duration(seconds: timePassedRaw.inSeconds);

        activeSession.otletTools[0].value = activeSession.timePassed.inSeconds;
        notifyListeners();
      });
    } else {
      timerSubscription.pause();
      activeSession.lastPaused = DateTime
          .now(); // mark when the pause was to calculate how much time was spent not reading
    }
    notifyListeners();
  }

  void endSession() {
    Duration timePassed = activeSession.timePassed;

    try {
      timerSubscription.cancel();
      _stream = null;
    } catch (e) {
      print('Error stopping session stream: $e');
    }

    if (timePassed.inSeconds >= 1) {
      activeSession.ended = DateTime.now();
      activeSession.isReading = false;
      print(activeSession.otletTools
          .map((e) => '${e.name} : ${e.displayValue()}'));
      activeSession.otletTools[1].value = activeSession.started;
      activeSession.otletTools[2].value = activeSession.ended;
      activeSession.otletTools[3].value = DateTime(activeSession.started.year,
          activeSession.started.month, activeSession.started.day);
      activeSession.otletTools[4].value = activeSession.pagesRead;
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
