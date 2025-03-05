import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class PublisherModel {
  //final int id;
  final String name;
  final String host;
  final int port;
  final String topic;
  final String serverName; // Added property to specify the server
  // final String user;
  // final String pass;

  PublisherModel(
      {
      //this.id = 0,
      required this.name,
      required this.host,
      required this.port,
      required this.topic,
      required this.serverName
      // required this.user,
      // required this.pass,
      });

  Map<String, dynamic> toMap() {
    return {
      //'id': id,
      'name': name,
      'host': host,
      'port': port,
      'topic': topic,
      'serverName': serverName
      // 'user': user,
      // 'pass': pass, // Include server name
    };
  }

  factory PublisherModel.fromMap(Map<String, dynamic> map) {
    return PublisherModel(
        //id: map['id'],
        name: map['name'],
        host: map['host'],
        port: map['port'],
        topic: map['topic'],
        serverName: map['serverName']
        // user: map['user'],
        // pass: map['pass'],
        );
  }
}

class PublisherDatabase {
  static Database? _database;
  final String tableName = 'publishers';

  PublisherDatabase._privateConstructor();
  static final PublisherDatabase instance =
      PublisherDatabase._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'publishers.db');
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

  Future<int> insertPublisher(PublisherModel publisher) async {
    final db = await database;
    return await db.insert(tableName, publisher.toMap());
  }

  Future<List<PublisherModel>> getPublishers(String serverName) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db
        .query(tableName, where: 'serverName = ?', whereArgs: [serverName]);

    return List.generate(maps.length, (index) {
      return PublisherModel.fromMap(maps[index]);
    });
  }

  Future<void> deletePublisher(String publisherId) async {
    final db = await database;
    await db.delete(
      'publishers',
      where: 'topic = ?',
      whereArgs: [publisherId],
    );
  }
}
