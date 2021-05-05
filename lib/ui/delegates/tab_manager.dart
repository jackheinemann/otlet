import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otlet/business_logic/models/book.dart';
import 'package:otlet/business_logic/models/otlet_instance.dart';
import 'package:otlet/ui/screens/add_book_screen.dart';
import 'package:otlet/ui/screens/home_screen.dart';
import 'package:otlet/ui/screens/view_books_screen.dart';
import 'package:provider/provider.dart';

class TabManager extends StatefulWidget {
  final OtletInstance instance;

  TabManager(this.instance);
  @override
  _TabManagerState createState() => _TabManagerState();
}

class _TabManagerState extends State<TabManager> {
  OtletInstance instance;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    instance = widget.instance;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableProvider<OtletInstance>(
      create: (context) => instance,
      child: Scaffold(
        appBar: AppBar(
          leading: Icon(Icons.menu_book),
          title: Text('Otlet'),
          centerTitle: true,
          actions: [
            IconButton(
                icon: Icon(Icons.add),
                onPressed: () async {
                  Book temp = await Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddBookScreen()));
                  if (temp == null) return;

                  // got a new book!
                  setState(() {
                    instance.addNewBook(temp);
                  });

                  // save to json local storage
                  instance.saveInstance();
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Saved ${temp.title} to Books!')));
                })
          ],
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: [HomeScreen(), ViewBooksScreen()],
        ),
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) {
              setState(() {
                _currentIndex = i;
              });
            },
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.library_books), label: 'My Books')
            ]),
      ),
    );
  }
}
