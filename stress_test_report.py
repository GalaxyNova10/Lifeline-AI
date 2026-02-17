from ml_engine.nlp.pipeline import process_voice_note
from ml_engine.inference import predict_priority_score
import os

def run_stress_test(filename, lang):
    print(f"\n--- 🧪 TESTING: {lang} ---")
    path = f"ml_engine/nlp/{filename}"
    
    if not os.path.exists(path):
        print(f"⚠️ Missing: {filename}. Please record a messy phrase in {lang}!")
        return

    # 1. NLP Phase
    nlp = process_voice_note(path)
    # 2. ML Phase (Simulate an elderly patient to test Red Flags)
    ml = predict_priority_score({**nlp['symptoms'], "age": 60}) 

    print(f"  Result -> Transcription: {nlp['transcribed_text']}")
    # Correctly extracting keys where value is 1
    found_symptoms = [k for k,v in nlp['symptoms'].items() if v == 1]
    print(f"  Result -> Symptoms Found: {found_symptoms}")
    print(f"  Result -> Final Priority: {ml['score']}/100 ({ml['risk_level']})")

if __name__ == "__main__":
    # Expecting files: messy_en.wav, messy_hi.wav, messy_ta.wav
    tests = [("messy_en.wav", "English"), ("messy_hi.wav", "Hindi"), ("messy_ta.wav", "Tamil")]
    for f, l in tests:
        run_stress_test(f, l)
