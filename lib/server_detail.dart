import 'package:flutter/material.dart';
import 'package:mqtt_chat/database.dart';
import 'package:mqtt_chat/message/publish.dart';
import 'package:mqtt_chat/message/subscribe1.dart';

class ServerDetails extends StatefulWidget {
  final Server server;

  ServerDetails({required this.server});

  @override
  State<ServerDetails> createState() => _ServerDetailsState();
}

class _ServerDetailsState extends State<ServerDetails> {
  int _selectedIndex = 0;

  void _onItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MQTT Connection'),
      ),
      body: Center(
        child: _selectedIndex == 0
            ? Publisher(
                serverHost: widget.server.host,
                serverPort: widget.server.port.toString(),
                serverName: widget.server.name,
                serverUser: widget.server.user,
                serverPass: widget.server.pass,
              )
            : Subscriber(
                serverHost: widget.server.host,
                serverPort: widget.server.port.toString(),
                serverName: widget.server.name,
                serverUser: widget.server.user,
                serverPass: widget.server.pass,
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.subscriptions),
            label: 'Publish',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.publish),
            label: 'Subscribe',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTap,
      ),
    );
  }
}
