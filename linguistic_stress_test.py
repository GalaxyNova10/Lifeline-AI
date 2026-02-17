from ml_engine.nlp.extract import extract_symptoms

def test_linguistic_resilience():
    print("🌍 Testing Multilingual Medical Context...")
    
    test_cases = [
        "I am having seene mein dard", # Hindi-English
        "Nenju vali and high fever",     # Tamil-English
        "Sugar patient with dizzy feeling" # Colloquial English
    ]
    
    for text in test_cases:
        symptoms = extract_symptoms(text)
        found = [k for k, v in symptoms.items() if v == 1]
        print(f"Input: '{text}' -> Detected: {found}")
        if not found:
            print("❌ HOLE FOUND: System missed the symptom!")
        else:
            print("✅ PASS")

if __name__ == "__main__":
    test_linguistic_resilience()
