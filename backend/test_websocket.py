"""
WebSocket endpoint'lerini test etmek için test scripti
Watch ve Phone endpoint'lerini test eder
"""

import asyncio
import websockets
import json
from datetime import datetime

# Backend server URL'i
WS_WATCH_URL = "ws://localhost:8000/ws/watch"
WS_PHONE_URL = "ws://localhost:8000/ws/phone"


async def test_watch_sender():
    """Watch endpoint'ine bağlanıp veri gönderir"""
    print("🔵 Watch cihazı olarak bağlanılıyor...")
    
    try:
        async with websockets.connect(WS_WATCH_URL) as websocket:
            print("✅ Watch bağlantısı başarılı!")
            
            # Test verileri gönder
            for i in range(5):
                test_data = {
                    "heart_rate": 70 + (i * 2),
                    "steps": 1000 + (i * 100),
                    "timestamp": datetime.now().isoformat() + "Z",
                    "watch_id": "test_watch_1"
                }
                
                await websocket.send(json.dumps(test_data))
                print(f"📤 Veri gönderildi: HR={test_data['heart_rate']}, Steps={test_data['steps']}")
                
                # Yanıt al (varsa)
                try:
                    response = await asyncio.wait_for(websocket.recv(), timeout=1.0)
                    print(f"📥 Yanıt: {response}")
                except asyncio.TimeoutError:
                    pass
                
                await asyncio.sleep(2)  # 2 saniye bekle
            
            print("✅ Watch testi tamamlandı!")
            
    except Exception as e:
        print(f"❌ Watch bağlantı hatası: {e}")


async def test_phone_receiver():
    """Phone endpoint'ine bağlanıp veri alır"""
    print("\n🟢 Phone uygulaması olarak bağlanılıyor...")
    
    try:
        async with websockets.connect(WS_PHONE_URL) as websocket:
            print("✅ Phone bağlantısı başarılı! Veri bekleniyor...")
            
            # 15 saniye boyunca veri dinle
            timeout = 15
            start_time = asyncio.get_event_loop().time()
            
            while (asyncio.get_event_loop().time() - start_time) < timeout:
                try:
                    message = await asyncio.wait_for(websocket.recv(), timeout=1.0)
                    data = json.loads(message)
                    print(f"📥 Veri alındı: HR={data.get('heart_rate')}, Steps={data.get('steps')}, Timestamp={data.get('timestamp')}")
                except asyncio.TimeoutError:
                    print("⏳ Hala bekleniyor... (Ctrl+C ile çıkış)")
                    continue
                except json.JSONDecodeError:
                    print(f"📥 Ham mesaj: {message}")
            
            print("✅ Phone testi tamamlandı!")
            
    except KeyboardInterrupt:
        print("\n⏹️  Test kullanıcı tarafından durduruldu")
    except Exception as e:
        print(f"❌ Phone bağlantı hatası: {e}")


async def test_full_flow():
    """Tam akış testi: Watch gönderir, Phone alır"""
    print("=" * 50)
    print("🚀 TAM AKIŞ TESTİ BAŞLIYOR")
    print("=" * 50)
    
    # Phone'u önce başlat (veri almaya hazır olsun)
    phone_task = asyncio.create_task(test_phone_receiver())
    
    # 2 saniye bekle (phone bağlansın)
    await asyncio.sleep(2)
    
    # Watch'ı başlat (veri göndersin)
    watch_task = asyncio.create_task(test_watch_sender())
    
    # Her iki task'ın da bitmesini bekle
    await asyncio.gather(watch_task, phone_task, return_exceptions=True)


async def test_simple():
    """Basit test: Sadece watch gönderir"""
    await test_watch_sender()


async def test_receive_only():
    """Sadece phone receiver testi"""
    await test_phone_receiver()


if __name__ == "__main__":
    import sys
    
    print("""
    🔧 WebSocket Test Scripti
    ========================
    
    Kullanım:
    1. Basit test (sadece watch gönderir):
       python test_websocket.py watch
       
    2. Sadece phone testi (veri bekler):
       python test_websocket.py phone
       
    3. Tam akış testi (watch gönderir, phone alır):
       python test_websocket.py full
       
    Varsayılan: full test
    """)
    
    test_type = sys.argv[1] if len(sys.argv) > 1 else "full"
    
    try:
        if test_type == "watch":
            asyncio.run(test_simple())
        elif test_type == "phone":
            asyncio.run(test_receive_only())
        elif test_type == "full":
            asyncio.run(test_full_flow())
        else:
            print(f"❌ Bilinmeyen test tipi: {test_type}")
            print("Kullanım: python test_websocket.py [watch|phone|full]")
    except KeyboardInterrupt:
        print("\n⏹️  Test durduruldu")

