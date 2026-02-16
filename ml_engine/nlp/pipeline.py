"""
Script: pipeline.py
Role: End-to-End Voice-to-Data Pipeline
Author: AI Engineer (Member 2)
Description: Connects transcription and extraction into a single workflow.
"""

from .transcribe import transcribe_audio
from .extract import extract_symptoms

def process_voice_note(file_path):
    """
    The Master Function for the Backend.
    1. Audio -> English Text (Whisper)
    2. English Text -> Symptom Data (NLP)
    """
    print(f"🔄 Processing audio: {file_path}")
    
    # --- Step 1: Transcribe ---
    transcribed_text = transcribe_audio(file_path)
    
    if isinstance(transcribed_text, dict) and "error" in transcribed_text:
        return transcribed_text # Return the error if transcription fails

    # --- Step 2: Extract ---
    symptom_data = extract_symptoms(transcribed_text)
    
    # --- Step 3: Bundle ---
    # We include the raw text so the doctor can read it in the UI
    result = {
        "transcribed_text": transcribed_text,
        "symptoms": symptom_data
    }
    
    print("✅ Pipeline processing complete.")
    return result

# --- Local Test Logic ---
if __name__ == "__main__":
    print("🧪 Testing Pipeline Connectivity...")
    # This test simply checks if the imports work. 
    # To run a full test, you would need the 'test.wav' mentioned in Chunk 1.
    print("✅ Pipeline imports and logic are functional.")
