import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Model for received data
class ReceivedDataModel {
  //final int id;
  final String subscriberId;
  final String message;
  // final DateTime timestamp;

  ReceivedDataModel({
    //required this.id,
    required this.subscriberId,
    required this.message,
    // required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      //'id': id,
      'subscriberId': subscriberId,
      'message': message,
      // 'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ReceivedDataModel.fromMap(Map<String, dynamic> map) {
    return ReceivedDataModel(
      //id: map['id'],
      subscriberId: map['subscriberId'],
      message: map['message'],
      // timestamp: DateTime.parse(map['timestamp']),
    );
  }

  @override
  String toString() {
    return '$message'; // Customize based on your data
  }
}

// Database helper class
class ReceivedDataDatabase {
  static Database? _database;
  final String tableName = 'receiveddata';

  ReceivedDataDatabase._privateConstructor();
  static final ReceivedDataDatabase instance =
      ReceivedDataDatabase._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    final dbPath = join(path, 'receiveddata.db');

    return await openDatabase(dbPath, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subscriberId TEXT,
        message TEXT
      )
    ''');
  }

  Future<int> insertReceivedData(ReceivedDataModel sub) async {
    final db = await database;
    return await db.insert(tableName, sub.toMap());
  }

  Future<List<ReceivedDataModel>> getReceivedData(String subscriberId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'subscriberId = ?',
      whereArgs: [subscriberId],
    );
    List<ReceivedDataModel> reversedData = List.generate(maps.length, (index) {
      return ReceivedDataModel.fromMap(maps[index]);
    });
    return reversedData.reversed.toList();

    /*return List.generate(maps.length, (index) {
      return ReceivedDataModel.fromMap(maps[index]);
    });*/
  }
}
