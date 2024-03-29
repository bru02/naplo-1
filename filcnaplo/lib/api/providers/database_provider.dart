import 'package:filcnaplo/database/query.dart';
import 'package:filcnaplo/database/store.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  // late Database _database;
  late DatabaseQuery query;
  late UserDatabaseQuery userQuery;
  late DatabaseStore store;
  late UserDatabaseStore userStore;

  Future<void> init() async {
    var db = await openDatabase("app.db");
    // _database = db;
    query = DatabaseQuery(db: db);
    store = DatabaseStore(db: db);
    userQuery = UserDatabaseQuery(db: db);
    userStore = UserDatabaseStore(db: db);
  }
}
