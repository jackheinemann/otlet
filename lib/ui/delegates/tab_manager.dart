import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/book.dart';
import 'package:otlet/business_logic/models/otlet_chart.dart';
import 'package:otlet/business_logic/models/otlet_instance.dart';
import 'package:otlet/business_logic/models/tool.dart';
import 'package:otlet/business_logic/utils/constants.dart';
import 'package:otlet/business_logic/utils/functions.dart';
import 'package:otlet/ui/screens/add_book_screen.dart';
import 'package:otlet/ui/screens/charts_screen/create_chart_screen.dart';
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
  int _screensIndex = 0;
  int _currentIndex = 0;

  List<Widget> screens = [];
  @override
  void initState() {
    super.initState();
    instance = widget.instance;
  }

  @override
  Widget build(BuildContext context) {
    screens = [
      Scaffold(
        appBar: AppBar(
          title: defaultAppBarTitle,
          centerTitle: true,
          actions: [
            if (_currentIndex >= 1)
              IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () async {
                    if (_currentIndex == 1) {
                      setState(() {
                        _screensIndex = 1; // 1 is the index of add book
                      });
                      return;
                    } else if (_currentIndex == 2) {
                      Tool tool = await createNewTool(context);
                      if (tool == null) return;
                      setState(() {
                        instance.addNewTool(tool);
                        instance.tools.sort((a, b) => a.name.compareTo(b.name));
                      });
                    } else {
                      OtletChart temp = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CreateChartScreen(instance)));
                      if (temp == null) return;
                      setState(() {
                        instance.addNewChart(temp);
                      });
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
            ViewBooksScreen(updateScreenIndex: (index) {
              setState(() {
                _screensIndex = index;
              });
            }),
            ViewToolsScreen(),
            ViewChartsScreen()
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
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
              BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Tools'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart), label: 'Charts'),
            ]),
      ),
      AddBookScreen(
        updateScreenIndex: (index) {
          setState(() {
            _screensIndex = index;
          });
        },
      )
    ];
    return ChangeNotifierProvider<OtletInstance>(
        create: (context) => instance, child: screens[_screensIndex]);
  }
}
