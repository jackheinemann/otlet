import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';
import 'package:otlet/business_logic/models/book.dart';
import 'package:otlet/business_logic/services/open_library_service.dart';
import 'package:otlet/ui/widgets/books/book_search_result_card.dart';

import '../../business_logic/utils/constants.dart';

class AddBookScreen extends StatefulWidget {
  @override
  _AddBookScreenState createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();

  Book book = Book();

  bool isSearching = false;
  List<Book> searchResults = [];

  TextEditingController titleController = TextEditingController();
  TextEditingController authorController = TextEditingController();
  TextEditingController genreController = TextEditingController();
  TextEditingController publishedController = TextEditingController();
  TextEditingController pageCountController = TextEditingController();
  OpenLibraryService libraryService = OpenLibraryService();

  double bookImageWidth;

  // @override
  // initState() {
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    bookImageWidth = MediaQuery.of(context).size.width * .15;
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Book'),
        centerTitle: true,
        actions: [
          IconButton(
              icon: Icon(Icons.qr_code_scanner),
              onPressed: () async {
                String barcodeScan = await FlutterBarcodeScanner.scanBarcode(
                    null, 'Cancel', true, ScanMode.BARCODE);

                if (barcodeScan.trim() == '-1') return;

                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: LinearProgressIndicator(
                            backgroundColor: Theme.of(context).backgroundColor,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).accentColor),
                          ),
                        ));

                // we have an ISBN code to lookup
                Map<String, dynamic> bookJson =
                    await libraryService.getBookInfoFromIsbn(barcodeScan);
                if (bookJson.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Text('Error retrieving data for ISBN $barcodeScan')));
                } else {
                  // we have book data
                  setState(() {
                    book = Book.fromOpenLibrary(bookJson);
                    book.isbn = barcodeScan;
                    titleController.text = book.title;
                    authorController.text = book.author;
                    genreController.text = book.genre;
                    if (book.published != null)
                      publishedController.text =
                          DateFormat('y').format(book.published);
                    if (book.pageCount != null)
                      pageCountController.text = book.pageCount.toString();
                  });
                }

                Navigator.pop(context);
              }),
          IconButton(
              icon: Icon(isSearching ? Icons.search_off : Icons.search),
              onPressed: () async {
                // if (isSearching && titleController.text.isNotEmpty) {
                //   showDialog(
                //       context: context,
                //       builder: (context) => AlertDialog(
                //             title: Text('Loading search results'),
                //             content: LinearProgressIndicator(),
                //           ));
                //   List<Map<String, dynamic>> results = await libraryService
                //       .searchForBook(titleController.text);
                //   searchResults = results
                //       .map((e) => Book.fromOpenLibrarySearch(e))
                //       .toList();
                //   Navigator.pop(context);
                // }
                setState(() {
                  isSearching = !isSearching;
                });
              })
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: isSearching
              ? Column(
                  children: [
                    SizedBox(height: 10),
                    TextFormField(
                      textCapitalization: TextCapitalization.words,
                      controller: titleController,
                      textInputAction:
                          isSearching ? TextInputAction.search : null,
                      decoration: InputDecoration(
                          labelText: 'Search by title',
                          border: OutlineInputBorder()),
                      onEditingComplete: () async {
                        FocusScope.of(context).unfocus();
                        if (!isSearching) return;
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: Text('Loading search results'),
                                  content: LinearProgressIndicator(),
                                ));
                        List<Map<String, dynamic>> results =
                            await libraryService
                                .searchForBook(titleController.text);
                        searchResults = results
                            .map((e) => Book.fromOpenLibrarySearch(e))
                            .toList();
                        setState(() {
                          searchResults.removeWhere(
                              (element) => element.coverUrl == null);
                        });
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(height: 15),
                    if (isSearching)
                      searchResults.length == 0
                          ? Column(
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                Center(
                                  child: Text('No Results To Display',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500)),
                                ),
                              ],
                            )
                          : Expanded(
                              child: ListView.builder(
                                  itemCount: searchResults.length,
                                  itemBuilder: (context, i) =>
                                      BookSearchResultCard(
                                        searchResults[i],
                                        selectEdition: (edition) {
                                          setState(() {
                                            book = searchResults[i];
                                            book.importEditionInfo(edition);
                                            titleController.text = book.title;
                                            authorController.text = book.author;
                                            genreController.text = book.genre;
                                            if (book.published != null)
                                              publishedController.text =
                                                  DateFormat('y')
                                                      .format(book.published);
                                            // if (book.pageCount != null)
                                            //   pageCountController.text =
                                            //       book.pageCount.toString();
                                            isSearching = false;
                                          });
                                        },
                                      )),
                            )
                  ],
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 10),
                      Row(children: [
                        if (!isSearching)
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              color: primaryColor,
                              width: bookImageWidth,
                              height: bookImageWidth * 1.4,
                              child: Center(
                                  child: Icon(
                                Icons.add_a_photo,
                                size: 20,
                                color: Colors.white,
                              )),
                            ),
                          ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 8.0, bottom: 8, left: 8),
                            child: TextFormField(
                              textCapitalization: TextCapitalization.words,
                              controller: titleController,
                              decoration: InputDecoration(
                                  labelText: 'Title (required)',
                                  border: OutlineInputBorder()),
                              validator: (value) {
                                if (value.trim().isEmpty)
                                  return 'Title required';
                                return null;
                              },
                            ),
                          ),
                        ),
                      ]),
                      SizedBox(height: 15),
                      TextFormField(
                        textCapitalization: TextCapitalization.words,
                        controller: authorController,
                        decoration: InputDecoration(
                            labelText: 'Author', border: OutlineInputBorder()),
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        textCapitalization: TextCapitalization.words,
                        controller: genreController,
                        decoration: InputDecoration(
                            labelText: 'Genre', border: OutlineInputBorder()),
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: publishedController,
                        keyboardType:
                            TextInputType.numberWithOptions(signed: true),
                        validator: (value) {
                          if (value.trim().isEmpty) return null;
                          try {
                            DateFormat('y').parse(value.trim());
                            return null;
                          } catch (e) {
                            return 'Enter a valid year';
                          }
                        },
                        decoration: InputDecoration(
                            labelText: 'Publication Year',
                            border: OutlineInputBorder()),
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        keyboardType:
                            TextInputType.numberWithOptions(signed: true),
                        controller: pageCountController,
                        decoration: InputDecoration(
                            labelText: 'Page Count',
                            border: OutlineInputBorder()),
                      ),
                      SizedBox(height: 40),
                      ElevatedButton(
                          style:
                              ElevatedButton.styleFrom(primary: primaryColor),
                          onPressed: () {
                            if (!_formKey.currentState.validate()) return;
                            book.title = titleController.text.trim();
                            book.author = authorController.text.trim();
                            book.genre = genreController.text.trim();

                            book.pageCount =
                                int.tryParse(pageCountController.text.trim());
                            try {
                              book.published = DateFormat('y')
                                  .parse(publishedController.text.trim());
                            } catch (e) {
                              print('Error formatting published date');
                            }

                            Navigator.pop(context, book);
                          },
                          child: Text('Add to My Books')),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
