from fastapi import APIRouter, WebSocket, WebSocketDisconnect, UploadFile, File, Form, HTTPException, Query
from backend.rppg_engine import RPPGHeartRateEngine
from backend.database.auth import log_vital, get_user_by_token
import cv2
import numpy as np
import base64
import shutil
import os

router = APIRouter(prefix="/vitals", tags=["Vitals"])

# Global state for simple session management in MVP
# In production, use Redis or mapped memory
active_engines = {} 

@router.websocket("/heartrate/ws")
async def websocket_heartrate(websocket: WebSocket, token: str = Query(...)):
    """
    WebSocket endpoint for real-time heart rate monitoring.
    Expects: Base64 encoded image strings or raw bytes.
    Returns: JSON {"bpm": float|None}
    """
    # 1. Security: Validate Token
    user = get_user_by_token(token)
    if not user:
        # Close with policy violation code if invalid
        print(f"❌ WebSocket Auth Failed: Invalid Token '{token}'")
        await websocket.close(code=4001) 
        return

    await websocket.accept()
    print(f"✅ WebSocket Connected: {user['name']} ({token})")
    
    # Create an engine instance for this connection
    engine = RPPGHeartRateEngine()
    
    try:
        while True:
            # Receive data (text base64 or bytes)
            data = await websocket.receive_text()
            
            # Handle Base64 header if present
            if "," in data:
                data = data.split(",")[1]
            
            # Decode image
            try:
                image_bytes = base64.b64decode(data)
                nparr = np.frombuffer(image_bytes, np.uint8)
                frame = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
            except Exception as e:
                print(f"Frame decode error: {e}")
                continue

            if frame is None:
                continue

            # Process frame
            bpm = engine.process_frame(frame)
            
            # Send result
            response = {"bpm": bpm}
            await websocket.send_json(response)
            
            # Log to DB if BPM is valid
            if bpm is not None:
                # We don't have the token in WS yet. 
                # Ideally, WS should authenticate. 
                # For now, skipping DB log in unnamed WS session.
                pass
            
    except WebSocketDisconnect:
        print("Client disconnected from Vitals WS")
    except Exception as e:
        print(f"Vitals WS Error: {e}")
        try:
            await websocket.close()
        except:
            pass

@router.post("/process_frame")
async def process_frame_post(token: str = Form(...), file: UploadFile = File(...)):
    """
    POST endpoint for frame-by-frame processing (Stateless-ish).
    Uses 'token' to maintain state across requests.
    """
    # Get or create engine for this user
    if token not in active_engines:
        active_engines[token] = RPPGHeartRateEngine()
    
    engine = active_engines[token]
    
    # Read file
    try:
        contents = await file.read()
        nparr = np.frombuffer(contents, np.uint8)
        frame = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    except Exception as e:
         raise HTTPException(status_code=400, detail=f"Invalid image data: {e}")

    if frame is None:
        raise HTTPException(status_code=400, detail="Could not decode image")

    # Process
    bpm = engine.process_frame(frame)
    
    # Log to DB
    if bpm is not None:
        log_vital(token, bpm)
    
    return {"status": "success", "bpm": bpm}

@router.delete("/session/{token}")
async def clear_session(token: str):
    """Clear the rPPG engine session for a user"""
    if token in active_engines:
        del active_engines[token]
        return {"status": "cleared"}
    return {"status": "not_found"}
