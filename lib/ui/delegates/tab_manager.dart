import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/book.dart';
import 'package:otlet/business_logic/models/otlet_instance.dart';
import 'package:otlet/business_logic/models/tool.dart';
import 'package:otlet/business_logic/utils/functions.dart';
import 'package:otlet/ui/screens/home_screen.dart';
import 'package:otlet/ui/screens/view_books_screen.dart';
import 'package:otlet/ui/screens/view_tools_screens/view_tools_screen.dart';
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
            if (_currentIndex == 1 || _currentIndex == 2)
              IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () async {
                    if (_currentIndex == 1) {
                      Book temp = await createNewBook(context);
                      if (temp == null) return;
                      // got a new book!
                      setState(() {
                        instance.addNewBook(temp);
                      });

                      // save to json local storage
                      instance.saveInstance();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Saved ${temp.title} to Books!')));
                    } else {
                      Tool tool = await createNewTool(context);
                      if (tool == null) return;
                      setState(() {
                        instance.addNewTool(tool);
                      });
                    }
                  })
          ],
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: [HomeScreen(), ViewBooksScreen(), ViewToolsScreen()],
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
                  icon: Icon(Icons.library_books), label: 'My Books'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.build), label: 'My Tools'),
            ]),
      ),
    );
  }
}
