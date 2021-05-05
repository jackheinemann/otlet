import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:otlet/ui/screens/view_book_tabs/book_info_edit.dart';
import 'package:otlet/ui/screens/view_book_tabs/book_info_static.dart';
import 'package:otlet/ui/screens/view_book_tabs/book_sessions_tab.dart';
import 'package:otlet/ui/widgets/alerts/confirm_dialog.dart';
import 'package:provider/provider.dart';

import '../../business_logic/models/book.dart';
import '../../business_logic/utils/constants.dart';

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
        if (book.hasBeenEdited) {
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
          Divider(),
        ]);
        // START SCAFFOLD

        return Scaffold(
          appBar: AppBar(
            title: Icon(Icons.menu_book),
            centerTitle: true,
            actions: [
              IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () async {
                    Book temp = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                BookInfoEdit(Book.fromBook(book))));
                    if (temp == null) return;
                    temp.hasBeenEdited = true;
                    setState(() {
                      book = temp;
                    });
                  })
            ],
          ),
          body: Column(
            children: [
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
                    BookInfoStatic(book),
                    Center(child: Text('No tools yet')),
                    BookSessionsTab(book)
                  ]
                      .map((e) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: e,
                          ))
                      .toList(),
                ),
              ),
              if (book.hasBeenEdited)
                ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: primaryColor),
                    onPressed: () {
                      book.hasBeenEdited = false;
                      Navigator.pop(context, book);
                    },
                    child: Container(
                        width: MediaQuery.of(context).size.width * .65,
                        child: Center(
                            child: Text('Save Edits',
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
