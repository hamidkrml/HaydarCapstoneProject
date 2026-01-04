"""
FastAPI WebSocket Server for Real-time Health Data Transfer
Watch devices send data to /ws/watch endpoint
Mobile apps receive data from /ws/phone endpoint
"""

from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from typing import Set, Dict
import json
import asyncio
from datetime import datetime
from pydantic import BaseModel

app = FastAPI(title="Health Data WebSocket Server")

# CORS middleware for Flutter apps
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Data model for health data
class HealthData(BaseModel):
    heart_rate: int
    steps: int
    timestamp: str


# Store connected clients
watch_clients: Set[WebSocket] = set()
phone_clients: Set[WebSocket] = set()

# Store latest health data
latest_health_data: Dict[str, HealthData] = {}


async def broadcast_to_phones(data: dict):
    """Broadcast health data to all connected phone clients"""
    if phone_clients:
        message = json.dumps(data)
        disconnected_clients = []
        for client in phone_clients:
            try:
                await client.send_text(message)
            except Exception as e:
                print(f"Error sending to phone client: {e}")
                disconnected_clients.append(client)
        
        # Remove disconnected clients
        for client in disconnected_clients:
            phone_clients.discard(client)


@app.websocket("/ws/watch")
async def websocket_watch(websocket: WebSocket):
    """
    WebSocket endpoint for watch devices
    Watch devices connect here and send health data
    """
    await websocket.accept()
    watch_clients.add(websocket)
    print(f"Watch device connected. Total watches: {len(watch_clients)}")
    
    try:
        while True:
            # Receive data from watch
            data = await websocket.receive_text()
            try:
                # Parse JSON data
                health_data = json.loads(data)
                
                # Validate data structure
                if "heart_rate" in health_data and "steps" in health_data:
                    # Store latest data (optional: can store per watch ID)
                    watch_id = health_data.get("watch_id", "default")
                    latest_health_data[watch_id] = health_data
                    
                    # Broadcast to all phone clients
                    await broadcast_to_phones(health_data)
                    
                    print(f"Received from watch: HR={health_data.get('heart_rate')}, Steps={health_data.get('steps')}")
                else:
                    await websocket.send_text(json.dumps({
                        "error": "Invalid data format. Required: heart_rate, steps"
                    }))
            except json.JSONDecodeError:
                await websocket.send_text(json.dumps({
                    "error": "Invalid JSON format"
                }))
    
    except WebSocketDisconnect:
        watch_clients.discard(websocket)
        print(f"Watch device disconnected. Total watches: {len(watch_clients)}")
    except Exception as e:
        print(f"Error in watch connection: {e}")
        watch_clients.discard(websocket)


@app.websocket("/ws/phone")
async def websocket_phone(websocket: WebSocket):
    """
    WebSocket endpoint for mobile applications
    Mobile apps connect here to receive real-time health data
    """
    await websocket.accept()
    phone_clients.add(websocket)
    print(f"Phone connected. Total phones: {len(phone_clients)}")
    
    # Send latest data immediately upon connection (if available)
    if latest_health_data:
        for watch_id, data in latest_health_data.items():
            try:
                await websocket.send_text(json.dumps(data))
            except Exception as e:
                print(f"Error sending initial data: {e}")
    
    try:
        # Keep connection alive and handle any incoming messages (optional)
        while True:
            data = await websocket.receive_text()
            # Phone can send heartbeat or other messages
            # For now, just echo back (optional)
            try:
                message = json.loads(data)
                if message.get("type") == "ping":
                    await websocket.send_text(json.dumps({"type": "pong"}))
            except:
                pass
    
    except WebSocketDisconnect:
        phone_clients.discard(websocket)
        print(f"Phone disconnected. Total phones: {len(phone_clients)}")
    except Exception as e:
        print(f"Error in phone connection: {e}")
        phone_clients.discard(websocket)


@app.get("/")
async def root():
    """Health check endpoint"""
    return {
        "status": "running",
        "connected_watches": len(watch_clients),
        "connected_phones": len(phone_clients),
        "latest_data_count": len(latest_health_data)
    }


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

