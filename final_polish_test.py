import requests

BASE_URL = "http://127.0.0.1:8000"

def final_polish_check():
    print("💎 --- VITAL SYNC AI: FINAL POLISH AUDIT --- 💎")

    # Test: Load Balancing for Cardiac Case 
    print("\n🔍 Testing Load Balancing (Cardiac Condition)...")
    payload = {
        "age": 60,
        "heart_rate": 130, # Tachycardia check [cite: 19]
        "manual_symptoms": "chest_pain"
    }
    try:
        r = requests.post(f"{BASE_URL}/triage/process", data=payload).json()
        
        print(f"   - Predicted Score: {r['triage']['score']}")
        print(f"   - Recommendation: {r['appointment']['recommendation']}")
        print(f"   - Status: {'✅ SUCCESS' if 'Cardiac' in r['appointment']['recommendation'] else '❌ FAIL'}")

        # Test: Privacy/Data Security 
        print("\n🔍 Testing Data Privacy Masking...")
        if "surgical_history" not in r:
            print("   - PII Masking: ✅ PASS (Sensitive data not leaked in triage)")
        else:
            print("   - PII Masking: ❌ FAIL (Security Hole)")
    except Exception as e:
        print(f"❌ Error during test: {e}")

if __name__ == "__main__":
    final_polish_check()
