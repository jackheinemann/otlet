import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:otlet/ui/screens/view_book_screens/view_book_tabs/edit_book_info_tab.dart';
import 'package:otlet/ui/screens/view_book_screens/view_book_tabs/edit_book_tools_tab.dart';
import 'package:otlet/ui/screens/view_book_screens/book_info_edit.dart';
import 'package:otlet/ui/screens/view_book_screens/view_book_tabs/book_info_static.dart';
import 'package:otlet/ui/screens/view_book_screens/view_book_tabs/book_sessions_tab.dart';
import 'package:otlet/ui/screens/view_book_screens/view_book_tabs/book_tools_static_tab.dart';
import 'package:otlet/ui/widgets/alerts/confirm_dialog.dart';

import '../../../business_logic/models/book.dart';
import '../../../business_logic/utils/constants.dart';

class ViewBookScreen extends StatefulWidget {
  final Book book;

  ViewBookScreen(this.book);
  @override
  _ViewBookScreenState createState() => _ViewBookScreenState();
}

class _ViewBookScreenState extends State<ViewBookScreen>
    with SingleTickerProviderStateMixin {
  Book book;

  TextEditingController startedController = TextEditingController();
  TextEditingController finishedController = TextEditingController();

  TabController tabController;

  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    book = widget.book;
    tabController = TabController(length: 3, vsync: this);
    if (book.started != null)
      startedController.text = DateFormat('MMMM d y').format(book.started);
    if (book.finished != null)
      finishedController.text = DateFormat('MMMM d y').format(book.finished);
  }

  @override
  Widget build(BuildContext context) {
    double bookImageWidth = MediaQuery.of(context).size.width * .35;
    return WillPopScope(
      onWillPop: () async {
        if (book.hasBeenEdited || isEditing) {
          bool shouldPop = await showConfirmDialog(
              'Discard changes to ${book.title}?', context);
          if (!shouldPop) return Future.value(false);
        }
        Navigator.pop(context);
        return Future.value(true);
      },
      child: Builder(builder: (context) {
        Column bookviewHeader = Column(children: [
          Row(
            children: [
              book.coverUrl != null
                  ? CachedNetworkImage(
                      imageUrl: book.coverUrl,
                      width: bookImageWidth,
                    )
                  : Container(
                      color: Colors.grey,
                      width: bookImageWidth,
                      height: bookImageWidth * 1.4,
                      child: Center(
                          child: Text(book.relevantFirstChar(),
                              style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))),
                    ),
              Expanded(
                child: Container(
                  height: bookImageWidth * 1.4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(book.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      if (book.author != null)
                        Text(book.author,
                            style: TextStyle(
                                fontSize: 19, fontWeight: FontWeight.w400)),
                      if (book.published != null)
                        Text(book.displayPublicationYear(),
                            style: TextStyle(
                                fontSize: 19, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          if (book.trackProgress && book.readingProgress() != null)
            Row(
              children: [
                Spacer(),
                Container(
                  width: MediaQuery.of(context).size.width * .75,
                  child: LinearProgressIndicator(
                    value: book.readingProgress(),
                  ),
                ),
                Spacer(),
                Text(book.readingPercent(),
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                Spacer()
              ],
            ),
          if (book.trackProgress && book.readingProgress() != null)
            SizedBox(
              height: 20,
            ),
          OutlinedButton(
              onPressed: () {
                setState(() {
                  isEditing = true;
                });
              },
              child: Text('Edit',
                  style: TextStyle(fontSize: 16, color: primaryColor))),
          Divider(),
        ]);
        // START SCAFFOLD

        return Scaffold(
          appBar: AppBar(
            title: Icon(Icons.menu_book),
            centerTitle: true,
            actions: [
              // IconButton(
              //     icon: Icon(Icons.edit),
              //     onPressed: () async {
              //       Book temp = Book.fromBook(book);
              //       Book returnedBook = await Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //               builder: (context) => BookInfoEdit(book)));

              //       if (returnedBook != null) if (returnedBook.isEmpty()) {
              //         Navigator.pop(context, returnedBook);
              //         return;
              //       }
              //       if (!temp.compareToBook(book)) {
              //         setState(() {
              //           book.hasBeenEdited = true;
              //         });
              //       }
              //     })
            ],
          ),
          body: Column(
            children: [
              if (!isEditing)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: bookviewHeader,
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(
                  height: 30,
                  child: TabBar(
                    controller: tabController,
                    tabs: ['Info', 'Tools', 'Sessions']
                        .map((e) => Text(e,
                            style:
                                TextStyle(fontSize: 16, color: Colors.black)))
                        .toList(),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: [
                    isEditing
                        ? EditBookInfoTab(book, stopEditing: () {
                            setState(() {
                              isEditing = false;
                              book.hasBeenEdited = true;
                            });
                          })
                        : BookInfoStatic(
                            book,
                            updateActive: (active) {
                              setState(() {
                                book.isActive = active;
                                book.hasBeenEdited = true;
                              });
                            },
                          ),
                    // BookToolsTab(
                    //   book,
                    //   updateBook: (updatedBook) {
                    //     setState(() {
                    //       book = updatedBook;
                    //       book.hasBeenEdited = true;
                    //     });
                    //   },
                    //   toolIsEditing: (tool, editing) {
                    //     setState(() {
                    //       editingTool = editing ? tool : null;
                    //       if (editing == false) book.hasBeenEdited = true;
                    //     });
                    //   },
                    // ),
                    isEditing
                        ? EditBookToolsTab(book, stopEditing: () {
                            setState(() {
                              isEditing = false;
                              book.hasBeenEdited = true;
                            });
                          })
                        : BookToolsStaticTab(book, editTools: () {
                            setState(() {
                              isEditing = true;
                            });
                          }),
                    BookSessionsTab(book)
                  ]
                      .map((e) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: e,
                          ))
                      .toList(),
                ),
              ),
              if (book.hasBeenEdited && !isEditing)
                ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: primaryColor),
                    onPressed: () {
                      book.hasBeenEdited = false;
                      Navigator.pop(context, book);
                    },
                    child: Container(
                        width: MediaQuery.of(context).size.width * .65,
                        child: Center(
                            child: Text('Save Book',
                                style: TextStyle(fontSize: 17))))),
              if (book.hasBeenEdited)
                SizedBox(
                  height: 20,
                )
            ],
          ),
        );
      }),
    );
  }
}
