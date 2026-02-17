"""
Script: generate_disease_data.py
Role: Disease Classification Data Generator
Author: ML Lead (Member 1)
"""
import pandas as pd
import random
import os

OUTPUT_PATH = os.path.join(os.path.dirname(__file__), '../data/disease_synthetic.csv')

def generate_disease_data(num_samples=2000):
    data = []
    print("🧪 Generating Disease Classification Data...")

    for _ in range(num_samples):
        # Random Vitals
        age = random.randint(18, 90)
        heart_rate = random.randint(50, 160)
        systolic_bp = random.randint(90, 180)
        oxygen = random.randint(85, 100)
        
        # Symptoms
        chest_pain = random.choice([0, 0, 1])
        breath_short = random.choice([0, 1])
        dizzy = random.choice([0, 1])
        fever = random.choice([0, 1])

        # --- LOGIC FOR DISEASE LABELS ---
        # 0=Healthy, 1=Cardiac, 2=Respiratory, 3=Viral/Infection, 4=General/Dehydration
        
        condition = "Healthy/Routine" # Default
        
        # Cardiac Rules
        if chest_pain == 1 and (age > 45 or heart_rate > 120):
            condition = "Potential Cardiac Event"
        
        # Respiratory Rules
        elif breath_short == 1 and oxygen < 94:
            condition = "Respiratory Distress/Hypoxia"
            
        # Infection Rules
        elif fever == 1 and heart_rate > 100:
            condition = "Possible Sepsis/Infection"
            
        # General Rules
        elif systolic_bp > 160:
            condition = "Hypertension Crisis"
        elif dizzy == 1 and systolic_bp < 100:
            condition = "Hypotension/Dehydration"

        data.append({
            'age': age, 'heart_rate': heart_rate, 'systolic_bp': systolic_bp,
            'oxygen_level': oxygen, 'symptom_chest_pain': chest_pain,
            'symptom_shortness_of_breath': breath_short, 'symptom_dizziness': dizzy,
            'symptom_fever': fever,
            'condition_label': condition # TARGET
        })

    df = pd.DataFrame(data)
    os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)
    df.to_csv(OUTPUT_PATH, index=False)
    print(f"✅ Generated {num_samples} disease records.")

if __name__ == "__main__":
    generate_disease_data()
