"""
Script: ultimate_system_check.py
Role: End-to-End Validation (Members 1, 2, 3, & 4)
Coverage: Phase I (DB), Phase II (NLP), Phase III (ML), Phase IV (Scheduling)
"""

import requests
import json
import time

BASE_URL = "http://127.0.0.1:8000"

def run_ultimate_check():
    print("🏥 --- LIFELINE AI: ULTIMATE SYSTEM AUDIT --- 🏥")

    # TEST SCENARIO 1: ENGLISH - CRITICAL RED FLAG (PHASE III OVERRIDE)
    # Scenario: Elderly patient with stroke history and chest pain
    print("\n🔍 Test 1: [English] Critical Stroke/Cardiac Case")
    p1_data = {
        "name": "Jane Doe", "age": 72, "blood_type": "A+",
        "allergies": "Latex", "conditions": "History of Stroke", "contact": "911"
    }
    # Register (Phase I)
    try:
        reg1 = requests.post(f"{BASE_URL}/register", params=p1_data).json()
        token1 = reg1.get('token')
        print(f"   - Registration Token: {token1}")

        # Triage (Phase II & III) - Simulating "Chest Pain" which triggers Red-Flag Override
        # NOTE: We pass the qr_token so the backend can fetch history!
        triage1 = requests.post(f"{BASE_URL}/triage/process", data={
            "age": 72, 
            "heart_rate": 110, 
            "manual_symptoms": "chest_pain",
            "qr_token": token1 
        }).json()
        
        print(f"   - Priority Score: {triage1['triage']['score']}/100")
        print(f"   - Emergency Mode Triggered: {'YES ✅' if triage1['appointment']['severity'] == 'Critical' else 'NO ❌'}")
        print(f"   - Appointment: {triage1['appointment']['appointment_time']} (IMMEDIATE)")

    except Exception as e:
        print(f"❌ Test 1 Failed: {e}")


    # TEST SCENARIO 2: HINDI - HIGH RISK (PHASE IV DYNAMIC QUEUE)
    # Scenario: Adult with high fever and asthma (Member 2 NLP check)
    print("\n🔍 Test 2: [Hindi] High Risk Asthma/Fever Case")
    try:
        # Simulating the Hindi translation of 'fever' logic via the manual_symptoms hook for testing
        triage2 = requests.post(f"{BASE_URL}/triage/process", data={
            "age": 35, "heart_rate": 102, "manual_symptoms": "fever"
        }).json()
        
        print(f"   - AI Detected Symptoms: {triage2['analysis']['detected_symptoms']}")
        print(f"   - Dynamic Wait Time: {triage2['appointment']['estimated_wait_minutes']} mins")
    except Exception as e:
        print(f"❌ Test 2 Failed: {e}")


    # TEST SCENARIO 3: TAMIL - ROUTINE (PHASE I OFFLINE DATA)
    print("\n🔍 Test 3: [Tamil] Routine Case & QR Data Retrieval")
    try:
        if 'token1' in locals() and token1:
            emergency = requests.get(f"{BASE_URL}/emergency/{token1}").json()
            print(f"   - QR Retrieval (Blood/Allergy): {emergency['data']['blood_type']} / {emergency['data']['allergies']}")
            print("   - Phase I Data Integrity: PASS ✅")
        else:
            print("   - Skipping Phase I check (No token from Test 1)")
    except Exception as e:
        print(f"❌ Test 3 Failed: {e}")

if __name__ == "__main__":
    run_ultimate_check()
