# Health Data WebSocket Backend Server

Backend server for real-time health data transfer between watch devices and mobile applications.

## Project Structure

```
.
├── backend/           # Python FastAPI WebSocket server
└── README.md          # This file
```

## System Architecture

```
Watch Device (WearOS/watchOS)
    ↓ WebSocket
Backend Server (FastAPI)
    ↓ WebSocket Broadcast
Mobile App (Android/iOS)
```

## Quick Start

### Backend Server (Docker - Önerilen)

```bash
cd backend
docker-compose up -d
```

Server runs on `http://localhost:8000`

### Backend Server (Local Python)

```bash
cd backend
pip install -r requirements.txt
python main.py
```

Or using uvicorn directly:
```bash
cd backend
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

### Android Emulator Kurulumu

Detaylı rehber için: [ANDROID_STUDIO_SETUP.md](ANDROID_STUDIO_SETUP.md)

Kısa özet:
1. Android Studio > Device Manager > Create Device
2. Fitness app için: Phone emulator oluştur
3. Watch app için: Wear OS emulator oluştur
4. Emulator'leri başlat ve `flutter run` yap

## Backend Endpoints

- `GET /` - Server status and connection counts
- `GET /health` - Health check endpoint
- `WS /ws/watch` - Watch devices connect here and send health data
- `WS /ws/phone` - Mobile apps connect here to receive real-time data

## Data Format

Health data is transmitted in JSON format:

```json
{
  "heart_rate": 72,
  "steps": 1200,
  "timestamp": "2026-01-04T12:00:00Z",
  "watch_id": "optional-device-id"
}
```

## Features

- ✅ FastAPI WebSocket server
- ✅ Real-time data broadcasting from watches to phones
- ✅ Multiple watch and phone client support
- ✅ Connection status tracking
- ✅ CORS enabled for mobile applications
- ✅ Error handling and client disconnection management

## How It Works

1. **Watch devices** connect to `/ws/watch` and send health data (heart rate, steps, timestamp)
2. **Backend** receives data from watch devices and stores the latest data
3. **Mobile apps** connect to `/ws/phone` and receive real-time broadcasts of health data
4. All connected phone clients receive data simultaneously when a watch sends new data

## Network Configuration

For testing with mobile apps:
- Android Emulator: Use `ws://10.0.2.2:8000`
- iOS Simulator: Use `ws://localhost:8000`
- Physical devices: Use your computer's local IP address (e.g., `ws://192.168.1.100:8000`)
- Ensure all devices are on the same network
- Check firewall settings if connection fails

## Development

The server supports multiple watch devices and multiple phone clients. Data from watches is broadcast to all connected phone clients in real-time.

### Production Considerations

- Add authentication/authorization
- Implement data persistence (database)
- Add error handling and reconnection logic
- Implement secure WebSocket (WSS) with SSL/TLS
- Add rate limiting
- Monitor and log connections
- Add data validation and sanitization
- Implement user sessions and device pairing
