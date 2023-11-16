import 'package:flutter/material.dart';
import 'document_model.dart';
import 'main.dart';
import 'database_helper.dart';
import 'document_list.dart';

class SimpleDocumentFormScreen extends StatefulWidget {
  const SimpleDocumentFormScreen({Key? key}) : super(key: key);

  @override
  State<SimpleDocumentFormScreen> createState() => _SimpleDocumentFormScreenState();
}

class _SimpleDocumentFormScreenState extends State<SimpleDocumentFormScreen> {
  var _personDropdownList = <DropdownMenuItem>[];
  var _documentNameController = TextEditingController();
  var _selectedPersonValue;
  var _personNameController = TextEditingController();

  String buttonText = 'Save';

  bool originalDefaultValue = false;
  bool scanDefaultValue = false;
  bool copyDefaultValue = false;

  bool firstTimeFlag = false;
  int _selectedId = 0;

  @override
  void initState() {
    super.initState();
    getAllPerson();
  }

  getAllPerson() async {
    var person = await dbHelper.queryAllRows(DatabaseHelper.personTable);

    person.forEach((row) {
      setState(() {
        _personDropdownList.add(
          DropdownMenuItem(
            child: Text(row['person_name']),
            value: row['person_name'],
          ),
        );
      });
    });
  }

  _deleteFormDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (param) {
          return AlertDialog(
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await dbHelper.delete(_selectedId, DatabaseHelper.documentTable);

                  debugPrint('-----------------> Deleted Row Id: $result');

                  if(result >0 ) {
                    _showSuccessSnackBar(context, 'Deleted.');
                    Navigator.pop(context);
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => DocumentListScreen()));
                  }
                },
                child: const Text('Delete'),
              )
            ],
            title: const Text('Are you sure you want to delete this?'),

          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // edit only
    if (firstTimeFlag == false) {
      print('---------->once execute ');
      firstTimeFlag = true;
      final document =
          ModalRoute.of(context)!.settings.arguments;

      if (document == null) {
        print('---------> FAB: insert'); //save
      } else {
        print('---------> Listview: Received Data: Edit/Delete');

        document as DocumentModel;

        print('---------->Received Data:');
        print(document.id);
        print(document.docName);
        print(document.original);
        print(document.scan);
        print(document.copy);
        print(document.personName);

        _selectedId = document.id!;
        _documentNameController.text = document.docName;

        _selectedPersonValue = document.personName;

        buttonText = 'Update';

        // Check Box - original
        if (document.original == 'true') {
          print('------------> set original true');
          originalDefaultValue = true;
        } else {
          print('------------> set original false');
          originalDefaultValue = false;
        }

        // Check Box - Scan
        if (document.scan == 'true') {
          print('------------> set scan true');
          scanDefaultValue = true;
        } else {
          print('------------> set scan false');
          scanDefaultValue = false;
        }

        // Check Box - Copy
        if (document.copy == 'true') {
          print('------------> set copy true');
          copyDefaultValue = true;
        } else {
          print('------------> set copy false');
          copyDefaultValue = false;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        actions: _selectedId != 0 ? [
          PopupMenuButton(
              itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 1,
                      child: Text('Delete'),
                    ),
                  ],
          onSelected: (value) {
                if (value == 1) {
                  _deleteFormDialog(context);
                }
          },
          ),
        ] :null,
        title: Text('Personal ID Details Form'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextField(
                controller: _documentNameController,
                decoration: InputDecoration(
                  labelText: 'Document Name',
                  hintText: 'Enter Document Name',
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Original',
                          style: TextStyle(
                            fontSize: 17.0,
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Checkbox(
                            value: this.originalDefaultValue,
                            onChanged: (value) {
                              setState(() {
                                this.originalDefaultValue = value!;
                                print(
                                    '---------> Original Check Box Status: $value');
                              });
                            }),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Card(
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Scan',
                          style: TextStyle(
                            fontSize: 17.0,
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Checkbox(
                          value: this.scanDefaultValue,
                          onChanged: (value) {
                            setState(() {
                              this.scanDefaultValue = value!;
                              print(
                                  '---------> Scan Check Box Status : $value');
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Card(
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Copy',
                          style: TextStyle(
                            fontSize: 17.0,
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Checkbox(
                          value: this.copyDefaultValue,
                          onChanged: (value) {
                            setState(() {
                              this.copyDefaultValue = value!;
                              print(
                                  '----------> Copy Check Box Status : $value');
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              DropdownButtonFormField(
                value: _selectedPersonValue,
                items: _personDropdownList,
                hint: Text('Person Name'),
                onChanged: (value) {
                  setState(() {
                    _selectedPersonValue = value!;
                    print(_selectedPersonValue);
                  });
                },
              ),
              SizedBox(
                height: 50,
              ),
              ElevatedButton(
                onPressed: () async {
                  _showFromDialog(context);
                },
                child: Text('Add Person Name'),
              ),
              SizedBox(
                height: 50,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_selectedId == 0) {
                    print('------> Save');
                    _save();
                  } else {
                    print('---------> Update');
                    _update();
                  }
                },
                child: Text(buttonText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() async {
    print('-------> save');

    String tempOriginalValue = 'false';
    String tempScanValue = 'false';
    String tempCopyValue = 'false';

    if(originalDefaultValue == true){
      print('------------> save original true');
      tempOriginalValue = 'true';
    }else{
      print('------------> save original false');
      tempOriginalValue = 'false';
    }

    if(scanDefaultValue == true){
      print('------------> save scan true');
      tempScanValue = 'true';
    }else{
      print('------------> save scan false');
      tempScanValue = 'false';
    }

    if(copyDefaultValue == true){
      print('------------> save copy true');
      tempCopyValue = 'true';
    }else{
      print('------------> save copy false');
      tempCopyValue = 'false';
    }

    print('---------------> Document Name: ${_documentNameController.text}');
    print('---------------> Original: $tempOriginalValue');
    print('---------------> Scan: $tempScanValue');
    print('---------------> Copy: $tempCopyValue');
    print('---------------> Person Name: $_selectedPersonValue');

    Map<String, dynamic> row = {
      DatabaseHelper.columnDocName: _documentNameController.text,
      DatabaseHelper.columnOriginal: tempOriginalValue,
      DatabaseHelper.columnScan: tempScanValue,
      DatabaseHelper.columnCopy: tempCopyValue,
      DatabaseHelper.columnPersonName: _selectedPersonValue,
    };

    final result = await dbHelper.insert(row, DatabaseHelper.documentTable);

    debugPrint('-----------------> inserted row id: $result');

    if (result > 0) {
      Navigator.pop(context);
      _showSuccessSnackBar(context, 'Saved.');
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => DocumentListScreen()));
    }
  }

  void _update() async {
    print('-------> update');

    String tempOriginalValue = 'false';
    String tempScanValue = 'false';
    String tempCopyValue = 'false';

    if (originalDefaultValue == true) {
      print('------------> save original true');
      tempOriginalValue = 'true';
    } else {
      print('------------> save original false');
      tempOriginalValue = 'false';
    }

    if (scanDefaultValue == true) {
      print('------------> save scan true');
      tempScanValue = 'true';
    } else {
      print('------------> save scan false');
      tempScanValue = 'false';
    }

    if (copyDefaultValue == true) {
      print('------------> save copy true');
      tempCopyValue = 'true';
    } else {
      print('------------> save copy false');
      tempCopyValue = 'false';
    }

    print('---------------> Document Name: ${_documentNameController.text}');
    print('---------------> Original: $tempOriginalValue');
    print('---------------> Scan: $tempScanValue');
    print('---------------> Copy: $tempCopyValue');
    print('---------------> Person Name: $_selectedPersonValue');
    print('---------------> id: $_selectedId');

    Map<String, dynamic> row = {
      DatabaseHelper.columnId: _selectedId,
      DatabaseHelper.columnDocName: _documentNameController.text,
      DatabaseHelper.columnOriginal: tempOriginalValue,
      DatabaseHelper.columnScan: tempScanValue,
      DatabaseHelper.columnCopy: tempCopyValue,
      DatabaseHelper.columnPersonName: _selectedPersonValue,
    };

    final result = await dbHelper.update(row, DatabaseHelper.documentTable);

    debugPrint('-----------------> updated row id: $result');

    if (result > 0) {
      Navigator.pop(context);
      _showSuccessSnackBar(context, 'Updated.');
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => DocumentListScreen()));
    }
  }

  _showFromDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (param) {
          return AlertDialog(
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  print('------> Cancel invoked');
                  Navigator.pop(context);
                  _personNameController.clear();
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  print('---------> save invoked');
                  _savePersonName();
                },
                child: Text('Save'),
              ),
            ],
            title: Text('Person Name'),
            content: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: _personNameController,
                    decoration: InputDecoration(
                      hintText: 'Enter Person Name',
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  void _savePersonName() async {
    print('---------> Save Person Name');
    print('----------> Person Name : $_personNameController.text');

    Map<String, dynamic> row = {
      DatabaseHelper.columnPersonName: _personNameController.text,
    };

    final result = await dbHelper.insert(row, DatabaseHelper.personTable);

    debugPrint('-----------------> inserted row id: $result');

    if (result > 0) {
      Navigator.pop(context);
      _showSuccessSnackBar(context, 'Saved.');
      _personDropdownList.clear();
      getAllPerson();
    }

    _personNameController.clear();
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(new SnackBar(content: new Text(message)));
  }
}
