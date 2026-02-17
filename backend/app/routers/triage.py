"""
Script: triage.py (Hardened Version)
Role: Unified Triage with History & Security
Author: Member 4 (Coordinator)
"""

from fastapi import APIRouter, UploadFile, File, Form, HTTPException
from typing import Optional
import os
import shutil
import uuid

# Import AI work from Members 1 & 2
from ml_engine.nlp.pipeline import process_voice_note
from ml_engine.inference import predict_priority_score
from backend.app.services.scheduler import calculate_appointment_time
from backend.database.auth import get_user_by_token

router = APIRouter(prefix="/triage", tags=["Triage"])
TEMP_DIR = "backend/temp_audio"
MOCK_QUEUE = 4 # Current number of patients in the ER

@router.post("/process")
async def process_triage(
    age: int = Form(...),
    heart_rate: int = Form(72),
    manual_symptoms: Optional[str] = Form(""),
    qr_token: Optional[str] = Form(None), # Added for Phase I Integration
    voice_note: UploadFile = File(None)
):
    # 1. Initialize symptoms
    final_symptoms = {
        "symptom_chest_pain": 0, "symptom_shortness_of_breath": 0,
        "symptom_dizziness": 0, "symptom_vomiting": 0, "symptom_fever": 0,
        "symptom_numbness": 0, "history_diabetes": 0, "history_hypertension": 0
    }

    # 2. Fetch History from Phase I (Member 3)
    history_bonus = 0
    chronic_conditions = ""
    history_noted = ""
    
    if qr_token:
        user_data = get_user_by_token(qr_token)
        if user_data:
            chronic_conditions = user_data.get('chronic_conditions', "").lower()
            history_noted = chronic_conditions
            
            # Map history to ML inputs
            if "diabetes" in chronic_conditions: 
                final_symptoms["history_diabetes"] = 1
            if "stent" in chronic_conditions or "heart" in chronic_conditions or "hypertension" in chronic_conditions:
                final_symptoms["history_hypertension"] = 1
            
            # Safety Logic: Increase base score if high-risk history exists [cite: 13, 34]
            # This is a 'Coordination Layer' bonus on top of ML
            if "stroke" in chronic_conditions or "heart" in chronic_conditions:
                history_bonus = 20 

    # 3. Process Manual UI Symptoms
    if manual_symptoms:
        selected = manual_symptoms.split(",")
        for s in selected:
            key = f"symptom_{s.strip()}"
            if key in final_symptoms:
                final_symptoms[key] = 1

    # 4. Process Voice / NLP (Member 2) [cite: 17, 18]
    transcription = ""
    if voice_note:
        file_path = os.path.join(TEMP_DIR, f"{uuid.uuid4()}_{voice_note.filename}")
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(voice_note.file, buffer)
        try:
            nlp_result = process_voice_note(file_path)
            # Merge voice-detected symptoms
            for key, value in nlp_result['symptoms'].items():
                if key in final_symptoms and value == 1:
                    final_symptoms[key] = 1
            transcription = nlp_result.get('transcribed_text', "")
        finally:
            if os.path.exists(file_path):
                os.remove(file_path)

    # 5. Enhanced ML Scoring (Member 1) [cite: 20, 21]
    # Combine Vitals, Symptoms, and History
    input_payload = {**final_symptoms, "age": age, "heart_rate": heart_rate}
    ml_result = predict_priority_score(input_payload)
    
    # Apply Coordination Layer Bonus
    final_score = min(ml_result['score'] + history_bonus, 100)
    risk_level = ml_result['risk_level']

    # 6. Red-Flag Override (Member 4 Hardening) 
    # Hardcoded safety for Tachycardia or specific detected keywords in HISTORY
    if heart_rate > 120 or "chest" in chronic_conditions: # Tachycardia or Chest Pain History
        final_score = 99
        risk_level = "CRITICAL"
    
    # 7. Dynamic Scheduling & Load Balancing (Member 4) [cite: 24, 25]
    scheduling = calculate_appointment_time(final_score, MOCK_QUEUE, ml_result.get('predicted_condition', 'Unknown'))
    
    return {
        "status": "success",
        "triage": {"score": final_score, "risk": risk_level},
        "analysis": {
            "transcription": transcription,
            "detected_symptoms": [k for k,v in final_symptoms.items() if v == 1],
            "severity": scheduling['severity']
        },
        "appointment": scheduling,
        "history_noted": history_noted
    }
