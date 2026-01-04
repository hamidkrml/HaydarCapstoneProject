# Backend API Endpoint'leri

Backend Docker'da `http://0.0.0.0:8000` adresinde çalışıyor.

## HTTP Endpoint'leri

### 1. Health Check
```
GET http://localhost:8000/health
```

**Yanıt:**
```json
{
  "status": "healthy"
}
```

**Test:**
```bash
curl http://localhost:8000/health
```

### 2. Server Status
```
GET http://localhost:8000/
```

**Yanıt:**
```json
{
  "status": "running",
  "connected_watches": 0,
  "connected_phones": 0,
  "latest_data_count": 0
}
```

**Test:**
```bash
curl http://localhost:8000/
```

**Tarayıcıda:**
- http://localhost:8000/
- http://localhost:8000/health

## WebSocket Endpoint'leri

### 1. Watch Endpoint (Watch App için)
```
WS ws://localhost:8000/ws/watch
```

**Android Emulator için:**
```
WS ws://10.0.2.2:8000/ws/watch
```

**Kullanım:** Watch uygulaması bu endpoint'e bağlanır ve health data gönderir.

**Gönderilen Veri Formatı:**
```json
{
  "heart_rate": 72,
  "steps": 1200,
  "timestamp": "2026-01-04T12:00:00Z",
  "watch_id": "optional-device-id"
}
```

### 2. Phone Endpoint (Fitness App için)
```
WS ws://localhost:8000/ws/phone
```

**Android Emulator için:**
```
WS ws://10.0.2.2:8000/ws/phone
```

**Kullanım:** Mobil uygulama bu endpoint'e bağlanır ve watch'lardan gelen verileri alır.

**Alınan Veri Formatı:**
```json
{
  "heart_rate": 72,
  "steps": 1200,
  "timestamp": "2026-01-04T12:00:00Z",
  "watch_id": "optional-device-id"
}
```

## Android Emulator için URL'ler

Backend Docker'da çalışırken, Android emulator'den bağlanmak için:

- **Watch App:** `ws://10.0.2.2:8000/ws/watch`
- **Fitness App:** `ws://10.0.2.2:8000/ws/phone`

**Neden 10.0.2.2?**
- Android emulator'de `10.0.2.2` = Host machine'in `localhost`'u
- Docker container host'ta port 8000'i expose ettiği için erişilebilir

## Fiziksel Cihaz için URL'ler

Fiziksel Android cihaz kullanıyorsanız:

1. Bilgisayarınızın yerel IP adresini öğrenin:
   - **Windows:** `ipconfig` → IPv4 Address
   - **Mac/Linux:** `ifconfig` veya `ip addr` → inet address

2. Örnek IP: `192.168.1.100` ise:
   - **Watch App:** `ws://192.168.1.100:8000/ws/watch`
   - **Fitness App:** `ws://192.168.1.100:8000/ws/phone`

**Önemli:** Bilgisayar ve telefon aynı WiFi ağında olmalı!

## Test Komutları

### HTTP Endpoint Test
```bash
# Health check
curl http://localhost:8000/health

# Server status
curl http://localhost:8000/
```

### WebSocket Test (Python scripti)
```bash
cd backend
python test_websocket.py full
```

### WebSocket Test (Browser Console)
Tarayıcı konsolunda (F12):
```javascript
// Phone olarak bağlan
const phoneWs = new WebSocket('ws://localhost:8000/ws/phone');
phoneWs.onmessage = (event) => {
  console.log('Alındı:', JSON.parse(event.data));
};

// Watch olarak bağlan (başka tab)
const watchWs = new WebSocket('ws://localhost:8000/ws/watch');
watchWs.onopen = () => {
  watchWs.send(JSON.stringify({
    heart_rate: 75,
    steps: 1500,
    timestamp: new Date().toISOString()
  }));
};
```

## Özet Tablo

| Endpoint | Tip | Kullanım | Emulator URL | Fiziksel Cihaz URL |
|----------|-----|----------|--------------|-------------------|
| `/health` | HTTP GET | Health check | `http://10.0.2.2:8000/health` | `http://[IP]:8000/health` |
| `/` | HTTP GET | Server status | `http://10.0.2.2:8000/` | `http://[IP]:8000/` |
| `/ws/watch` | WebSocket | Watch veri gönderir | `ws://10.0.2.2:8000/ws/watch` | `ws://[IP]:8000/ws/watch` |
| `/ws/phone` | WebSocket | Phone veri alır | `ws://10.0.2.2:8000/ws/phone` | `ws://[IP]:8000/ws/phone` |

## Docker Port Mapping

Docker compose dosyasında:
```yaml
ports:
  - "8000:8000"
```

Bu, container'ın 8000 portunu host'un 8000 portuna map eder.

**Backend çalışıyor mu kontrol:**
```bash
curl http://localhost:8000/health
# veya tarayıcıda: http://localhost:8000/
```


