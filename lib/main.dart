import 'package:flutter/material.dart';
import 'package:lorap2p/tcpClient.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final P2PTCP p2pClient = P2PTCP();
  final TextEditingController _controller = TextEditingController();
  final List<String> messages = [];

  @override
  void initState() {
    super.initState();

    p2pClient.messages.listen((message) {
      setState(() {
        messages.add('Server: $message');
      });
    });
  }

  void _sendMessage() {
    final text = _controller.text;
    if (text.isNotEmpty) {
      p2pClient.sendToServer(text);
      setState(() {
        messages.add('Me: $text');
      });
      _controller.clear();
    }
  }

  void _startServer() async {
    await p2pClient.startServer(port: 4040);
    setState(() {
      messages.add('Server started on port 4040');
    });
  }

  void _connectToServer() async {
    try {
      await p2pClient.connectToServer(host: '10.0.2.2', port: 4040);
      setState(() {
        messages.add('Connected to port 4040');
      });
    } on Exception catch (e) {
      setState(() {
        messages.add('Failed to connect to server: $e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('P2P Chat'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: _startServer,
                    child: const Text('Start Server'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _connectToServer,
                    child: const Text('Connect to Server'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(messages[index]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Enter a message...',
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    p2pClient.close();
    _controller.dispose();
    super.dispose();
  }
}
