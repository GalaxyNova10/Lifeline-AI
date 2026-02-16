"""
Script: inference.py
Role: The API Bridge for Vital Sync AI
Author: ML Lead (Member 1)
Description: Loads the trained .pkl model and provides a single function 
for the backend to calculate the Triage Score.
"""

import os
import joblib
import pandas as pd

# Define path to the saved model
MODEL_PATH = os.path.join(os.path.dirname(__file__), 'models/triage_model.pkl')

# Global variable to cache the model in memory
_MODEL = None

def get_model():
    """Loads the model into memory ONLY once."""
    global _MODEL
    if _MODEL is None:
        if not os.path.exists(MODEL_PATH):
            raise FileNotFoundError(f"❌ Model not found at {MODEL_PATH}. Run train_model.py first.")
        _MODEL = joblib.load(MODEL_PATH)
    return _MODEL

def predict_priority_score(patient_data: dict) -> dict:
    """
    The main function called by the Backend API.
    Input: Dictionary of patient vitals and symptoms.
    Output: Dictionary containing 'score' and 'risk_level'.
    """
    # --- 1. Extract Vitals for Safety Checks ---
    age = patient_data.get('age', 30)
    heart_rate = patient_data.get('heart_rate', 75)
    oxygen_level = patient_data.get('oxygen_level', 98)
    chest_pain = patient_data.get('symptom_chest_pain', 0)

    # --- 2. HARDCODED RED FLAGS (Safety Override) ---
    # ML models are probabilistic. We don't take chances with critical emergencies.
    if chest_pain == 1 and age > 45:
        return {"score": 99, "risk_level": "CRITICAL - CARDIAC RISK"}
    if oxygen_level < 90:
        return {"score": 95, "risk_level": "CRITICAL - HYPOXIA"}
    if heart_rate > 140:
        return {"score": 90, "risk_level": "CRITICAL - TACHYCARDIA"}

    # --- 3. Format Data for the ML Model ---
    # The dictionary keys MUST exactly match the columns from your CSV
    features = {
        'age': age,
        'heart_rate': heart_rate,
        'systolic_bp': patient_data.get('systolic_bp', 120),
        'oxygen_level': oxygen_level,
        'symptom_chest_pain': chest_pain,
        'symptom_shortness_of_breath': patient_data.get('symptom_shortness_of_breath', 0),
        'symptom_dizziness': patient_data.get('symptom_dizziness', 0),
        'symptom_vomiting': patient_data.get('symptom_vomiting', 0),
        'history_diabetes': patient_data.get('history_diabetes', 0),
        'history_hypertension': patient_data.get('history_hypertension', 0)
    }

    # Convert to a 1-row DataFrame
    df = pd.DataFrame([features])

    # --- 4. Run Inference ---
    try:
        model = get_model()
        score_array = model.predict(df)
        score = int(score_array[0])
        # Ensure the score stays strictly between 0 and 100
        score = max(0, min(100, score))
    except Exception as e:
        return {"error": str(e), "score": None, "risk_level": "UNKNOWN"}

    # --- 5. Determine General Risk Level ---
    if score >= 70:
        risk_level = "HIGH"
    elif score >= 40:
        risk_level = "MEDIUM"
    else:
        risk_level = "LOW"

    return {"score": score, "risk_level": risk_level}

# --- Quick Local Test ---
if __name__ == "__main__":
    print("🧪 Testing Inference Bridge...")
    
    # Test Case 1: Routine Patient
    routine_patient = {"age": 25, "heart_rate": 70, "oxygen_level": 99}
    print("Routine Test:", predict_priority_score(routine_patient))
    
    # Test Case 2: Red Flag Override
    critical_patient = {"age": 55, "symptom_chest_pain": 1, "oxygen_level": 95}
    print("Critical Test:", predict_priority_score(critical_patient))
