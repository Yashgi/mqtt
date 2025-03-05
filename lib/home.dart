import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mqtt_chat/Mqtt.dart';
import 'package:mqtt_chat/database.dart';
import 'package:mqtt_chat/server_detail.dart';
import 'package:mqtt_chat/subscribe.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Server> servers = [];
  late Timer statusCheckTimer;
  Map<String, bool> serverStatus = {};

  @override
  void initState() {
    super.initState();
    _loadServers();
    // Initialize and start a timer to periodically check server statuses
    statusCheckTimer =
        Timer.periodic(const Duration(seconds: 10), (Timer timer) {
      _checkServerStatus();
    });
  }

  @override
  void dispose() {
    statusCheckTimer.cancel();
    super.dispose();
  }

  void _loadServers() async {
    //await ServerDatabase.instance.database;
    final serverDatabase = ServerDatabase.instance;
    final loadedServers = await serverDatabase.getServers();

    setState(() {
      servers = loadedServers;
    });
  }

  void _checkServerStatus() {
    final mqttServiceManager =
        Provider.of<MqttServiceManager>(context, listen: false);

    for (Server server in servers) {
      final mqttService = mqttServiceManager.findServiceByName(server.name);

      if (mqttService != null) {
        bool isConnected = mqttService.isConnected();
        serverStatus[server.name] = isConnected;
      }
    }

    setState(() {});
  }

  void _deleteServer(Server server) async {
    if (server.id != null) {
      final serverDatabase = ServerDatabase.instance;
      await serverDatabase
          .deleteServer(server.id!); // Use the ! operator to assert non-null.
      setState(() {
        servers.remove(server);
      });
    } else {
      // Handle the case where server.id is null (optional).
    }
  }

  void _navigateToServerDetails(Server server) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServerDetails(
          server: server,
        ),
      ),
    );
  }

  void _editServer(Server server) {
    TextEditingController nameController =
        TextEditingController(text: server.name);
    TextEditingController portController =
        TextEditingController(text: server.port);
    TextEditingController hostController =
        TextEditingController(text: server.host);
    TextEditingController userController =
        TextEditingController(text: server.user);
    TextEditingController passController =
        TextEditingController(text: server.pass);
    bool _isObscure = true;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Server Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Server Name'),
              ),
              TextField(
                controller: portController,
                decoration: const InputDecoration(labelText: 'Port'),
              ),
              TextField(
                controller: hostController,
                decoration: const InputDecoration(labelText: 'Host'),
              ),
              TextField(
                controller: userController,
                decoration: const InputDecoration(labelText: 'User'),
              ),
              TextField(
                controller: passController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure; // Toggle visibility
                      });
                    },
                    icon: Icon(
                      _isObscure ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                Server updatedServer = Server(
                  id: server.id,
                  name: nameController.text,
                  mqttId: server.mqttId,
                  host: hostController.text,
                  user: server.user,
                  port: server.port,
                  pass: server.pass,
                );

                await _updateServer(updatedServer);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateServer(Server server) async {
    final serverDatabase = ServerDatabase.instance;
    await serverDatabase.updateServer(server);
    _loadServers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MQTT Connection'),
      ),
      body: ListView.builder(
        itemCount: servers.length,
        itemBuilder: (context, index) {
          final server = servers[index];
          //bool isConnected = serverStatus[server.name] ?? false;
          Color wifiIconColor = Colors.green;
          return Container(
            child: ListTile(
              title: Text('Name: ${server.name}'),
              subtitle: Text('Host: ${server.host}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      _editServer(server);
                      // Handle the edit details action for the server
                      // You can navigate to an edit screen or perform the desired action here.
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Confirm Deletion'),
                            content: const Text(
                                'Are you sure you want to delete this server?'),
                            actions: [
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: const Text('Delete'),
                                onPressed: () {
                                  _deleteServer(server);
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.wifi),
                    color: wifiIconColor,
                    onPressed: () {
                      // Handle the connect action for the server
                      // You can call a method to connect to the server here.
                    },
                  ),
                ],
              ),
              onTap: () {
                _navigateToServerDetails(server);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Subscribe(),
            ),
          ); // Add new server logic here if needed
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
