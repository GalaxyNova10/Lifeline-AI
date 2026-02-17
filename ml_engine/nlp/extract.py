"""
Script: extract.py (v2 - Robust Edition)
Role: Medical Entity Extractor with Synonym Mapping
"""

def extract_symptoms(text):
    text = text.lower()
    
    # Expanded Dictionary to catch "messy" speech
    dictionary = {
        "symptom_chest_pain": ["chest", "heart pain", "heavy heart", "tightness", "seene mein dard", "nenju vali"],
        "symptom_shortness_of_breath": ["breath", "suffocat", "gasp", "saans", "moochu", "panting"],
        "symptom_dizziness": ["dizzy", "spinning", "chakkar", "thalaichitral", "faint", "unsteady"],
        "symptom_vomiting": ["vomit", "nausea", "ultee", "vaandhi", "sick to stomach"],
        "symptom_fever": ["fever", "bukhar", "kaichal", "temperature", "hot", "chills", "body heat"],
        "history_diabetes": ["diabetes", "diabetic", "sugar", "insulin", "sugar patient", "madhumegam"],
        "history_hypertension": ["hypertension", "blood pressure", "bp", "high pressure", "raththa azhuththam"]
    }

    # Initialize all to 0
    symptoms = {key: 0 for key in dictionary.keys()}

    # Multi-word match logic - Iterate through dictionary and match synonyms
    for key, synonyms_list in dictionary.items():
        if any(synonym in text for synonym in synonyms_list):
            symptoms[key] = 1

    return symptoms

if __name__ == "__main__":
    # Test cases to prove rigidity is fixed
    test_cases = [
        "I am a sugar patient and I have body heat", # Should find Diabetes & Fever
        "seene mein dard hai",                        # Should find Chest Pain
        "I feel dizzy and have a high temperature"    # Should find Dizziness & Fever
    ]
    for t in test_cases:
        print(f"Input: {t} -> Result: {extract_symptoms(t)}")
