import 'package:sqflite/sqflite.dart'; //for andriod
import 'package:path/path.dart';
//import 'package:sqflite_common_ffi/sqflite_ffi.dart'; //for windows

class ServerDatabase {
  static Database? _database;
  final String tableName = 'servers';

  ServerDatabase._privateConstructor();
  static final ServerDatabase instance = ServerDatabase._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    //sqfliteFfiInit(); // Initialize sqflite_ffi
    //databaseFactory = databaseFactoryFfi; // Set the database factory

    final path = join(await getDatabasesPath(), 'server_database.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY,
        name TEXT,
        mqttId TEXT,
        host TEXT,
        user TEXT,
        port TEXT,
        pass TEXT
      )
    ''');
  }

  Future<int> insertServer(Server server) async {
    final db = await database;
    return await db.insert(tableName, server.toMap());
  }

  Future<List<Server>> getServers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (index) {
      return Server.fromMap(maps[index]);
    });
  }

  Future<void> deleteServer(int serverId) async {
    final db = await database;
    await db.delete(
      'servers',
      where: 'id = ?',
      whereArgs: [serverId],
    );
  }

  Future<void> updateServer(Server server) async {
    final db = await database;
    await db.update(
      tableName,
      server.toMap(),
      where: 'id = ?',
      whereArgs: [server.id],
    );
  }
}

class Server {
  final int? id;
  final String name;
  final String mqttId;
  final String host;
  final String user;
  final String port;
  final String pass;
  //MqttService mqttService;
  //String connectionStatus;

  Server({
    this.id,
    required this.name,
    required this.mqttId,
    required this.host,
    required this.user,
    required this.port,
    required this.pass,
    //required this.mqttService,

    //required this.connectionStatus, // Initialize connectionStatus
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'mqttId': mqttId,
      'host': host,
      'user': user,
      'port': port,
      'pass': pass,
      //'connectionStatus': connectionStatus,
    };
  }

  factory Server.fromMap(Map<String, dynamic> map) {
    return Server(
      id: map['id'],
      name: map['name'],
      mqttId: map['mqttId'],
      host: map['host'],
      user: map['user'],
      port: map['port'],
      pass: map['pass'],
      //mqttService: map['']

      //connectionStatus: map['connectionStatus'],
    );
  }
}
