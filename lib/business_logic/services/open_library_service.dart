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
}
