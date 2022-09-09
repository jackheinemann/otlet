import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:otlet/business_logic/models/book.dart';
import 'package:otlet/business_logic/models/otlet_instance.dart';
import 'package:otlet/business_logic/services/open_library_service.dart';
import 'package:otlet/ui/screens/general/collections_selector.dart';
import 'package:otlet/ui/screens/view_book_editions_screen.dart';
import 'package:otlet/ui/widgets/alerts/confirm_dialog.dart';
import 'package:otlet/ui/widgets/books/book_search_result_card.dart';
import 'package:provider/provider.dart';

import '../../business_logic/utils/constants.dart';

class AddBookScreen extends StatefulWidget {
  final Function(int) updateScreenIndex;

  AddBookScreen({@required this.updateScreenIndex});
  @override
  _AddBookScreenState createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();

  Book book = Book();

  OtletInstance instance;

  bool isSearching = false;
  List<Book> searchResults = [];

  int _currentAddIndex = 0; // handle add book screens (main, qr, editions, etc)

  TextEditingController titleController = TextEditingController();
  TextEditingController authorController = TextEditingController();
  TextEditingController genreController = TextEditingController();
  TextEditingController publishedController = TextEditingController();
  TextEditingController pageCountController = TextEditingController();
  TextEditingController collectionController = TextEditingController();
  OpenLibraryService libraryService = OpenLibraryService();

  double bookImageWidth;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bookImageWidth = MediaQuery.of(context).size.width * .15;
    return Consumer<OtletInstance>(
      builder: (context, instance, _) => _currentAddIndex == 0
          ? WillPopScope(
              onWillPop: () async {
                bool shouldPop =
                    await showConfirmDialog('Discard current book?', context);
                if (shouldPop) widget.updateScreenIndex(ScreenIndex.mainTabs);
                return Future.value(false);
              },
              child: Scaffold(
                appBar: AppBar(
                  title: Text('Add New Book'),
                  centerTitle: true,
                  leading: IconButton(
                      icon: Icon(Platform.isAndroid
                          ? Icons.arrow_back
                          : Icons.arrow_back_ios),
                      onPressed: () async {
                        bool shouldPop = await showConfirmDialog(
                            'Discard current book?', context);
                        if (shouldPop)
                          widget.updateScreenIndex(ScreenIndex.mainTabs);
                      }),
                  actions: [
                    IconButton(
                        icon: Icon(Icons.qr_code_scanner),
                        onPressed: () async {
                          String barcodeScan =
                              await FlutterBarcodeScanner.scanBarcode(
                                  null, 'Cancel', true, ScanMode.BARCODE);

                          if (barcodeScan.trim() == '-1') return;

                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: LinearProgressIndicator(
                                      backgroundColor:
                                          Theme.of(context).backgroundColor,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Theme.of(context).accentColor),
                                    ),
                                  ));

                          // we have an ISBN code to lookup
                          Map<String, dynamic> bookJson = await libraryService
                              .getBookInfoFromIsbn(barcodeScan);
                          if (bookJson.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    'Error retrieving data for ISBN $barcodeScan')));
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
                                pageCountController.text =
                                    book.pageCount.toString();
                              isSearching = false;
                            });
                          }

                          Navigator.pop(context);
                        }),
                    IconButton(
                        icon:
                            Icon(isSearching ? Icons.search_off : Icons.search),
                        onPressed: () async {
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
                                            title:
                                                Text('Loading search results'),
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
                                                    fontWeight:
                                                        FontWeight.w500)),
                                          ),
                                        ],
                                      )
                                    : Expanded(
                                        child: ListView.builder(
                                            itemCount: searchResults.length,
                                            itemBuilder: (context, i) =>
                                                BookSearchResultCard(
                                                  searchResults[i],
                                                  selectWork: (work) {
                                                    setState(() {
                                                      book = work;
                                                      _currentAddIndex = 2;
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
                                        onTap: () async {
                                          final picked = await picker.getImage(
                                              source: ImageSource.gallery);

                                          if (picked == null) return;

                                          File cropped = await ImageCropper()
                                              .cropImage(
                                                  sourcePath: picked.path,
                                                  aspectRatio: CropAspectRatio(
                                                      ratioX: 1, ratioY: 1.5));

                                          setState(() {
                                            book.coverUrl = cropped.path;
                                          });
                                        },
                                        child: book.coverUrl == null
                                            ? Container(
                                                color: primaryColor,
                                                width: bookImageWidth,
                                                height: bookImageWidth * 1.5,
                                                child: Center(
                                                    child: Icon(
                                                  Icons.add_a_photo,
                                                  size: 20,
                                                  color: Colors.white,
                                                )),
                                              )
                                            : book.coverImage(bookImageWidth,
                                                bookImageWidth * 1.5)
                                        // : book.coverUrl.contains('http')
                                        //     ? CachedNetworkImage(
                                        //         imageUrl: book.coverUrl,
                                        //       )
                                        //     : Image.file(File(book.coverUrl),
                                        //         width: bookImageWidth),
                                        ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8.0, bottom: 8, left: 8),
                                      child: TextFormField(
                                        textCapitalization:
                                            TextCapitalization.words,
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
                                      labelText: 'Author',
                                      border: OutlineInputBorder()),
                                ),
                                SizedBox(height: 15),
                                TextFormField(
                                  textCapitalization: TextCapitalization.words,
                                  controller: genreController,
                                  decoration: InputDecoration(
                                      labelText: 'Genre',
                                      border: OutlineInputBorder()),
                                ),
                                SizedBox(height: 15),
                                TextFormField(
                                  controller: publishedController,
                                  keyboardType: TextInputType.numberWithOptions(
                                      signed: true),
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
                                  keyboardType: TextInputType.numberWithOptions(
                                      signed: true),
                                  controller: pageCountController,
                                  decoration: InputDecoration(
                                      labelText: 'Page Count',
                                      border: OutlineInputBorder()),
                                ),
                                SizedBox(height: 15),
                                TextFormField(
                                  controller: collectionController,
                                  textCapitalization: TextCapitalization.words,
                                  readOnly: true,
                                  onTap: () async {
                                    setState(() {
                                      _currentAddIndex = 1;
                                    });
                                    // if (collections == null) return;

                                    // List<String> selected = collections.keys
                                    //     .where((element) => collections[element])
                                    //     .toList(); // where collections[element] == true

                                    // setState(() {
                                    //   book.collections = selected;
                                    //   instance.collections =
                                    //       collections.keys.toList();
                                    //   collectionController.text = selected.join(', ');
                                    // });
                                  },
                                  decoration: InputDecoration(
                                      labelText: 'Collections',
                                      border: OutlineInputBorder()),
                                ),
                                SizedBox(height: 40),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: primaryColor),
                                    onPressed: () {
                                      if (!_formKey.currentState.validate())
                                        return;
                                      book.title = titleController.text.trim();
                                      book.author =
                                          authorController.text.trim();
                                      book.genre = genreController.text.isEmpty
                                          ? null
                                          : genreController.text.trim();
                                      book.pageCount = int.tryParse(
                                          pageCountController.text.trim());
                                      try {
                                        book.published = DateFormat('y').parse(
                                            publishedController.text.trim());
                                      } catch (e) {
                                        print(
                                            'Error formatting published date');
                                      }

                                      instance.addNewBook(book);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                                  'Saved ${book.title} to Books!')));
                                      widget.updateScreenIndex(
                                          ScreenIndex.mainTabs);
                                    },
                                    child: Text('Add to My Books')),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            )
          : _currentAddIndex == 1
              ? CollectionsSelector(
                  options: instance.generateBookCollections(book),
                  instance: instance,
                  title: 'Manage Collections',
                  updateAddIndex: (index, {options}) {
                    setState(() {
                      if (options != null) {
                        book.collections = options.keys
                            .where((element) => options[element])
                            .toList();
                        collectionController.text = book.collections.join(', ');
                      }
                      _currentAddIndex = 0;
                    });
                  },
                )
              : ViewBookEditionsScreen(
                  book,
                  selectEdition: (edition) {
                    setState(() {
                      book.importEditionInfo(edition);
                      titleController.text = book.title;
                      authorController.text = book.author;
                      genreController.text = book.genre;
                      if (book.published != null)
                        publishedController.text =
                            DateFormat('y').format(book.published);
                      isSearching = false;
                      _currentAddIndex = 0;
                    });
                  },
                ),
    );
  }
}
