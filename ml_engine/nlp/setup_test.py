import whisper
import spacy
import shutil

print("✅ Spacy imported.")
print("✅ Whisper imported.")

if shutil.which("ffmpeg"):
    print("✅ FFmpeg found.")
else:
    print("❌ FFmpeg NOT found. Audio processing will fail.")

try:
    nlp = spacy.load("en_core_web_sm")
    print("✅ Spacy Model (en_core_web_sm) loaded.")
except:
    print("❌ Spacy Model NOT found. Run 'python -m spacy download en_core_web_sm'")
