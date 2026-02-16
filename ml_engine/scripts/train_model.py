"""
Script: train_model.py
Role: Model Trainer for Vital Sync AI
Author: ML Lead (Member 1)
Description: Loads the synthetic data, trains a Random Forest Regressor, 
and serializes the model to a .pkl file.
"""

import pandas as pd
import joblib
import os
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_absolute_error, r2_score

# Paths
DATA_PATH = os.path.join(os.path.dirname(__file__), '../data/triage_synthetic.csv')
MODEL_PATH = os.path.join(os.path.dirname(__file__), '../models/triage_model.pkl')

def train_triage_model():
    print("🧠 Starting Model Training...")

    # 1. Load Data
    if not os.path.exists(DATA_PATH):
        print("❌ ERROR: Data file not found. Please run 'generate_data.py' first.")
        return

    df = pd.read_csv(DATA_PATH)

    # 2. Separate Features (X) and Target (y)
    X = df.drop(columns=['triage_score'])
    y = df['triage_score']

    # 3. Split Data (80% Train, 20% Test)
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    # 4. Initialize and Train Model
    # n_estimators=100 means we use 100 decision trees for better accuracy
    model = RandomForestRegressor(n_estimators=100, random_state=42)
    model.fit(X_train, y_train)
    print("✅ Model Trained.")

    # 5. Evaluate Performance
    predictions = model.predict(X_test)
    mae = mean_absolute_error(y_test, predictions)
    r2 = r2_score(y_test, predictions)
    
    print(f"📊 Performance Metrics:")
    print(f"   - Mean Absolute Error: {mae:.2f} (Lower is better)")
    print(f"   - Accuracy Score (R2): {r2:.2f} (Closer to 1.0 is better)")

    # 6. Save the Model (Serialization)
    os.makedirs(os.path.dirname(MODEL_PATH), exist_ok=True)
    joblib.dump(model, MODEL_PATH)
    print(f"💾 Model saved successfully to: {MODEL_PATH}")
    print("🚀 Ready for Backend Integration.")

if __name__ == "__main__":
    train_triage_model()
