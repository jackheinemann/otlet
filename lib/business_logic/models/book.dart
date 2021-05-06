import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:otlet/business_logic/models/reading_session.dart';
import 'package:otlet/business_logic/models/tool.dart';
import 'package:otlet/business_logic/utils/constants.dart';
import 'package:uuid/uuid.dart';

import 'reading_session.dart';
import 'reading_session.dart';

class Book {
  String id;
  String isbn;
  String title;
  String coverUrl;
  String author;
  DateTime started;
  DateTime finished;
  List<String> genres = [];
  int rating;
  DateTime published;
  int pageCount;
  int wordCount;
  int currentPage = 0;
  bool trackProgress = false;

  bool hasBeenEdited = false; // just for local 'show save button' stuff
  bool isActive;

  List<ReadingSession> sessions = [];
  List<Tool> tools = [];

  Book({
    this.title,
    this.author,
    this.started,
    this.finished,
    this.genres,
    this.rating,
    this.published,
    this.pageCount,
    this.wordCount,
    this.sessions,
  }) {
    id = Uuid().v1();
  }

  Book.fromBook(Book book) {
    print('starting book copy');
    id = book.id;
    isbn = book.isbn;
    title = book.title;
    coverUrl = book.coverUrl;
    author = book.author;
    started = book.started;
    finished = book.finished;
    genres = List<String>.from(book.genres);
    rating = book.rating;
    published = book.published;
    pageCount = book.pageCount;
    wordCount = book.wordCount;
    currentPage = book.currentPage;
    trackProgress = book.trackProgress;
    print('finished book copy');
    sessions = List<ReadingSession>.from(book.sessions ?? []);
    isActive = book.isActive;
    tools = book.tools.map((e) => Tool.fromTool(e)).toList();
  }

  Book.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    author = json['author'];
    coverUrl = json['coverUrl'];
    if (json['started'] != null) started = DateTime.parse(json['started']);
    if (json['finished'] != null) finished = DateTime.parse(json['finished']);
    genres = List<String>.from(jsonDecode(json['genres']));
    rating = json['rating'];
    if (json['published'] != null)
      published = DateTime.parse(json['published']);
    pageCount = json['pageCount'];
    wordCount = json['wordCount'];
    currentPage = json['currentPage'];
    if (json['sessions'] != null) {
      List<Map<String, dynamic>> sessionJsons =
          List<Map<String, dynamic>>.from(jsonDecode(json['sessions']));
      sessions = sessionJsons.map((e) => ReadingSession.fromJson(e)).toList();
    }
    trackProgress = json['trackProgress'] ?? false;
    if (json['tools'] != null) {
      List<dynamic> toolsJson = List<dynamic>.from(jsonDecode(json['tools']));
      for (Map<String, dynamic> json in toolsJson) {
        tools.add(Tool.fromJson(json));
      }
    }
  }

  Book.fromOpenLibrary(Map<String, dynamic> json) {
    id = Uuid().v1();
    title = json['title'];
    if (json['cover'] != null) coverUrl = json['cover']['large'];
    pageCount = json['number_of_pages'];
    if (json['authors'] != null) author = json['authors'].last['name'];
    if (json['subjects'] != null) {
      List<dynamic> subjects = json['subjects'];
      genres = parseGenres(
          List<String>.from(subjects.map((e) => e['name']).toList()));
      genres.removeWhere((element) => element.isEmpty);
    }
    if (json['publish_date'] != null) {
      String publishedString = json['publish_date'];
      try {
        published = DateFormat('MMMM d, yyyy').parse(publishedString);
      } catch (e) {
        print('Error formatting date: $e');
        try {
          published = DateFormat('y').parse(publishedString);
        } catch (e) {
          print('Second date format error: $e. Abandoning.');
        }
      }
    }
  }

  bool compareIds(Book book) {
    if (book == null) return false;
    return book.id == id;
  }

  bool compareToBook(Book book) {
    if (book.id != id) return false;
    if (book.title != title) return false;
    if (book.author != author) return false;
    if (book.genres.length != genres.length) return false;
    for (int i = 0; i < book.genres.length; i++) {
      if (genres[i] != book.genres[i]) return false;
    }
    if (book.trackProgress != trackProgress) return false;
    if (book.coverUrl != coverUrl) return false;
    if (book.pageCount != pageCount) return false;
    if (book.currentPage != currentPage) return false;
    if (book.wordCount != wordCount) return false;
    if (book.rating != rating) return false;
    if (book.published != published) return false;
    if (book.started != started) return false;
    if (book.finished != finished) return false;
    if (book.isbn != isbn) return false;
    if (book.sessions.length != sessions.length) return false;
    for (int i = 0; i < book.sessions.length; i++) {
      ReadingSession sourceSession = sessions[i];
      ReadingSession foreignSession = book.sessions[i];
      if ((sourceSession.id != foreignSession.id ||
              sourceSession.timePassed != foreignSession.timePassed) ||
          (sourceSession.started != foreignSession.started ||
              sourceSession.ended != foreignSession.ended)) return false;
    }
    if (book.isActive != isActive) return false;
    return true;
  }

  String displayPublicationYear() => DateFormat('y').format(published);

  void injectModifiedMasterTool(Tool masterTool) {
    Tool newTool = Tool.fromTool(masterTool); // make a copy of the master tool
    int indexOfTool;
    for (int i = 0; i < tools.length; i++) {
      Tool tool = tools[i];
      if (masterTool.compareToolId(tool)) {
        // means we've found the old version of master tool
        if (masterTool.toolType == tool.toolType &&
            masterTool.fixedOptions.map((e) => e.toString()) ==
                tool.fixedOptions.map((e) => e.toString())) {
          // toolType and fixedOptions have not changed, so attach old value
          newTool.value = tool.value;
        }
        newTool.isActive = tool.isActive;
        indexOfTool = i;
        break;
      }
    }
    if (indexOfTool == null) {
      print('couldnt find tool ${masterTool.name}');
      return;
    }
    tools[indexOfTool] = newTool;
  }

  bool isEmpty() {
    if (title != null) return false;
    if (author != null) return false;
    if (published != null) return false;
    if (genres != null) return false;
    return true;
  }

  List<String> parseGenres(List<String> subjects) {
    List<String> parsedGenres = [];
    for (String subject in subjects) {
      for (String genre in litGenres) {
        if (subject.trim().toLowerCase() == genre.trim().toLowerCase() &&
            !parsedGenres.contains(genre)) {
          parsedGenres.add(genre);
          break;
        }
      }
    }
    return parsedGenres;
  }

  String readingPercent() {
    return '${(readingProgress() * 100).round()}%';
  }

  double readingProgress() {
    if (currentPage == null || pageCount == null) return null;

    double progress = currentPage.toDouble() / pageCount.toDouble();

    if (progress > 1) return 1;

    return progress;
  }

  String relevantFirstChar() {
    String titleString = title.toLowerCase();
    titleString = titleString.replaceAll('the', '');
    titleString = titleString.replaceAll('a ', '');
    titleString = titleString.trim();
    return titleString[0].toUpperCase();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'coverUrl': coverUrl,
      'started': started?.toString(),
      'finished': finished?.toString(),
      'genres': jsonEncode(genres ?? []),
      'rating': rating,
      'published': published?.toString(),
      'pageCount': pageCount,
      'wordCount': wordCount,
      'currentPage': currentPage,
      'trackProgress': trackProgress,
      if (sessions != null)
        'sessions': jsonEncode(sessions.map((e) => e.toJson()).toList()),
      if (tools != null)
        'tools': jsonEncode(tools.map((e) => e.toJson()).toList())
    };
  }
}
