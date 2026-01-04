# Backend Test Rehberi

Backend'i test etmek için birkaç yöntem var:

## 1. REST API Test (Basit Kontrol)

Backend'in çalıştığını kontrol etmek için:

```bash
# Health check
curl http://localhost:8000/health

# Server durumu
curl http://localhost:8000/
```

Beklenen çıktı:
```json
{
  "status": "running",
  "connected_watches": 0,
  "connected_phones": 0,
  "latest_data_count": 0
}
```

## 2. Python Test Scripti ile WebSocket Testi

### Test Scriptini Çalıştırma

```bash
cd backend
python test_websocket.py
```

### Test Seçenekleri

#### a) Tam Akış Testi (Önerilen)
Watch gönderir, Phone alır:
```bash
python test_websocket.py full
```

#### b) Sadece Watch Testi
Watch olarak veri gönderir:
```bash
python test_websocket.py watch
```

#### c) Sadece Phone Testi
Phone olarak veri bekler (başka bir terminalden watch göndermelisiniz):
```bash
python test_websocket.py phone
```

## 3. İki Terminal ile Test

### Terminal 1 - Phone (Veri Alır)
```bash
cd backend
python test_websocket.py phone
```

### Terminal 2 - Watch (Veri Gönderir)
```bash
cd backend
python test_websocket.py watch
```

Terminal 1'de gelen verileri göreceksiniz!

## 4. WebSocket Client Araçları ile Test

### websocat (Kurulum: `brew install websocat` veya `cargo install websocat`)

#### Watch olarak veri gönder:
```bash
echo '{"heart_rate": 75, "steps": 1500, "timestamp": "2026-01-04T12:00:00Z"}' | websocat ws://localhost:8000/ws/watch
```

#### Phone olarak veri al:
```bash
websocat ws://localhost:8000/ws/phone
```

### wscat (Node.js tool: `npm install -g wscat`)

#### Watch olarak bağlan:
```bash
wscat -c ws://localhost:8000/ws/watch
```

Bağlandıktan sonra şunu gönder:
```json
{"heart_rate": 75, "steps": 1500, "timestamp": "2026-01-04T12:00:00Z"}
```

#### Phone olarak bağlan:
```bash
wscat -c ws://localhost:8000/ws/phone
```

## 5. Browser Console ile Test (Basit)

Tarayıcı konsolunda (Chrome DevTools):

```javascript
// Phone olarak bağlan
const phoneWs = new WebSocket('ws://localhost:8000/ws/phone');
phoneWs.onmessage = (event) => {
  console.log('Phone alındı:', JSON.parse(event.data));
};

// Watch olarak bağlan (başka bir tab)
const watchWs = new WebSocket('ws://localhost:8000/ws/watch');
watchWs.onopen = () => {
  watchWs.send(JSON.stringify({
    heart_rate: 72,
    steps: 1200,
    timestamp: new Date().toISOString()
  }));
};
```

## Test Senaryoları

### Senaryo 1: Basit Test
1. Backend'i başlat
2. `curl http://localhost:8000/` ile kontrol et
3. `python test_websocket.py full` çalıştır

### Senaryo 2: İki Cihaz Testi
1. Terminal 1: `python test_websocket.py phone` (veri bekler)
2. Terminal 2: `python test_websocket.py watch` (veri gönderir)
3. Terminal 1'de gelen verileri gör

### Senaryo 3: Birden Fazla Phone Client
1. Terminal 1: `python test_websocket.py phone`
2. Terminal 2: `python test_websocket.py phone`
3. Terminal 3: `python test_websocket.py watch`
4. Her iki phone terminalinde de veri gelmeli

## Beklenen Sonuçlar

✅ Başarılı test sonucu:
- Watch bağlantısı: "✅ Watch bağlantısı başarılı!"
- Phone bağlantısı: "✅ Phone bağlantısı başarılı!"
- Veri gönderimi: "📤 Veri gönderildi: HR=72, Steps=1200"
- Veri alma: "📥 Veri alındı: HR=72, Steps=1200"

❌ Hata durumları:
- "Connection refused" → Backend çalışmıyor
- "Name or service not known" → URL yanlış
- Timeout → Backend yanıt vermiyor

## Troubleshooting

### Backend çalışmıyor:
```bash
cd backend
python main.py
# veya
docker-compose up
```

### Port 8000 kullanımda:
```bash
# Mac/Linux
lsof -i :8000

# Backend'i farklı portta çalıştır veya process'i durdur
```

### Import hatası (websockets):
```bash
pip install websockets
```

