import 'dart:convert';

import 'package:http/http.dart';

class OpenLibraryService {
  String apiEndpoint = 'https://openlibrary.org/api/books';

  Future<Map<String, dynamic>> getBookInfoFromIsbn(String isbn) async {
    String url = '$apiEndpoint?bibkeys=ISBN:$isbn&jscmd=data&format=json';

    Response response;

    try {
      response = await get(Uri.parse(url));
    } catch (e) {
      print('Error: ${e.toString()}');
      return {};
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // means the response is probably good
      Map<String, dynamic> initialResponse = jsonDecode(response.body);
      return initialResponse['ISBN:$isbn'] ?? {};
    } else {
      print('Error ${response.statusCode}: ${response.reasonPhrase}');
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> searchForBook(String title) async {
    title = title.trim().replaceAll(' ', '+');
    String url = 'https://openlibrary.org/search.json?title=$title';

    Response response;

    try {
      response = await get(Uri.parse(url));
    } catch (e) {
      print('Error searching OpenLibrary: ${e.toString()}');
      return [];
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // means the response is probably good
      Map<String, dynamic> initialResponse = jsonDecode(response.body) ?? {};
      int maxResults = 10;
      List<dynamic> unTypedItems = initialResponse['docs'] ?? [];
      List<Map<String, dynamic>> docs =
          unTypedItems.map((e) => Map<String, dynamic>.from(e)).toList();
      List<Map<String, dynamic>> items = docs
          .getRange(0, docs.length < maxResults ? docs.length : maxResults)
          .toList();
      return items;
      // return initialResponse['ISBN:$isbn'] ?? {};
    } else {
      print('Error ${response.statusCode}: ${response.reasonPhrase}');
      return [];
    }
  }
}
