from ml_engine.nlp.extract import extract_symptoms
from ml_engine.inference import predict_priority_score

def run_acid_test(text, age, label):
    print(f"\n🧪 {label} Test: '{text}'")
    
    # 1. Test the Extractor (Member 2)
    symptoms = extract_symptoms(text)
    found = [k for k,v in symptoms.items() if v == 1]
    print(f"   Ears Found: {found}")
    
    # 2. Test the Brain (Member 1)
    result = predict_priority_score({**symptoms, "age": age})
    print(f"   Brain Result: Score {result['score']}, Risk {result['risk_level']}")
    
    if result['score'] >= 90 and "Chest" in label:
        print("   ✅ PASS: Red Flag correctly triggered!")
    elif len(found) > 0:
        print("   ✅ PASS: Synonyms correctly mapped!")
    else:
        print("   ❌ FAIL: Logic missed the keywords.")

if __name__ == "__main__":
    # Test 1: Messy Hindi-English Cardiac Case
    run_acid_test("My heart is heavy and I have seene mein dard", 55, "Hindi-English Chest Pain")
    
    # Test 2: Tamil-English Diabetic Fever Case
    run_acid_test("I am a sugar patient and have high kaichal", 30, "Tamil-English Diabetes/Fever")
    
    # Test 3: Slang Dizziness
    run_acid_test("Everything is spinning and I feel chakkar", 25, "Slang Dizziness")
