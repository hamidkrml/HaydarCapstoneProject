# WearOS Watch App - Health Data Sender

Android WearOS için Flutter watch uygulaması. Saat sensörlerinden veri alıp backend server'a gönderir.

## Özellikler

- ✅ WearOS uyumlu Flutter uygulaması
- ✅ WebSocket ile backend'e bağlanma
- ✅ Kalp atışı ve adım sayısı gösterimi
- ✅ Simüle edilmiş sensör verileri (gerçek sensörler için hazır)
- ✅ Başlat/Durdur kontrolü
- ✅ WearOS için optimize edilmiş kompakt UI

## Gereksinimler

- Flutter SDK (3.0+)
- Android Studio
- WearOS emulator veya fiziksel WearOS cihazı
- Backend server çalışıyor olmalı

## Kurulum

1. Flutter bağımlılıklarını yükleyin:
```bash
cd watch_app
flutter pub get
```

2. Android yapılandırmasını kontrol edin:
- `android/app/build.gradle` dosyasında `minSdkVersion 28` (WearOS için minimum)
- `AndroidManifest.xml` dosyasında gerekli izinler

## Çalıştırma

### Emulator ile:

1. WearOS emulator başlatın (Android Studio > Tools > Device Manager)
2. Uygulamayı çalıştırın:
```bash
flutter run
```

### Fiziksel Cihaz ile:

1. WearOS saati USB ile bağlayın veya WiFi debugging kullanın
2. Developer options'ı açın (Settings > System > About > Build Number'a 7 kez dokunun)
3. ADB debugging'i açın
4. Uygulamayı çalıştırın:
```bash
flutter run
```

## Yapılandırma

### Backend URL

Varsayılan URL: `ws://10.0.2.2:8000/ws/watch` (emulator için)

- **Emulator için**: `ws://10.0.2.2:8000/ws/watch`
- **Fiziksel cihaz için**: Bilgisayarınızın yerel IP'si (örn: `ws://192.168.1.100:8000/ws/watch`)

URL'i uygulama içinde değiştirebilirsiniz.

## Gerçek Sensör Entegrasyonu

Şu anda uygulama simüle edilmiş veri kullanıyor. Gerçek sensörler için:

### 1. Health Services API (WearOS 3.0+)

WearOS 3.0+ için Google Health Services API kullanılabilir.

### 2. Platform Channels

Flutter'dan native Android koduna platform channels ile erişim:

1. `android/app/src/main/kotlin/` altında sensör okuma kodu yazın
2. Flutter'dan platform channel ile çağırın
3. Kalp atışı için: `SensorManager` veya Health Services API
4. Adımlar için: `StepCounterSensor` veya Health Services API

### 3. Örnek Platform Channel Kodu

```kotlin
// MainActivity.kt
class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.watch_app/sensors"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getHeartRate" -> {
                        // Sensör okuma kodu
                        result.success(heartRateValue)
                    }
                    "getSteps" -> {
                        // Adım sayma kodu
                        result.success(stepsValue)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
```

### 4. Flutter Tarafı

```dart
import 'package:flutter/services.dart';

class SensorService {
  static const platform = MethodChannel('com.example.watch_app/sensors');
  
  static Future<int> getHeartRate() async {
    try {
      final result = await platform.invokeMethod('getHeartRate');
      return result as int;
    } catch (e) {
      return 0;
    }
  }
  
  static Future<int> getSteps() async {
    try {
      final result = await platform.invokeMethod('getSteps');
      return result as int;
    } catch (e) {
      return 0;
    }
  }
}
```

## İzinler

Uygulama aşağıdaki izinleri kullanır:

- `INTERNET` - WebSocket bağlantısı için
- `ACCESS_NETWORK_STATE` - Ağ durumunu kontrol için
- `BODY_SENSORS` - Kalp atışı sensörü için (gerçek sensörler için)
- `ACTIVITY_RECOGNITION` - Adım sayma için (gerçek sensörler için)

## Notlar

- Bu uygulama şu anda simüle edilmiş veri kullanıyor
- Gerçek sensör entegrasyonu için native Android kodu gereklidir
- WearOS 3.0+ için Health Services API önerilir
- Battery optimization önemlidir - sürekli sensör okuma pil tüketir
- Permissions runtime'da istenmelidir (Android 6.0+)

## Sorun Giderme

### Uygulama çalışmıyor:
- Flutter doctor kontrol edin: `flutter doctor`
- Gradle sync yapın: Android Studio > File > Sync Project with Gradle Files

### Backend bağlantısı yok:
- Backend'in çalıştığından emin olun
- URL'i kontrol edin (emulator vs fiziksel cihaz)
- Firewall ayarlarını kontrol edin

### Sensör verileri yok:
- Şu anda simüle edilmiş veri kullanılıyor
- Gerçek sensörler için platform channel implementasyonu gerekli

## Lisans

Capstone projesi için geliştirilmiştir.
