# Docker Backend Kullanım Prompt'u

## Backend'i Docker ile Çalıştırma

Backend server'ı Docker ile kolayca çalıştırabilirsiniz. İşte adım adım talimatlar:

### 1. Docker'ın Yüklü Olduğundan Emin Olun

Docker'ın yüklü olduğunu kontrol edin:
```bash
docker --version
docker-compose --version
```

### 2. Backend Klasörüne Gidin

```bash
cd backend
```

### 3. Docker Compose ile Başlatın (En Kolay Yöntem)

```bash
docker-compose up -d
```

`-d` parametresi container'ı arka planda (detached mode) çalıştırır.

### 4. Server'ın Çalıştığını Kontrol Edin

Tarayıcıda veya terminalde:
```bash
curl http://localhost:8000/health
```

Ya da tarayıcıda açın: `http://localhost:8000`

### 5. Logları Görüntüleme

```bash
docker-compose logs -f
```

### 6. Server'ı Durdurma

```bash
docker-compose down
```

---

## Alternatif: Manuel Docker Komutları

### Image Build Etme

```bash
cd backend
docker build -t health-backend .
```

### Container Çalıştırma

```bash
docker run -d -p 8000:8000 --name health_backend health-backend
```

### Container Kontrol Komutları

```bash
# Çalışan container'ları listele
docker ps

# Logları görüntüle
docker logs -f health_backend

# Container'ı durdur
docker stop health_backend

# Container'ı başlat (durdurulmuşsa)
docker start health_backend

# Container'ı kaldır
docker rm health_backend

# Image'ı sil
docker rmi health-backend
```

---

## Android Uygulamanızda Kullanım

### Emülatör için:
```
ws://10.0.2.2:8000/ws/phone
```

### Fiziksel cihaz için:
1. Bilgisayarınızın yerel IP adresini öğrenin:
   - Mac/Linux: `ifconfig` veya `ip addr`
   - Windows: `ipconfig`
   
2. Örnek: `ws://192.168.1.100:8000/ws/phone`

### Önemli Notlar:

- Docker container çalışırken port 8000 açık olmalı
- Fiziksel cihazlar için bilgisayar ve telefon aynı WiFi ağında olmalı
- Firewall ayarlarını kontrol edin
- Docker container'ın dış ağa erişimine izin verildiğinden emin olun

---

## Troubleshooting

### Port 8000 zaten kullanımda hatası:
```bash
# Port 8000'i kullanan process'i bulun
lsof -i :8000  # Mac/Linux
netstat -ano | findstr :8000  # Windows

# Docker compose dosyasında portu değiştirebilirsiniz:
# ports:
#   - "8001:8000"  # 8001 portunu kullan
```

### Container çalışmıyor:
```bash
# Logları kontrol edin
docker logs health_backend

# Container'ı yeniden başlatın
docker restart health_backend
```

### Image yeniden build etmek:
```bash
docker-compose build --no-cache
docker-compose up -d
```

---

## Hızlı Başlangıç Özeti

```bash
# 1. Backend klasörüne git
cd backend

# 2. Docker compose ile başlat
docker-compose up -d

# 3. Kontrol et
curl http://localhost:8000/health

# 4. Logları izle (opsiyonel)
docker-compose logs -f

# 5. Durdur (işiniz bittiğinde)
docker-compose down
```

Hepsi bu kadar! Backend'iniz Docker'da çalışıyor. 🐳

