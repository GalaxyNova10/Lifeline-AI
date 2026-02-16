"""
Script: transcribe.py
Role: Multilingual Audio-to-Text Converter
Author: AI Engineer (Member 2)
Description: Uses OpenAI Whisper to transcribe and translate audio into English text.
"""

import whisper
import os
import warnings

# Suppress technical warnings to keep the console clean
warnings.filterwarnings("ignore")

# Load the model globally so it stays in memory (speeds up your app)
# 'base' is used for a good balance of speed and multilingual accuracy.
print("⏳ Loading Whisper Model... (The first time takes 1-2 minutes)")
_MODEL = whisper.load_model("base")
print("✅ Whisper Model Loaded.")

def transcribe_audio(file_path):
    """
    Takes an audio file and returns translated English text.
    Automatically handles English, Hindi, and Tamil.
    """
    if not os.path.exists(file_path):
        return {"error": f"Audio file not found at: {file_path}"}

    try:
        # task="translate" ensures non-English speech is converted to English text.
        # This is the "secret sauce" for the multilingual requirement.
        result = _MODEL.transcribe(file_path, task="translate")
        
        text = result.get("text", "").strip()
        return text
    except Exception as e:
        return {"error": f"Transcription failed: {str(e)}"}

# --- Local Test Logic ---
if __name__ == "__main__":
    print("🧪 Transcriber logic is active.")
    # Check if a test file exists to run a live trial
    test_file = "ml_engine/nlp/test.wav"
    if os.path.exists(test_file):
        print(f"Running test on: {test_file}")
        print("Result:", transcribe_audio(test_file))
    else:
        print("💡 Tip: Place a 'test.wav' in this folder to run a live transcription test.")
