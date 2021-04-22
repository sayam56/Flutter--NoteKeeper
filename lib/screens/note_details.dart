import 'package:flutter/material.dart';
import '../models/note.dart';
import '../utils/db_helper.dart';
import 'package:intl/intl.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  NoteDetail(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  static var _priorities = ['High', 'Low'];

  DatabaseHelper helper = DatabaseHelper();

  String appBarTitle;
  Note note;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  NoteDetailState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    //TextStyle textStyle = Theme.of(context).textTheme.bodyText1;

    final _formKey = GlobalKey<FormState>();

    titleController.text = note.title;
    descriptionController.text = note.description;

    return WillPopScope(

        // ignore: missing_return
        onWillPop: () {
          // Write some code to control things, when user press Back navigation button in device navigationBar
          moveToLastScreen();
        },
        child: Scaffold(
          backgroundColor: Colors.grey[900],
          appBar: AppBar(
            title: Text(appBarTitle),
            backgroundColor: Colors.black12,
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  // Write some code to control things, when user press back button in AppBar
                  moveToLastScreen();
                }),
          ),
          body: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
              child: ListView(
                children: <Widget>[
                  // First element
                  ListTile(
                    title: DropdownButton(
                        dropdownColor: Colors.black54,
                        items: _priorities.map((String dropDownStringItem) {
                          return DropdownMenuItem<String>(
                            value: dropDownStringItem,
                            child: Text(
                              dropDownStringItem,
                              style: TextStyle(backgroundColor: Colors.black12),
                            ),
                          );
                        }).toList(),
                        style: TextStyle(
                          color: Colors.white,
                          backgroundColor: Colors.black12,
                          fontSize: 18,
                        ),
                        value: getPriorityAsString(note.priority),
                        onChanged: (valueSelectedByUser) {
                          setState(() {
                            debugPrint('User selected $valueSelectedByUser');
                            updatePriorityAsInt(valueSelectedByUser);
                          });
                        }),
                  ),

                  // Second Element
                  Padding(
                    padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                    child: TextFormField(
                      cursorColor: Colors.white,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please Enter The Title';
                        }
                        return null;
                      },
                      controller: titleController,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                      onChanged: (value) {
                        debugPrint('Something changed in Title Text Field');
                        updateTitle();
                      },
                      decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                    ),
                  ),

                  // Third Element
                  Padding(
                    padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                    child: TextFormField(
                      cursorColor: Colors.white,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please Provide A Description';
                        }
                        return null;
                      },
                      controller: descriptionController,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      onChanged: (value) {
                        debugPrint('Something changed in Title Text Field');
                        updateDescription();
                      },
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                    ),
                  ),

                  // Fourth Element
                  Padding(
                    padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: RaisedButton(
                            color: Colors.black12,
                            textColor: Colors.white,
                            child: Text(
                              'Save',
                              textScaleFactor: 1.2,
                            ),
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                setState(() {
                                  debugPrint("Save button clicked");
                                  _save();
                                });
                              }
                            },
                          ),
                        ),
                        Container(
                          width: 5.0,
                        ),
                        Expanded(
                          child: RaisedButton(
                            color: Colors.black12,
                            textColor: Colors.white,
                            child: Text(
                              'Delete',
                              textScaleFactor: 1.2,
                            ),
                            onPressed: () {
                              setState(() {
                                debugPrint("Delete button clicked");
                                _delete();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  // Convert the String priority in the form of integer before saving it to Database
  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  // Convert int priority to String priority and display it to user in DropDown
  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0]; // 'High'
        break;
      case 2:
        priority = _priorities[1]; // 'Low'
        break;
    }
    return priority;
  }

  // Update the title of Note object
  void updateTitle() {
    note.title = titleController.text;
  }

  // Update the description of Note object
  void updateDescription() {
    note.description = descriptionController.text;
  }

  // Save data to database
  void _save() async {
    moveToLastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (note.id != null) {
      // Case 1: Update operation
      result = await helper.updateNote(note);
    } else {
      // Case 2: Insert Operation
      result = await helper.insertNote(note);
    }

    if (result != 0) {
      // Success
      _showAlertDialog('Status', 'Note Saved Successfully');
    } else {
      // Failure
      _showAlertDialog('Status', 'Problem Saving Note');
    }
  }

  void _delete() async {
    moveToLastScreen();

    // Case 1: If user is trying to delete the NEW NOTE i.e. he has come to
    // the detail page by pressing the FAB of NoteList page.
    if (note.id == null) {
      _showAlertDialog('Status', 'No Note was deleted');
      return;
    }

    // Case 2: User is trying to delete the old note that already has a valid ID.
    int result = await helper.deleteNote(note.id);
    if (result != 0) {
      _showAlertDialog('Status', 'Note Deleted Successfully');
    } else {
      _showAlertDialog('Status', 'Error Occured while Deleting Note');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
