import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Model for received data
class SendDataModel {
  //final int id;
  final String publisherId;
  final String message;
  // final DateTime timestamp;

  SendDataModel({
    //required this.id,
    required this.publisherId,
    required this.message,
    // required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      //'id': id,
      'publisherId': publisherId,
      'message': message,
      // 'timestamp': timestamp.toIso8601String(),
    };
  }

  factory SendDataModel.fromMap(Map<String, dynamic> map) {
    return SendDataModel(
      //id: map['id'],
      publisherId: map['publisherId'],
      message: map['message'],
      // timestamp: DateTime.parse(map['timestamp']),
    );
  }

  /*factory ReceivedDataModel.fromJson(Map<String, dynamic> json) {
    return ReceivedDataModel(
      //id: json['id'],
      subscriberId: json['subscriberId'],
      message: json['message'],
      //timestamp: DateTime.parse(json['timestamp']),
    );
  }*/
  @override
  String toString() {
    return '$message'; // Customize based on your data
  }
}

// Database helper class
class SendDataDatabase {
  static Database? _database;
  final String tableName = 'senddata';

  SendDataDatabase._privateConstructor();
  static final SendDataDatabase instance =
      SendDataDatabase._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    final dbPath = join(path, 'senddata.db');

    return await openDatabase(dbPath, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        publisherId TEXT,
        message TEXT
      )
    ''');
  }

  Future<int> insertSendData(SendDataModel pub) async {
    final db = await database;
    return await db.insert(tableName, pub.toMap());
  }

  Future<List<SendDataModel>> getSendData(String publisherId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'publisherId = ?',
      whereArgs: [publisherId],
    );

    return List.generate(maps.length, (index) {
      return SendDataModel.fromMap(maps[index]);
    });
  }
}
