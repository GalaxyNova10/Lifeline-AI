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

if __name__ == "__main__":
    run_demo()
