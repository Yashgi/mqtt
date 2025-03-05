import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SubscriberDatabase {
  static Database? _database;
  final String tableName = 'subscribers';

  SubscriberDatabase._privateConstructor();
  static final SubscriberDatabase instance =
      SubscriberDatabase._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'subscribers.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        host TEXT,
        port INTEGER,
        topic TEXT,
        serverName TEXT
      )
    ''');
  }

  Future<int> insertSubscriber(SubscriberModel subscriber) async {
    final db = await database;
    return await db.insert(tableName, subscriber.toMap());
  }

  Future<List<SubscriberModel>> getSubscriber(String serverName) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db
        .query(tableName, where: 'serverName = ?', whereArgs: [serverName]);
    return List.generate(maps.length, (index) {
      return SubscriberModel.fromMap(maps[index]);
    });
  }

  Future<void> deleteSubscriber(String subscriberId) async {
    final db = await database;
    await db.delete(
      'subscribers',
      where: 'topic = ?',
      whereArgs: [subscriberId],
    );
  }
}

class SubscriberModel {
  //final int id;
  final String name;
  final String host;
  final int port;
  final String topic;
  final String serverName;

  SubscriberModel(
      {
      //this.id = 0,
      required this.name,
      required this.host,
      required this.port,
      required this.topic,
      required this.serverName});

  Map<String, dynamic> toMap() {
    return {
      //'id': id,
      'name': name,
      'host': host,
      'port': port,
      'topic': topic,
      'serverName': serverName
    };
  }

  factory SubscriberModel.fromMap(Map<String, dynamic> map) {
    return SubscriberModel(
        //id: map['id'],
        name: map['name'],
        host: map['host'],
        port: map['port'],
        topic: map['topic'],
        serverName: map['serverName']);
  }
}
