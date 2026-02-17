"""
Script: inference.py
Role: The API Bridge for Lifeline AI
Author: ML Lead (Member 1)
Description: Loads the trained .pkl models and provides a single function 
for the backend to calculate the Triage Score and Predict Condition.
"""

import os
import joblib
import pandas as pd

# Define path to the saved models
BASE_DIR = os.path.dirname(__file__)
TRIAGE_MODEL_PATH = os.path.join(BASE_DIR, 'models/triage_model.pkl')
DISEASE_MODEL_PATH = os.path.join(BASE_DIR, 'models/disease_model.pkl')

# Global variable to cache the models in memory
_TRIAGE_MODEL = None
_DISEASE_MODEL = None

def get_triage_model():
    """Loads the triage model into memory ONLY once."""
    global _TRIAGE_MODEL
    if _TRIAGE_MODEL is None:
        if not os.path.exists(TRIAGE_MODEL_PATH):
            raise FileNotFoundError(f"❌ Triage Model not found at {TRIAGE_MODEL_PATH}.")
        _TRIAGE_MODEL = joblib.load(TRIAGE_MODEL_PATH)
    return _TRIAGE_MODEL

def get_disease_model():
    """Loads the disease model into memory ONLY once."""
    global _DISEASE_MODEL
    if _DISEASE_MODEL is None:
        if not os.path.exists(DISEASE_MODEL_PATH):
            # It's okay if disease model is missing for now, just return None
            print(f"⚠️ Disease Model not found at {DISEASE_MODEL_PATH}. Skipping disease prediction.")
            return None
        _DISEASE_MODEL = joblib.load(DISEASE_MODEL_PATH)
    return _DISEASE_MODEL

def predict_priority_score(patient_data: dict) -> dict:
    """
    The main function called by the Backend API.
    Input: Dictionary of patient vitals and symptoms.
    Output: Dictionary containing 'score', 'risk_level', and 'predicted_condition'.
    """
    # --- 1. Extract Vitals for Safety Checks & Inference ---
    age = patient_data.get('age', 30)
    heart_rate = patient_data.get('heart_rate', 75)
    systolic_bp = patient_data.get('systolic_bp', 120)
    oxygen_level = patient_data.get('oxygen_level', 98)
    
    # Symptoms
    chest_pain = patient_data.get('symptom_chest_pain', 0)
    shortness_of_breath = patient_data.get('symptom_shortness_of_breath', 0)
    dizziness = patient_data.get('symptom_dizziness', 0)
    vomiting = patient_data.get('symptom_vomiting', 0)
    fever = patient_data.get('symptom_fever', 0)
    
    # History
    diabetes = patient_data.get('history_diabetes', 0)
    hypertension = patient_data.get('history_hypertension', 0)

    # --- 2. HARDCODED RED FLAGS (Safety Override) ---
    red_flag_score = None
    red_flag_risk = None

    # Critical Cardiac / Stroke Indicators
    if (chest_pain == 1 and age > 45) or (patient_data.get('symptom_numbness', 0) == 1):
        red_flag_score = 99
        red_flag_risk = "CRITICAL - CARDIAC/STROKE RISK"
    elif oxygen_level < 90:
        red_flag_score = 95
        red_flag_risk = "CRITICAL - HYPOXIA"
    elif heart_rate > 100: # Tachycardia threshold lowered as per audit
        red_flag_score = 90
        red_flag_risk = "CRITICAL - TACHYCARDIA"

    # --- 3. TRIAGE SCORE INFERENCE ---
    triage_score = 10 # Default
    risk_level = "LOW"

    try:
        if red_flag_score:
            triage_score = red_flag_score
            risk_level = red_flag_risk
        else:
            # Prepare features for Triage Model (Order Matters!)
            triage_features = {
                'age': age,
                'heart_rate': heart_rate,
                'systolic_bp': systolic_bp,
                'oxygen_level': oxygen_level,
                'symptom_chest_pain': chest_pain,
                'symptom_shortness_of_breath': shortness_of_breath,
                'symptom_dizziness': dizziness,
                'symptom_vomiting': vomiting,
                'history_diabetes': diabetes,
                'history_hypertension': hypertension
            }
            triage_df = pd.DataFrame([triage_features])
            
            model = get_triage_model()
            score_array = model.predict(triage_df)
            triage_score = int(score_array[0])
            triage_score = max(0, min(100, triage_score))
            
            # Boost score if HR is elevated but not critical (90-100)
            if heart_rate > 90 and triage_score < 70:
                triage_score += 15

            if triage_score >= 70:
                risk_level = "HIGH"
            elif triage_score >= 40:
                risk_level = "MEDIUM"

    except Exception as e:
        print(f"⚠️ Triage Inference Error: {e}")
        triage_score = None
        risk_level = "UNKNOWN"

    # --- 4. DISEASE PREDICTION INFERENCE ---
    predicted_condition = "Unknown"
    
    try:
        disease_model = get_disease_model()
        if disease_model:
            # Prepare features for Disease Model (Order Matters!)
            # ['age', 'heart_rate', 'systolic_bp', 'oxygen_level', 'symptom_chest_pain', 
            #  'symptom_shortness_of_breath', 'symptom_dizziness', 'symptom_fever']
            disease_features = {
                'age': age,
                'heart_rate': heart_rate,
                'systolic_bp': systolic_bp,
                'oxygen_level': oxygen_level,
                'symptom_chest_pain': chest_pain,
                'symptom_shortness_of_breath': shortness_of_breath,
                'symptom_dizziness': dizziness,
                'symptom_fever': fever
            }
            disease_df = pd.DataFrame([disease_features])
            
            condition_array = disease_model.predict(disease_df)
            predicted_condition = condition_array[0]
            
    except Exception as e:
        print(f"⚠️ Disease Inference Error: {e}")
        predicted_condition = "Error in Prediction"

    return {
        "score": triage_score, 
        "risk_level": risk_level,
        "predicted_condition": predicted_condition
    }

# --- Quick Local Test ---
if __name__ == "__main__":
    print("🧪 Testing Inference Bridge...")
    
    # Test Case 1: Routine
    routine_patient = {"age": 25, "heart_rate": 70}
    print("Routine:", predict_priority_score(routine_patient))
    
    # Test Case 2: Sepsis (Fever + High HR)
    sepsis_patient = {"age": 30, "heart_rate": 110, "symptom_fever": 1}
    print("Sepsis Check:", predict_priority_score(sepsis_patient))
