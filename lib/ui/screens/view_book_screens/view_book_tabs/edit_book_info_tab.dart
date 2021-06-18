import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:otlet/business_logic/models/otlet_instance.dart';
import 'package:otlet/ui/widgets/alerts/collection_selector.dart';
import 'package:provider/provider.dart';

import '../../../../business_logic/models/book.dart';
import '../../../../business_logic/utils/constants.dart';

class EditBookInfoTab extends StatefulWidget {
  final Book book;
  final VoidCallback stopEditing;
  EditBookInfoTab(this.book, {@required this.stopEditing});
  @override
  _EditBookInfoTabState createState() => _EditBookInfoTabState();
}

class _EditBookInfoTabState extends State<EditBookInfoTab> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController genreController = TextEditingController();
  final TextEditingController publishedController = TextEditingController();
  final TextEditingController pageCountController = TextEditingController();
  final TextEditingController currentPageController = TextEditingController();
  final TextEditingController collectionController = TextEditingController();
  final TextEditingController startedController = TextEditingController();
  final TextEditingController finishedController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Book book;

  final picker = ImagePicker();
  double bookImageWidth;

  @override
  initState() {
    super.initState();
    book = widget.book;
    if (book.started != null)
      startedController.text = monthDayYearFormat.format(book.started);
    if (book.finished != null)
      finishedController.text = monthDayYearFormat.format(book.finished);
    titleController.text = book.title;
    authorController.text = book.author;
    if (book.genre != null) genreController.text = book.genre;
    if (book.published != null)
      publishedController.text = DateFormat('y').format(book.published);
    if (book.pageCount != null)
      pageCountController.text = book.pageCount.toString();
    if (book.currentPage != null)
      currentPageController.text = book.currentPage.toString();
    if (book.collections != null)
      collectionController.text = book.collections.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    bookImageWidth = MediaQuery.of(context).size.width * .15;
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 10),
                  Row(
                    children: [
                      GestureDetector(
                          onTap: () async {
                            final picked = await picker.getImage(
                                source: ImageSource.gallery);

                            if (picked == null) return;

                            File cropped = await ImageCropper.cropImage(
                                sourcePath: picked.path,
                                aspectRatio:
                                    CropAspectRatio(ratioX: 1, ratioY: 1.5));

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
                              : book.coverImage(
                                  bookImageWidth, bookImageWidth * 1.5)),
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
                              if (value.trim().isEmpty) return 'Title required';
                              return null;
                            },
                            onEditingComplete: () {
                              FocusScope.of(context).unfocus();
                              setState(() {
                                book.title = titleController.text.trim();
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    textCapitalization: TextCapitalization.words,
                    controller: authorController,
                    decoration: InputDecoration(
                        labelText: 'Author', border: OutlineInputBorder()),
                    onEditingComplete: () {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        book.author = authorController.text.trim();
                      });
                    },
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    textCapitalization: TextCapitalization.words,
                    controller: genreController,
                    onEditingComplete: () {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        book.genre = genreController.text;
                      });
                    },
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
                    onEditingComplete: () {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        book.published = DateFormat('y')
                            .parse(publishedController.text.trim());
                      });
                    },
                    decoration: InputDecoration(
                        labelText: 'Publication Year',
                        border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: currentPageController,
                    keyboardType: TextInputType.numberWithOptions(signed: true),
                    onEditingComplete: () {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        book.currentPage =
                            int.tryParse(currentPageController.text);
                      });
                    },
                    decoration: InputDecoration(
                        labelText: 'Current Page',
                        border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: pageCountController,
                    keyboardType: TextInputType.numberWithOptions(signed: true),
                    onEditingComplete: () {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        book.pageCount = int.tryParse(pageCountController.text);
                      });
                    },
                    decoration: InputDecoration(
                        labelText: 'Page Count', border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 15),
                  Consumer<OtletInstance>(
                    builder: (context, instance, _) => TextFormField(
                      controller: collectionController,
                      textCapitalization: TextCapitalization.words,
                      readOnly: true,
                      onTap: () async {
                        List<String> selected =
                            await showCollectionSelectorDialog(
                                context,
                                'Assign ${book.title} to:',
                                instance.collections,
                                book.collections);
                        if (selected == null) return;
                        setState(() {
                          book.collections = List<String>.from(selected);
                          collectionController.text =
                              book.collections.join(', ');
                        });
                      },
                      decoration: InputDecoration(
                          labelText: 'Collections',
                          border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    width: MediaQuery.of(context).size.width * .44,
                    child: TextFormField(
                      onTap: () async {
                        DateTime started = await showDatePicker(
                            context: context,
                            initialDate: book.started ?? DateTime.now(),
                            firstDate: DateTime.now()
                                .subtract(Duration(days: 365 * 50)),
                            lastDate: DateTime.now().add(Duration(days: 7)));
                        if (started == null) return;
                        book.started = started;
                        setState(() {
                          startedController.text =
                              monthDayYearFormat.format(started);
                        });
                      },
                      controller: startedController,
                      readOnly: true,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                          labelText: 'Date Started',
                          border: OutlineInputBorder()),
                    )),
                Container(
                  width: MediaQuery.of(context).size.width * .44,
                  child: TextFormField(
                    onTap: () async {
                      DateTime finished = await showDatePicker(
                          context: context,
                          initialDate: book.finished ?? DateTime.now(),
                          firstDate:
                              DateTime.now().subtract(Duration(days: 365 * 50)),
                          lastDate: DateTime.now().add(Duration(days: 7)));
                      if (finished == null) return;
                      book.finished = finished;
                      setState(() {
                        finishedController.text =
                            monthDayYearFormat.format(finished);
                      });
                    },
                    controller: finishedController,
                    readOnly: true,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                        labelText: 'Date Finished',
                        border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    width: MediaQuery.of(context).size.width * .44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: primaryColor),
                      onPressed: () {
                        setState(() {
                          book.started = null;
                          startedController.clear();
                        });
                      },
                      child: Center(child: Text('Clear Date')),
                    )),
                Container(
                    width: MediaQuery.of(context).size.width * .44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: primaryColor),
                      onPressed: () {
                        setState(() {
                          book.finished = null;
                          finishedController.clear();
                        });
                      },
                      child: Center(child: Text('Clear Date')),
                    )),
              ],
            ),
          ),
          // SizedBox(
          //   height: 20,
          // ),
          // Container(
          //     width: MediaQuery.of(context).size.width * .44,
          //     child: ElevatedButton(
          //       style: ElevatedButton.styleFrom(primary: accentColor),
          //       onPressed: () {

          //       },
          //       child: Center(child: Text('')),
          //     )),
        ],
      ),
    );
  }
}
