import asyncio
import pytest
import httpx
import websockets
import json
import base64
import numpy as np
import cv2
import time
import uuid

BASE_URL = "http://127.0.0.1:8000"
WS_URL = "ws://127.0.0.1:8000/vitals/heartrate/ws"

# Test Data
USER_DATA_EN = {
    "name": "Test User QA",
    "age": 25,
    "blood_type": "A+",
    "allergies": "None",
    "conditions": "None",
    "contact": "1234567890"
}

# UTF-8 Stress Test Data
USER_DATA_UTF8 = {
    "name": "टेस यूज़र (Hindi)",
    "age": 30,
    "blood_type": "B+", 
    "allergies": "मूंगफली", # Peanuts in Hindi
    "conditions": " मधुमेह", # Diabetes in Hindi
    "contact": "9876543211"
}

@pytest.mark.asyncio
async def test_01_health_check():
    """Verify backend is running."""
    async with httpx.AsyncClient() as client:
        response = await client.get(f"{BASE_URL}/")
        assert response.status_code == 200
        assert response.json()["status"] == "online"

@pytest.mark.asyncio
async def test_02_register_user_utf8():
    """Verify registration handles UTF-8 characters without crashing DB."""
    async with httpx.AsyncClient() as client:
        # Note: API expects query params for registration
        response = await client.post(f"{BASE_URL}/register", params=USER_DATA_UTF8)
        assert response.status_code == 200
        data = response.json()
        assert "token" in data
        assert len(data["token"]) == 8
        print(f"\n✅ UTF-8 Registration Token: {data['token']}")
        return data["token"]

@pytest.mark.asyncio
async def test_03_rppg_websocket_flow():
    """Verify rPPG WebSocket connection and processing."""
    # Generate dummy frame (noise)
    frame = np.random.randint(0, 255, (480, 640, 3), dtype=np.uint8)
    _, buffer = cv2.imencode('.jpg', frame)
    jpg_as_text = base64.b64encode(buffer).decode('utf-8')
    
    async with httpx.AsyncClient() as client:
        reg = await client.post(f"{BASE_URL}/register", params=USER_DATA_EN)
        token = reg.json()["token"]

    async with websockets.connect(f"{WS_URL}?token={token}") as websocket:
        # Send 5 frames
        for i in range(5):
            await websocket.send(jpg_as_text)
            response = await websocket.recv()
            data = json.loads(response)
            assert "bpm" in data
            # BPM might be None initially as buffer fills
            print(f"Frame {i+1}: BPM={data['bpm']}")
            
        print("\n✅ WebSocket rPPG Flow Passed")

@pytest.mark.asyncio
async def test_04_vitals_post_stateless():
    """Verify stateless POST endpoint for Vitals."""
    # Register temp user to get token
    async with httpx.AsyncClient() as client:
        reg = await client.post(f"{BASE_URL}/register", params=USER_DATA_EN)
        token = reg.json()["token"]
        
        # Create dummy frame
        frame = np.zeros((100, 100, 3), dtype=np.uint8)
        _, buffer = cv2.imencode('.jpg', frame)
        
        files = {"file": ("test.jpg", buffer.tobytes(), "image/jpeg")}
        data = {"token": token}
        
        response = await client.post(f"{BASE_URL}/vitals/process_frame", data=data, files=files)
        assert response.status_code == 200
        result = response.json()
        assert "bpm" in result
        print(f"\n✅ Vitals POST Stateless Passed (Token: {token})")

@pytest.mark.asyncio
async def test_05_database_bpm_persistence():
    """
    CRITICAL: Verify that the BPM reading is actually stored in the DB.
    This test manually seeds the DB because we can't easily generate a valid face image for rPPG in a test.
    """
    import sqlite3
    
    # 1. Register
    async with httpx.AsyncClient() as client:
        reg = await client.post(f"{BASE_URL}/register", params=USER_DATA_EN)
        token = reg.json()["token"]
        
        # 2. Manually Seed DB (Simulate a successful rPPG write)
        # We do this because generating a face-detectable image programmatically is hard
        conn = sqlite3.connect("lifeline_identity.db")
        cursor = conn.cursor()
        cursor.execute("INSERT INTO vitals (user_token, bpm) VALUES (?, ?)", (token, 75.5))
        conn.commit()
        conn.close()
        
        # 3. Fetch User Record to check if BPM/Vitals are logged
        resp = await client.get(f"{BASE_URL}/emergency/{token}")
        assert resp.status_code == 200
        data = resp.json()["data"]
        
        # WEAKNESS CHECK: Does the data contain 'heart_rate'?
        if "heart_rate" not in data:
             pytest.fail("❌ Database Weakness: BPM data is NOT being persisted/retrieved in the User/Emergency record!")
        
        assert data["heart_rate"] == 75.5
        print("\n✅ Database Persistence Passed (Seeded)")

if __name__ == "__main__":
    # Manual runner if pytest not used directly
    # But usually ran via `pytest test_suite_comprehensive.py`
    pass
