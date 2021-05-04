import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';
import 'package:otlet/business_logic/models/book.dart';
import 'package:otlet/business_logic/services/open_library_service.dart';

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
                          title: LinearProgressIndicator(),
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
                    genreController.text = book.genres.join(', ');
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
                      labelText: 'Genres',
                      hintText: 'Separate with commas',
                      border: OutlineInputBorder()),
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: publishedController,
                  readOnly: true,
                  onTap: () async {
                    DateTime published = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(0),
                        lastDate: DateTime.now().add(Duration(days: 7)));

                    if (published != null) {
                      setState(() {
                        book.published = published;
                        publishedController.text =
                            DateFormat('y').format(published);
                      });
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
                    onPressed: () {
                      if (!_formKey.currentState.validate()) return;
                      book.title = titleController.text.trim();
                      book.author = authorController.text.trim();
                      book.genres = genreController.text
                          .split(',')
                          .map((e) => e.trim())
                          .toList();
                      book.pageCount =
                          int.tryParse(pageCountController.text.trim());

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
