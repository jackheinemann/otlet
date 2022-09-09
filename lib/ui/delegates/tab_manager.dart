import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/book.dart';
import 'package:otlet/business_logic/models/otlet_chart.dart';
import 'package:otlet/business_logic/models/otlet_instance.dart';
import 'package:otlet/business_logic/models/reading_session.dart';
import 'package:otlet/business_logic/models/tool.dart';
import 'package:otlet/business_logic/utils/constants.dart';
import 'package:otlet/ui/screens/add_book_screen.dart';
import 'package:otlet/ui/screens/charts_screen/create_chart_screen.dart';
import 'package:otlet/ui/screens/charts_screen/view_chart_screen.dart';
import 'package:otlet/ui/screens/charts_screen/view_charts_screen.dart';
import 'package:otlet/ui/screens/home_screen/home_screen.dart';
import 'package:otlet/ui/screens/sessions/view_sessions_screen.dart';
import 'package:otlet/ui/screens/settings/settings_screen.dart';
import 'package:otlet/ui/screens/view_book_screens/create_session_screen.dart';
import 'package:otlet/ui/screens/view_book_screens/view_book_screen.dart';
import 'package:otlet/ui/screens/view_books_screen.dart';
import 'package:otlet/ui/screens/view_tools_screens/create_custom_tool_screen.dart';
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
  int _screensIndex = ScreenIndex.mainTabs;
  int _currentIndex = 0;

  List<Widget> screens = [];
  Book selectedBook; // for when otlet card is pressed
  ReadingSession selectedSession; // for when session card is pressed
  Tool selectedTool; // for when a tool card is pressed
  OtletChart selectedChart; // for when a chart card is pressed

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
                        _screensIndex = ScreenIndex
                            .addBookScreen; // 1 is the index of add book
                      });
                      return;
                    } else if (_currentIndex == 2) {
                      setState(() {
                        _screensIndex = ScreenIndex.addEditSessionScreen;
                      });
                    } else if (_currentIndex == 3) {
                      setState(() {
                        _screensIndex = ScreenIndex.addEditTool;
                      });
                    } else {
                      setState(() {
                        _screensIndex = ScreenIndex.addEditChart;
                      });
                    }
                  })
            else
              IconButton(
                  onPressed: () {
                    setState(() {
                      _screensIndex = ScreenIndex.settings;
                    });
                  },
                  icon: Icon(Icons.settings)),
            // if (_currentIndex == 1)
            //   IconButton(icon: Icon(Icons.tune), onPressed: () async {})
          ],
          backgroundColor: primaryColor,
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: [
            HomeScreen(),
            ViewBooksScreen(
              updateScreenIndex: (index, {book}) {
                if (book != null) selectedBook = Book.fromBook(book);
                setState(() {
                  _screensIndex = index;
                });
              },
            ),
            ViewSessionsScreen(
              instance,
              updateScreenIndex: (index, {session}) {
                if (session != null)
                  selectedSession = ReadingSession.fromSession(session);
                setState(() {
                  _screensIndex = index;
                });
              },
            ),
            ViewToolsScreen(
              updateScreenIndex: (index, {tool}) {
                if (tool != null) selectedTool = Tool.fromTool(tool);
                setState(() {
                  _screensIndex = index;
                });
              },
            ),
            ViewChartsScreen(
              updateScreenIndex: (index, {chart}) {
                if (chart != null) selectedChart = OtletChart.fromChart(chart);
                setState(() {
                  _screensIndex = index;
                });
              },
            )
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
              BottomNavigationBarItem(
                  icon: Icon(Icons.history), label: 'Sessions'),
              BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Tools'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart), label: 'Charts'),
            ]),
      ),
      AddBookScreen(
        updateScreenIndex: (index) {
          setState(() {
            _screensIndex = index;
            if (_screensIndex == ScreenIndex.mainTabs) selectedBook = null;
          });
        },
      ),
      ViewBookScreen(selectedBook, updateScreenIndex: (index) {
        setState(() {
          _screensIndex = index;
          if (_screensIndex == ScreenIndex.mainTabs) selectedBook = null;
        });
      }),
      CreateSessionScreen(
          session: selectedSession,
          updateScreenIndex: (index) {
            setState(() {
              _screensIndex = index;
              if (_screensIndex == ScreenIndex.mainTabs) selectedSession = null;
            });
          }),
      CreateCustomToolScreen(
          tool: selectedTool,
          isEdit: selectedTool != null,
          updateScreenIndex: (index) {
            setState(() {
              _screensIndex = index;
              if (_screensIndex == ScreenIndex.mainTabs) selectedTool = null;
            });
          }),
      CreateChartScreen(
        chart: selectedChart,
        instance: instance,
        updateScreenIndex: (index) {
          setState(() {
            _screensIndex = index;
            if (_screensIndex == ScreenIndex.mainTabs) selectedChart = null;
          });
        },
      ),
      ViewChartScreen(selectedChart, updateScreenIndex: (index) {
        setState(() {
          _screensIndex = index;
          if (_screensIndex == ScreenIndex.mainTabs) selectedChart = null;
        });
      }),
      SettingsScreen(instance, updateScreenIndex: (index) {
        setState(() {
          _screensIndex = index;
        });
      })
    ];
    return ChangeNotifierProvider<OtletInstance>(
        create: (context) => instance, child: screens[_screensIndex]);
  }
}
