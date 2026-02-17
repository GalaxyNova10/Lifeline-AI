# 🏥 Lifeline AI: Intelligent Triage & Emergency Healthcare Ecosystem 

Lifeline AI is a mobile-first healthcare solution designed to eliminate hospital overcrowding and improve patient outcomes. By integrating Machine Learning, Multilingual NLP, and Digital Health Passports, the system automates patient prioritization and ensures that critical cases receive immediate attention.

## 🚀 The Core Innovation
The system replaces traditional "first-come-first-served" prioritization—which often ignores medical urgency—with a **Dynamic Priority Queue**.

## 🛠️ Key Features

### Phase I: Digital Health Passport & Emergency QR 
- **Offline Access**: First responders to view blood type, allergies, and chronic conditions (e.g., Diabetes, Stroke history) even if the user is unconscious.

### Phase II: Multilingual AI Voice Interface 
- **Voice-to-Vital**: Full support for English, Hindi, and Tamil voice descriptions using **OpenAI Whisper**.
- **Vitals Analysis**: Vital analysis via PPG-simulated heart rate inputs to provide quantitative data to the ML model.

### Phase III: The Intelligence Engine 
- **Hybrid Scoring**: A hybrid Scoring Algorithm combining real-time symptoms with stored medical history.
- **Red-Flag Override**: Automatic **99/100 priority** for life-threatening events like Cardiac Arrest or Stroke, bypassing the queue entirely.

### Phase IV: Dynamic Scheduling & Load Balancing 
- **Smart Queue**: Automatic appointment slotting based on medical severity (Critical, High, Medium, Low).
- **Load Balancing**: Recommends hospitals based on specialization (e.g., Cardiac vs. Orthopedic) and real-time wait times.

## 🏗️ Technical Stack
- **Frontend**: Cross-platform Mobile App (React Native/Flutter).
- **Backend**: Python-based ML models for risk prediction and scoring.
- **Speech-to-Text**: Whisper for Tamil, Hindi, and English.
- **Data Security**: Encrypted storage to ensure patient medical history remains private and HIPAA/GDPR compliant.

## 🚀 Getting Started

1. **Install Dependencies**
   ```bash
   pip install -r requirements.txt
   ```

2. **Run the Server**
   ```bash
   uvicorn backend.app.main:app --reload
   ```

3. **Access the API**
   - Docs: `http://127.0.0.1:8000/docs`
   - Triage Endpoint: `http://127.0.0.1:8000/triage/process`

---
*Built for the Lifeline AI Hackathon 2026*
