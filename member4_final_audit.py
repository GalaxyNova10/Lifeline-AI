import requests

BASE_URL = "http://127.0.0.1:8000"

def run_final_audit():
    print("🏥 --- LIFELINE AI: FINAL BACKEND AUDIT --- 🏥")

    # Simulation: A High-Risk Case (Fever + Asthma History)
    # Matching the Phase IV Table in the documentation
    test_case = {
        "age": 35,
        "heart_rate": 105,
        "manual_symptoms": "fever"
    }
    
    # Simulate Member 2's audio: "I am having trouble breathing"
    # (Using your existing test_en.wav for this simulation)
    # Note: Ensure test_en.wav exists in ml_engine/nlp/ folder from previous steps
    try:
        with open("ml_engine/nlp/test_en.wav", "rb") as f:
            files = {"voice_note": ("test_en.wav", f, "audio/wav")}
            print("\nStep 1: Processing High-Risk Patient (Fever + Shortness of Breath)...")
            r = requests.post(f"{BASE_URL}/triage/process", data=test_case, files=files)
        
        if r.status_code == 200:
            result = r.json()
            
            print("\n--- AUDIT RESULTS ---")
            print(f"✅ AI Transcription: {result['analysis']['transcription']}")
            print(f"✅ AI Risk Level: {result['triage']['risk_level']} (Score: {result['triage']['score']})")
            print(f"✅ Priority Status: {result['appointment']['severity']}")
            print(f"✅ APPOINTMENT SLOT: {result['appointment']['appointment_time']}")
            print(f"✅ ESTIMATED WAIT: {result['appointment']['estimated_wait_minutes']} minutes")
        else:
            print(f"\n❌ Error: {r.status_code} - {r.text}")
            
    except FileNotFoundError:
        print("\n❌ Error: 'ml_engine/nlp/test_en.wav' not found. Please verify the file exists.")

if __name__ == "__main__":
    run_final_audit()
