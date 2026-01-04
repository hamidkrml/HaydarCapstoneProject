import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(const FitnessApp());
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const FitnessScreen(),
    );
  }
}

class HealthData {
  final int heartRate;
  final int steps;
  final String timestamp;
  final DateTime? receivedAt;

  HealthData({
    required this.heartRate,
    required this.steps,
    required this.timestamp,
    this.receivedAt,
  });

  factory HealthData.fromJson(Map<String, dynamic> json) {
    return HealthData(
      heartRate: json['heart_rate'] ?? 0,
      steps: json['steps'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      receivedAt: DateTime.now(),
    );
  }
}

class FitnessScreen extends StatefulWidget {
  const FitnessScreen({super.key});

  @override
  State<FitnessScreen> createState() => _FitnessScreenState();
}

class _FitnessScreenState extends State<FitnessScreen> {
  WebSocketChannel? _channel;
  HealthData? _latestData;
  bool _isConnected = false;
  String _connectionStatus = 'Bağlantı Yok';
  String _serverUrl = 'ws://10.0.2.2:8000/ws/phone'; // Android Emulator için
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _urlController.text = _serverUrl;
  }

  void _connect() {
    if (_channel != null) {
      _disconnect();
    }

    setState(() {
      _connectionStatus = 'Bağlanıyor...';
      _isConnected = false;
    });

    try {
      final uri = Uri.parse(_urlController.text);
      _channel = WebSocketChannel.connect(uri);

      _channel!.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message);
            setState(() {
              _latestData = HealthData.fromJson(data);
              _connectionStatus = 'Bağlı';
              _isConnected = true;
            });
          } catch (e) {
            print('Veri parse hatası: $e');
          }
        },
        onError: (error) {
          setState(() {
            _connectionStatus = 'Hata: $error';
            _isConnected = false;
          });
        },
        onDone: () {
          setState(() {
            _connectionStatus = 'Bağlantı Kesildi';
            _isConnected = false;
          });
        },
      );

      // Bağlantı sonrası ping gönder
      Future.delayed(const Duration(seconds: 1), () {
        _channel?.sink.add(jsonEncode({'type': 'ping'}));
      });
    } catch (e) {
      setState(() {
        _connectionStatus = 'Bağlantı Hatası: $e';
        _isConnected = false;
      });
    }
  }

  void _disconnect() {
    _channel?.sink.close();
    _channel = null;
    setState(() {
      _isConnected = false;
      _connectionStatus = 'Bağlantı Yok';
    });
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return DateFormat('HH:mm:ss').format(dateTime);
    } catch (e) {
      return timestamp;
    }
  }

  @override
  void dispose() {
    _disconnect();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Fitness Monitor'),
        actions: [
          IconButton(
            icon: Icon(_isConnected ? Icons.wifi : Icons.wifi_off),
            onPressed: _isConnected ? _disconnect : _connect,
            tooltip: _isConnected ? 'Bağlantıyı Kes' : 'Bağlan',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bağlantı Durumu Kartı
            Card(
              color: _isConnected ? Colors.green.shade50 : Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isConnected ? Icons.check_circle : Icons.error,
                          color: _isConnected ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _connectionStatus,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _isConnected ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                        labelText: 'Backend Server URL',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.link),
                      ),
                      enabled: !_isConnected,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isConnected ? _disconnect : _connect,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isConnected ? Colors.red : Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(_isConnected ? 'Bağlantıyı Kes' : 'Bağlan'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Kalp Atışı Kartı
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.favorite,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Kalp Atışı',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _latestData?.heartRate.toString() ?? '--',
                      style: const TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'BPM',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    if (_latestData?.receivedAt != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Güncellendi: ${DateFormat('HH:mm:ss').format(_latestData!.receivedAt!)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Adımlar Kartı
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.directions_walk,
                      size: 64,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Adımlar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _latestData?.steps.toString() ?? '--',
                      style: const TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_latestData != null && _latestData!.timestamp.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Zaman: ${_formatTimestamp(_latestData!.timestamp)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
