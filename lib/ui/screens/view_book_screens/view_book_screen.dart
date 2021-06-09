import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:otlet/business_logic/models/otlet_instance.dart';
import 'package:otlet/ui/screens/view_book_screens/view_book_tabs/edit_book_info_tab.dart';
import 'package:otlet/ui/screens/view_book_screens/view_book_tabs/edit_book_tools_tab.dart';
import 'package:otlet/ui/screens/view_book_screens/view_book_tabs/book_info_static.dart';
import 'package:otlet/ui/screens/view_book_screens/view_book_tabs/book_sessions_tab.dart';
import 'package:otlet/ui/screens/view_book_screens/view_book_tabs/book_tools_static_tab.dart';
import 'package:otlet/ui/widgets/alerts/confirm_dialog.dart';
import 'package:provider/provider.dart';

import '../../../business_logic/models/book.dart';
import '../../../business_logic/utils/constants.dart';

class ViewBookScreen extends StatefulWidget {
  final Book book;
  final Function(int) updateScreenIndex;

  ViewBookScreen(this.book, {@required this.updateScreenIndex});
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
        if (isEditing) {
          setState(() {
            isEditing = false;
          });
          return Future.value(false);
        }
        if (book.hasBeenEdited) {
          bool shouldPop = await showConfirmDialog(
              'Discard changes to ${book.title}?', context);
          if (!shouldPop) return Future.value(false);
        }
        widget.updateScreenIndex(ScreenIndex.mainTabs);
        return Future.value(false);
      },
      child: Consumer<OtletInstance>(builder: (context, instance, _) {
        Column bookviewHeader = Column(children: [
          Row(
            children: [
              book.coverUrl != null
                  ? book.coverImage(bookImageWidth)
                  : Container(
                      color: Colors.grey,
                      width: bookImageWidth,
                      height: bookImageWidth * 1.5,
                      child: Center(
                          child: Text(book.relevantFirstChar(),
                              style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))),
                    ),
              Expanded(
                child: Container(
                  height: bookImageWidth * 1.5,
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
                    backgroundColor: Theme.of(context).backgroundColor,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).accentColor),
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
            title: Image.asset(
              'assets/images/book_logo_small.png',
              scale: 2.7,
            ),
            centerTitle: true,
            leading: IconButton(
                icon: backButton(),
                onPressed: () async {
                  if (isEditing) {
                    setState(() {
                      isEditing = false;
                    });
                    return;
                  }
                  if (book.hasBeenEdited) {
                    bool shouldPop = await showConfirmDialog(
                        'Discard changes to ${book.title}?', context);
                    if (!shouldPop) return;
                  }
                  widget.updateScreenIndex(ScreenIndex.mainTabs);
                }),
            actions: [
              if (isEditing)
                IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      bool shouldDelete = await showConfirmDialog(
                          'Are you sure you want to delete ${book.title}?',
                          context);
                      if (!shouldDelete) return;
                      Navigator.pop(context, Book.toDelete(book));
                    })
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
                            updateTrackProgress: (trackProgress) {
                              setState(() {
                                book.trackProgress = trackProgress;
                                book.hasBeenEdited = true;
                              });
                            },
                          ),
                    isEditing
                        ? EditBookToolsTab(
                            book,
                            stopEditing: () {
                              setState(() {
                                isEditing = false;
                                book.hasBeenEdited = true;
                              });
                            },
                            onValueChange: (editedBook) {
                              setState(() {
                                book.hasBeenEdited = true;
                                book = editedBook;
                              });
                            },
                          )
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
              if (isEditing)
                OutlinedButton(
                    onPressed: () {
                      setState(() {
                        isEditing = false;
                        book.hasBeenEdited = true;
                      });
                    },
                    child: Text('Stop Editing',
                        style: TextStyle(fontSize: 16, color: primaryColor))),
              if (book.hasBeenEdited && !isEditing)
                ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: primaryColor),
                    onPressed: () {
                      book.hasBeenEdited = false;
                      instance.modifyBook(book);
                      widget.updateScreenIndex(ScreenIndex.mainTabs);
                    },
                    child: Container(
                        width: MediaQuery.of(context).size.width * .65,
                        child: Center(
                            child: Text('Save Book',
                                style: TextStyle(fontSize: 17))))),
              if (book.hasBeenEdited || isEditing)
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
