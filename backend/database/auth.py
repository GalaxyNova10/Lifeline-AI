"""
Script: auth.py
Role: User Registration & Passport Retrieval
Author: Member 3 (Backend Lead)
"""
import sqlite3
import uuid
from .models import DB_PATH

def register_user(name, age, blood_type, allergies, conditions, contact):
    """Adds a new patient to the system and generates a unique QR Token."""
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    # Generate a unique 8-character token for the Emergency QR Card
    qr_token = str(uuid.uuid4())[:8].upper()
    
    try:
        cursor.execute('''
            INSERT INTO users (name, age, blood_type, allergies, chronic_conditions, emergency_contact, qr_token)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        ''', (name, age, blood_type, allergies, conditions, contact, qr_token))
        
        conn.commit()
        print(f"✅ User '{name}' successfully registered!")
        return qr_token
    except Exception as e:
        print(f"❌ Registration Error: {e}")
        return None
    finally:
        conn.close()

def get_user_by_token(token):
    """Retrieves user data using the QR Token (Emergency Mode)."""
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row # Returns results as a dictionary-like object
    cursor = conn.cursor()
    
    cursor.execute("SELECT * FROM users WHERE qr_token = ?", (token,))
    user = cursor.fetchone()
    conn.close()
    
    return dict(user) if user else None

if __name__ == "__main__":
    # Test Registration for the Hackathon Demo
    print("🧪 Testing User Registration...")
    token = register_user(
        name="John Christo Rosario", 
        age=21, 
        blood_type="O+", 
        allergies="None", 
        conditions="Asthma", 
        contact="9876543210"
    )
    if token:
        print(f"🚀 Registration Successful. Emergency ID: {token}")
