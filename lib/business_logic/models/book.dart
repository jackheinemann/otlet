import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:otlet/business_logic/models/reading_session.dart';
import 'package:otlet/business_logic/utils/constants.dart';
import 'package:uuid/uuid.dart';

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

  List<ReadingSession> sessions = [];

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
    // tools = book.tools.map((e) => Tool.fromTool(e)).toList();
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
    // if (json['tools'] != null) {
    //   List<dynamic> toolsJson = List<dynamic>.from(jsonDecode(json['tools']));
    //   for (Map<String, dynamic> json in toolsJson) {
    //     tools.add(Tool.fromJson(json));
    //   }
    // }
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
      // if (tools != null)
      //   'tools': jsonEncode(tools.map((e) => e.toJson()).toList())
    };
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

  String relevantFirstChar() {
    String titleString = title.toLowerCase();
    titleString = titleString.replaceAll('the', '');
    titleString = titleString.replaceAll('a ', '');
    titleString = titleString.trim();
    return titleString[0].toUpperCase();
  }

  double readingProgress() {
    if (currentPage == null || pageCount == null) return null;

    double progress = currentPage.toDouble() / pageCount.toDouble();

    if (progress > 1) return 1;

    return progress;
  }
}
