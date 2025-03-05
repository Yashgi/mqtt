import 'package:flutter/material.dart';
import 'package:mqtt_chat/chat_data/pub_data.dart';
import 'package:mqtt_chat/data/publich_data.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class ChatPage extends StatefulWidget {
  final String publisherName;
  final MqttServerClient client;
  final PublisherModel publisher;
  final String serverHost;
  final String serverPort;
  final String serverUser;
  final String serverPass;

  ChatPage({
    Key? key,
    required this.publisherName,
    required this.client,
    required this.publisher,
    required this.serverHost,
    required this.serverPort,
    required this.serverUser,
    required this.serverPass,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  List<SendDataModel> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadPub();
    _connectAndPublisher();
  }

  void _loadPub() async {
    final pubDatabase = SendDataDatabase.instance;
    final loadedPub = await pubDatabase.getSendData(widget.publisherName);

    setState(() {
      _messages = loadedPub;
    });
  }

  void _connectAndPublisher() async {
    // Check if the MQTT server is connected
    if (widget.client.connectionStatus?.state ==
        MqttConnectionState.connected) {
      // Subscribe to the MQTT topic used by this publisher
      widget.client.subscribe(widget.publisherName, MqttQos.atLeastOnce);

      // Listen to incoming messages on the subscribed topic
      widget.client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        //final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        //final String newMessage =
        //MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        // _addReceivedMessage(newMessage);
      });
    } else {
      // Handle the case when the MQTT server is not connected
      //_addReceivedMessage('MQTT server is not connected.');
      widget.client.connect();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.publisherName),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final pdata = _messages[index];
                return Card(
                  child: ListTile(
                      title: Text(
                        'Send Content:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('$pdata')),
                );
              },
              /*return ListTile(
                  title: Text(_messages[index]),
                );
              },*/
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(labelText: 'Type a message'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    sendMessage(_messageController.text);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void sendMessage(String message) async {
    if (message.isNotEmpty) {
      final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
      builder.addString(message);

      final typedData = builder.payload;

      if (typedData != null) {
        widget.client.publishMessage(
          widget.publisherName,
          MqttQos.atLeastOnce,
          typedData,
        );
      } else {
        print('Error: Payload is null.');
      }
      final sentData = SendDataModel(
        publisherId: widget.publisherName, // Change publisherId to match sender
        message: message,
      );
      final sendDatabase = SendDataDatabase.instance;
      await sendDatabase.insertSendData(sentData);
      setState(() {
        _messages.add(sentData);
      });
    }
  }
}
