import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:otlet/business_logic/models/chart_helpers.dart';
import 'package:otlet/business_logic/models/otlet_chart.dart';
import 'package:otlet/business_logic/models/reading_session.dart';
import 'package:otlet/business_logic/models/tool.dart';
import 'package:otlet/business_logic/utils/constants.dart';
import 'package:otlet/business_logic/utils/functions.dart';
import 'package:uuid/uuid.dart';

import 'reading_session.dart';

class Book {
  String id;
  String isbn;
  String title;
  String coverUrl;
  String author;
  DateTime started;
  DateTime finished;
  String genre;
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
  List<Tool> otletTools = [];

  List<String> editionIds = []; // openlibrary title search stuff

  Book({
    this.title,
    this.author,
    this.started,
    this.finished,
    this.genre,
    this.rating,
    this.published,
    this.pageCount,
    this.wordCount,
    this.sessions,
  }) {
    id = Uuid().v1();
  }

  Book.toDelete(Book book) {
    id = book.id;
  }

  Book.fromBook(Book book) {
    id = book.id;
    isbn = book.isbn;
    title = book.title;
    coverUrl = book.coverUrl;
    author = book.author;
    started = book.started;
    finished = book.finished;
    genre = book.genre;
    rating = book.rating;
    published = book.published;
    pageCount = book.pageCount;
    wordCount = book.wordCount;
    currentPage = book.currentPage;
    trackProgress = book.trackProgress;
    sessions = List<ReadingSession>.from(book.sessions ?? []);
    isActive = book.isActive;
    tools = book.tools.map((e) => Tool.fromTool(e)).toList();
    otletTools = book.otletTools.map((e) => Tool.fromTool(e)).toList();
    editionIds = List<String>.from(book.editionIds);
  }

  Book.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    author = json['author'];
    coverUrl = json['coverUrl'];
    if (json['started'] != null) started = DateTime.parse(json['started']);
    if (json['finished'] != null) finished = DateTime.parse(json['finished']);
    genre = json['genre'];
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
    if (json['otletTools'] != null) {
      List<dynamic> otletToolsJson =
          List<dynamic>.from(jsonDecode(json['otletTools']));
      for (Map<String, dynamic> json in otletToolsJson) {
        otletTools.add(Tool.fromJson(json));
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
      genre = parseGenres(
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

  Book.fromOpenLibraryEdition(Map<String, dynamic> json) {
    id = Uuid().v1();
    title = json['title'] ?? json['full_title'] ?? 'title error';
    if (json['covers'] != null) {
      List<int> coverKeys = List<int>.from(json['covers']);

      if (!coverKeys.contains(-1))
        coverUrl = generateCoverUrl(coverKeys.first.toString());
    }
    if (json['publish_date'] != null) {
      print(json['publish_date']);
      try {
        published = DateTime.parse(json['publish_date']);
      } catch (e) {
        print(e);
        try {
          published = DateFormat('y').parse(json['publish_date']);
        } catch (e) {
          print(e);
        }
      }
    }
    if (json['number_of_pages'] != null) pageCount = json['number_of_pages'];
  }

  Book.fromOpenLibrarySearch(Map<String, dynamic> json) {
    id = Uuid().v1();
    title = json['title_suggest'] ?? json['title'];
    if (json['cover_i'] != null)
      coverUrl = generateCoverUrl(json['cover_i'].toString());
    if (json['author_name'] != null) author = json['author_name'].first;
    if (json['subject'] != null) {
      List<String> subjects = List<String>.from(json['subject']);
      genre = parseGenres(subjects) ?? null;
    }
    if (json['first_publish_year'] != null)
      published = DateFormat('y').parse(json['first_publish_year'].toString());
    if (json['edition_key'] != null)
      editionIds = List<String>.from(json['edition_key']);
  }

  Widget coverImage(double width, [double height]) {
    if (coverUrl.contains('http'))
      return CachedNetworkImage(
        imageUrl: coverUrl,
        width: width,
      );
    else
      return Image.file(File(coverUrl), height: height, width: width);
  }

  bool doesPassChartFilters(OtletChart chart) {
    for (ChartFilter filter in chart.filters) {
      Tool pseudoTool = filter.pseudoTool;
      Tool bookTool = (tools + otletTools)
          .firstWhere((element) => element.compareToolId(pseudoTool));
      print(bookTool.name);
      print(bookTool.value);
      if (!bookTool.isActive) return false;
      if (bookTool.value == null) return false;
      if (!filter.compareFilterValue(bookTool)) return false;
    }
    return true;
  }

  bool compareIds(Book book) {
    if (book == null) return false;
    return book.id == id;
  }

  bool compareToBook(Book book) {
    if (book.id != id) return false;
    if (book.title != title) return false;
    if (book.author != author) return false;
    if (book.genre != genre) return false;
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
    for (int i = 0; i < book.tools.length; i++) {
      Tool sourceTool = tools[i];
      Tool foreignTool = book.tools[i];
      if (sourceTool.value != foreignTool.value) return false;
      if (sourceTool.isActive != foreignTool.isActive) return false;
    }
    if (book.isActive != isActive) return false;
    return true;
  }

  String displayPublicationYear() => DateFormat('y').format(published);

  void importEditionInfo(Book edition) {
    title = edition.title;
    if (edition.published != null) published = edition.published;
    if (edition.pageCount != null) pageCount = edition.pageCount;
    if (edition.coverUrl != null) coverUrl = edition.coverUrl;
  }

  void injectModifiedMasterTool(Tool masterTool) {
    Tool newTool = Tool.fromTool(masterTool); // make a copy of the master tool
    int indexOfTool;
    for (int i = 0; i < tools.length; i++) {
      Tool tool = tools[i];
      if (masterTool.compareToolId(tool)) {
        // means we've found the old version of master tool
        if (masterTool.toolType == tool.toolType) {
          // toolType and fixedOptions have not changed, so attach old value
          if (masterTool.fixedOptions.toString() ==
                  tool.fixedOptions.toString() ||
              masterTool.fixedOptions.contains(tool.value))
            newTool.value = tool.value;
          else
            newTool.value = null;
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
    if (genre != null) return false;
    return true;
  }

  String parseGenres(List<String> subjects) {
    List<String> parsedGenres = [];
    for (String subject in subjects) {
      for (String genre in litGenres) {
        if (subject.trim().toLowerCase() == genre.trim().toLowerCase() &&
            !parsedGenres.contains(genre)) {
          return genre;
        }
      }
    }
    return null;
  }

  String readingPercent() {
    int percent = (readingProgress() * 100).round();
    if (currentPage < pageCount && percent == 1) percent = 99;
    if (currentPage > 0 && percent == 0) percent = 1;
    return '$percent%';
  }

  double readingProgress() {
    if (currentPage == null || pageCount == null) return null;

    double progress = currentPage.toDouble() / pageCount.toDouble();

    if (progress > 1) return 1;

    return progress;
  }

  String relevantFirstChar() {
    String titleString = title.toLowerCase();
    titleString = titleString.replaceAll('the ', '');
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
      'genre': genre,
      'rating': rating,
      'published': published?.toString(),
      'pageCount': pageCount,
      'wordCount': wordCount,
      'currentPage': currentPage,
      'trackProgress': trackProgress,
      if (sessions != null)
        'sessions': jsonEncode(sessions.map((e) => e.toJson()).toList()),
      if (tools != null)
        'tools': jsonEncode(tools.map((e) => e.toJson()).toList()),
      if (otletTools != null)
        'otletTools': jsonEncode(otletTools.map((e) => e.toJson()).toList())
    };
  }
}
