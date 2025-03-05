import 'package:flutter/material.dart';
import 'package:mqtt_chat/Mqtt.dart';
import 'package:mqtt_chat/home.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //await ServerDatabase.instance.database;
  //await PublisherDatabase.instance.database;
  //await SubscriberDatabase.instance.database;

  final mqttServiceManager = MqttServiceManager();
  runApp(
    ChangeNotifierProvider(
      create: (context) => mqttServiceManager,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MQTT Connection',
      home: Home(),
    );
  }
}
