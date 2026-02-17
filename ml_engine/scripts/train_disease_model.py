"""
Script: train_disease_model.py
Role: Disease Classifier Trainer
"""
import pandas as pd
import joblib
import os
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score

DATA_PATH = os.path.join(os.path.dirname(__file__), '../data/disease_synthetic.csv')
MODEL_PATH = os.path.join(os.path.dirname(__file__), '../models/disease_model.pkl')

def train_disease_model():
    if not os.path.exists(DATA_PATH):
        print("❌ Data not found. Run generate_disease_data.py first.")
        return

    df = pd.read_csv(DATA_PATH)
    X = df.drop(columns=['condition_label'])
    y = df['condition_label']

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    print("🧠 Training Disease Classifier...")
    model = RandomForestClassifier(n_estimators=100, random_state=42)
    model.fit(X_train, y_train)

    predictions = model.predict(X_test)
    acc = accuracy_score(y_test, predictions)
    print(f"📊 Model Accuracy: {acc*100:.2f}%")

    os.makedirs(os.path.dirname(MODEL_PATH), exist_ok=True)
    joblib.dump(model, MODEL_PATH)
    print(f"✅ Disease Model saved to {MODEL_PATH}")

if __name__ == "__main__":
    train_disease_model()
