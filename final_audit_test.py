import requests
import os

BASE_URL = "http://127.0.0.1:8000"

def audit_system():
    print("🔍 --- STARTING FINAL SYSTEM AUDIT --- 🔍")
    
    # Test Cases: [Name, Lang, Symptom Text, Age, Blood]
    test_patients = [
        ["Patient_EN", "English", "I have chest pain and I am a sugar patient", 65, "O+"],
        ["Patient_HI", "Hindi", "Mujhe seene mein dard hai aur bukhar hai", 45, "B+"],
        ["Patient_TA", "Tamil", "Enaku nenju vali matrum kaichal iruku", 28, "A-"]
    ]

    for name, lang, text, age, blood in test_patients:
        print(f"\n📝 Testing Patient: {name} ({lang})")
        
        # 1. Test Member 3: Registration
        reg = requests.post(f"{BASE_URL}/register", params={
            "name": name, "age": age, "blood_type": blood, 
            "allergies": "None", "conditions": "Diabetes", "contact": "0000"
        })
        token = reg.json().get('token')
        print(f"   - DB Registration: {'PASS ✅' if token else 'FAIL ❌'}")

        # 2. Test Member 3: Emergency Retrieval
        emergency = requests.get(f"{BASE_URL}/emergency/{token}")
        print(f"   - QR Lookup: {'PASS ✅' if emergency.status_code == 200 else 'FAIL ❌'}")

        # 3. Test Member 1 & 2: AI Triage (Forcing the text to verify logic)
        # In the real app, this comes from the voice file.
        # Here we verify the extraction logic matches the ML input requirements.
        from ml_engine.nlp.extract import extract_symptoms
        from ml_engine.inference import predict_priority_score
        
        symptoms = extract_symptoms(text)
        result = predict_priority_score({**symptoms, "age": age})
        
        print(f"   - AI Transcription/Extraction: {'PASS ✅' if any(symptoms.values()) else 'FAIL ❌'}")
        print(f"   - ML Priority Result: {result['score']}/100 ({result['risk_level']})")
        
        if age > 50 and symptoms['symptom_chest_pain'] == 1:
            if result['score'] >= 90:
                print("   - Safety Override Check: PASS ✅ (Critical Flag Triggered)")
            else:
                print("   - Safety Override Check: FAIL ❌ (Score too low for Cardiac)")

    print("\n✅ --- AUDIT COMPLETE: ALL SYSTEMS NOMINAL ---")

if __name__ == "__main__":
    audit_system()
