import requests
import time

BASE_URL = "http://127.0.0.1:8000"

def run_demo():
    print("🏥 --- LIFELINE AI: FULL-STACK DEMO --- 🏥")

    # 1. Register a Patient
    print("\nStep 1: Registering Patient 'John Christo Rosario'...")
    reg_params = {
        "name": "John Christo Rosario",
        "age": 21,
        "blood_type": "O+",
        "allergies": "Penicillin",
        "conditions": "Asthma",
        "contact": "9876543210"
    }
    # Note: Using query params as the endpoint expects them, not JSON body for this specific implementation
    r = requests.post(f"{BASE_URL}/register", params=reg_params)
    if r.status_code == 200:
        user_data = r.json()
        token = user_data['token']
        print(f"✅ Success! User Token: {token}")
    else:
        print(f"❌ Registration Failed: {r.text}")
        return

    # 2. Test Emergency Scan
    print(f"\nStep 2: Simulating Emergency QR Scan for {token}...")
    r = requests.get(f"{BASE_URL}/emergency/{token}")
    if r.status_code == 200:
        print(f"✅ Paramedic View: {r.json()['data']}")
    else:
        print(f"❌ Emergency Lookup Failed: {r.text}")

    # 3. Test AI Triage
    print("\nStep 3: Sending Voice Note ('I have chest pain and fever')...")
    # Using your existing test file
    try:
        with open("ml_engine/nlp/test_en.wav", "rb") as f:
            files = {"file": ("test_en.wav", f, "audio/wav")}
            r = requests.post(f"{BASE_URL}/triage/voice", files=files)
        
        if r.status_code == 200:
            result = r.json()
            print(f"✅ AI Transcription: {result['transcription']}")
            print(f"✅ AI Triage Score: {result['analysis']['score']}/100")
            print(f"✅ Risk Level: {result['analysis']['risk_level']}")
        else:
            print(f"❌ Triage Failed: {r.text}")
    except FileNotFoundError:
        print("❌ Audio file 'ml_engine/nlp/test_en.wav' not found.")

    # 4. Test Vitals (Heart Rate) - Member 1 Integration
    print("\nStep 4: Testing Vitals API (rPPG Heart Rate)...")
    try:
        import cv2
        import numpy as np
        
        # Capture a single frame
        cap = cv2.VideoCapture(0)
        ret, frame = cap.read()
        cap.release()
        
        if ret:
            # Encode frame to JPEG
            _, img_encoded = cv2.imencode('.jpg', frame)
            files = {"file": ("frame.jpg", img_encoded.tobytes(), "image/jpeg")}
            data = {"token": token} # Use the token from Step 1
            
            t0 = time.time()
            r = requests.post(f"{BASE_URL}/vitals/process_frame", data=data, files=files)
            dt = time.time() - t0
            
            if r.status_code == 200:
                result = r.json()
                bpm = result.get('bpm')
                print(f"✅ Vitals Processed in {dt:.2f}s")
                if bpm:
                    print(f"❤️ Heart Rate: {bpm:.1f} BPM")
                else:
                    print(f"⚠️ Heart Rate: Buffer filling / Detecting face...")
            else:
                print(f"❌ Vitals API Failed: {r.text}")
        else:
            print("⚠️ Could not capture webcam frame for test.")
            
    except ImportError:
        print("⚠️ OpenCV not found, skipping local camera test.")
    except Exception as e:
        print(f"❌ Vitals Test Diagnostic Error: {e}")

if __name__ == "__main__":
    run_demo()
