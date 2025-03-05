import 'package:flutter/material.dart';
import 'package:mqtt_chat/database.dart';
import 'package:mqtt_chat/home.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class MqttServiceManager extends ChangeNotifier {
  final Map<String, MqttService> services = {};

  void addService(String name, MqttService service) {
    services[name] = service;
    notifyListeners();
  }

  MqttService? findServiceByName(String name) {
    return services[name];
  }

  void removeService(String name) {
    services.remove(name);
    notifyListeners();
  }
}

class MqttService extends ChangeNotifier {
  MqttServerClient? client;
  final Uuid uuid = Uuid();
  String connectionStatus = 'Connecting...';

  final String name;
  final String host;
  final String user;
  final String port;
  final String pass;

  MqttService({
    required this.name,
    required this.host,
    required this.user,
    required this.port,
    required this.pass,
  }) {
    // Initialize the MQTT client
    final clientId = 'flutter_client_${uuid.v4()}';
    client = MqttServerClient(host, clientId);
    client!.port = int.parse(port);
    client!.connect(user, pass);
    client!.keepAlivePeriod = 60;
    client!.logging(on: true);
  }

  Future<void> connect(BuildContext context) async {
    //final mqttConnectMessage =
    //MqttConnectMessage().withClientIdentifier(name).startClean();

    try {
      await client!.connect(user, pass);
      print('Connected to MQTT broker');
      connectionStatus = 'Connected';
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('mqtt_name', name);
      prefs.setString('mqtt_host', host);
      prefs.setInt('mqtt_port', int.parse(port));
      prefs.setString('mqtt_user', user);
      prefs.setString('mqtt_pass', pass);

      final server = Server(
        name: name,
        mqttId: name,
        host: host,
        user: user,
        port: port,
        pass: pass,
        //connectionStatus: widget.onConnectionSuccess as String,
      );
      await ServerDatabase.instance.insertServer(server);

      // ... Rest of your code remains the same
      Navigator.push(
        context as BuildContext,
        MaterialPageRoute(builder: (context) => Home()),
      );
    } catch (e) {
      connectionStatus = 'Not Connected';
      print('Error connecting to MQTT broker: $e');
      client!.disconnect();
      notifyListeners();
    }
  }

  bool isConnected() {
    return client!.connectionStatus!.state == MqttConnectionState.connected;
  }
  // ... Add other methods like subscribe, unsubscribe, etc.
}
