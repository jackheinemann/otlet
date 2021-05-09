import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  final TextEditingController startedController = TextEditingController();
  final TextEditingController finishedController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Book book;

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
    if (book.genres != null) genreController.text = book.genres.join(', ');
    if (book.published != null)
      publishedController.text = DateFormat('y').format(book.published);
    if (book.pageCount != null)
      pageCountController.text = book.pageCount.toString();
  }

  @override
  Widget build(BuildContext context) {
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
                    onEditingComplete: () {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        book.title = titleController.text.trim();
                      });
                    },
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
                        book.genres = genreController.text
                            .trim()
                            .split(',')
                            .map((e) => e.trim())
                            .toList();
                      });
                    },
                    decoration: InputDecoration(
                        labelText: 'Genres',
                        hintText: 'Separate with commas',
                        border: OutlineInputBorder()),
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