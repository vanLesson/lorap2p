import 'package:flutter/material.dart';
import 'package:lorap2p/tcpClient.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final P2PTCP p2pClient = P2PTCP();
  final TextEditingController _controller = TextEditingController();
  final List<String> messages = [];

  @override
  void initState() {
    super.initState();

    // Слухаємо повідомлення з сервера
    p2pClient.messages.listen((message) {
      setState(() {
        messages.add(message);
      });
    });
  }

  void _sendMessage() {
    final text = _controller.text;
    p2pClient.sendToServer(text); // Відправка повідомлення
    _controller.clear(); // Очищення текстового поля після відправки
  }
  void _startServer() async {
   await p2pClient.startServer(port: 4040); // Запуск сервера для самопідключення

  }
  void _connectToTheServer() async {
    await p2pClient.connectToServer(host: '10.0.2.2', port: 4040);

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('P2P Чат'),
        ),
        body: Column(
          children: [
            Padding(padding: const EdgeInsets.all(8.0),child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: _startServer,
                  child: const Text('Start'),
                ),
                const SizedBox(width: 50),
                ElevatedButton(
                  onPressed: _connectToTheServer,
                  child: const Text('Connect'),
                ),
              ],
            )),
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
                      decoration: InputDecoration(hintText: 'Введіть повідомлення...'),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
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
    p2pClient.close(); // Закриття з'єднань та сервера
    _controller.dispose();
    super.dispose();
  }
}