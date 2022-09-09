import 'package:flutter/material.dart';
import 'package:otlet/business_logic/models/book.dart';
import 'package:otlet/business_logic/models/otlet_instance.dart';
import 'package:otlet/business_logic/models/reading_session.dart';
import 'package:otlet/business_logic/models/tool.dart';
import 'package:otlet/business_logic/utils/constants.dart';
import 'package:otlet/ui/screens/home_screen/edit_session_tools.dart';
import 'package:otlet/ui/widgets/alerts/confirm_dialog.dart';
import 'package:otlet/ui/widgets/alerts/id_simple_selector.dart';
import 'package:provider/provider.dart';

class CreateSessionScreen extends StatefulWidget {
  final ReadingSession session;
  final Book book;
  final Function(int) updateScreenIndex;

  CreateSessionScreen(
      {this.book, this.session, @required this.updateScreenIndex});
  @override
  _CreateSessionScreenState createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  ReadingSession session;
  bool isEdit;

  final _formKey = GlobalKey<FormState>();

  TextEditingController bookController = TextEditingController();
  TextEditingController startedController = TextEditingController();
  TextEditingController endedController = TextEditingController();
  TextEditingController pagesReadController = TextEditingController();

  bool importedSessionTools = false;

  Book book;

  @override
  void initState() {
    super.initState();
    session = widget.session ?? ReadingSession.basic(widget.book);
    isEdit = widget.session != null;

    if (session.pagesRead != null)
      pagesReadController.text = session.pagesRead.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OtletInstance>(builder: (context, instance, _) {
      if (!importedSessionTools && session.bookId != null) {
        // session.importSessionTools(instance.getBookById(session.bookId));
        book = instance.getBookById(session.bookId);

        for (Tool tool in book.tools) {
          session.importSessionToolSingular(Tool.fromTool(tool), false);
        }
        for (Tool tool in book.otletTools) {
          session.importSessionToolSingular(Tool.fromTool(tool), true);
        }
        importedSessionTools = true;
      }
      if (book == null && session.bookId != null)
        book = instance.getBookById(session.bookId);
      bookController.text = book?.title;
      if (session.started != null)
        startedController.text = monthDayYearTimeFormat.format(session.started);
      if (session.ended != null)
        endedController.text = monthDayYearTimeFormat.format(session.ended);

      return WillPopScope(
        onWillPop: () async {
          bool shouldPop =
              await showConfirmDialog('Discard changes to session?', context);
          if (shouldPop) widget.updateScreenIndex(0);
          return Future.value(false);
        },
        child: Scaffold(
          appBar: AppBar(
              leading: IconButton(
                  icon: backButton(),
                  onPressed: () async {
                    bool shouldPop = await showConfirmDialog(
                        'Discard changes to session?', context);
                    if (shouldPop) widget.updateScreenIndex(0);
                  }),
              centerTitle: true,
              title: Text('${isEdit ? 'Edit' : 'Create'} Session'),
              actions: [
                if (isEdit)
                  IconButton(
                    onPressed: () async {
                      bool shouldDelete = await showConfirmDialog(
                          'Delete this session forever?', context);

                      if (shouldDelete) {
                        instance.deleteSession(session);
                        widget.updateScreenIndex(0);
                      }
                    },
                    icon: Icon(Icons.delete),
                  ),
              ]),
          body: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 15),
                ListTile(
                  title: TextFormField(
                    textCapitalization: TextCapitalization.words,
                    controller: bookController,
                    readOnly: true,
                    decoration: InputDecoration(
                        labelText: 'Book',
                        border: OutlineInputBorder(),
                        suffixIcon:
                            isEdit ? null : Icon(Icons.arrow_drop_down)),
                    onTap: () async {
                      if (isEdit) return;
                      MapEntry selected = await showIdSelectorDialog(
                          context,
                          'Select a book',
                          Map<String, String>.fromIterable(instance.books,
                              key: (book) => book.id,
                              value: (book) => book.title));
                      if (selected == null) return;
                      setState(() {
                        session.bookId = selected.key;
                        session.bookTitle = selected.value;
                        importedSessionTools = false;
                        book = null;
                      });
                    },
                    validator: (value) {
                      if (value.isEmpty) return 'Book required';
                      return null;
                    },
                  ),
                ),
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * .44,
                        child: TextFormField(
                          textCapitalization: TextCapitalization.words,
                          controller: startedController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Session Started',
                            border: OutlineInputBorder(),
                          ),
                          onTap: () async {
                            DateTime started = await showDatePicker(
                                context: context,
                                initialDate: session.started ?? DateTime.now(),
                                firstDate: DateTime(1950),
                                lastDate: DateTime.now()
                                    .add(Duration(days: 365 * 50)));
                            if (started == null) return;
                            TimeOfDay timeOfDay = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(
                                    session.started ?? DateTime.now()));
                            if (timeOfDay == null) return;
                            started = DateTime(started.year, started.month,
                                started.day, timeOfDay.hour, timeOfDay.minute);
                            setState(() {
                              session.started = started;
                            });
                          },
                          validator: (value) {
                            if (value.isEmpty) return 'Date required';
                            return null;
                          },
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * .44,
                        child: TextFormField(
                          textCapitalization: TextCapitalization.words,
                          controller: endedController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Session Ended',
                            border: OutlineInputBorder(),
                          ),
                          onTap: () async {
                            DateTime ended = await showDatePicker(
                                context: context,
                                initialDate: session.ended ?? DateTime.now(),
                                firstDate: DateTime(1950),
                                lastDate: DateTime.now()
                                    .add(Duration(days: 365 * 50)));
                            if (ended == null) return;
                            TimeOfDay timeOfDay = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(
                                    session.ended ?? DateTime.now()));
                            if (timeOfDay == null) return;
                            ended = DateTime(ended.year, ended.month, ended.day,
                                timeOfDay.hour, timeOfDay.minute);
                            setState(() {
                              session.ended = ended;
                            });
                          },
                          validator: (value) {
                            if (value.isEmpty) return 'Date required';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: TextFormField(
                    keyboardType: TextInputType.numberWithOptions(signed: true),
                    controller: pagesReadController,
                    decoration: InputDecoration(
                      labelText: 'Pages Read',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                EditSessionTools(
                  session: session,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: primaryColor),
                    onPressed: () {
                      if (!_formKey.currentState.validate()) return;
                      session.pagesRead =
                          int.tryParse(pagesReadController.text.trim());
                      session.timePassed =
                          session.ended.difference(session.started);
                      session.otletTools[1].value = session.started;
                      session.otletTools[2].value = session.ended;
                      session.otletTools[3].value = DateTime(
                          session.started.year,
                          session.started.month,
                          session.started.day);
                      session.otletTools[4].value = session.pagesRead;
                      isEdit
                          ? instance.modifySession(session)
                          : instance.addNewSession(session);
                      widget.updateScreenIndex(0);
                    },
                    child: Text('${isEdit ? 'Save' : 'Create'} Session')),
                SizedBox(
                  height: 30,
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
