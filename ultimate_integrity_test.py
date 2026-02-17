"""
Script: ultimate_integrity_test.py
Purpose: Stress test the entire backend for language, logic, and safety holes.
"""
import requests

BASE_URL = "http://127.0.0.1:8000"

def run_integrity_audit():
    print("🚀 --- VITAL SYNC AI: FINAL INTEGRITY AUDIT --- 🚀")

    # 1. Test Linguistic Resilience (Hindi/Tamil/Slang)
    print("\n🌍 Testing Multilingual NLP Integrity...")
    nlp_scenarios = [
        {"lang": "Hindi-English", "text": "Mujhe seene mein dard hai", "expected": "symptom_chest_pain"},
        {"lang": "Tamil-English", "text": "Enaku nenju vali iruku", "expected": "symptom_chest_pain"},
        {"lang": "Colloquial", "text": "I am a sugar patient and dizzy", "expected": "history_diabetes"}
    ]
    
    # Simulating internal logic check
    from ml_engine.nlp.extract import extract_symptoms
    for case in nlp_scenarios:
        res = extract_symptoms(case['text'])
        status = "✅ PASS" if res.get(case['expected']) == 1 else "❌ FAIL (Hole Found)"
        print(f"   - {case['lang']} Test: {status}")

    # 2. Test Phase III Safety Override (Red-Flag Check)
    print("\n🚨 Testing Red-Flag Override (Emergency Mode)...")
    # Scenario: Elderly patient (75) mentioning "Chest Pain"
    p_data = {"age": 75, "heart_rate": 115, "manual_symptoms": "chest_pain"}
    r = requests.post(f"{BASE_URL}/triage/process", data=p_data).json()
    
    if r['appointment']['severity'] == "Critical" and r['triage']['score'] >= 99:
        print("   - Cardiac Safety Logic: ✅ PASS (Bypassed Queue)")
    else:
        print("   - Cardiac Safety Logic: ❌ FAIL (Safety Hole Detected)")

    # 3. Test Phase IV Dynamic Scheduling Accuracy
    print("\n📅 Testing Dynamic Queue Precision...")
    # Scenario: Minor symptoms (Fever)
    low_risk = requests.post(f"{BASE_URL}/triage/process", data={"age": 25, "heart_rate": 72, "manual_symptoms": "fever"}).json()
    wait_time = low_risk['appointment']['estimated_wait_minutes']
    
    if wait_time >= 120:
        print(f"   - Routine Queue Logic: ✅ PASS ({wait_time} mins wait)")
    else:
        print(f"   - Routine Queue Logic: ❌ FAIL (Wait time too short for low risk)")

if __name__ == "__main__":
    run_integrity_audit()
