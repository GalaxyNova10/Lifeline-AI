# 🧠 ML Engine Documentation (Updated)

## 1. Inference Usage (For Backend - Member 4)
Import the function from `inference.py`:

```python
from ml_engine.inference import predict_priority_score

patient_data = {
    "age": 45,
    "heart_rate": 80,
    "oxygen_level": 98,
    "symptom_chest_pain": 0,  # 0 or 1
    "symptom_shortness_of_breath": 1,
    "symptom_dizziness": 0,
    "symptom_fever": 1,      # <--- NEW: REQUIRED FOR DISEASE MODEL
    "history_diabetes": 0,
    "history_hypertension": 1
}

result = predict_priority_score(patient_data)
# Returns: 
# {
#   'score': 75, 
#   'risk_level': 'HIGH',
#   'predicted_condition': 'Possible Sepsis'
# }
```

## 2. Input Keys (For NLP Team - Member 2)
Ensure your NLP extraction outputs a dictionary with these exact keys:

- `symptom_chest_pain` (0/1)
- `symptom_shortness_of_breath` (0/1)
- `symptom_dizziness` (0/1)
- `symptom_vomiting` (0/1)
- `symptom_fever` (0/1)  <--- NEW
