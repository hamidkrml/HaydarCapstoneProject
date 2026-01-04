import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const WatchApp());
}

class WatchApp extends StatelessWidget {
  const WatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Watch',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const WatchHealthScreen(),
    );
  }
}

class WatchHealthScreen extends StatefulWidget {
  const WatchHealthScreen({super.key});

  @override
  State<WatchHealthScreen> createState() => _WatchHealthScreenState();
}

class _WatchHealthScreenState extends State<WatchHealthScreen> {
  WebSocketChannel? _channel;
  bool _isConnected = false;
  bool _isSending = false;
  String _connectionStatus = 'Bağlantı Yok';
  String _serverUrl = 'ws://10.0.2.2:8000/ws/watch'; // Android Emulator için
  final TextEditingController _urlController = TextEditingController();

  // Sensör verileri (gerçek sensörler için değiştirilecek)
  int _heartRate = 72;
  int _steps = 0;
  Timer? _sensorTimer;
  Timer? _sendTimer;

  @override
  void initState() {
    super.initState();
    _urlController.text = _serverUrl;
    _startSimulatedSensors();
  }

  void _startSimulatedSensors() {
    // Simüle edilmiş sensör verileri (gerçek sensörler için değiştirilecek)
    _sensorTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _heartRate = 60 + Random().nextInt(40); // 60-100 BPM
          _steps += Random().nextInt(5);
        });
      }
    });
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
            if (data['error'] != null) {
              setState(() {
                _connectionStatus = 'Hata: ${data['error']}';
                _isConnected = false;
              });
            } else {
              setState(() {
                _connectionStatus = 'Bağlı';
                _isConnected = true;
              });
            }
          } catch (e) {
            // JSON parse hatası - sessizce geç
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _connectionStatus = 'Bağlantı Hatası';
              _isConnected = false;
              _isSending = false;
            });
          }
          _stopSending();
        },
        onDone: () {
          if (mounted) {
            setState(() {
              _connectionStatus = 'Bağlantı Kesildi';
              _isConnected = false;
              _isSending = false;
            });
          }
          _stopSending();
        },
      );

      setState(() {
        _connectionStatus = 'Bağlı';
        _isConnected = true;
      });
    } catch (e) {
      setState(() {
        _connectionStatus = 'Hata: $e';
        _isConnected = false;
      });
    }
  }

  void _disconnect() {
    _stopSending();
    _channel?.sink.close();
    _channel = null;
    if (mounted) {
      setState(() {
        _isConnected = false;
        _connectionStatus = 'Bağlantı Yok';
      });
    }
  }

  void _startSending() {
    if (!_isConnected || _isSending) return;

    setState(() {
      _isSending = true;
    });

    // Her 3 saniyede bir veri gönder
    _sendTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_channel != null && _isConnected && mounted) {
        final data = {
          'heart_rate': _heartRate,
          'steps': _steps,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
          'watch_id': 'wearos_watch_1',
        };

        try {
          _channel!.sink.add(jsonEncode(data));
        } catch (e) {
          _stopSending();
        }
      }
    });
  }

  void _stopSending() {
    _sendTimer?.cancel();
    _sendTimer = null;
    if (mounted) {
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  void dispose() {
    _stopSending();
    _sensorTimer?.cancel();
    _disconnect();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Bağlantı Durumu
              Card(
                color: _isConnected ? Colors.green.shade900 : Colors.red.shade900,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isConnected ? Icons.check_circle : Icons.error,
                            color: _isConnected ? Colors.green : Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _connectionStatus,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _isConnected ? Colors.green : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _urlController,
                        decoration: InputDecoration(
                          labelText: 'Server URL',
                          labelStyle: const TextStyle(fontSize: 11),
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.link, size: 18),
                          isDense: true,
                          contentPadding: const EdgeInsets.all(8),
                        ),
                        enabled: !_isConnected,
                        style: const TextStyle(fontSize: 11),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isConnected ? _disconnect : _connect,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isConnected ? Colors.red : Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: Text(
                            _isConnected ? 'Bağlantıyı Kes' : 'Bağlan',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Gönderim Kontrolü
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Text(
                        _isSending ? 'Veri Gönderiliyor' : 'Beklemede',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _isSending ? Colors.green : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isConnected
                              ? (_isSending ? _stopSending : _startSending)
                              : null,
                          icon: Icon(
                            _isSending ? Icons.stop : Icons.play_arrow,
                            size: 18,
                          ),
                          label: Text(_isSending ? 'Durdur' : 'Başlat'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isSending ? Colors.red : Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Kalp Atışı
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.favorite,
                        size: 32,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Kalp Atışı',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_heartRate',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'BPM',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Adımlar
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.directions_walk,
                        size: 32,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Adımlar',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_steps',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
