import 'dart:io';
import 'dart:async';

class P2PTCP {
  ServerSocket? _serverSocket;
  Socket? _clientSocket;
  final List<Socket> _connectedClients = [];

  // Старт сервера
  Future<void> startServer({required int port}) async {
    _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    print('Сервер запущено на: ${_serverSocket!.address.address}:${_serverSocket!.port}');
    _serverSocket!.listen(_handleClientConnected);
  }

  // Обробка підключення клієнта
  void _handleClientConnected(Socket client) {
    print('Клієнт підключено: ${client.remoteAddress.address}:${client.remotePort}');
    _connectedClients.add(client);
    client.listen(
          (data) {
        print('Дані від клієнта ${client.remoteAddress.address}:${client.remotePort}: ${String.fromCharCodes(data)}');
        // Тут можна додати логіку обробки даних
      },
      onError: (error) {
        print('Помилка: $error');
        _connectedClients.remove(client);
        client.close();
      },
      onDone: () {
        print('Клієнт відключено');
        _connectedClients.remove(client);
        client.close();
      },
    );
  }

  // Підключення до сервера як клієнт
  Future<void> connectToServer({required String host, required int port}) async {
    _clientSocket = await Socket.connect(host, port);
    print('Підключено до сервера на: $host:$port');
    _clientSocket!.listen(
          (data) {
        print('Дані від сервера: ${String.fromCharCodes(data)}');
        // Тут можна додати логіку обробки даних
      },
      onError: (error) {
            _clientSocket!.close();
      },
      onDone: () {
        print('Зєднання з сервером закрито');
            _clientSocket!.close();
      },
    );
  }

  // Відправлення даних сервером до всіх підключених клієнтів
  void sendToAllClients(String message) {
    for (var client in _connectedClients) {
      client.write(message);
    }
  }

  // Відправлення даних клієнтом до сервера
  void sendToServer(String message) {
    _clientSocket?.write(message);
  }

  // Закриття сервера та всіх з'єднань
  void close() {
    for (var client in _connectedClients) {
      client.close();
    }
    _connectedClients.clear();
    _serverSocket?.close();
    _clientSocket?.close();
  }
}