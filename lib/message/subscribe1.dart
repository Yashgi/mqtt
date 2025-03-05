import 'package:flutter/material.dart';
import 'package:mqtt_chat/chat/subscribe_chat.dart';
import 'package:mqtt_chat/data/subscribe_data.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class Subscriber extends StatefulWidget {
  final String serverName;
  final String serverHost;
  final String serverPort;
  final String serverUser;
  final String serverPass;

  const Subscriber({
    super.key,
    required this.serverHost,
    required this.serverPort,
    required this.serverName,
    required this.serverUser,
    required this.serverPass,
  });

  @override
  _SubscriberState createState() => _SubscriberState();
}

class _SubscriberState extends State<Subscriber> {
  final TextEditingController topicController = TextEditingController();
  List<SubscriberModel> subscribers = [];

  @override
  void initState() {
    super.initState();
    _loadSubscriber();
  }

  void _loadSubscriber() async {
    final subscriberDatabase = SubscriberDatabase.instance;
    final loadedSubscriber =
        await subscriberDatabase.getSubscriber(widget.serverName);

    setState(() {
      subscribers = loadedSubscriber;
    });
  }

  void _showAddSubscriberDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Subscriber'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: topicController,
                  decoration: InputDecoration(labelText: 'Subscribe Topic'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newSubscriber = SubscriberModel(
                    name: topicController.text, // Use the topic as the name
                    host: widget.serverHost,
                    port: int.tryParse(widget.serverPort) ?? 1883,
                    topic: topicController.text,
                    serverName: widget.serverName);

                addSubscriber(newSubscriber);

                // Close the dialog
                Navigator.of(context).pop();
              },
              child: const Text('Add Subscriber'),
            ),
          ],
        );
      },
    );
  }

  void addSubscriber(SubscriberModel newSubscriber) async {
    final newSubscriber = SubscriberModel(
        name: topicController.text,
        host: widget.serverHost,
        port: int.tryParse(widget.serverPort) ?? 1883,
        topic: topicController.text,
        serverName: widget.serverName);
    final subscriberDatabase = SubscriberDatabase.instance;
    await subscriberDatabase.insertSubscriber(newSubscriber);

    setState(() {
      subscribers.add(newSubscriber);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.serverName} Live'),
      ),
      body: ListView.builder(
        itemCount: subscribers.length,
        itemBuilder: (context, index) {
          final subscriber = subscribers[index];
          return ListTile(
            title: Text(subscriber.name),
            subtitle:
                Text('Host: ${subscriber.host}, Port: ${subscriber.port}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _editSubscriberDialog(context, subscriber);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Confirm Deletion'),
                          content: Text(
                              'Are you sure you want to delete this server?'),
                          actions: [
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text('Delete'),
                              onPressed: () {
                                _deleteSubscriber(subscriber);
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            onTap: () {
              _openChatForSubscriber(subscriber);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddSubscriberDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _editSubscriberDialog(
      BuildContext context, SubscriberModel subscriber) {}

  void _deleteSubscriber(SubscriberModel subscriber) async {
    final subscriberDatabase = SubscriberDatabase.instance;
    await subscriberDatabase.deleteSubscriber(subscriber.name);

    setState(() {
      subscribers.remove(subscriber);
    });
  }

  void _openChatForSubscriber(SubscriberModel subscriber) {
    final client = MqttServerClient(widget.serverHost, widget.serverName);
    client.port = int.tryParse(widget.serverPort) ?? 1883; // Set the port

    // Connect the client
    client.connect(widget.serverUser, widget.serverPass).then((value) {
      // If connected, navigate to chat page
      if (client.connectionStatus?.state == MqttConnectionState.connected) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubscribeChatPage(
              subscriber: subscriber,
              subscriberName: subscriber.name,
              client: client,
              serverHost: widget.serverHost,
              serverPort: widget.serverPort,
              serverUser: widget.serverUser,
              serverPass: widget.serverPass,
            ),
          ),
        );
      }
    }).catchError((e) {
      print('Error connecting to MQTT broker: $e');
      client.disconnect();
    });
  }
}
