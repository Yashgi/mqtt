import 'package:flutter/material.dart';
import 'package:mqtt_chat/chat/publish_chat.dart';
import 'package:mqtt_chat/data/publich_data.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class Publisher extends StatefulWidget {
  final String serverName;
  final String serverHost;
  final String serverPort;
  final String serverUser;
  final String serverPass;

  Publisher({
    super.key,
    required this.serverName,
    required this.serverHost,
    required this.serverPort,
    required this.serverUser,
    required this.serverPass,
  });

  @override
  _PublisherState createState() => _PublisherState();
}

class _PublisherState extends State<Publisher> {
  final TextEditingController topicController = TextEditingController();
  List<PublisherModel> publishers = [];

  @override
  void initState() {
    super.initState();
    _loadPublisher();
  }

  void _loadPublisher() async {
    final publisherDatabase = PublisherDatabase.instance;
    final loadedPublishers =
        await publisherDatabase.getPublishers(widget.serverName);

    setState(() {
      publishers = loadedPublishers;
    });
  }

  void _showAddPublisherDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Publisher'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: topicController,
                  decoration: InputDecoration(labelText: 'Publish Topic'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newPublisher = PublisherModel(
                    name: topicController.text,
                    host: widget.serverHost,
                    port: int.tryParse(widget.serverPort) ?? 1883,
                    topic: topicController.text,
                    serverName: widget.serverName);

                _addPublisherToDatabase(newPublisher);

                // Close the dialog
                Navigator.of(context).pop();
              },
              child: Text('Add Publisher'),
            ),
          ],
        );
      },
    );
  }

  void _addPublisherToDatabase(PublisherModel newPublisher) async {
    final newPublisher = PublisherModel(
        name: topicController.text,
        host: widget.serverHost,
        port: int.tryParse(widget.serverPort) ?? 1883,
        topic: topicController.text,
        serverName: widget.serverName);
    final publisherDatabase = PublisherDatabase.instance;
    await publisherDatabase.insertPublisher(newPublisher);

    setState(() {
      publishers.add(newPublisher);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.serverName} Live'),
      ),
      body: ListView.builder(
        itemCount: publishers.length,
        itemBuilder: (context, index) {
          final publisher = publishers[index];
          return ListTile(
            title: Text(publisher.name),
            subtitle: Text('Host: ${publisher.host}, Port: ${publisher.port}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _editPublisherDialog(context, publisher);
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
                                _deletePublisher(publisher);
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
              _openChatForPublisher(publisher);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddPublisherDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _editPublisherDialog(BuildContext context, PublisherModel publisher) {}

  void _deletePublisher(PublisherModel publisher) async {
    final publisherDatabase = PublisherDatabase.instance;
    await publisherDatabase.deletePublisher(publisher.name);

    setState(() {
      publishers.remove(publisher);
    });
  }

  void _openChatForPublisher(PublisherModel publisher) {
    final client = MqttServerClient(widget.serverHost, widget.serverName);
    client.port = int.tryParse(widget.serverPort) ?? 1883; // Set the port

    // Connect the client
    client.connect(widget.serverUser, widget.serverPass).then((value) {
      // If connected, navigate to chat page
      if (client.connectionStatus?.state == MqttConnectionState.connected) {
        // The client is now connected to the server. You can proceed to open the chat.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              publisher: publisher,
              publisherName: publisher.name,
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
