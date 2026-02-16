"""
Script: extract.py
Role: Text-to-Data Medical Entity Extractor
Author: AI Engineer (Member 2)
Description: Uses Keyword Matching and NLP to map text to ML-compatible keys.
"""

import re

def extract_symptoms(text):
    """
    Input: English text (e.g., "I have a high fever and my chest hurts")
    Output: Dictionary of 0s and 1s matching Member 1's requirements.
    """
    # Convert to lowercase for easier matching
    text = text.lower()
    
    # Initialize all symptoms to 0 (Absent)
    # THESE KEYS MUST MATCH MEMBER 1'S README EXACTLY
    symptoms = {
        "symptom_chest_pain": 0,
        "symptom_shortness_of_breath": 0,
        "symptom_dizziness": 0,
        "symptom_vomiting": 0,
        "symptom_fever": 0,
        "history_diabetes": 0,
        "history_hypertension": 0
    }

    # --- Keyword Mapping Logic ---

    # 1. Chest Pain
    if any(word in text for word in ["chest", "heart hurts", "pain in my heart", "heavy chest"]):
        symptoms["symptom_chest_pain"] = 1
        
    # 2. Shortness of Breath
    if any(word in text for word in ["breath", "suffocat", "gasp", "can't breathe", "short of breath"]):
        symptoms["symptom_shortness_of_breath"] = 1
        
    # 3. Dizziness
    if any(word in text for word in ["dizzy", "spinning", "lightheaded", "faint", "giddy"]):
        symptoms["symptom_dizziness"] = 1
        
    # 4. Vomiting
    if any(word in text for word in ["vomit", "nausea", "throwing up", "threw up", "sick to my stomach"]):
        symptoms["symptom_vomiting"] = 1
        
    # 5. Fever (New requirement for Disease Model)
    if any(word in text for word in ["fever", "temperature", "hot", "chills", "burning up"]):
        symptoms["symptom_fever"] = 1

    # 6. Medical History (Check for mentions of chronic conditions)
    if any(word in text for word in ["diabetes", "diabetic", "sugar"]):
        symptoms["history_diabetes"] = 1
    if any(word in text for word in ["hypertension", "blood pressure", "bp", "high pressure"]):
        symptoms["history_hypertension"] = 1

    return symptoms

# --- Local Test ---
if __name__ == "__main__":
    test_phrase = "I am a diabetic patient and I have a very high fever with chest pain."
    print(f"🧪 Testing NLP Extraction...")
    print(f"Input: {test_phrase}")
    result = extract_symptoms(test_phrase)
    print("Extracted Data:", result)
    
    # Verification: Did it find the 3 symptoms?
    if result["history_diabetes"] == 1 and result["symptom_fever"] == 1 and result["symptom_chest_pain"] == 1:
        print("✅ SUCCESS: All symptoms correctly mapped!")
    else:
        print("❌ FAILED: Some symptoms were missed.")
