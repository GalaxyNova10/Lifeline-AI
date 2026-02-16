"""
Script: generate_data.py
Role: Synthetic Data Generator for Vital Sync AI
Author: ML Lead (Member 1)
Description: Generates 2000 dummy patient records with medically accurate logic 
to train the Triage Engine.
"""

import pandas as pd
import random
import os

# Define the output path ensuring it lands in the 'data' folder
OUTPUT_PATH = os.path.join(os.path.dirname(__file__), '../data/triage_synthetic.csv')

def generate_patient_data(num_samples=2000):
    print("🧪 Starting Synthetic Data Generation...")
    data = []

    for _ in range(num_samples):
        # --- 1. Randomize Vitals ---
        age = random.randint(1, 90) # [cite: 26]
        heart_rate = random.randint(50, 160) # [cite: 19]
        systolic_bp = random.randint(90, 180)
        oxygen_level = random.randint(85, 100)
        
        # --- 2. Randomize Symptoms (Binary 0/1) ---
        # 1 = Present, 0 = Absent
        chest_pain = random.choice([0, 0, 0, 1]) # Skewed slightly towards 0
        shortness_of_breath = random.choice([0, 0, 1])
        dizziness = random.choice([0, 1])
        vomiting = random.choice([0, 1])
        
        # --- 3. Medical History ---
        diabetes = random.choice([0, 1]) # [cite: 13]
        hypertension = random.choice([0, 1])

        # --- 4. CALCULATE GROUND TRUTH SCORE (The "Teacher" Logic) ---
        # We manually calculate the score so the AI model can learn this pattern later.
        
        score = 10 # Base score (Routine)

        # CRITICAL / RED FLAG RULES (Priority: Immediate) [cite: 22]
        if chest_pain == 1 and age > 45:
            score = random.randint(95, 100) # Possible Cardiac Arrest
        elif oxygen_level < 90:
            score = random.randint(90, 100) # Hypoxia / Respiratory Failure
        elif heart_rate > 140:
             score = random.randint(85, 95) # Severe Tachycardia
            
        # URGENT / HIGH RISK RULES (Priority: High) [cite: 27]
        elif shortness_of_breath == 1:
            score = random.randint(70, 85)
        elif systolic_bp > 160:
            score = random.randint(60, 80) # Hypertensive Crisis
             
        # MODERATE RISK RULES (Priority: Medium) [cite: 28]
        elif dizziness == 1 or vomiting == 1:
             score = random.randint(40, 60)
             
        # ROUTINE / LOW RISK [cite: 29]
        else:
            # Chronic conditions add slight urgency but aren't emergencies
            if diabetes or hypertension:
                score += random.randint(5, 15)
            
            # Cap low-risk scores at 30
            score = min(score, 30)

        # --- 5. Append Record ---
        data.append({
            'age': age,
            'heart_rate': heart_rate,
            'systolic_bp': systolic_bp,
            'oxygen_level': oxygen_level,
            'symptom_chest_pain': chest_pain,
            'symptom_shortness_of_breath': shortness_of_breath,
            'symptom_dizziness': dizziness,
            'symptom_vomiting': vomiting,
            'history_diabetes': diabetes,
            'history_hypertension': hypertension,
            'triage_score': score  # TARGET VARIABLE
        })

    # Convert to DataFrame and Save
    df = pd.DataFrame(data)
    
    # Create directory if it doesn't exist
    os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)
    
    df.to_csv(OUTPUT_PATH, index=False)
    print(f"✅ SUCCESS: Generated {num_samples} records.")
    print(f"📁 Saved to: {OUTPUT_PATH}")
    print("👀 Preview:")
    print(df.head())

if __name__ == "__main__":
    generate_patient_data()
