import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/book.dart';
import 'package:otlet/business_logic/models/otlet_instance.dart';
import 'package:otlet/business_logic/models/tool.dart';
import 'package:otlet/business_logic/utils/constants.dart';
import 'package:otlet/business_logic/utils/functions.dart';
import 'package:otlet/ui/screens/charts_screen/view_charts_screen.dart';
import 'package:otlet/ui/screens/home_screen/home_screen.dart';
import 'package:otlet/ui/screens/settings/settings_screen.dart';
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
          title: Text('Otlet'),
          centerTitle: true,
          actions: [
            if (_currentIndex >= 1)
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
                    } else if (_currentIndex == 2) {
                      Tool tool = await createNewTool(context);
                      if (tool == null) return;
                      setState(() {
                        instance.addNewTool(tool);
                        instance.tools.sort((a, b) => a.name.compareTo(b.name));
                      });
                    } else {
                      // await createNewChart(context);
                    }
                  })
            else
              IconButton(
                  onPressed: () async {
                    bool wipingEverything = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    SettingsScreen(instance))) ??
                        false;
                    if (wipingEverything)
                      setState(() {
                        instance.scorchEarth();
                      });
                  },
                  icon: Icon(Icons.settings))
          ],
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: [
            HomeScreen(),
            ViewBooksScreen(),
            ViewToolsScreen(),
            ViewChartsScreen()
          ],
        ),
        bottomNavigationBar: Theme(
          data: ThemeData(
              canvasColor: Colors.white, primaryColor: secondaryColor),
          child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _currentIndex,
              onTap: (i) {
                setState(() {
                  _currentIndex = i;
                });
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                    icon: Icon(Icons.library_books), label: 'Books'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.build), label: 'Tools'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.bar_chart), label: 'Charts'),
              ]),
        ),
      ),
    );
  }
}
