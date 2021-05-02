import 'dart:io';

import 'package:bsrufood/srceen/sqllite/item_clas.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class DataItemOder {
  
  final _databaseName = "item.db";
  final _databaseVersion = 1;
  final table = 'my_table';
  
  static final columnId = '_id';
  static final columnFoodid = 'food_id';
  static final columnShopId = 'shop_id';
  static final columnName = 'name';
  static final columnPrice = 'price';
  static final columnCount = 'count';
  static final columnStatus = 'status';
  // static final columnOption = 'option';

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }
  
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    print("Opening!!");
    return await openDatabase(path,
      version: _databaseVersion,
      onCreate: _onCreate
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY,
        $columnFoodid INTEGER,
        $columnShopId TEXT NOT NULL,
        $columnName TEXT NOT NULL,
        $columnPrice INTEGER,
        $columnCount INTEGER,
        $columnStatus INTEGER
      )
    ''');
  }

  Future<int> insert(ItemClas data) async {
    Database db = await database;
    // return await db.insert(table, data.toMap());
      var item  = await queryAllRows();
      var index = item.indexWhere((element) => element.food_id==data.food_id);
      if(index!=-1){
           data.count  = item[index].count+1;
          //  print(data.toMapnokey());
           await db.update(table, data.toMapnokey(), where: '$columnFoodid = ?', whereArgs: [data.food_id]);
      }else{
        data.count = 1 ;
         await db.insert(table, data.toMap());
      }
      // print(await db.query(table));
      // print('fD : $data');    
      return 0;
  }

  Future<List<ItemClas>> queryAllRows() async {
    Database db = await database;
    return (await db.query(table)).map((e) => ItemClas.fromMap(e)).toList();
  }

  Future<int> queryRowCount() async {
    Database db = await database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  Future<int> update(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

   Future<int> updatelist(ItemClas data,String status) async {
    Database db = await database;
     var item  = await queryAllRows();
     var index = item.indexWhere((element) => element.food_id==data.food_id);
      if(status == "add"){
           data.count  = item[index].count+1;
          //  print(data.toMapnokey());
           await db.update(table, data.toMapnokey(), where: '$columnName = ?', whereArgs: [data.name]);
      }else{
          data.count  = item[index].count-1;
          //  print(data.toMapnokey());
           await db.update(table, data.toMapnokey(), where: '$columnName = ?', whereArgs: [data.name]);
      }
      return 0;
  }


  Future<int> delete() async {
    Database db = await database;
    return await db.delete(table);
  }

  Future<int> deletelist(int id) async {
    Database db = await database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  void close() {
    _database?.close();
    print("Closed!!");
  }
}