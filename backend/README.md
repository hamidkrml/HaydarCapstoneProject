# Health Data WebSocket Server

Backend server for real-time health data transfer between watch devices and mobile applications.

## Features

- WebSocket server using FastAPI
- `/ws/watch` endpoint for watch devices to send health data
- `/ws/phone` endpoint for mobile apps to receive real-time data
- Real-time broadcasting from watches to phones
- CORS enabled for Flutter apps

## Setup

### Option 1: Docker (Önerilen)

#### Docker Compose ile çalıştırma:
```bash
docker-compose up -d
```

#### Docker ile manuel çalıştırma:
```bash
# Image'i build et
docker build -t health-backend .

# Container'ı çalıştır
docker run -d -p 8000:8000 --name health_backend health-backend
```

#### Docker komutları:
```bash
# Logları görüntüle
docker logs -f health_backend

# Container'ı durdur
docker stop health_backend

# Container'ı kaldır
docker rm health_backend

# Docker Compose ile durdur
docker-compose down
```

### Option 2: Local Python

1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. Run the server:
```bash
python main.py
```

Or using uvicorn directly:
```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

Server will start on `http://localhost:8000`

## WebSocket Endpoints

### `/ws/watch`
Watch devices connect here and send health data in JSON format:
```json
{
  "heart_rate": 72,
  "steps": 1200,
  "timestamp": "2026-01-04T12:00:00Z",
  "watch_id": "optional-device-id"
}
```

### `/ws/phone`
Mobile applications connect here to receive real-time health data broadcasts.

## API Endpoints

- `GET /` - Server status and connection counts
- `GET /health` - Health check endpoint

## Development

The server supports multiple watch devices and multiple phone clients. Data from watches is broadcast to all connected phone clients in real-time.

