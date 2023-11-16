import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = 'DocumentListDB.db';
  static const _databaseVersion = 3;

  static const personTable = 'person_table';
  static const documentTable = 'document_table';

  static const columnId = '_id';
  static const columnPersonName = 'person_name';

  static const columnDocName = 'doc_name';
  static const columnOriginal = 'original';
  static const columnScan = 'scan';
  static const columnCopy = 'copy';

  late Database _db;

  Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    _db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database database, int version) async {
    await database.execute('''
          CREATE TABLE $personTable (
            $columnId INTEGER PRIMARY KEY,
            $columnPersonName TEXT
          )
          ''');

    await database.execute('''
          CREATE TABLE $documentTable (
            $columnId INTEGER PRIMARY KEY,
            $columnDocName TEXT,
            $columnOriginal TEXT,  
            $columnScan TEXT,
            $columnCopy TEXT,
            $columnPersonName TEXT
          )
          ''');
  }

  _onUpgrade(Database database, int oldVersion, int newVersion) async {
    await database.execute('drop table $personTable');
    await database.execute('drop table $documentTable');
    _onCreate(database, newVersion);
  }

  Future<int> insert(Map<String, dynamic> row, String tableName) async {
    return await _db.insert(tableName, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows(String tableName) async {
    // select * from person_table
    return await _db.query(tableName);
  }

  readDataById(table, itemId) async {
    return await _db.query(table, where: "_id =? ", whereArgs: [itemId]);
  }

  Future<int> update(Map<String, dynamic> row, String tableName) async {
    int id = row[columnId];
    return await _db.update(
      tableName,
      row,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id, String tableName) async {
    return await _db.delete(
      tableName,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }
}
