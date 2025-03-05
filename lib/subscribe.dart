import 'package:flutter/material.dart';
import 'package:mqtt_chat/Mqtt.dart';
import 'package:provider/provider.dart';

class Subscribe extends StatefulWidget {
  const Subscribe({super.key});

  @override
  State<Subscribe> createState() => _SubscribeState();
}

class _SubscribeState extends State<Subscribe> {
  var name = TextEditingController();
  var id = TextEditingController();
  var host = TextEditingController();
  var user = TextEditingController();
  var pass = TextEditingController();
  var port = TextEditingController();
  bool _isObscure = true; // Track password visibility

  String selectedProtocol = 'Protocol'; // Default protocol
  List<String> protocols = ['TCP/IP', 'UDP', 'MQTT', 'HTTP'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 350,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 21),
                TextField(
                  controller: name,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(21),
                      borderSide: const BorderSide(
                        color: Colors.deepOrange,
                      ),
                    ),
                    hintText: "MQTT Client Name",
                  ),
                ),
                const SizedBox(height: 11),
                GestureDetector(
                  onTap: () {
                    showProtocolDropdown(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color.fromARGB(255, 48, 157, 194)),
                      borderRadius: BorderRadius.circular(21),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedProtocol,
                          style: const TextStyle(color: Colors.black),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 11),
                TextField(
                  controller: id,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(21),
                      borderSide: const BorderSide(color: Colors.deepOrange),
                    ),
                    hintText: "MQTT Client Id",
                  ),
                ),
                const SizedBox(height: 11),
                TextField(
                  controller: port,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(21),
                      borderSide: const BorderSide(color: Colors.deepOrange),
                    ),
                    hintText: "Port",
                  ),
                ),
                const SizedBox(height: 11),
                TextField(
                  controller: host,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(21),
                      borderSide: const BorderSide(color: Colors.deepOrange),
                    ),
                    hintText: "Host",
                  ),
                ),
                const SizedBox(height: 11),
                TextField(
                  controller: user,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(21),
                      borderSide: const BorderSide(
                        color: Colors.deepOrange,
                      ),
                    ),
                    hintText: "Username",
                  ),
                ),
                const SizedBox(height: 11),
                TextField(
                  controller: pass,
                  obscureText: _isObscure,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(21),
                      borderSide: const BorderSide(
                        color: Colors.deepOrange,
                      ),
                    ),
                    hintText: "Password",
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
                const SizedBox(height: 11),
                ElevatedButton(
                  onPressed: () {
                    if (selectedProtocol == 'MQTT') {
                      MqttService mqttService = MqttService(
                        name: name.text,
                        host: host.text,
                        user: user.text,
                        port: port.text,
                        pass: pass.text,
                      );

                      // Connect to MQTT using the MqttService
                      mqttService.connect(context);

                      // Add the MQTT service to MqttServiceManager
                      final mqttServiceManager =
                          Provider.of<MqttServiceManager>(context,
                              listen: false);
                      mqttServiceManager.addService(name.text, mqttService);
                    } else {}

                    // Save and connect logic
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showProtocolDropdown(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Protocol"),
          content: SizedBox(
            width: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: protocols.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(protocols[index]),
                  onTap: () {
                    setState(() {
                      selectedProtocol = protocols[index];
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
