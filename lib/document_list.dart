import 'package:flutter/material.dart';

import 'database_helper.dart';
import 'document_model.dart';
import 'drawer_navigation.dart';
import 'main.dart';
import 'simple_document_form_screen.dart';

class DocumentListScreen extends StatefulWidget {
  const DocumentListScreen({Key? key}) : super(key: key);

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> {

  late List<DocumentModel> _documentList;

  @override
  void initState() {
    super.initState();
    getAllDocuments();
  }

  getAllDocuments() async {
    _documentList = <DocumentModel>[];

    var documents = await dbHelper.queryAllRows(DatabaseHelper.documentTable);

    documents.forEach((row) {
      setState(() {
        print(row['_id']);
        print(row['doc_name']);
        print(row['original']);
        print(row['scan']);
        print(row['copy']);
        print(row['person_name']);

        var documentModel = DocumentModel(row['_id'], row['doc_name'],
            row['original'], row['scan'], row['copy'], row['person_name']);

        _documentList.add(documentModel);
      });
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerNavigation(),
      appBar: AppBar(
        title: Text('Document List'),
      ),
      body: ListView.builder(
          itemCount: _documentList.length,
          itemBuilder: (context, index) {
            return Padding(
                padding: const EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  onTap: () {
                    print('-------> Edit or Delete invoked : Send Data');
                    print(_documentList[index].id);
                    print(_documentList[index].docName);
                    print(_documentList[index].original);
                    print(_documentList[index].scan);
                    print(_documentList[index].copy);
                    print(_documentList[index].personName);

                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SimpleDocumentFormScreen(),
                    settings: RouteSettings(
                      arguments: _documentList[index],
                    )
                    ));
                  },
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(_documentList[index].docName),
                    ],
                  ),
                  subtitle: Text(_documentList[index].personName),
                ),
              ),
            );
          }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SimpleDocumentFormScreen()));
        },
        child: Icon(
          Icons.add
      ),
      ),
    );
  }
}
