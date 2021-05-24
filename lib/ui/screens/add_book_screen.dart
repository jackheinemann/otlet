import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';
import 'package:otlet/business_logic/models/book.dart';
import 'package:otlet/business_logic/services/open_library_service.dart';

import '../../business_logic/utils/constants.dart';

class AddBookScreen extends StatefulWidget {
  @override
  _AddBookScreenState createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();

  Book book = Book();

  TextEditingController titleController = TextEditingController();
  TextEditingController authorController = TextEditingController();
  TextEditingController genreController = TextEditingController();
  TextEditingController publishedController = TextEditingController();
  TextEditingController pageCountController = TextEditingController();
  OpenLibraryService libraryService = OpenLibraryService();

  @override
  Widget build(BuildContext context) {
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
              })
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                TextFormField(
                  textCapitalization: TextCapitalization.words,
                  controller: titleController,
                  decoration: InputDecoration(
                      labelText: 'Title (required)',
                      border: OutlineInputBorder()),
                  validator: (value) {
                    if (value.trim().isEmpty) return 'Title required';
                    return null;
                  },
                ),
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
                  keyboardType: TextInputType.numberWithOptions(signed: true),
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
                  keyboardType: TextInputType.numberWithOptions(signed: true),
                  controller: pageCountController,
                  decoration: InputDecoration(
                      labelText: 'Page Count', border: OutlineInputBorder()),
                ),
                SizedBox(height: 40),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: primaryColor),
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
