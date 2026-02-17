"""
Script: main.py
Role: Unified API Gateway for Lifeline AI
Author: Member 3 (Backend Lead)
"""

from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import os
import shutil

# Import Member 1 & 2's work
from ml_engine.nlp.pipeline import process_voice_note
from ml_engine.inference import predict_priority_score

# Import Member 3's work
from backend.database.auth import register_user, get_user_by_token
from backend.utils.qr_generator import generate_emergency_qr

app = FastAPI(title="Lifeline AI API")

# Enable CORS so the Mobile App (React Native/Flutter) can connect
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- ENDPOINT 1: USER REGISTRATION ---
@app.post("/register")
async def register(name: str, age: int, blood_type: str, allergies: str, conditions: str, contact: str):
    token = register_user(name, age, blood_type, allergies, conditions, contact)
    if token:
        qr_path = generate_emergency_qr(token)
        return {"status": "success", "token": token, "qr_code_ready": True}
    raise HTTPException(status_code=500, detail="Registration failed")

# --- ENDPOINT 2: EMERGENCY QR LOOKUP ---
@app.get("/emergency/{token}")
async def emergency_lookup(token: str):
    user = get_user_by_token(token)
    if user:
        return {"mode": "EMERGENCY_ACCESS", "data": user}
    raise HTTPException(status_code=404, detail="User not found")

# --- ENDPOINT 3: AI TRIAGE (VOICE) ---
@app.post("/triage/voice")
async def triage_voice(file: UploadFile = File(...)):
    temp_path = f"temp_{file.filename}"
    with open(temp_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    
    try:
        # Process through Member 2's NLP Pipeline
        nlp_result = process_voice_note(temp_path)
        
        # Process through Member 1's ML Inference
        # Defaulting age to 30 for the voice-only demo
        ml_result = predict_priority_score({**nlp_result['symptoms'], "age": 30})
        
        return {
            "transcription": nlp_result['transcribed_text'],
            "analysis": ml_result
        }
    finally:
        if os.path.exists(temp_path):
            os.remove(temp_path)

@app.get("/")
def health_check():
    return {"status": "online", "project": "Lifeline AI"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
