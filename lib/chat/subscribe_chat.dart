import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mqtt_chat/chat_data/sub_data.dart';
import 'package:mqtt_chat/data/subscribe_data.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

class SubscribeChatPage extends StatefulWidget {
  final String subscriberName;
  final MqttServerClient client;
  final SubscriberModel subscriber;
  final String serverHost;
  final String serverPort;
  final String serverUser;
  final String serverPass;

  SubscribeChatPage({
    Key? key,
    required this.subscriberName,
    required this.client,
    required this.subscriber,
    required this.serverHost,
    required this.serverPort,
    required this.serverUser,
    required this.serverPass,
  }) : super(key: key);

  @override
  _SubscribeChatPageState createState() => _SubscribeChatPageState();
}
//...

class _SubscribeChatPageState extends State<SubscribeChatPage> {
  List<ReceivedDataModel> _receivedData = [];

  @override
  void initState() {
    super.initState();
    _loadSub();
    _connectAndSubscribe();
  }

  void _loadSub() async {
    final subDatabase = ReceivedDataDatabase.instance;
    final loadedSub = await subDatabase.getReceivedData(widget.subscriberName);

    setState(() {
      _receivedData = loadedSub;
    });
  }

  void _connectAndSubscribe() async {
    if (widget.client.connectionStatus!.state ==
        MqttConnectionState.connected) {
      _subscribeToTopic();
    } else {
      //_addReceivedMessage('MQTT server is not connected.');
      await widget.client.connect();
      _subscribeToTopic();
    }
  }

  void _subscribeToTopic() {
    widget.client.subscribe(widget.subscriberName, MqttQos.atLeastOnce);
    widget.client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      final String newMessage =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      _addReceivedMessage(newMessage);
    });
  }

  void _addReceivedMessage(String message) async {
    final receivedData = ReceivedDataModel(
        subscriberId: widget.subscriberName, message: message);
    final subsDatabase = ReceivedDataDatabase.instance;
    await subsDatabase.insertReceivedData(receivedData);
    setState(() {
      _receivedData.insert(0, receivedData);
      //_receivedData.add(receivedData);
    });

    /*catch (e) {
        print('Error processing received data: $e');

        final Map<String, dynamic> receivedContent = jsonDecode(message);
        final ReceivedDataModel receivedData =
            ReceivedDataModel.fromJson(receivedContent);

        final subDatabase = ReceivedDataDatabase.instance;
        subDatabase.insertReceivedData(receivedData).then((insertedId) {
          setState(() {
            //receivedData.id = insertedId; // Ensure you have an 'id' property in ReceivedDataModel
            _receivedData.add(receivedData);
          });
        });
        // Handle the error if JSON parsing fails
      }
    });*/
  }

  Future<void> _exportDataToCSV() async {
    try {
      final receivedDataDatabase = ReceivedDataDatabase.instance;
      final List<ReceivedDataModel> data =
          await receivedDataDatabase.getReceivedData(widget.subscriberName);

      final List<List<dynamic>> csvData = [
        ['Subscriber ID', 'Message'],
        for (ReceivedDataModel item in data) [item.subscriberId, item.message],
      ];

      // Get the directory for storing CSV file
      Directory? directory = await getApplicationDocumentsDirectory();
      if (directory != null) {
        File csvFile = File('${directory.path}/exported_data.csv');
        String csv = const ListToCsvConverter().convert(csvData);
        await csvFile.writeAsString(csv);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data exported to CSV: ${csvFile.path}'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting storage directory'),
          ),
        );
      }
    } catch (e) {
      print('Error exporting data to CSV: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting data to CSV'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subscriberName),
        actions: [
          IconButton(
            icon: Icon(Icons.file_download),
            onPressed: _exportDataToCSV,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _receivedData.length,
              itemBuilder: (context, index) {
                final data = _receivedData[index];
                return Card(
                  child: ListTile(
                    title: Text(
                      'Received Content:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '$data',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
