"""
Script: final_system_test.py
Role: Full-Stack Integration Tester (Member 1 + Member 2)
Description: Verifies that Audio -> Text -> Symptoms -> Priority Score works for all 3 languages.
"""

from ml_engine.nlp.pipeline import process_voice_note
from ml_engine.inference import predict_priority_score
import os

def run_integration_test(audio_filename, language_label):
    print(f"\n--- 🧪 TESTING LANGUAGE: {language_label} ---")
    file_path = f"ml_engine/nlp/{audio_filename}"
    
    if not os.path.exists(file_path):
        print(f"❌ Error: {audio_filename} not found in ml_engine/nlp/. Please record it!")
        return

    # 1. TEST MEMBER 2: NLP Pipeline
    print(f"👂 Step 1: Processing Voice Note...")
    nlp_result = process_voice_note(file_path)
    print(f"   Transcribed: '{nlp_result['transcribed_text']}'")
    print(f"   Extracted Symptoms: {nlp_result['symptoms']}")

    # 2. TEST MEMBER 1: ML Inference
    print(f"🧠 Step 2: Running ML Inference...")
    # We add a default age and vitals since the voice note only gives symptoms
    patient_payload = {**nlp_result['symptoms'], "age": 55, "heart_rate": 110} 
    ml_result = predict_priority_score(patient_payload)
    
    print(f"✅ FINAL RESULT:")
    print(f"   - Triage Score: {ml_result['score']}/100")
    print(f"   - Risk Level: {ml_result['risk_level']}")
    print(f"   - Predicted Condition: {ml_result['predicted_condition']}")

if __name__ == "__main__":
    # Test cases (You must record these and put them in ml_engine/nlp/)
    run_integration_test("test_en.wav", "ENGLISH") # "I have chest pain and fever"
    run_integration_test("test_hi.wav", "HINDI")   # "Mujhe seene mein dard hai aur bukhar hai"
    run_integration_test("test_ta.wav", "TAMIL")   # "Enaku nenju vali matrum kaichal iruku"
